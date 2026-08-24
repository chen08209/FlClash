import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef UpdatingMap = Map<String, bool>;

class ProvidersView extends ConsumerStatefulWidget {
  const ProvidersView({super.key});

  @override
  ConsumerState<ProvidersView> createState() => _ProvidersViewState();
}

class _ProvidersViewState extends ConsumerState<ProvidersView> {
  Future<void> _updateProviders() async {
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
          UpdatingMessage(label: provider.name, message: compactError(error)),
        );
      }
    });
    await Future.wait(updateProviders);
    proxiesAction.updateGroupsDebounce();
    if (messages.isNotEmpty) {
      unawaited(dialogs.showAllUpdatingMessagesDialog(messages));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final providers = ref.watch(providersProvider);
    final proxyProviders = providers
        .where((item) => item.type == 'Proxy')
        .map((item) => ProviderItem(provider: item));
    final ruleProviders = providers
        .where((item) => item.type == 'Rule')
        .map((item) => ProviderItem(provider: item));
    final proxySection = generateSection(
      title: appLocalizations.proxyProviders,
      items: proxyProviders,
    );
    final ruleSection = generateSection(
      title: appLocalizations.ruleProviders,
      items: ruleProviders,
    );
    return AdaptiveSheetScaffold(
      actions: [
        IconButtonData(
          icon: Icons.sync,
          onPressed: _updateProviders,
          tooltip: context.appLocalizations.update,
        ),
      ],
      body: generateListView([...proxySection, ...ruleSection]),
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
      );
      if (message.isNotEmpty) throw MessageException(message);
    });
    proxiesAction.updateGroupsDebounce();
  }

  String _buildProviderDesc(BuildContext context) {
    final baseInfo = provider.updateAt.getLastUpdateTimeDesc(context);
    final count = provider.count;
    return switch (count == 0) {
      true => baseInfo,
      false => '$baseInfo  ·  ${context.appLocalizations.entriesCount(count)}',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(provider.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (provider.updateAt.microsecondsSinceEpoch > 0)
            Text(_buildProviderDesc(context)),
          const SizedBox(height: 4),
          if (provider.subscriptionInfo != null)
            SubscriptionInfoView(subscriptionInfo: provider.subscriptionInfo),
          const SizedBox(height: 8),
          Wrap(
            runSpacing: 6,
            spacing: 12,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CommonChip(
                avatar: const Icon(Icons.upload),
                label: context.appLocalizations.upload,
                onPressed: () => _handleSideLoadProvider(ref),
              ),
              if (provider.vehicleType == 'HTTP')
                Consumer(
                  builder: (_, ref, _) {
                    final isUpdating = ref.watch(
                      isUpdatingProvider(provider.updatingKey),
                    );
                    return isUpdating
                        ? const SizedBox(
                            height: 30,
                            width: 30,
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: CommonCircleLoading(),
                            ),
                          )
                        : CommonChip(
                            avatar: const Icon(Icons.sync),
                            label: context.appLocalizations.sync,
                            onPressed: () => _handleUpdateProvider(ref),
                          );
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
