import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomProxiesView extends ConsumerStatefulWidget {
  final int profileId;

  const CustomProxiesView(this.profileId, {super.key});

  @override
  ConsumerState createState() => _CustomProxiesViewState();
}

class _CustomProxiesViewState extends ConsumerState<CustomProxiesView> {
  void _handleReorder(int oldIndex, int newIndex) {
    ref
        .read(customProxiesProvider(widget.profileId).notifier)
        .order(oldIndex, newIndex);
  }

  void _handleDelete(Set<int> ids) {
    ref.read(customProxiesProvider(widget.profileId).notifier).delAll(ids);
  }

  void _handleAddOrUpdate({CustomProxy? proxy}) {
    showOverwriteNestedSheet<CustomProxy>(
      context: context,
      profileId: widget.profileId,
      overrides: [
        customProxyProvider.overrideWithBuild(
          (_, _) =>
              proxy ??
              const CustomProxy(id: -1, definition: {'name': '', 'type': 'ss'}),
        ),
      ],
      currentOf: (ref) => ref.read(customProxyProvider),
      save: _handleSaveCustomProxy,
      formBuilder: (_) => const _EditCustomProxyView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return OverwriteEditorPage<CustomProxy, int>(
      title: appLocalizations.proxies,
      selectionEnabled: true,
      dragFromRow: true,
      idOf: (proxy) => proxy.id,
      itemsOf: (ref) {
        return ref.watch(customProxiesProvider(widget.profileId)).value;
      },
      itemBuilder:
          (
            context,
            ref,
            proxy,
            index,
            isEditing,
            isSelected,
            onToggleSelected,
          ) {
            return _CustomProxyItem(
              profileId: widget.profileId,
              proxy: proxy,
              isEditing: isEditing,
              isSelected: isSelected,
              onSelected: onToggleSelected,
              onPressed: () {
                _handleAddOrUpdate(proxy: proxy);
              },
            );
          },
      onReorder: _handleReorder,
      onAdd: _handleAddOrUpdate,
      onDelete: _handleDelete,
      searchFieldsOf: (proxy) => proxy.searchFields,
      emptyLabel: appLocalizations.customProxiesEmpty,
      itemExtent:
          globalState.measure.bodyLargeHeight +
          globalState.measure.bodyMediumHeight +
          16,
    );
  }
}

class _CustomProxyItem extends ConsumerWidget {
  final int profileId;
  final CustomProxy proxy;
  final bool isEditing;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onPressed;

  const _CustomProxyItem({
    required this.profileId,
    required this.proxy,
    required this.isEditing,
    required this.isSelected,
    required this.onSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issues = ref
        .watch(
          customOverwriteIssuesProvider(profileId).select(
            (state) => SelectValue(
              state.proxies[proxy.id] ?? const <OverwriteIssue>[],
            ),
          ),
        )
        .value;
    final address = proxy.address;
    return DecorationListItem(
      invalid: issues.isNotEmpty,
      isSelected: isSelected,
      onPressed: isEditing ? onSelected : onPressed,
      contentPadding: const EdgeInsets.only(left: 16),
      minVerticalPadding: 8,
      title: TooltipText(
        text: Text(
          proxy.name.isEmpty ? '-' : proxy.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Text(
        address == null ? proxy.type : '${proxy.type} · $address',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (issues.isNotEmpty) OverwriteIssueButton(issues: issues),
          CommonCheckBox(
            value: isSelected,
            isCircle: true,
            onChanged: (_) => onSelected(),
          ),
        ],
      ),
    );
  }
}

Future<bool> _handleSaveCustomProxy(BuildContext context, WidgetRef ref) async {
  final profileId = ProfileIdProvider.of(context)!.profileId;
  final proxy = ref.read(customProxyProvider);
  final issues = customProxyIssues(
    proxy,
    proxies: ref.read(customProxiesProvider(profileId)).value ?? const [],
    proxyGroups: ref.read(customOverwriteDateProvider(profileId)).proxyGroups,
  );
  if (issues.isEmpty) {
    try {
      final errors = await ref.read(coreHandlerProvider).validateProxies([
        proxy.definition,
      ]);
      if (errors.first.isNotEmpty) {
        issues.add(OverwriteIssue.coreRejected(errors.first));
      }
    } catch (error) {
      issues.add(OverwriteIssue.coreRejected(compactError(error)));
    }
  }
  if (!context.mounted) {
    return false;
  }
  if (issues.isNotEmpty) {
    await showOverwriteIssues(context, issues);
    return false;
  }
  ref
      .read(customProxiesProvider(profileId).notifier)
      .put(proxy.id == -1 ? proxy.copyWith(id: snowflake.id) : proxy);
  return true;
}

class _EditCustomProxyView extends ConsumerStatefulWidget {
  const _EditCustomProxyView();

  @override
  ConsumerState<_EditCustomProxyView> createState() =>
      _EditCustomProxyViewState();
}

class _EditCustomProxyViewState extends ConsumerState<_EditCustomProxyView> {
  static const _validateDelay = Duration(milliseconds: 400);

  Timer? _validateTimer;
  int _validateRequest = 0;
  String? _coreError;

  /// Bumped when the whole mapping is replaced, so the fields drop the text
  /// they were initialized with.
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      customProxyProvider.select((state) => state.definition),
      (_, _) => _scheduleValidate(),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _validateTimer?.cancel();
    super.dispose();
  }

  void _scheduleValidate() {
    _validateTimer?.cancel();
    _validateTimer = Timer(_validateDelay, _validate);
  }

  Future<void> _validate() async {
    final request = ++_validateRequest;
    final definition = ref.read(customProxyProvider).definition;
    String? error;
    try {
      final errors = await ref.read(coreHandlerProvider).validateProxies([
        definition,
      ]);
      error = errors.first.isEmpty ? null : errors.first;
    } catch (_) {
      error = null;
    }
    if (!mounted || request != _validateRequest || error == _coreError) {
      return;
    }
    setState(() {
      _coreError = error;
    });
  }

  void _update(String key, Object? value) {
    ref
        .read(customProxyProvider.notifier)
        .update((state) => state.withValue(key, value));
  }

  Widget _buildTextItem({
    required String title,
    required String key,
    required String? value,
    required int maxLength,
    String? hintText,
    bool digitsOnly = false,
    bool invalid = false,
  }) {
    return OverwriteFormRow(
      title: title,
      invalid: invalid,
      trailing: TextFormField(
        key: ValueKey('$key-$_revision'),
        initialValue: value,
        textAlign: TextAlign.end,
        keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
        inputFormatters: digitsOnly
            ? TextInputLimits.digitsOnly(maxLength)
            : TextInputLimits.limit(maxLength),
        onChanged: (value) {
          _update(key, digitsOnly ? int.tryParse(value) : value);
        },
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: hintText ?? context.appLocalizations.optional,
        ),
      ),
    );
  }

  Future<void> _handleSelectType() async {
    final res = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => OverwriteSelectionSheet<String>(
          title: context.appLocalizations.proxyType,
          sections: const [OverwriteSelectionSection(items: customProxyTypes)],
          labelBuilder: (item) => item,
          selectedOf: (ref) =>
              ref.watch(customProxyProvider.select((state) => state.type)),
          onSelected: (item) => Navigator.of(context).pop(item),
        ),
      ),
    );
    if (res == null) {
      return;
    }
    _update('type', res);
  }

  Widget _buildTypeItem(String type) {
    return OverwriteFormRow(
      title: context.appLocalizations.proxyType,
      onPressed: _handleSelectType,
      trailing: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              type,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const GlyphIcon(AppGlyphs.chevronForward),
        ],
      ),
    );
  }

  Widget _buildUdpItem(bool udp) {
    return OverwriteFormRow(
      title: 'UDP',
      onPressed: () => _update('udp', !udp),
      trailing: Switch(value: udp, onChanged: (value) => _update('udp', value)),
    );
  }

  Future<void> _handleEditDefinition() async {
    final raw = ref.read(customProxyProvider).definitionYaml;
    final page = EditorPage(
      title: context.appLocalizations.proxyDefinition,
      content: raw,
      readOnly: false,
      onPop: (_, _, content) => _handleDefinitionPop(content, raw),
    );
    await Navigator.of(context, rootNavigator: true).push(
      context.isMobileView
          ? CommonRoute(builder: (_) => page)
          : CommonDesktopRoute(builder: (_) => page),
    );
  }

  Future<bool> _handleDefinitionPop(String content, String raw) async {
    if (content == raw) {
      return true;
    }
    final CustomProxy next;
    try {
      next = ref.read(customProxyProvider).withDefinitionYaml(content);
    } catch (error) {
      final res = await dialogs.showMessage(
        message: TextSpan(
          text:
              '${currentAppLocalizations.proxyDefinitionNotMap}\n\n'
              '${currentAppLocalizations.discardChanges}',
        ),
      );
      return res == true;
    }
    ref.read(customProxyProvider.notifier).value = next;
    if (mounted) {
      setState(() {
        _revision++;
      });
    }
    return true;
  }

  Future<void> _handleDelete(int profileId) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.proxies),
      ),
    );
    if (res == true && mounted) {
      final id = ref.read(customProxyProvider).id;
      ref.read(customProxiesProvider(profileId).notifier).delAll([id]);
      context.safeNestedPop();
    }
  }

  Future<void> _handleSave() async {
    if (await _handleSaveCustomProxy(context, ref) && mounted) {
      context.safeNestedPop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final proxy = ref.watch(customProxyProvider);
    final issues = [
      ...customProxyIssues(
        proxy,
        proxies: ref.watch(customProxiesProvider(profileId)).value ?? const [],
        proxyGroups: ref.watch(
          customOverwriteDateProvider(
            profileId,
          ).select((state) => state.proxyGroups),
        ),
      ),
      if (_coreError != null) OverwriteIssue.coreRejected(_coreError!),
    ];
    final nameInvalid = issues.any(
      (issue) =>
          issue is EmptyNameIssue ||
          issue is ReservedNameIssue ||
          issue is DuplicateNameIssue,
    );
    final height = ref.sheetHeight(context, 0.65);
    return CommonScaffold(
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.check,
            onPressed: _handleSave,
            tooltip: appLocalizations.save,
          ),
        ),
      ],
      body: SizedBox(
        height: height,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 20, top: context.contentTopPadding),
          children: [
            OverwriteIssuesBanner(issues: issues),
            generateSectionV3(
              title: appLocalizations.basicInfo,
              items: [
                _buildTextItem(
                  title: appLocalizations.name,
                  key: 'name',
                  value: proxy.name,
                  maxLength: TextInputLimits.proxyName,
                  hintText: appLocalizations.name,
                  invalid: nameInvalid,
                ),
                _buildTypeItem(proxy.type),
                _buildTextItem(
                  title: appLocalizations.server,
                  key: 'server',
                  value: proxy.server,
                  maxLength: TextInputLimits.domain,
                ),
                _buildTextItem(
                  title: appLocalizations.port,
                  key: 'port',
                  value: proxy.port?.toString(),
                  maxLength: TextInputLimits.port,
                  digitsOnly: true,
                ),
                _buildUdpItem(proxy.definition['udp'] == true),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.other,
              items: [
                OverwriteFormRow(
                  title: appLocalizations.proxyDefinition,
                  invalid: _coreError != null,
                  onPressed: _handleEditDefinition,
                  trailing: const GlyphIcon(AppGlyphs.chevronForward),
                ),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.action,
              items: [
                if (proxy.id != -1)
                  OverwriteFormRow(
                    title: appLocalizations.delete,
                    titleStyle: TextStyle(color: context.colorScheme.error),
                    onPressed: () {
                      _handleDelete(profileId);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      title: proxy.id == -1
          ? appLocalizations.addCustomProxy
          : appLocalizations.editProxy,
    );
  }
}
