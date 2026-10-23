import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExternalProvidersSliver extends ConsumerStatefulWidget {
  final List<ExternalProvider> providers;

  const ExternalProvidersSliver({super.key, required this.providers});

  @override
  ConsumerState<ExternalProvidersSliver> createState() =>
      _ExternalProvidersSliverState();
}

class _ExternalProvidersSliverState
    extends ConsumerState<ExternalProvidersSliver> {
  bool _isUpdating = false;

  Future<void> _updateProviders() async {
    final appLocalizations = context.appLocalizations;
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    final List<UpdatingMessage> messages = [];
    setState(() => _isUpdating = true);
    try {
      await Future.wait(
        widget.providers.map((provider) async {
          try {
            final message = await proxiesAction.updateProvider(
              provider,
              showLoading: true,
            );
            if (message.isNotEmpty) {
              messages.add(
                UpdatingMessage(label: provider.name, message: message),
              );
            }
          } catch (error) {
            messages.add(
              UpdatingMessage(
                label: provider.name,
                message: userFacingErrorMessage(error, appLocalizations),
              ),
            );
          }
        }),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
    proxiesAction.updateGroupsDebounce();
    dialogs.showFailures(messages);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final providers = widget.providers;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: ListHeader(
            title: appLocalizations.providers,
            actions: [
              IconButtonData(
                glyph: AppGlyphs.sync,
                tooltip: appLocalizations.update,
                isLoading: _isUpdating,
                onPressed: _updateProviders,
              ),
            ],
          ),
        ),
        SliverList.builder(
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
      ],
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
  _ProviderFile _file = _ProviderFile.binary;
  bool _isAppRuleSet = false;

  ExternalProvider get provider => widget.provider;

  bool get _isSyncable => provider.vehicleType == 'HTTP' || _isAppRuleSet;

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
    final clashProvidersAction = ref.read(
      clashProvidersActionProvider.notifier,
    );
    final file = await _probeProviderFile(provider.path);
    final isAppRuleSet =
        await clashProvidersAction.remoteProviderOf(provider) != null;
    if (!mounted || (file == _file && isAppRuleSet == _isAppRuleSet)) {
      return;
    }
    setState(() {
      _file = file;
      _isAppRuleSet = isAppRuleSet;
    });
  }

  Future<void> _handleUpdateProvider() async {
    if (!_isSyncable) return;
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

  void _handlePreviewProvider(BuildContext context) {
    final path = provider.path;
    if (path == null || path.isEmpty) return;
    final core = ref.read(coreHandlerProvider);
    final isRuleSet = _file == _ProviderFile.ruleSet;
    unawaited(
      BaseNavigator.push<void>(
        context,
        EditorPage(
          title: provider.name,
          load: isRuleSet
              ? () async =>
                    CodeForgeDocument.fromText(await core.dumpRuleSet(path))
              : () => _openProviderText(path),
          schema: EditorSchema.provider,
        ),
      ),
    );
  }

  void _handleShowSubscriptionInfo() {
    unawaited(
      dialogs.showCommonDialog<void>(
        child: Builder(
          builder: (context) {
            return CommonDialog(
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

  List<CommonPopupMenuItem> _menuItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final subscriptionInfo = provider.subscriptionInfo;
    return [
      if (_file == _ProviderFile.text)
        CommonPopupMenuItem(
          glyph: AppGlyphs.edit,
          label: appLocalizations.edit,
          onPressed: () {
            _handleEditProvider(context);
          },
        ),
      if (_file == _ProviderFile.ruleSet)
        CommonPopupMenuItem(
          glyph: AppGlyphs.eye,
          label: appLocalizations.preview,
          onPressed: () {
            _handlePreviewProvider(context);
          },
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.upload,
        label: appLocalizations.upload,
        onPressed: () {
          _handleSideLoadProvider();
        },
      ),
      if (_isSyncable)
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
    final previewable = _file != _ProviderFile.binary;
    return ContextMenuRegion(
      menuItems: isUpdating ? null : _menuItems(context),
      child: _ExternalProviderItem(
        provider: provider,
        isUpdating: isUpdating,
        onPressed: isUpdating || !previewable
            ? null
            : () => _handlePreviewProvider(context),
      ),
    );
  }
}

class _ExternalProviderItem extends StatelessWidget {
  final ExternalProvider provider;
  final bool isUpdating;
  final VoidCallback? onPressed;

  const _ExternalProviderItem({
    required this.provider,
    required this.isUpdating,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final count = provider.count;
    final updateAt = provider.updateAt;
    final subscriptionInfo = provider.subscriptionInfo;
    final usage = subscriptionInfo?.usage;
    return DecorationListItem(
      onPressed: onPressed,
      title: ChipTitle(
        title: provider.name,
        chip: usage == null ? null : count.compact,
        expire: subscriptionInfo?.expireDate,
      ),
      subtitle: switch ((subscriptionInfo, usage)) {
        (final info?, final usage?) => _TrafficMeter(info: info, usage: usage),
        _ => Text(switch (provider.type) {
          'Proxy' => appLocalizations.proxiesCount(count, count.compact),
          _ => appLocalizations.rulesCount(count, count.compact),
        }),
      },
      trailing: AnimatedSwitcher(
        duration: context.motionDuration(commonDuration),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerRight,
          children: [...previous, ?current],
        ),
        child: isUpdating
            ? const CommonCircleLoading(key: ValueKey('loading'), size: 24)
            : LastUpdateTimeText(
                key: const ValueKey('time'),
                lastUpdateDate: updateAt.microsecondsSinceEpoch > 0
                    ? updateAt
                    : null,
                compact: true,
                style: context.listCaptionStyle,
              ),
      ),
    );
  }
}

class _TrafficMeter extends StatelessWidget {
  final SubscriptionInfo info;
  final double usage;

  const _TrafficMeter({required this.info, required this.usage});

  @override
  Widget build(BuildContext context) {
    final used = info.upload + info.download;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Text(
          '${used.traffic.show} / ${info.total.traffic.show}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        LinearProgressIndicator(
          minHeight: 4,
          value: usage,
          backgroundColor: context.colorScheme.primary.opacity15,
        ),
      ],
    );
  }
}

Future<CodeForgeDocument> _openProviderText(String path) async {
  try {
    return await openEditorFile(path);
  } on FormatException {
    throw MessageException(currentAppLocalizations.nonTextProviderFile);
  }
}

const _zstdMagic = [0x28, 0xB5, 0x2F, 0xFD];
const _probeLength = 512;

enum _ProviderFile { text, ruleSet, binary }

// An .mrs rule set is a zstd stream and any other binary file gives itself
// away with a NUL byte; neither can go through the Core's string side-load,
// but the Core can dump an .mrs set back to text for reading.
Future<_ProviderFile> _probeProviderFile(String? path) async {
  if (path == null || path.isEmpty) {
    return _ProviderFile.binary;
  }
  try {
    final file = File(path);
    if (!await file.exists()) {
      return _ProviderFile.text;
    }
    final head = await file
        .openRead(0, _probeLength)
        .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
    if (listEquals(head.take(_zstdMagic.length).toList(), _zstdMagic)) {
      return _ProviderFile.ruleSet;
    }
    return head.contains(0) ? _ProviderFile.binary : _ProviderFile.text;
  } catch (_) {
    return _ProviderFile.binary;
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
  Future<void> _handleSave(BuildContext context, EditorContent content) async {
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    final saved = await globalState.safeRun<bool>(() async {
      await _sideLoadProvider(ref, widget.provider, await content.readBytes());
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

  Future<bool> _handlePop(BuildContext context, EditorContent content) async {
    final res = await dialogs.showSaveChanges(title: widget.provider.name);
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
    return EditorPage(
      title: widget.provider.name,
      load: () => _openProviderText(widget.path),
      schema: EditorSchema.provider,
      onSave: (context, _, content) => _handleSave(context, content),
      onPop: (context, _, content) => _handlePop(context, content),
    );
  }
}
