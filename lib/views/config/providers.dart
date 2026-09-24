import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClashProvidersView extends ConsumerStatefulWidget {
  const ClashProvidersView({super.key, required this.kind});

  final ProviderKind kind;

  @override
  ConsumerState<ClashProvidersView> createState() => _ClashProvidersViewState();
}

class _ClashProvidersViewState extends ConsumerState<ClashProvidersView> {
  late final ClashProvidersAction _providersAction;

  ProviderKind get _kind => widget.kind;

  @override
  void initState() {
    super.initState();
    _providersAction = ref.read(clashProvidersActionProvider.notifier);
  }

  String get _template => switch (_kind) {
    ProviderKind.proxy => proxyProviderTemplate,
    ProviderKind.rule => ruleProviderTemplate,
  };

  String _sectionLabel(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return switch (_kind) {
      ProviderKind.proxy => appLocalizations.proxyProviders,
      ProviderKind.rule => appLocalizations.ruleProviders,
    };
  }

  List<ClashProvider> get _providers =>
      ref.read(clashProvidersProvider(_kind)).value ?? [];

  Set<String> _reservedLabels({ClashProvider? except}) {
    return {
      for (final item in _providers)
        if (item.id != except?.id) item.label,
      if (_kind == ProviderKind.proxy)
        ...ref.read(profileProvidersProvider).keys,
    };
  }

  String? _validateLabel(
    String? value, {
    ClashProvider? except,
    bool optional = false,
  }) {
    final appLocalizations = context.appLocalizations;
    final label = value?.trim() ?? '';
    if (label.isEmpty) {
      return optional ? null : appLocalizations.emptyTip(appLocalizations.name);
    }
    if (_reservedLabels(except: except).contains(label)) {
      return appLocalizations.existsTip(appLocalizations.name);
    }
    return null;
  }

  String _uniqueLabel(String name) {
    final reserved = _reservedLabels();
    return uniqueLabelFor(
      name,
      fallback: _sectionLabel(context),
      taken: reserved.contains,
    );
  }

  Future<bool> _put(
    ClashProvider provider, {
    ClashProvider? previous,
    List<int>? content,
  }) async {
    final appLocalizations = context.appLocalizations;
    final conflicts = await _providersAction.putProvider(
      provider,
      previous: previous,
      content: content,
    );
    if (conflicts.isEmpty) {
      return true;
    }
    await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.providerRenameShadowed(
          conflicts.map((profile) => profile.realLabel).join(', '),
          provider.label,
        ),
      ),
      cancelable: false,
    );
    return false;
  }

  /// The core has no default for behavior and refuses the whole config without
  /// one, so a new rule set names it before anything is written.
  Future<ClashProvider?> _resolveBehavior(ClashProvider provider) async {
    if (provider.kind != ProviderKind.rule) {
      return provider;
    }
    final res = await _showBehaviorDialog(provider);
    return res == null ? null : provider.copyWith(behavior: res);
  }

  Future<RuleProviderBehavior?> _showBehaviorDialog(
    ClashProvider provider,
  ) async {
    final options = provider.format.behaviors;
    return dialogs.showCommonDialog<RuleProviderBehavior>(
      child: OptionsDialog<RuleProviderBehavior>(
        title: context.appLocalizations.behavior,
        options: options,
        textBuilder: (item) => item.name,
        value: options.contains(provider.behavior)
            ? provider.behavior!
            : options.first,
      ),
    );
  }

  Future<void> _handleImportFromUrl() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showNamedUrlInput(
      title: appLocalizations.importUrl,
      labelValidator: (value) => _validateLabel(value, optional: true),
      urlValidator: _validateProviderUrl,
    );
    if (res == null || !mounted) {
      return;
    }
    final fileName = res.url.urlFileName;
    final label = res.label.isNotEmpty
        ? res.label
        : _uniqueLabel(fileName.fileStem);
    final provider = await _resolveBehavior(
      ClashProvider.create(
        kind: _kind,
        label: label,
        url: res.url,
      ).withFileFormat(fileName),
    );
    if (provider == null) {
      return;
    }
    await _put(provider);
  }

  Future<void> _handleImportFromFile() async {
    final file = await globalState.safeRun(picker.pickerFile);
    if (file == null) {
      return;
    }
    final bytes = await file.readBytes();
    if (!mounted) {
      return;
    }
    final provider = await _resolveBehavior(
      ClashProvider.create(
        kind: _kind,
        label: _uniqueLabel(file.name.fileStem),
      ).withFileFormat(file.name),
    );
    if (provider == null) {
      return;
    }
    await _put(provider, content: bytes);
  }

  Future<String?> _showNameDialog({ClashProvider? except}) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.save,
        value: '',
        labelText: appLocalizations.name,
        inputFormatters: TextInputLimits.limit(TextInputLimits.name),
        validator: (value) => _validateLabel(value, except: except),
      ),
    );
    return res?.trim().value;
  }

  Future<void> _handleEditorSave(
    String title,
    String content, {
    ClashProvider? provider,
  }) async {
    final appLocalizations = context.appLocalizations;
    var label = title.trim();
    if (label.isEmpty) {
      final res = await _showNameDialog(except: provider);
      if (res == null) {
        return;
      }
      label = res;
    }
    if (_reservedLabels(except: provider).contains(label)) {
      unawaited(
        dialogs.showMessage(
          message: TextSpan(
            text: appLocalizations.existsTip(appLocalizations.name),
          ),
        ),
      );
      return;
    }
    var next = provider?.copyWith(label: label);
    if (next == null) {
      next = await _resolveBehavior(
        ClashProvider.create(kind: _kind, label: label),
      );
      if (next == null) {
        return;
      }
    }
    if (!await _put(next, previous: provider, content: utf8.encode(content))) {
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _handleEditorPop(
    String title,
    String content,
    String raw, {
    ClashProvider? provider,
  }) async {
    if (content == raw) {
      return true;
    }
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.saveChanges),
    );
    if (res == null) {
      return false;
    }
    if (!res || !mounted) {
      return true;
    }
    unawaited(_handleEditorSave(title, content, provider: provider));
    return false;
  }

  void _handleToEditor([ClashProvider? provider]) {
    late final String raw;
    unawaited(
      BaseNavigator.push(
        context,
        EditorPage(
          titleEditable: true,
          title: provider?.label ?? '',
          load: () async => raw = (await provider?.content) ?? _template,
          onSave: (_, title, content) {
            _handleEditorSave(title, content, provider: provider);
          },
          onPop: (_, title, content) =>
              _handleEditorPop(title, content, raw, provider: provider),
        ),
      ),
    );
  }

  Future<void> _handleEditOptions(ClashProvider provider) async {
    final res = await dialogs.showCommonDialog<ClashProvider>(
      child: _ProviderDialog(
        provider: provider,
        reservedLabels: _reservedLabels(except: provider),
      ),
    );
    if (res == null) {
      return;
    }
    await _put(res, previous: provider);
  }

  Future<void> _handleDelete(ClashProvider provider) async {
    final appLocalizations = context.appLocalizations;
    var users = await _providersAction.profilesUsing(provider);
    if (users.isEmpty) {
      final res = await dialogs.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: appLocalizations.deleteTip(provider.label)),
      );
      if (res != true) {
        return;
      }
      users = await _providersAction.delProvider(provider);
      if (users.isEmpty) {
        return;
      }
    }
    await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.providerInUse(
          provider.label,
          users.map((profile) => profile.realLabel).join(', '),
        ),
      ),
      cancelable: false,
    );
  }

  bool _isEditable(ClashProvider provider) =>
      !provider.isRemote && provider.isTextContent;

  Widget _buildItem(ClashProvider provider, int index, int length) {
    final appLocalizations = context.appLocalizations;
    final editable = _isEditable(provider);
    return ItemPositionProvider(
      position: ItemPosition.get(index, length),
      child: DecorationListItem(
        contentPadding: const EdgeInsets.only(left: 16, right: 6),
        title: Text(
          provider.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          provider.isRemote ? provider.url : appLocalizations.file,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: CommonPopupBox(
          popupBuilder: (_) => CommonPopupMenu(
            items: [
              if (editable)
                CommonPopupMenuItem(
                  glyph: AppGlyphs.compose,
                  label: appLocalizations.edit,
                  onPressed: () {
                    _handleToEditor(provider);
                  },
                ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.settings,
                label: appLocalizations.options,
                onPressed: () {
                  _handleEditOptions(provider);
                },
              ),
              CommonPopupMenuItem(
                danger: true,
                glyph: AppGlyphs.delete,
                label: appLocalizations.delete,
                onPressed: () {
                  _handleDelete(provider);
                },
              ),
            ],
          ),
          targetBuilder: (open) {
            return IconButton(
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.standard,
              ),
              tooltip: appLocalizations.more,
              onPressed: () {
                open();
              },
              icon: const GlyphIcon(AppGlyphs.more),
            );
          },
        ),
        onPressed: () {
          if (editable) {
            _handleToEditor(provider);
          } else {
            _handleEditOptions(provider);
          }
        },
      ),
    );
  }

  Widget _buildContent(List<ClashProvider> providers, {required bool loading}) {
    final appLocalizations = context.appLocalizations;
    return NullStatusSwitcher(
      isLoading: loading,
      isEmpty: providers.isEmpty,
      nullStatus: NullStatus(
        illustration: switch (_kind) {
          ProviderKind.proxy => NullStatusIllustration.proxies,
          ProviderKind.rule => NullStatusIllustration.rules,
        },
        label: appLocalizations.nullTip(_sectionLabel(context)),
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(
          16,
        ).copyWith(top: context.contentTopPadding),
        buildDefaultDragHandles: false,
        itemCount: providers.length,
        itemBuilder: (_, index) {
          return ReorderableDelayedDragStartListener(
            key: ValueKey(providers[index].id),
            index: index,
            child: _buildItem(providers[index], index, providers.length),
          );
        },
        proxyDecorator: (_, index, animation) {
          return commonProxyDecorator(
            _buildItem(providers[index], index, providers.length),
            index,
            animation,
          );
        },
        onReorderItem: ref.read(clashProvidersProvider(_kind).notifier).order,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final state = ref.watch(clashProvidersProvider(_kind));
    return CommonScaffold(
      actions: [
        CommonPopupBox(
          targetBuilder: (open) {
            return FilledButton.tonal(
              onPressed: () {
                final isMobile = ref.read(isMobileViewProvider);
                open(offset: Offset(0, isMobile ? 0 : 20));
              },
              child: Text(appLocalizations.add),
            );
          },
          popupBuilder: (_) => CommonPopupMenu(
            items: [
              CommonPopupMenuItem(
                glyph: AppGlyphs.compose,
                label: appLocalizations.startFromScratch,
                onPressed: _handleToEditor,
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.cloudDownload,
                label: appLocalizations.importUrl,
                onPressed: _handleImportFromUrl,
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.importFile,
                label: appLocalizations.importFile,
                onPressed: _handleImportFromFile,
              ),
            ],
          ),
        ),
      ],
      body: _buildContent(state.value ?? [], loading: state.isLoading),
      title: _sectionLabel(context),
    );
  }
}

String? _validateProviderUrl(String? value) {
  final appLocalizations = currentAppLocalizations;
  final url = value?.trim() ?? '';
  if (url.isEmpty) {
    return appLocalizations.emptyTip(appLocalizations.url);
  }
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.isScheme('http') && !uri.isScheme('https')) {
    return appLocalizations.providerUrlTip;
  }
  return null;
}

class _ProviderDialog extends StatefulWidget {
  const _ProviderDialog({required this.provider, required this.reservedLabels});

  final ClashProvider provider;
  final Set<String> reservedLabels;

  @override
  State<_ProviderDialog> createState() => _ProviderDialogState();
}

class _ProviderDialogState extends State<_ProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;
  late ClashProvider _draft;

  ClashProvider get _provider => widget.provider;

  ProviderKind get _kind => _provider.kind;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: _provider.label);
    _urlController = TextEditingController(text: _provider.url)
      ..addListener(_followUrlFormat);
    _draft = _provider.withFormat(_provider.format ?? RuleProviderFormat.yaml);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _setFormat(RuleProviderFormat format) {
    if (format == _draft.format) {
      return;
    }
    setState(() {
      _draft = _draft.withFormat(format);
    });
  }

  /// A url whose extension names a format follows it, as an import does.
  void _followUrlFormat() {
    final format = ruleProviderFormatOf(_urlController.text.trim().urlFileName);
    if (format != null) {
      _setFormat(format);
    }
  }

  String? _validateLabel(String? value) {
    final appLocalizations = context.appLocalizations;
    final label = value?.trim() ?? '';
    if (label.isEmpty) {
      return appLocalizations.emptyTip(appLocalizations.name);
    }
    if (widget.reservedLabels.contains(label)) {
      return appLocalizations.existsTip(appLocalizations.name);
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == false) {
      return;
    }
    Navigator.of(context).pop(
      _draft.copyWith(
        label: _labelController.text.trim(),
        url: _urlController.text.trim(),
      ),
    );
  }

  Future<void> _handleSelectFormat() async {
    final res = await dialogs.showCommonDialog<RuleProviderFormat>(
      context: context,
      child: OptionsDialog<RuleProviderFormat>(
        title: context.appLocalizations.format,
        options: RuleProviderFormat.values,
        textBuilder: (item) => item.name,
        value: _draft.format!,
      ),
    );
    if (res == null) {
      return;
    }
    _setFormat(res);
  }

  Future<void> _handleSelectBehavior() async {
    final res = await dialogs.showCommonDialog<RuleProviderBehavior>(
      context: context,
      child: OptionsDialog<RuleProviderBehavior>(
        title: context.appLocalizations.behavior,
        options: _draft.format.behaviors,
        textBuilder: (item) => item.name,
        value: _draft.behavior!,
      ),
    );
    if (res == null) {
      return;
    }
    setState(() {
      _draft = _draft.copyWith(behavior: res);
    });
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(border: AppShape.input, labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.options,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Wrap(
          runSpacing: 16,
          children: [
            _buildField(
              controller: _labelController,
              label: appLocalizations.name,
              validator: _validateLabel,
              inputFormatters: TextInputLimits.limit(TextInputLimits.name),
            ),
            if (_provider.isRemote)
              _buildField(
                controller: _urlController,
                label: appLocalizations.url,
                validator: _validateProviderUrl,
                keyboardType: TextInputType.url,
              ),
            if (_kind == ProviderKind.rule) ...[
              ListItem(
                padding: EdgeInsets.zero,
                title: Text(appLocalizations.format),
                trailing: ElasticButton(
                  child: FilledButton(
                    onPressed: _handleSelectFormat,
                    child: Text(_draft.format!.name),
                  ),
                ),
              ),
              ListItem(
                padding: EdgeInsets.zero,
                title: Text(appLocalizations.behavior),
                trailing: ElasticButton(
                  child: FilledButton(
                    onPressed: _handleSelectBehavior,
                    child: Text(_draft.behavior!.name),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
