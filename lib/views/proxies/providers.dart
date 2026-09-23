import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
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
    return CommonScaffold(
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.sync,
            onPressed: _updateProviders,
            tooltip: appLocalizations.update,
          ),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: context.contentTopPadding),
          ),
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

class ProviderItem extends ConsumerStatefulWidget {
  final ExternalProvider provider;

  const ProviderItem({super.key, required this.provider});

  @override
  ConsumerState<ProviderItem> createState() => _ProviderItemState();
}

class _ProviderItemState extends ConsumerState<ProviderItem> {
  bool _editable = false;

  ExternalProvider get provider => widget.provider;

  @override
  void initState() {
    super.initState();
    unawaited(_probeFile());
  }

  @override
  void didUpdateWidget(covariant ProviderItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider.path != provider.path ||
        oldWidget.provider.updateAt != provider.updateAt) {
      unawaited(_probeFile());
    }
  }

  Future<void> _probeFile() async {
    final editable = await _isTextProviderFile(provider.path);
    if (!mounted || editable == _editable) {
      return;
    }
    setState(() {
      _editable = editable;
    });
  }

  Future<void> _handleUpdateProvider() async {
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

  Future<void> _handleSideLoadProvider() async {
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    await globalState.safeRun<void>(() async {
      final platformFile = await picker.pickerFile();
      if (platformFile == null) return;
      await _sideLoadProvider(ref, provider, await platformFile.readBytes());
    });
    proxiesAction.updateGroupsDebounce();
  }

  void _handleEditProvider(BuildContext context) {
    final path = provider.path;
    if (path == null || path.isEmpty) return;
    unawaited(
      BaseNavigator.push<void>(
        context,
        _EditProviderView(provider: provider, path: path),
      ),
    );
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
        MetaChip(label: provider.updateAt.getLastUpdateTimeDesc(context)),
      if (provider.count > 0 && countLabel != null) MetaChip(label: countLabel),
    ];
    return chips.isEmpty
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Row(spacing: 4, children: chips),
          );
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final subscriptionInfo = provider.subscriptionInfo;
    return [
      if (_editable)
        CommonPopupMenuItem(
          glyph: AppGlyphs.edit,
          label: appLocalizations.edit,
          onPressed: () {
            _handleEditProvider(context);
          },
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.upload,
        label: appLocalizations.upload,
        onPressed: () {
          _handleSideLoadProvider();
        },
      ),
      if (provider.vehicleType == 'HTTP')
        CommonPopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            _handleUpdateProvider();
          },
        ),
      if (subscriptionInfo != null && subscriptionInfo.total > 0)
        CommonPopupMenuItem(
          glyph: AppGlyphs.dataUsage,
          label: appLocalizations.subscriptionInfo,
          onPressed: _handleShowSubscriptionInfo,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                      CommonPopupMenu(items: _menuItems(context)),
                  targetBuilder: (open) {
                    return IconButton(
                      tooltip: context.appLocalizations.more,
                      onPressed: () {
                        open();
                      },
                      icon: const GlyphIcon(AppGlyphs.more),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

const _zstdMagic = [0x28, 0xB5, 0x2F, 0xFD];
const _probeLength = 512;

// An .mrs rule set is a zstd stream and any other binary file gives itself
// away with a NUL byte; neither can go through the Core's string side-load.
Future<bool> _isTextProviderFile(String? path) async {
  if (path == null || path.isEmpty) {
    return false;
  }
  try {
    final file = File(path);
    if (!await file.exists()) {
      return true;
    }
    final head = await file
        .openRead(0, _probeLength)
        .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
    if (listEquals(head.take(_zstdMagic.length).toList(), _zstdMagic)) {
      return false;
    }
    return !head.contains(0);
  } catch (_) {
    return false;
  }
}

String _decodeProviderFile(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    throw MessageException(currentAppLocalizations.nonTextProviderFile);
  }
}

Future<void> _sideLoadProvider(
  WidgetRef ref,
  ExternalProvider provider,
  List<int> bytes,
) async {
  final path = provider.path;
  if (path == null) return;
  final data = _decodeProviderFile(bytes);
  final message = await ref
      .read(proxiesActionProvider.notifier)
      .sideLoadExternalProvider(provider, data, showLoading: true);
  if (message.isNotEmpty) throw MessageException(message);
  await File(path).safeWriteAsBytes(bytes);
}

class _EditProviderView extends ConsumerStatefulWidget {
  final ExternalProvider provider;
  final String path;

  const _EditProviderView({required this.provider, required this.path});

  @override
  ConsumerState<_EditProviderView> createState() => _EditProviderViewState();
}

class _EditProviderViewState extends ConsumerState<_EditProviderView> {
  final _contentNotifier = ValueNotifier<String>('');
  String? _raw;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) {
      return;
    }
    _loadStarted = true;
    unawaited(_load());
  }

  @override
  void dispose() {
    _contentNotifier.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await whenRouteSettled(context);
    if (!mounted) {
      return;
    }
    final raw = await globalState.safeRun<String>(() async {
      final file = File(widget.path);
      if (!await file.exists()) {
        return '';
      }
      return _decodeProviderFile(await file.readAsBytes());
    }, silence: false);
    if (!mounted) {
      return;
    }
    if (raw == null) {
      // The message safeRun shows sits above this page, so take the page out
      // from under it instead of popping whatever is on top.
      final route = ModalRoute.of(context);
      if (route != null) {
        Navigator.of(context).removeRoute(route);
      }
      return;
    }
    _raw = raw;
    _contentNotifier.value = raw;
  }

  Future<void> _handleSave(BuildContext context, String content) async {
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    final saved = await globalState.safeRun<bool>(() async {
      await _sideLoadProvider(ref, widget.provider, utf8.encode(content));
      return true;
    }, silence: false);
    if (saved != true) {
      return;
    }
    proxiesAction.updateGroupsDebounce();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _handlePop(BuildContext context, String content) async {
    final raw = _raw;
    if (raw == null || content == raw) {
      return true;
    }
    final res = await dialogs.showMessage(
      title: widget.provider.name,
      message: TextSpan(text: context.appLocalizations.saveChanges),
    );
    if (res == null) {
      return false;
    }
    if (!res || !context.mounted) {
      return true;
    }
    unawaited(_handleSave(context, content));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _contentNotifier,
      builder: (_, content, _) {
        return EditorPage(
          title: widget.provider.name,
          content: content,
          onSave: (context, _, content) {
            _handleSave(context, content);
          },
          onPop: (context, _, content) => _handlePop(context, content),
        );
      },
    );
  }
}
