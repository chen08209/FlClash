import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProvidersView extends ConsumerStatefulWidget {
  const ProvidersView({super.key});

  @override
  ConsumerState<ProvidersView> createState() => _ProvidersViewState();
}

class _ProvidersViewState extends ConsumerState<ProvidersView> {
  Future<void> _updateProviders() async {
    final appLocalizations = context.appLocalizations;
    final providers = ref.read(providersProvider);
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    final List<UpdatingMessage> messages = [];
    final updateProviders = providers.map<Future>((provider) async {
      try {
        final message = await proxiesAction.updateProvider(
          provider,
          showLoading: true,
        );
        if (message.isNotEmpty) {
          messages.add(UpdatingMessage(label: provider.name, message: message));
        }
      } catch (error) {
        messages.add(
          UpdatingMessage(
            label: provider.name,
            message: userFacingErrorMessage(error, appLocalizations),
          ),
        );
      }
    });
    await Future.wait(updateProviders);
    proxiesAction.updateGroupsDebounce();
    if (messages.isNotEmpty) {
      unawaited(dialogs.showAllUpdatingMessagesDialog(messages));
    }
  }

  List<Widget> _buildSection({
    required String title,
    required List<ExternalProvider> providers,
  }) {
    if (providers.isEmpty) {
      return const [];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(child: ListHeader(title: title)),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: providers.length,
          itemBuilder: (_, index) {
            final provider = providers[index];
            final position = ItemPosition.get(index, providers.length);
            return ItemPositionProvider(
              position: position,
              child: ProviderItem(
                key: ValueKey(provider.name),
                provider: provider,
              ),
            );
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final providers = ref.watch(providersProvider);
    final proxyProviders = providers
        .where((item) => item.type == 'Proxy')
        .toList();
    final ruleProviders = providers
        .where((item) => item.type == 'Rule')
        .toList();
    return AdaptiveSheetScaffold(
      centerTitle: false,
      actions: [
        IconButtonData(
          icon: Icons.sync,
          onPressed: _updateProviders,
          tooltip: appLocalizations.update,
        ),
      ],
      body: CustomScrollView(
        slivers: [
          ..._buildSection(
            title: appLocalizations.proxies,
            providers: proxyProviders,
          ),
          ..._buildSection(
            title: appLocalizations.rules,
            providers: ruleProviders,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
      title: appLocalizations.providers,
    );
  }
}

class ProviderItem extends ConsumerWidget {
  final ExternalProvider provider;

  const ProviderItem({super.key, required this.provider});

  Future<void> _handleUpdateProvider(WidgetRef ref) async {
    if (provider.vehicleType != 'HTTP') return;
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    await globalState.safeRun(() async {
      final message = await proxiesAction.updateProvider(
        provider,
        showLoading: true,
      );
      if (message.isNotEmpty) throw MessageException(message);
    }, silence: false);
    proxiesAction.updateGroupsDebounce();
  }

  Future<void> _handleSideLoadProvider(WidgetRef ref) async {
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    await globalState.safeRun<void>(() async {
      final platformFile = await picker.pickerFile();
      if (platformFile == null || provider.path == null) return;
      final bytes = await platformFile.readBytes();
      await File(provider.path!).safeWriteAsBytes(bytes);
      final message = await proxiesAction.sideLoadExternalProvider(
        provider,
        utf8.decode(bytes),
        showLoading: true,
      );
      if (message.isNotEmpty) throw MessageException(message);
    });
    proxiesAction.updateGroupsDebounce();
  }

  void _handleShowSubscriptionInfo() {
    unawaited(
      dialogs.showCommonDialog<void>(
        child: Builder(
          builder: (context) {
            return CommonDialog(
              backgroundColor: context.colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: context.appLocalizations.subscriptionInfo,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(context.appLocalizations.confirm),
                ),
              ],
              child: SubscriptionInfoDetailView(
                subscriptionInfo: provider.subscriptionInfo!,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget? _buildProviderMetadata(BuildContext context) {
    final countLabel = switch (provider.type) {
      'Proxy' => context.appLocalizations.proxiesCount(provider.count),
      'Rule' => context.appLocalizations.rulesCount(provider.count),
      _ => null,
    };
    final chips = [
      if (provider.updateAt.microsecondsSinceEpoch > 0)
        ListItemMetaChip(
          label: provider.updateAt.getLastUpdateTimeDesc(context),
          tone: ListItemMetaChipTone.tertiary,
        ),
      if (provider.count > 0 && countLabel != null)
        ListItemMetaChip(
          label: countLabel,
          tone: ListItemMetaChipTone.secondary,
        ),
    ];
    return chips.isEmpty
        ? null
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(spacing: 4, children: chips),
          );
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final subscriptionInfo = provider.subscriptionInfo;
    return [
      CommonPopupMenuItem(
        icon: Icons.upload_outlined,
        label: appLocalizations.upload,
        onPressed: () {
          _handleSideLoadProvider(ref);
        },
      ),
      if (provider.vehicleType == 'HTTP')
        CommonPopupMenuItem(
          icon: Icons.sync,
          label: appLocalizations.sync,
          onPressed: () {
            _handleUpdateProvider(ref);
          },
        ),
      if (subscriptionInfo != null && subscriptionInfo.total > 0)
        CommonPopupMenuItem(
          icon: Icons.data_usage_outlined,
          label: appLocalizations.subscriptionInfo,
          onPressed: _handleShowSubscriptionInfo,
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(provider.updatingKey));
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 0),
      title: Text(provider.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: _buildProviderMetadata(context),
      trailing: SizedBox.square(
        dimension: kMinInteractiveDimension,
        child: FadeThroughBox(
          alignment: Alignment.center,
          child: isUpdating
              ? const SizedBox.square(
                  key: ValueKey('loading'),
                  dimension: kMinInteractiveDimension,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CommonCircleLoading(),
                  ),
                )
              : CommonPopupBox(
                  key: const ValueKey('menu'),
                  popupBuilder: (_) =>
                      CommonPopupMenu(items: _menuItems(context, ref)),
                  targetBuilder: (open) {
                    return IconButton(
                      tooltip: context.appLocalizations.more,
                      onPressed: () {
                        open();
                      },
                      icon: const Icon(Icons.more_vert),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
