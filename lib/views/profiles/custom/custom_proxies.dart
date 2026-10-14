import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quick_edit.dart';

extension on ProxyField {
  String label(AppLocalizations l) => switch (this) {
    ProxyField.username => l.username,
    ProxyField.password => l.password,
    ProxyField.uuid => 'UUID',
    ProxyField.psk || ProxyField.preSharedKey => l.preSharedKey,
    ProxyField.authStr => l.password,
    ProxyField.key => l.secretKey,
    ProxyField.privateKey => l.privateKey,
    ProxyField.publicKey => l.publicKey,
    ProxyField.privateKeyPassphrase => l.privateKeyPassphrase,
    ProxyField.cipher => l.cipher,
    ProxyField.alterId => 'Alter ID',
    ProxyField.protocol => l.protocol,
    ProxyField.obfs => l.obfs,
    ProxyField.transport => l.transport,
    ProxyField.network => l.network,
    ProxyField.up => l.uploadBandwidth,
    ProxyField.down => l.downloadBandwidth,
    ProxyField.flow => 'Flow',
    ProxyField.wsPath => 'WebSocket Path',
    ProxyField.wsHost => 'WebSocket Host',
    ProxyField.grpcServiceName => 'gRPC Service Name',
    ProxyField.xhttpPath => 'XHTTP Path',
    ProxyField.xhttpHost => 'XHTTP Host',
    ProxyField.tls => 'TLS',
    ProxyField.sni || ProxyField.servername => 'SNI',
    ProxyField.alpn => 'ALPN',
    ProxyField.skipCertVerify => l.skipCertVerify,
    ProxyField.clientFingerprint => l.clientFingerprint,
    ProxyField.realityPublicKey => 'Reality Public Key',
    ProxyField.realityShortId => 'Reality Short ID',
    ProxyField.plugin => l.plugin,
    ProxyField.pluginMode => l.pluginMode,
    ProxyField.pluginHost => l.pluginHost,
    ProxyField.udpOverTcp => 'UDP over TCP',
    ProxyField.protocolParam => l.protocolParam,
    ProxyField.obfsParam => l.obfsParam,
    ProxyField.obfsPassword || ProxyField.obfsSecret => l.obfsPassword,
    ProxyField.obfsMode => l.obfsMode,
    ProxyField.obfsHost => l.obfsHost,
    ProxyField.version => l.protocolVersion,
    ProxyField.ports => l.portHopping,
    ProxyField.hopInterval => l.hopInterval,
    ProxyField.congestionController => l.congestionControl,
    ProxyField.udpRelayMode => l.udpRelayMode,
    ProxyField.reduceRtt => '0-RTT',
    ProxyField.ip => 'IPv4',
    ProxyField.ipv6 => 'IPv6',
    ProxyField.allowedIps => l.allowedIps,
    ProxyField.dns => 'DNS',
    ProxyField.remoteDnsResolve => l.remoteDnsResolve,
    ProxyField.mtu => 'MTU',
    ProxyField.tfo => 'TCP Fast Open',
    ProxyField.mptcp => 'MPTCP',
    ProxyField.interfaceName => l.interfaceName,
    ProxyField.routingMark => l.routingMark,
    ProxyField.ipVersion => l.ipVersion,
  };

  bool get isCredential => switch (this) {
    ProxyField.username ||
    ProxyField.password ||
    ProxyField.uuid ||
    ProxyField.psk ||
    ProxyField.key ||
    ProxyField.privateKey ||
    ProxyField.publicKey ||
    ProxyField.privateKeyPassphrase ||
    ProxyField.preSharedKey ||
    ProxyField.authStr => true,
    _ => false,
  };

  _OptionSection get section => switch (this) {
    _ when isCredential => _OptionSection.authentication,
    ProxyField.network ||
    ProxyField.flow ||
    ProxyField.wsPath ||
    ProxyField.wsHost ||
    ProxyField.grpcServiceName ||
    ProxyField.xhttpPath ||
    ProxyField.xhttpHost => _OptionSection.transport,
    ProxyField.tls ||
    ProxyField.sni ||
    ProxyField.servername ||
    ProxyField.alpn ||
    ProxyField.skipCertVerify ||
    ProxyField.clientFingerprint ||
    ProxyField.realityPublicKey ||
    ProxyField.realityShortId => _OptionSection.tls,
    ProxyField.tfo ||
    ProxyField.mptcp ||
    ProxyField.interfaceName ||
    ProxyField.routingMark ||
    ProxyField.ipVersion => _OptionSection.connection,
    _ => _OptionSection.other,
  };

  int get maxLength => switch (this) {
    ProxyField.username => TextInputLimits.userName,
    ProxyField.interfaceName || ProxyField.alpn => TextInputLimits.name,
    ProxyField.ip ||
    ProxyField.ipv6 ||
    ProxyField.allowedIps => TextInputLimits.cidr,
    ProxyField.dns => TextInputLimits.dnsServer,
    ProxyField.wsPath || ProxyField.xhttpPath => TextInputLimits.url,
    _ when kind == ProxyFieldKind.number => TextInputLimits.number,
    _ => TextInputLimits.domain,
  };

  String? get hintText => switch (this) {
    ProxyField.up || ProxyField.down => '100 Mbps',
    ProxyField.ports => '443,8000-9000',
    _ => null,
  };
}

enum _OptionSection {
  authentication,
  transport,
  tls,
  other,
  connection;

  String label(AppLocalizations l) => switch (this) {
    authentication => l.authentication,
    transport => l.transport,
    tls => 'TLS',
    other => l.other,
    connection => l.connection,
  };
}

class CustomProxiesView extends ConsumerStatefulWidget {
  const CustomProxiesView({super.key});

  @override
  ConsumerState createState() => _CustomProxiesViewState();
}

class _CustomProxiesViewState extends ConsumerState<CustomProxiesView> {
  late final ClashProvidersAction _providersAction;
  final _seenNames = <String>{};
  List<CustomProxy>? _opened;
  List<CustomProxy>? _latest;
  final _searchTexts = Expando<String>();
  var _query = SearchQuery('');
  var _selected = <int>{};

  @override
  void initState() {
    super.initState();
    _providersAction = ref.read(clashProvidersActionProvider.notifier);
    ref.listenManual(customProxiesProvider, (_, next) {
      final proxies = next.value;
      if (proxies == null) {
        return;
      }
      _seenNames.addAll([for (final proxy in proxies) proxy.name]);
      _opened ??= proxies;
      _latest = proxies;
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    if (!customProxiesEquality.equals(_applied(_opened), _applied(_latest))) {
      unawaited(_providersAction.applyIfProxiesNamed(_seenNames));
    }
    super.dispose();
  }

  static List<CustomProxy> _applied(List<CustomProxy>? proxies) => [
    for (final proxy in proxies ?? const <CustomProxy>[])
      proxy.copyWith(emptyOptions: const {}),
  ];

  void _handleReorder(int oldIndex, int newIndex) {
    ref.read(customProxiesProvider.notifier).order(oldIndex, newIndex);
  }

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  void _handleToggleSelected(int id) {
    setState(() {
      _selected = {..._selected}..addOrRemove(id);
    });
  }

  void _handleSelectAll(Set<int> ids) {
    setState(() {
      _selected = _selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleDelete(Set<int> ids, {required Set<int> kept}) async {
    final appLocalizations = context.appLocalizations;
    final message = await _deleteMessage(
      ref,
      ids,
      appLocalizations.deleteMultipTip(appLocalizations.proxies),
    );
    if (!mounted) {
      return;
    }
    final res = await dialogs.showMessage(message: TextSpan(text: message));
    if (res != true || !mounted) {
      return;
    }
    ref.read(customProxiesProvider.notifier).delAll(ids);
    setState(() {
      _selected = kept;
    });
  }

  Future<void> _handleQuickEdit() async {
    final previous = ref.read(customProxiesProvider).value;
    if (previous == null) {
      return;
    }
    final appLocalizations = context.appLocalizations;
    final core = ref.read(coreHandlerProvider);
    final List<String> links;
    try {
      links = await core.encodeShareLinks([
        for (final proxy in previous) proxy.definition,
      ]);
    } catch (error) {
      await dialogs.showMessage(message: TextSpan(text: compactError(error)));
      return;
    }
    if (!mounted) {
      return;
    }
    final notifier = ref.read(customProxiesProvider.notifier);
    return showCustomQuickEdit(
      context,
      title: appLocalizations.proxies,
      content: ShareLinkEdit.textOf(links),
      schema: EditorSchema.shareLinks,
      invalidMessage: appLocalizations.shareLinksInvalid,
      apply: (content) async {
        final edit = ShareLinkEdit.read(
          content,
          previous: previous,
          links: links,
        );
        final decoded = await _decodeShareLinks(core, edit.pending);
        final dropped = edit.droppedLinks;
        final linked = dropped.isEmpty
            ? const <List<Map<String, dynamic>>>[]
            : await core.decodeShareLinks(dropped.values.toList());
        final proxies = edit.apply(
          decoded,
          groupNames: await ref.read(customGroupNamesProvider.future),
          linked: {
            for (final (index, id) in dropped.keys.indexed)
              if (linked[index] case [final definition]) id: definition,
          },
        );
        if (!await _confirmReplaced(previous, proxies)) {
          throw const QuickEditCancelled();
        }
        notifier.setAll(proxies);
      },
    );
  }

  /// A line whose name changed is a new proxy: what custom profiles name the
  /// old one by is left missing, so the edit says which go and which come.
  Future<bool> _confirmReplaced(
    List<CustomProxy> previous,
    List<CustomProxy> next,
  ) async {
    final kept = {for (final proxy in next) proxy.id};
    final removed = [
      for (final proxy in previous)
        if (!kept.contains(proxy.id)) proxy.name,
    ];
    if (removed.isEmpty) {
      return true;
    }
    final existed = {for (final proxy in previous) proxy.id};
    final added = [
      for (final proxy in next)
        if (!existed.contains(proxy.id)) proxy.name,
    ];
    final appLocalizations = currentAppLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: added.isEmpty
            ? appLocalizations.proxiesRemovedTip(removed.join(', '))
            : appLocalizations.proxiesReplacedTip(
                removed.join(', '),
                added.join(', '),
              ),
      ),
    );
    return res == true;
  }

  void _handleAddOrUpdate({CustomProxy? proxy}) {
    showNestedFormSheet<CustomProxy>(
      context: context,
      profileId: null,
      overrides: [
        customProxyProvider.overrideWithBuild(
          (_, _) =>
              proxy ??
              const CustomProxy(id: -1, definition: {'name': '', 'type': 'ss'}),
        ),
      ],
      currentOf: (ref) => ref.read(customProxyProvider),
      formBuilder: (_) => const _EditCustomProxyView(),
    );
  }

  Widget _buildNode(
    CustomProxy proxy, {
    required Set<int> selected,
    required ItemPosition position,
    int? dragIndex,
  }) {
    final item = ItemPositionProvider(
      position: position,
      child: _NodeItem(
        proxy: proxy,
        isEditing: selected.isNotEmpty,
        isSelected: selected.contains(proxy.id),
        onSelected: () => _handleToggleSelected(proxy.id),
        onPressed: () => _handleAddOrUpdate(proxy: proxy),
      ),
    );
    if (dragIndex == null) {
      return KeyedSubtree(key: ValueKey(proxy.id), child: item);
    }
    return ReorderableDelayedDragStartListener(
      key: ValueKey(proxy.id),
      index: dragIndex,
      child: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final proxies = ref.watch(customProxiesProvider).value;
    final all = proxies ?? const <CustomProxy>[];
    final visible = all
        .whereMatches(
          _query,
          (proxy) => proxy.searchFields,
          texts: _searchTexts,
        )
        .toList();
    // Indices among the matches cannot be mapped back onto the full list.
    final reorderable = _query.isEmpty;
    final selected = _selected.intersection({
      for (final proxy in all) proxy.id,
    });
    final visibleIds = {for (final proxy in visible) proxy.id};
    final visibleSelected = selected.intersection(visibleIds);
    return CommonPopScope(
      onPop: selected.isEmpty
          ? null
          : (_) {
              setState(() {
                _selected = {};
              });
              return false;
            },
      child: CommonScaffold(
        title: appLocalizations.proxies,
        searchState: AppBarSearchState(onSearch: _handleSearch),
        actions: [
          if (selected.isEmpty)
            ListEditorAddAction(
              onAdd: _handleAddOrUpdate,
              onQuickEdit: _handleQuickEdit,
            ),
        ],
        selectionActions: selected.isEmpty
            ? const []
            : [
                IconButtonData(
                  glyph: AppGlyphs.delete,
                  onPressed: visibleSelected.isEmpty
                      ? null
                      : () => _handleDelete(
                          visibleSelected,
                          kept: selected.difference(visibleSelected),
                        ),
                  tooltip: appLocalizations.delete,
                ),
                IconButtonData(
                  glyph: AppGlyphs.selectAll,
                  onPressed: () => _handleSelectAll(visibleIds),
                  tooltip: appLocalizations.selectAll,
                ),
              ],
        body: NullStatusSwitcher(
          isLoading: proxies == null,
          isEmpty: visible.isEmpty,
          isSearching: _query.isNotEmpty,
          nullStatus: NullStatus(
            label: appLocalizations.nullTip(appLocalizations.proxies),
            illustration: NullStatusIllustration.proxies,
            action: ElasticButton(
              child: FilledButton.tonalIcon(
                onPressed: _handleAddOrUpdate,
                icon: const GlyphIcon(AppGlyphs.addCircle, fill: 1),
                label: Text(appLocalizations.add),
              ),
            ),
          ),
          child: Builder(
            builder: (context) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: context.contentTopPadding),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16 + BottomInsetScope.of(context),
                  ),
                  sliver: reorderable
                      ? SliverReorderableList(
                          itemCount: visible.length,
                          itemBuilder: (_, index) => _buildNode(
                            visible[index],
                            selected: selected,
                            position: ItemPosition.get(index, visible.length),
                            dragIndex: index,
                          ),
                          proxyDecorator: (child, index, animation) =>
                              commonProxyDecorator(
                                _buildNode(
                                  visible[index],
                                  selected: selected,
                                  position: ItemPosition.get(
                                    index,
                                    visible.length,
                                  ),
                                  dragIndex: index,
                                ),
                                index,
                                animation,
                              ),
                          onReorderItem: _handleReorder,
                        )
                      : SliverList.builder(
                          itemCount: visible.length,
                          itemBuilder: (_, index) => _buildNode(
                            visible[index],
                            selected: selected,
                            position: ItemPosition.get(index, visible.length),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NodeItem extends ConsumerWidget {
  final CustomProxy proxy;
  final bool isEditing;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onPressed;

  const _NodeItem({
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
          customProxyListIssuesProvider.select(
            (state) => SelectValue(state[proxy.id] ?? const <CustomIssue>[]),
          ),
        )
        .value;
    return DecorationListItem(
      invalid: issues.isNotEmpty,
      isSelected: isSelected,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      onPressed: isEditing ? onSelected : onPressed,
      title: EmojiText(
        proxy.name.isEmpty ? '-' : proxy.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(proxy.type, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (issues.isNotEmpty) CustomIssueButton(issues: issues),
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

Future<Map<int, List<Map<String, dynamic>>>> _decodeShareLinks(
  CoreController core,
  List<ShareLinkLine> lines,
) async {
  final appLocalizations = currentAppLocalizations;
  final results = await core.decodeShareLinks([
    for (final line in lines) line.link,
  ]);
  final decoded = <int, List<Map<String, dynamic>>>{};
  for (final (index, line) in lines.indexed) {
    if (results[index].isEmpty) {
      throw MessageException(
        appLocalizations.lineIssueTip(
          line.line,
          appLocalizations.shareLinksInvalid,
        ),
      );
    }
    decoded[line.line] = results[index];
  }
  final entries = [
    for (final MapEntry(key: line, value: proxies) in decoded.entries)
      for (final proxy in proxies) (line: line, proxy: proxy),
  ];
  final errors = await core.validateProxies([
    for (final entry in entries) entry.proxy,
  ]);
  for (final (index, error) in errors.indexed) {
    if (error.isNotEmpty) {
      throw MessageException(
        appLocalizations.lineIssueTip(entries[index].line, error),
      );
    }
  }
  return decoded;
}

/// Pops with what [read] made of the link, or with nothing when the link was
/// left as it came, which would only drop what the link cannot carry.
class _ShareLinkDialog extends StatefulWidget {
  final String initialLink;
  final Future<Map<String, dynamic>> Function(String link) read;

  const _ShareLinkDialog({required this.initialLink, required this.read});

  @override
  State<_ShareLinkDialog> createState() => _ShareLinkDialogState();
}

class _ShareLinkDialogState extends State<_ShareLinkDialog> {
  late final TextEditingController _controller;
  String? _error;
  bool _reading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLink);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final link = _controller.text.trim();
    if (link == widget.initialLink) {
      Navigator.of(context).pop();
      return;
    }
    if (_reading) {
      return;
    }
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final definition = await widget.read(link);
      if (mounted) {
        Navigator.of(context).pop(definition);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = compactError(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _reading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.quickEdit,
      actions: [
        TextButton(
          onPressed: _reading ? null : _submit,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: 'URI',
          alignLabelWithHint: true,
          hintText: 'vless://…',
          errorText: _error,
          errorMaxLines: 3,
        ),
      ),
    );
  }
}

Future<String> _deleteMessage(
  WidgetRef ref,
  Set<int> ids,
  String fallback,
) async {
  final names = {
    for (final proxy
        in ref.read(customProxiesProvider).value ?? const <CustomProxy>[])
      if (ids.contains(proxy.id)) proxy.name,
  };
  final users = await ref
      .read(profilesActionProvider.notifier)
      .proxyUsers(names);
  if (users.isEmpty) {
    return fallback;
  }
  return currentAppLocalizations.providerInUse(
    names.join(', '),
    users.map((profile) => profile.realLabel).join(', '),
  );
}

Future<bool> _handleSaveCustomProxy(
  BuildContext context,
  WidgetRef ref, {
  required ValueChanged<String> onCoreRejected,
}) async {
  final proxy = ref.read(customProxyProvider);
  // A source still loading reads as empty below and would pass any name.
  Set<String> groupNames = const {};
  try {
    (_, groupNames) = await (
      ref.read(customProxiesProvider.future),
      ref.read(customGroupNamesProvider.future),
    ).wait;
  } catch (_) {}
  if (!context.mounted) {
    return false;
  }
  final issues = customProxyIssues(
    proxy,
    proxies: ref.read(customProxiesProvider).value ?? const [],
    groupNames: groupNames,
  );
  if (issues.isEmpty) {
    try {
      final errors = await ref.read(coreHandlerProvider).validateProxies([
        proxy.definition,
      ]);
      if (errors.first.isNotEmpty) {
        issues.add(CustomIssue.coreRejected(errors.first));
      }
    } catch (error) {
      issues.add(CustomIssue.coreRejected(compactError(error)));
    }
  }
  if (!context.mounted) {
    return false;
  }
  // The form stays editable while the core checks the proxy.
  if (!identical(ref.read(customProxyProvider), proxy)) {
    return _handleSaveCustomProxy(context, ref, onCoreRejected: onCoreRejected);
  }
  if (issues.isNotEmpty) {
    if (issues case [CoreRejectedIssue(:final message)]) {
      onCoreRejected(message);
    }
    await showSaveBlocked(context, issues.getMessage(context));
    return false;
  }
  final saved = proxy.id == -1 ? proxy.copyWith(id: snowflake.id) : proxy;
  ref.read(customProxiesProvider.notifier).put(saved);
  // The closing form would otherwise take its stored copy for another proxy
  // with its name.
  ref.read(customProxyProvider.notifier).value = saved;
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

  late final bool _isNew;
  Timer? _validateTimer;
  int _validateRequest = 0;
  String? _coreError;
  bool _saving = false;
  bool _submitted = false;
  var _revealed = <String>{};
  late Set<ProxyField> _shown;

  /// Added options not given a value since, the only ones a save keeps empty.
  late Set<ProxyField> _untouched;

  /// Bumped when the whole mapping is replaced, so the fields drop the text
  /// they were initialized with.
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    final proxy = ref.read(customProxyProvider);
    _isNew = proxy.id == -1;
    _shown = _shownIn(proxy);
    _untouched = {
      for (final field in proxy.emptyOptions)
        if (proxy.valueOf(field) == null) field,
    };
    NestedFormSheet.bindSave(context, _handleSave);
    ref.listenManual(customProxyProvider, (_, proxy) {
      _untouched.removeWhere((field) => proxy.valueOf(field) != null);
    });
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

  Future<void> _handleQuickEdit() async {
    final appLocalizations = context.appLocalizations;
    final core = ref.read(coreHandlerProvider);
    var link = '';
    try {
      link = (await core.encodeShareLinks([
        ref.read(customProxyProvider).definition,
      ])).single;
    } catch (_) {}
    if (!mounted) {
      return;
    }
    final definition = await dialogs.showCommonDialog<Map<String, dynamic>>(
      child: _ShareLinkDialog(
        initialLink: link,
        read: (text) async {
          final results = await core.decodeShareLinks([
            text,
            if (link.isNotEmpty) link,
          ]);
          final definitions = results.first;
          if (definitions.isEmpty) {
            throw MessageException(appLocalizations.shareLinksInvalid);
          }
          if (definitions.length > 1) {
            throw MessageException(appLocalizations.singleShareLinkOnly);
          }
          return withUnlinkedFields(
            definitions.single,
            previous: ref.read(customProxyProvider).definition,
            linked: results.skip(1).firstOrNull?.singleOrNull,
          );
        },
      ),
    );
    if (definition == null || !mounted) {
      return;
    }
    _fillFromLink(definition);
  }

  void _fillFromLink(Map<String, dynamic> definition) {
    final current = ref.read(customProxyProvider);
    final named = (definition['name'] ?? '') == '' && current.name.isNotEmpty
        ? {...definition, 'name': current.name}
        : importedCustomProxies(
            [definition],
            groupNames: ref.read(customGroupNamesProvider).value ?? const {},
            existing: [
              for (final proxy in ref.read(customProxiesProvider).value ?? [])
                if (proxy.id != current.id) proxy,
            ],
          ).single.definition;
    final next = _withShown(current.copyWith(definition: named), {
      for (final field in _shown)
        if (current.valueOf(field) == null) field,
    });
    ref.read(customProxyProvider.notifier).value = next;
    setState(() {
      _shown = _shownIn(next);
      _revision++;
    });
  }

  static Set<ProxyField> _shownIn(CustomProxy proxy) => {
    for (final field in proxy.options)
      if (proxy.valueOf(field) != null || proxy.emptyOptions.contains(field))
        field,
  };

  CustomProxy _withShown(CustomProxy proxy, Set<ProxyField> shown) =>
      proxy.copyWith(
        emptyOptions: {
          for (final field in shown)
            if (proxy.valueOf(field) == null && _untouched.contains(field))
              field,
        },
      );

  /// Keeps a row for every option [proxy] offers that has a value, was shown,
  /// or was [unlocked] by the change that led to [proxy].
  void _syncShown(
    CustomProxy proxy, {
    Iterable<ProxyField> unlocked = const [],
  }) {
    final shown = {
      for (final field in proxy.options)
        if (_shown.contains(field) ||
            unlocked.contains(field) ||
            proxy.valueOf(field) != null)
          field,
    };
    _untouched.addAll(unlocked.where((field) => proxy.valueOf(field) == null));
    ref.read(customProxyProvider.notifier).value = _withShown(proxy, shown);
    setState(() {
      _shown = shown;
    });
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

  void _updateField(ProxyField field, Object? value) {
    ref
        .read(customProxyProvider.notifier)
        .update((state) => state.withField(field, value));
  }

  String? _requiredHint(CustomProxy proxy, String key) =>
      proxy.requiredKeys.contains(key)
      ? context.appLocalizations.required
      : null;

  void _updateOption(ProxyField field, Object? value) {
    final proxy = ref.read(customProxyProvider);
    final next = proxy.withField(field, value);
    final offered = proxy.options;
    _syncShown(
      next,
      unlocked: [
        for (final option in next.options)
          if (!offered.contains(option)) option,
      ],
    );
  }

  Widget _buildTextItem({
    required String title,
    required String key,
    required String? value,
    required int maxLength,
    String? hintText,
    bool digitsOnly = false,
    bool policyName = false,
    bool invalid = false,
    bool obscureText = false,
    Widget? leading,
    Widget? suffix,
    ValueChanged<Object?>? onChanged,
  }) {
    final update = onChanged ?? (Object? value) => _update(key, value);
    final field = TextFormField(
      key: ValueKey('$key-$_revision'),
      initialValue: value,
      textAlign: TextAlign.end,
      obscureText: obscureText,
      keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
      inputFormatters: digitsOnly
          ? TextInputLimits.digitsOnly(maxLength)
          : policyName
          ? TextInputLimits.policyName(maxLength)
          : TextInputLimits.limit(maxLength),
      onChanged: (value) {
        update(digitsOnly ? int.tryParse(value) : value);
      },
      decoration: InputDecoration.collapsed(
        border: const NoInputBorder(),
        hintText: hintText ?? context.appLocalizations.optional,
      ),
    );
    return FormRow(
      title: title,
      invalid: invalid,
      leading: leading,
      trailing: suffix == null
          ? field
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: field),
                suffix,
              ],
            ),
    );
  }

  Widget _buildSecretItem({
    required String title,
    required String key,
    required String? value,
    String? hintText,
    Widget? leading,
    ValueChanged<Object?>? onChanged,
  }) {
    final appLocalizations = context.appLocalizations;
    final revealed = _revealed.contains(key);
    return _buildTextItem(
      title: title,
      key: key,
      value: value,
      maxLength: TextInputLimits.password,
      hintText: hintText,
      obscureText: !revealed,
      leading: leading,
      onChanged: onChanged,
      suffix: CommonMinIconButtonTheme(
        child: IconButton(
          tooltip: revealed
              ? appLocalizations.hidePassword
              : appLocalizations.showPassword,
          onPressed: () {
            setState(() {
              _revealed = {..._revealed}..addOrRemove(key);
            });
          },
          icon: GlyphIcon(revealed ? AppGlyphs.eyeOff : AppGlyphs.eye),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? leading,
  }) {
    return FormRow(
      title: title,
      leading: leading,
      onPressed: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildField(CustomProxy proxy, ProxyField field, {Widget? leading}) {
    final appLocalizations = context.appLocalizations;
    final title = field.label(appLocalizations);
    final key = field.path.join('.');
    final value = proxy.valueOf(field);
    final hintText = _requiredHint(proxy, key);
    void update(Object? value) => _updateField(field, value);
    return switch (field.kind) {
      ProxyFieldKind.text || ProxyFieldKind.number => _buildTextItem(
        title: title,
        key: key,
        value: value?.toString(),
        maxLength: field.maxLength,
        hintText: field.hintText ?? hintText,
        digitsOnly: field.kind == ProxyFieldKind.number,
        leading: leading,
        onChanged: update,
      ),
      ProxyFieldKind.secret => _buildSecretItem(
        title: title,
        key: key,
        value: value?.toString(),
        hintText: hintText,
        leading: leading,
        onChanged: update,
      ),
      ProxyFieldKind.toggle => _buildSwitchItem(
        title: title,
        value: value == true,
        leading: leading,
        onChanged: update,
      ),
      ProxyFieldKind.choice => _buildPickerItem(
        title: title,
        value: value?.toString() ?? hintText ?? appLocalizations.optional,
        leading: leading,
        onPressed: () => _handleSelectChoice(field),
      ),
      ProxyFieldKind.list => _buildListItem(
        proxy,
        title: title,
        key: key,
        itemMaxLength: field.maxLength,
        leading: leading,
      ),
    };
  }

  Future<void> _handleSelectType() async {
    final res = await _selectChoice(
      title: context.appLocalizations.proxyType,
      items: customProxyTypes,
      selectedOf: (state) => state.type,
    );
    if (res == null) {
      return;
    }
    _syncShown(ref.read(customProxyProvider).withType(res));
  }

  Future<void> _handleSelectChoice(ProxyField field) async {
    final res = await _selectChoice(
      title: field.label(context.appLocalizations),
      items: ref.read(customProxyProvider).choicesOf(field),
      selectedOf: (state) => state.valueOf(field)?.toString(),
    );
    if (res == null) {
      return;
    }
    _updateOption(field, res);
  }

  Future<String?> _selectChoice({
    required String title,
    required List<String> items,
    required String? Function(CustomProxy state) selectedOf,
  }) {
    return Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => SelectionSheet<String>(
          title: title,
          sections: [SelectionSection(items: items)],
          labelBuilder: (item) => item,
          selectedOf: (ref) =>
              ref.watch(customProxyProvider.select(selectedOf)),
          onSelected: (item) => Navigator.of(context).pop(item),
        ),
      ),
    );
  }

  Widget _buildPickerItem({
    required String title,
    required String value,
    required VoidCallback onPressed,
    Widget? leading,
  }) {
    return FormRow(
      title: title,
      leading: leading,
      onPressed: onPressed,
      trailing: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              value,
              style: context.listTitleStyle?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const GlyphIcon(AppGlyphs.chevronForward),
        ],
      ),
    );
  }

  Widget _buildTypeItem(String type) {
    return _buildPickerItem(
      title: context.appLocalizations.proxyType,
      value: type,
      onPressed: _handleSelectType,
    );
  }

  Widget _buildListItem(
    CustomProxy proxy, {
    required String title,
    required String key,
    required int itemMaxLength,
    Widget? leading,
  }) {
    final appLocalizations = context.appLocalizations;
    final items = proxy.stringsOf(key);
    return _buildPickerItem(
      title: title,
      value: items.isEmpty
          ? appLocalizations.none
          : appLocalizations.itemsCount(items.length),
      leading: leading,
      onPressed: () => Navigator.of(context).push(
        PagedSheetRoute<void>(
          builder: (_) => _ProxyValuesView(
            title: title,
            field: key,
            itemMaxLength: itemMaxLength,
          ),
        ),
      ),
    );
  }

  void _handleAddOption(List<ProxyField> fields) {
    final appLocalizations = context.appLocalizations;
    final sections = {
      for (final section in _OptionSection.values)
        section: [
          for (final field in fields)
            if (field.section == section) field,
        ],
    };
    Navigator.of(context).push(
      PagedSheetRoute(
        builder: (_) => SelectionSheet<ProxyField>(
          title: appLocalizations.addSettingEntry,
          sections: [
            for (final MapEntry(:key, :value) in sections.entries)
              if (value.isNotEmpty)
                SelectionSection(
                  label: key.label(appLocalizations),
                  items: value,
                ),
          ],
          labelBuilder: (field) => field.label(appLocalizations),
          selectedOf: (_) => null,
          removeOnSelect: true,
          onSelected: _handleAddedOption,
        ),
      ),
    );
  }

  void _handleAddedOption(ProxyField field) {
    if (!mounted) {
      return;
    }
    final proxy = ref.read(customProxyProvider);
    final initial = switch (field.kind) {
      ProxyFieldKind.toggle => true,
      ProxyFieldKind.choice => proxy.choicesOf(field).firstOrNull,
      _ => null,
    };
    final value = proxy.valueOf(field) ?? initial;
    _shown = {..._shown, field};
    if (value == null) {
      _untouched.add(field);
    }
    _updateOption(field, value);
  }

  void _handleRemoveOption(ProxyField field) {
    _shown = {..._shown}..remove(field);
    _updateOption(field, null);
  }

  Widget _buildOptions(CustomProxy proxy) {
    final appLocalizations = context.appLocalizations;
    final options = proxy.options;
    final remaining = [
      for (final field in options)
        if (!_shown.contains(field)) field,
    ];
    void handleAdd() => _handleAddOption(remaining);
    return generateAnimatedSection(
      title: appLocalizations.options,
      items: [
        for (final field in options)
          if (_shown.contains(field))
            KeyedSubtree(
              key: ValueKey(field),
              child: _buildField(
                proxy,
                field,
                leading: EntryButton.remove(
                  onPressed: () => _handleRemoveOption(field),
                ),
              ),
            ),
        if (remaining.isNotEmpty)
          FormRow(
            key: const ValueKey(#add),
            leading: EntryButton.add(onPressed: handleAdd),
            title: appLocalizations.addSettingEntry,
            titleStyle: TextStyle(color: context.colorScheme.primary),
            onPressed: handleAdd,
          ),
      ],
    );
  }

  Widget _buildEasyTierSection(CustomProxy proxy) {
    final appLocalizations = context.appLocalizations;
    final definition = proxy.definition;
    return generateSectionV3(
      title: appLocalizations.network,
      items: [
        _buildTextItem(
          title: appLocalizations.networkName,
          key: 'network-name',
          value: definition['network-name']?.toString(),
          maxLength: TextInputLimits.name,
          hintText: appLocalizations.networkName,
        ),
        _buildSecretItem(
          title: appLocalizations.networkSecret,
          key: 'network-secret',
          value: definition['network-secret']?.toString(),
        ),
        _buildListItem(
          proxy,
          title: appLocalizations.peers,
          key: 'peers',
          itemMaxLength: TextInputLimits.uri,
        ),
        _buildTextItem(
          title: appLocalizations.virtualIpv4,
          key: 'ipv4',
          value: definition['ipv4']?.toString(),
          maxLength: TextInputLimits.cidr,
          hintText: 'DHCP',
        ),
        _buildTextItem(
          title: appLocalizations.hostname,
          key: 'hostname',
          value: definition['hostname']?.toString(),
          maxLength: TextInputLimits.domain,
        ),
        _buildListItem(
          proxy,
          title: appLocalizations.exitNodes,
          key: 'exit-nodes',
          itemMaxLength: TextInputLimits.cidr,
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
    final appLocalizations = context.appLocalizations;
    final id = ref.read(customProxyProvider).id;
    final message = await _deleteMessage(ref, {
      id,
    }, appLocalizations.deleteTip(appLocalizations.proxies));
    if (!mounted) {
      return;
    }
    final res = await dialogs.showMessage(message: TextSpan(text: message));
    if (res == true && mounted) {
      ref.read(customProxiesProvider.notifier).delAll([id]);
      context.safeNestedPop();
    }
  }

  Future<void> _handleSave() async {
    if (_saving) return;
    _saving = true;
    ref
        .read(customProxyProvider.notifier)
        .update((state) => _withShown(state, _shown));
    try {
      String? coreError;
      final saved = await _handleSaveCustomProxy(
        context,
        ref,
        onCoreRejected: (message) => coreError = message,
      );
      if (!mounted) return;
      if (saved) {
        context.safeNestedPop();
        return;
      }
      setState(() {
        _submitted = true;
        _coreError = coreError ?? _coreError;
      });
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final proxy = ref.watch(customProxyProvider);
    final showIncomplete = !_isNew || _submitted;
    final issues = [
      ...customProxyIssues(
        proxy,
        proxies: ref.watch(customProxiesProvider).value ?? const [],
        groupNames: ref.watch(customGroupNamesProvider).value ?? const {},
      ),
      if (_coreError != null) CustomIssue.coreRejected(_coreError!),
    ].where((issue) => showIncomplete || !issue.isIncomplete).toList();
    final nameInvalid = issues.any(
      (issue) =>
          issue is EmptyNameIssue ||
          issue is ReservedNameIssue ||
          issue is DuplicateNameIssue,
    );
    final easyTier = proxy.type == 'easytier';
    final fields = proxy.fields;
    return CommonScaffold(
      iconActions: customFormActions(
        context,
        onQuickEdit: _handleQuickEdit,
        onSave: _handleSave,
      ),
      body: CustomScrollView(
        slivers: [
          SliverCustomIssuesBanner(issues: issues),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: 20),
            sliver: SliverList.list(
              children: [
                generateSectionV3(
                  title: appLocalizations.basicInfo,
                  items: [
                    _buildTextItem(
                      title: appLocalizations.name,
                      key: 'name',
                      value: proxy.name,
                      maxLength: TextInputLimits.proxyName,
                      hintText: appLocalizations.name,
                      policyName: true,
                      invalid: nameInvalid,
                    ),
                    _buildTypeItem(proxy.type),
                    if (!easyTier) ...[
                      _buildTextItem(
                        title: appLocalizations.server,
                        key: 'server',
                        value: proxy.server,
                        maxLength: TextInputLimits.domain,
                        hintText: _requiredHint(proxy, 'server'),
                      ),
                      _buildTextItem(
                        title: appLocalizations.port,
                        key: 'port',
                        value: proxy.port?.toString(),
                        maxLength: TextInputLimits.port,
                        hintText: _requiredHint(proxy, 'port'),
                        digitsOnly: true,
                      ),
                    ],
                    for (final field in fields)
                      if (!field.isCredential) _buildField(proxy, field),
                    _buildSwitchItem(
                      title: 'UDP',
                      value: proxy.definition['udp'] == true,
                      onChanged: (value) => _update('udp', value),
                    ),
                  ],
                ),
                if (easyTier) _buildEasyTierSection(proxy),
                generateSectionV3(
                  title: appLocalizations.authentication,
                  items: [
                    for (final field in fields)
                      if (field.isCredential) _buildField(proxy, field),
                  ],
                ),
                _buildOptions(proxy),
                generateSectionV3(
                  title: appLocalizations.action,
                  items: [
                    if (!_isNew)
                      FormRow(
                        title: appLocalizations.delete,
                        titleStyle: TextStyle(color: context.colorScheme.error),
                        onPressed: _handleDelete,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      title: _isNew
          ? appLocalizations.addCustomProxy
          : appLocalizations.editProxy,
    );
  }
}

/// Writes each change straight into the form, since a sheet page's back
/// button pops it without a result.
class _ProxyValuesView extends ConsumerWidget {
  final String title;
  final String field;
  final int itemMaxLength;

  const _ProxyValuesView({
    required this.title,
    required this.field,
    required this.itemMaxLength,
  });

  List<String> _valuesOf(WidgetRef ref) =>
      ref.read(customProxyProvider).stringsOf(field);

  void _save(WidgetRef ref, List<String> values) {
    ref
        .read(customProxyProvider.notifier)
        .update(
          (state) => state.withValue(field, values.isEmpty ? null : values),
        );
  }

  Future<void> _handleAddOrUpdate(
    BuildContext context,
    WidgetRef ref, [
    String? value,
  ]) async {
    final res = await showListEntryDialog(
      context,
      title: title,
      entries: _valuesOf(ref),
      entry: value,
      itemMaxLength: itemMaxLength,
    );
    if (res == null || res.isEmpty || !context.mounted) {
      return;
    }
    final values = _valuesOf(ref);
    _save(
      ref,
      value == null
          ? [...values, ...res]
          : [for (final item in values) item == value ? res.single : item],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListEditorPage<String, String>(
      title: title,
      selectionEnabled: true,
      idOf: (value) => value,
      itemsOf: (ref) => ref.watch(
        customProxyProvider.select((state) => state.stringsOf(field)),
      ),
      itemBuilder:
          (
            context,
            ref,
            value,
            index,
            isEditing,
            isSelected,
            onToggleSelected,
          ) => SelectedDecorationListItem(
            title: Text(value),
            isEditing: isEditing,
            isSelected: isSelected,
            onSelected: onToggleSelected,
            onPressed: () => _handleAddOrUpdate(context, ref, value),
          ),
      onReorder: (oldIndex, newIndex) =>
          _save(ref, _valuesOf(ref).copyAndReorder(oldIndex, newIndex)),
      onAdd: () => _handleAddOrUpdate(context, ref),
      onDelete: (values) => _save(ref, [
        for (final value in _valuesOf(ref))
          if (!values.contains(value)) value,
      ]),
      emptyLabel: context.appLocalizations.nullTip(title),
    );
  }
}
