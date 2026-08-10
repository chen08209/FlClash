import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _existingNodeType = 'existing';
const _savedNodeType = 'saved';
const _proxyProtocolTypes = ['socks5', 'http', 'https'];

class _ProfileProxyItem {
  final Proxy proxy;
  final String? provider;

  const _ProfileProxyItem({required this.proxy, this.provider});
}

List<_ProfileProxyItem> _getProfileProxyItems(WidgetRef ref, int profileId) {
  final staticProxies =
      ref.read(clashConfigProvider(profileId)).value?.proxies ?? const [];
  final groups = ref.read(groupsProvider);
  final groupNames = groups.map((group) => group.name).toSet();
  final proxyByName = <String, Proxy>{
    for (final proxy in staticProxies) proxy.name: proxy,
    for (final proxy in groups.expand((group) => group.all))
      if (!groupNames.contains(proxy.name) &&
          !const {
            'DIRECT',
            'REJECT',
            'REJECT-DROP',
            'PASS',
            'COMPATIBLE',
          }.contains(proxy.name))
        proxy.name: proxy,
  };
  final providers = ref.read(providersProvider);
  final providerProxyNames = providers
      .expand((provider) => provider.proxies)
      .toSet();
  return [
    for (final proxy in proxyByName.values)
      if (!providerProxyNames.contains(proxy.name))
        _ProfileProxyItem(proxy: proxy),
    for (final provider in providers)
      for (final proxyName in provider.proxies)
        _ProfileProxyItem(
          proxy:
              proxyByName[proxyName] ??
              Proxy(name: proxyName, type: provider.type),
          provider: provider.name,
        ),
  ];
}

class ChainProxyManagerView extends ConsumerStatefulWidget {
  final int profileId;

  const ChainProxyManagerView({super.key, required this.profileId});

  @override
  ConsumerState<ChainProxyManagerView> createState() =>
      _ChainProxyManagerViewState();
}

class _ChainProxyManagerViewState extends ConsumerState<ChainProxyManagerView> {
  final _searchController = TextEditingController();
  int _tabIndex = 0;
  String? _protocolFilter;

  String _describeNode(ChainProxyNode node, Map<int, SavedProxy> savedProxies) {
    if (node.type == _existingNodeType) {
      final provider = node.provider;
      return provider == null
          ? node.proxy ?? ''
          : '${node.proxy ?? ''} ($provider)';
    }
    if (node.type == _savedNodeType) {
      final proxy = savedProxies[node.savedProxyId];
      if (proxy == null) return '';
      return '${proxy.name} (${proxy.type.toUpperCase()} '
          '${proxy.server}:${proxy.port})';
    }
    return '${node.type.toUpperCase()} ${node.server}:${node.port}';
  }

  String _describeChain(ProxyGroup chain, Map<int, SavedProxy> savedProxies) {
    final nodes = chain.chainNodes;
    if (nodes != null && nodes.isNotEmpty) {
      return nodes.map((node) => _describeNode(node, savedProxies)).join(' → ');
    }
    return (chain.proxies ?? []).join(' → ');
  }

  void _openEditor(BuildContext context, [ProxyGroup? chain]) {
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_) => ChainProxyView(profileId: widget.profileId, chain: chain),
    );
  }

  void _openSavedProxyEditor(BuildContext context, [SavedProxy? proxy]) {
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_) => SavedProxyView(profileId: widget.profileId, proxy: proxy),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(String value) {
    final query = _searchController.text.trim().toLowerCase();
    return query.isEmpty || value.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final chains =
        ref
            .watch(proxyGroupsProvider(widget.profileId))
            .value
            ?.where((item) => item.type == GroupType.Relay)
            .toList() ??
        [];
    final savedProxyList = ref.watch(savedProxiesProvider);
    final savedProxies = {for (final proxy in savedProxyList) proxy.id: proxy};
    final filteredProxies = savedProxyList.where((proxy) {
      final matchesProtocol =
          _protocolFilter == null || proxy.type == _protocolFilter;
      return matchesProtocol &&
          _matches('${proxy.name} ${proxy.type} ${proxy.server} ${proxy.port}');
    }).toList();
    final filteredChains = chains
        .where(
          (chain) =>
              _matches('${chain.name} ${_describeChain(chain, savedProxies)}'),
        )
        .toList();
    final showProxies = _tabIndex == 0;
    final itemsLength = showProxies
        ? filteredProxies.length
        : filteredChains.length;
    return AdaptiveSheetScaffold(
      title: context.appLocalizations.chainProxyManager,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              context.sheetTopPadding + 8,
              16,
              8,
            ),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  icon: const Icon(Icons.dns_outlined),
                  label: Text(
                    '${context.appLocalizations.proxyNodesTab} '
                    '(${savedProxyList.length})',
                  ),
                ),
                ButtonSegment(
                  value: 1,
                  icon: const Icon(Icons.account_tree_outlined),
                  label: Text(
                    '${context.appLocalizations.proxyChainsTab} '
                    '(${chains.length})',
                  ),
                ),
              ],
              selected: {_tabIndex},
              showSelectedIcon: false,
              onSelectionChanged: (value) {
                setState(() => _tabIndex = value.first);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: context.appLocalizations.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          if (showProxies)
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(context.appLocalizations.allItems),
                    selected: _protocolFilter == null,
                    onSelected: (_) => setState(() => _protocolFilter = null),
                  ),
                  const SizedBox(width: 8),
                  for (final type in _proxyProtocolTypes) ...[
                    FilterChip(
                      label: Text(type.toUpperCase()),
                      selected: _protocolFilter == type,
                      onSelected: (_) {
                        setState(() => _protocolFilter = type);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: showProxies
                    ? () => _openSavedProxyEditor(context)
                    : () => _openEditor(context),
                icon: const Icon(Icons.add),
                label: Text(
                  showProxies
                      ? context.appLocalizations.addProxyNode
                      : context.appLocalizations.addProxyChain,
                ),
              ),
            ),
          ),
          Expanded(
            child: itemsLength == 0
                ? Center(
                    child: Text(
                      _searchController.text.isNotEmpty ||
                              (showProxies && _protocolFilter != null)
                          ? context.appLocalizations.noData
                          : showProxies
                          ? context.appLocalizations.savedProxyEmpty
                          : context.appLocalizations.chainProxyEmpty,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    itemCount: itemsLength,
                    itemBuilder: (_, index) {
                      if (showProxies) {
                        final proxy = filteredProxies[index];
                        return ListTile(
                          leading: const Icon(Icons.dns_outlined),
                          title: Text(
                            proxy.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${proxy.type.toUpperCase()} · '
                            '${proxy.server}:${proxy.port}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openSavedProxyEditor(context, proxy),
                        );
                      }
                      final chain = filteredChains[index];
                      return ListTile(
                        leading: const Icon(Icons.account_tree_outlined),
                        title: Text(
                          chain.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _describeChain(chain, savedProxies),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openEditor(context, chain),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SavedProxyView extends ConsumerStatefulWidget {
  final int profileId;
  final SavedProxy? proxy;

  const SavedProxyView({super.key, required this.profileId, this.proxy});

  @override
  ConsumerState<SavedProxyView> createState() => _SavedProxyViewState();
}

class _SavedProxyViewState extends ConsumerState<SavedProxyView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _serverController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late String _type;

  @override
  void initState() {
    super.initState();
    final proxy = widget.proxy;
    _type = proxy?.type ?? 'socks5';
    _nameController = TextEditingController(text: proxy?.name);
    _serverController = TextEditingController(text: proxy?.server);
    _portController = TextEditingController(text: proxy?.port.toString());
    _usernameController = TextEditingController(text: proxy?.username);
    _passwordController = TextEditingController(text: proxy?.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _applySavedProxyChange(
    List<SavedProxy> previous,
    List<SavedProxy> candidate,
  ) async {
    final setupAction = ref.read(setupActionProvider.notifier);
    await setupAction.validateChainProxyProfile(
      profileId: widget.profileId,
      savedProxies: candidate,
      enabled: true,
    );
    ref.read(savedProxiesProvider.notifier).value = candidate;
    try {
      await preferences.saveConfig(ref.read(configProvider));
      ref.invalidate(setupStateProvider(widget.profileId));
      await setupAction.applyProfile(force: true);
    } catch (error, stackTrace) {
      ref.read(savedProxiesProvider.notifier).value = previous;
      await preferences.saveConfig(ref.read(configProvider));
      ref.invalidate(setupStateProvider(widget.profileId));
      try {
        await setupAction.applyProfile(force: true, silence: true);
      } catch (rollbackError) {
        commonPrint.log('Unable to restore proxy config: $rollbackError');
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final name = _nameController.text.trim();
    final duplicate = ref
        .read(savedProxiesProvider)
        .any((item) => item.name == name && item.id != widget.proxy?.id);
    if (duplicate) {
      globalState.showNotifier(
        context.appLocalizations.savedProxyNameDuplicate,
      );
      return;
    }
    final proxy = SavedProxy(
      id: widget.proxy?.id ?? snowflake.id,
      name: name,
      type: _type,
      server: _serverController.text.trim(),
      port: int.parse(_portController.text),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
    final previous = ref.read(savedProxiesProvider);
    final candidate = previous.copyAndPut(proxy, (item) => item.id == proxy.id);
    await _applySavedProxyChange(previous, candidate);
    if (!mounted) return;
    globalState.showNotifier(context.appLocalizations.savedProxySaved);
    context.safeNestedPop();
  }

  Future<void> _delete() async {
    final proxy = widget.proxy;
    if (proxy == null) return;
    final groups = await database.proxyGroupsDao.queryAll().get();
    final isUsed = groups.any(
      (group) =>
          group.chainNodes?.any((node) => node.savedProxyId == proxy.id) ==
          true,
    );
    if (!mounted) return;
    if (isUsed) {
      globalState.showNotifier(context.appLocalizations.savedProxyInUse);
      return;
    }
    final confirmed = await globalState.showMessage(
      message: TextSpan(text: context.appLocalizations.confirmDeleteSavedProxy),
    );
    if (confirmed != true) return;
    final previous = ref.read(savedProxiesProvider);
    final candidate = previous.where((item) => item.id != proxy.id).toList();
    await _applySavedProxyChange(previous, candidate);
    if (mounted) context.safeNestedPop();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return AdaptiveSheetScaffold(
      title: appLocalizations.savedProxy,
      actions: [
        if (widget.proxy != null)
          IconButtonData(icon: Icons.delete_outline, onPressed: _delete),
        IconButtonData(icon: Icons.save_outlined, onPressed: _save),
      ],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            context.sheetTopPadding + 12,
            20,
            32,
          ),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.name,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? appLocalizations.emptyTip(appLocalizations.name)
                  : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: _proxyProtocolTypes
                  .map(
                    (type) => ButtonSegment(
                      value: type,
                      label: Text(type.toUpperCase()),
                    ),
                  )
                  .toList(),
              selected: {_type},
              showSelectedIcon: false,
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serverController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.host,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? appLocalizations.emptyTip(appLocalizations.host)
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.port,
              ),
              validator: (value) {
                final port = int.tryParse(value ?? '');
                return port == null || port < 1 || port > 65535
                    ? appLocalizations.portTip(appLocalizations.port)
                    : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.username,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.password,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChainProxyView extends ConsumerStatefulWidget {
  final int profileId;
  final ProxyGroup? chain;

  const ChainProxyView({super.key, required this.profileId, this.chain});

  @override
  ConsumerState<ChainProxyView> createState() => _ChainProxyViewState();
}

class _ChainProxyViewState extends ConsumerState<ChainProxyView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final List<_ChainNodeFormState> _nodes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chain?.name ?? '');
    final configuredNodes = widget.chain?.chainNodes;
    final legacyNodes = widget.chain?.proxies ?? [];
    _nodes = configuredNodes?.isNotEmpty == true
        ? configuredNodes!.map(_ChainNodeFormState.fromNode).toList()
        : legacyNodes
              .map((proxy) => _ChainNodeFormState(proxy: proxy))
              .toList();
    while (_nodes.length < 2) {
      _nodes.add(_ChainNodeFormState());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final proxies = _getProfileProxyItems(ref, widget.profileId);
    final savedProxies = ref.read(savedProxiesProvider);
    final invalidNodeIndex = _nodes.indexWhere(
      (node) => !node.isValid(proxies: proxies, savedProxies: savedProxies),
    );
    if (invalidNodeIndex != -1) {
      globalState.showNotifier(
        context.appLocalizations.chainNodeInvalid(invalidNodeIndex + 1),
      );
      return;
    }
    final name = _nameController.text.trim();
    final groups = await database.proxyGroupsDao.query(widget.profileId).get();
    if (!mounted) return;
    final duplicate = groups.any(
      (item) => item.name == name && item.id != widget.chain?.id,
    );
    if (duplicate) {
      globalState.showNotifier(
        context.appLocalizations.proxyGroupNameDuplicate,
      );
      return;
    }
    final chain = ProxyGroup(
      profileId: widget.profileId,
      id: widget.chain?.id ?? snowflake.id,
      name: name,
      type: GroupType.Relay,
      proxies: _nodes
          .where((node) => node.type == _existingNodeType)
          .map((node) => node.proxy!)
          .toList(),
      chainNodes: _nodes.map((node) => node.toNode()).toList(),
      order: widget.chain?.order,
    );
    final candidateGroups = groups.copyAndPut(
      chain,
      (item) => item.id == chain.id,
    );
    final setupAction = ref.read(setupActionProvider.notifier);
    await setupAction.validateChainProxyProfile(
      profileId: widget.profileId,
      proxyGroups: candidateGroups,
      enabled: true,
    );
    await database.proxyGroups.put(chain.toCompanion(widget.profileId));
    try {
      ref.invalidate(proxyGroupsProvider(widget.profileId));
      ref.invalidate(setupStateProvider(widget.profileId));
      await setupAction.applyProfile(force: true);
    } catch (error, stackTrace) {
      final previous = widget.chain;
      if (previous == null) {
        await database.proxyGroups.remove((row) => row.id.equals(chain.id));
      } else {
        await database.proxyGroups.put(previous.toCompanion(widget.profileId));
      }
      ref.invalidate(proxyGroupsProvider(widget.profileId));
      ref.invalidate(setupStateProvider(widget.profileId));
      try {
        await setupAction.applyProfile(force: true, silence: true);
      } catch (rollbackError) {
        commonPrint.log('Unable to restore proxy config: $rollbackError');
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    if (!mounted) return;
    globalState.showNotifier(context.appLocalizations.chainProxySaved);
    context.safeNestedPop();
  }

  Future<void> _delete() async {
    final chain = widget.chain;
    if (chain == null) return;
    final confirmed = await globalState.showMessage(
      message: TextSpan(text: context.appLocalizations.confirmDeleteProxyGroup),
    );
    if (confirmed != true) return;
    final groups = await database.proxyGroupsDao.query(widget.profileId).get();
    final candidateGroups = groups
        .where((item) => item.id != chain.id)
        .toList();
    final setupAction = ref.read(setupActionProvider.notifier);
    await setupAction.validateChainProxyProfile(
      profileId: widget.profileId,
      proxyGroups: candidateGroups,
      enabled: true,
    );
    await database.proxyGroups.remove((row) => row.id.equals(chain.id));
    try {
      ref.invalidate(proxyGroupsProvider(widget.profileId));
      ref.invalidate(setupStateProvider(widget.profileId));
      await setupAction.applyProfile(force: true);
    } catch (error, stackTrace) {
      await database.proxyGroups.put(chain.toCompanion(widget.profileId));
      ref.invalidate(proxyGroupsProvider(widget.profileId));
      ref.invalidate(setupStateProvider(widget.profileId));
      try {
        await setupAction.applyProfile(force: true, silence: true);
      } catch (rollbackError) {
        commonPrint.log('Unable to restore proxy config: $rollbackError');
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    if (mounted) context.safeNestedPop();
  }

  void _addNode() {
    setState(() => _nodes.add(_ChainNodeFormState()));
  }

  void _removeNode(int index) {
    if (_nodes.length <= 2) return;
    final node = _nodes.removeAt(index);
    node.dispose();
    setState(() {});
  }

  void _reorderNode(int oldIndex, int newIndex) {
    final node = _nodes.removeAt(oldIndex);
    _nodes.insert(newIndex, node);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    ref.watch(clashConfigProvider(widget.profileId));
    ref.watch(groupsProvider);
    ref.watch(providersProvider);
    final proxies = _getProfileProxyItems(ref, widget.profileId);
    final savedProxies = ref.watch(savedProxiesProvider);
    return AdaptiveSheetScaffold(
      title: appLocalizations.chainProxyConfig,
      actions: [
        if (widget.chain != null)
          IconButtonData(icon: Icons.delete_outline, onPressed: _delete),
        IconButtonData(icon: Icons.save_outlined, onPressed: _save),
      ],
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                context.sheetTopPadding + 12,
                20,
                12,
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.name,
                  hintText: appLocalizations.chainProxy,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? appLocalizations.proxyGroupNameEmpty
                    : null,
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                itemCount: _nodes.length,
                onReorderItem: _reorderNode,
                itemBuilder: (_, index) {
                  final node = _nodes[index];
                  return _ChainNodeEditor(
                    key: ObjectKey(node),
                    index: index,
                    state: node,
                    proxies: proxies,
                    savedProxies: savedProxies,
                    canRemove: _nodes.length > 2,
                    onRemove: () => _removeNode(index),
                    onChanged: () => setState(() {}),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _addNode,
                  icon: const Icon(Icons.add),
                  label: Text(appLocalizations.addChainNode),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChainNodeEditor extends StatelessWidget {
  final int index;
  final _ChainNodeFormState state;
  final List<_ProfileProxyItem> proxies;
  final List<SavedProxy> savedProxies;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _ChainNodeEditor({
    super.key,
    required this.index,
    required this.state,
    required this.proxies,
    required this.savedProxies,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  String? _selectionLabel() {
    if (state.type == _existingNodeType) {
      final item = proxies
          .where(
            (item) =>
                item.proxy.name == state.proxy &&
                item.provider == state.provider,
          )
          .firstOrNull;
      if (item == null) return null;
      final source = item.provider == null ? '' : ' · ${item.provider}';
      return '${item.proxy.name} · ${item.proxy.type}$source';
    }
    if (state.type == _savedNodeType) {
      final proxy = savedProxies
          .where((item) => item.id == state.savedProxyId)
          .firstOrNull;
      return proxy == null
          ? null
          : '${proxy.name} · ${proxy.type.toUpperCase()} '
                '${proxy.server}:${proxy.port}';
    }
    return '${state.type.toUpperCase()} · '
        '${state.serverController.text}:${state.portController.text}';
  }

  Future<void> _pickNode(BuildContext context) async {
    final result = await showSheet<_ProxyPickerResult>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_) => _ChainNodePickerView(
        proxies: proxies,
        savedProxies: savedProxies,
        initialType: state.type,
        selectedProxy: state.proxy,
        selectedProvider: state.provider,
        selectedSavedProxyId: state.savedProxyId,
      ),
    );
    if (result == null) return;
    state.type = result.type;
    state.proxy = result.proxy;
    state.provider = result.provider;
    state.savedProxyId = result.savedProxyId;
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final selectionLabel = _selectionLabel();
    final isLegacyManual =
        state.type != _existingNodeType && state.type != _savedNodeType;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appLocalizations.chainNodeIndex(index + 1),
                    style: context.textTheme.titleMedium,
                  ),
                ),
                if (canRemove)
                  IconButton(
                    tooltip: appLocalizations.remove,
                    onPressed: onRemove,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ReorderableDragStartListener(
                  index: index,
                  child: Tooltip(
                    message: appLocalizations.sort,
                    child: const SizedBox.square(
                      dimension: 48,
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FormField<String>(
              key: ValueKey(
                '${identityHashCode(state)}-${state.type}-'
                '${state.proxy}-${state.savedProxyId}',
              ),
              initialValue: selectionLabel,
              validator: (_) => selectionLabel == null
                  ? appLocalizations.emptyTip(appLocalizations.selectProxy)
                  : null,
              builder: (field) {
                return InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => _pickNode(context),
                  child: InputDecorator(
                    isEmpty: selectionLabel == null,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.selectProxy,
                      errorText: field.errorText,
                      suffixIcon: const Icon(Icons.chevron_right),
                    ),
                    child: Text(
                      selectionLabel ?? appLocalizations.selectProxy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
            if (isLegacyManual) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: state.serverController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.host,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: state.portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.port,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: state.usernameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.username,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: state.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.password,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProxyPickerResult {
  final String type;
  final String? proxy;
  final String? provider;
  final int? savedProxyId;

  const _ProxyPickerResult({
    required this.type,
    this.proxy,
    this.provider,
    this.savedProxyId,
  });
}

class _ChainNodePickerView extends StatefulWidget {
  final List<_ProfileProxyItem> proxies;
  final List<SavedProxy> savedProxies;
  final String initialType;
  final String? selectedProxy;
  final String? selectedProvider;
  final int? selectedSavedProxyId;

  const _ChainNodePickerView({
    required this.proxies,
    required this.savedProxies,
    required this.initialType,
    required this.selectedProxy,
    required this.selectedProvider,
    required this.selectedSavedProxyId,
  });

  @override
  State<_ChainNodePickerView> createState() => _ChainNodePickerViewState();
}

class _ChainNodePickerViewState extends State<_ChainNodePickerView> {
  final _searchController = TextEditingController();
  late String _sourceType;
  String? _protocolFilter;

  @override
  void initState() {
    super.initState();
    _sourceType = widget.initialType == _savedNodeType
        ? _savedNodeType
        : _existingNodeType;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(String value) {
    final query = _searchController.text.trim().toLowerCase();
    return query.isEmpty || value.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final showSaved = _sourceType == _savedNodeType;
    final proxies = widget.proxies
        .where(
          (item) => _matches(
            '${item.proxy.name} ${item.proxy.type} ${item.provider ?? ''}',
          ),
        )
        .toList();
    final savedProxies = widget.savedProxies.where((proxy) {
      final matchesProtocol =
          _protocolFilter == null || proxy.type == _protocolFilter;
      return matchesProtocol &&
          _matches('${proxy.name} ${proxy.type} ${proxy.server} ${proxy.port}');
    }).toList();
    final itemCount = showSaved ? savedProxies.length : proxies.length;
    return AdaptiveSheetScaffold(
      title: appLocalizations.selectProxy,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              context.sheetTopPadding + 8,
              16,
              8,
            ),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: _existingNodeType,
                  icon: const Icon(Icons.cloud_outlined),
                  label: Text(appLocalizations.profileProxies),
                ),
                ButtonSegment(
                  value: _savedNodeType,
                  icon: const Icon(Icons.dns_outlined),
                  label: Text(appLocalizations.proxyNodesTab),
                ),
              ],
              selected: {_sourceType},
              showSelectedIcon: false,
              onSelectionChanged: (value) {
                setState(() => _sourceType = value.first);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: appLocalizations.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          if (showSaved)
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(appLocalizations.allItems),
                    selected: _protocolFilter == null,
                    onSelected: (_) => setState(() => _protocolFilter = null),
                  ),
                  const SizedBox(width: 8),
                  for (final type in _proxyProtocolTypes) ...[
                    FilterChip(
                      label: Text(type.toUpperCase()),
                      selected: _protocolFilter == type,
                      onSelected: (_) {
                        setState(() => _protocolFilter = type);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          Expanded(
            child: itemCount == 0
                ? Center(child: Text(appLocalizations.noData))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                    itemCount: itemCount,
                    itemBuilder: (_, index) {
                      if (showSaved) {
                        final proxy = savedProxies[index];
                        final selected =
                            proxy.id == widget.selectedSavedProxyId;
                        return ListTile(
                          leading: const Icon(Icons.dns_outlined),
                          title: Text(
                            proxy.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${proxy.type.toUpperCase()} · '
                            '${proxy.server}:${proxy.port}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: selected ? const Icon(Icons.check) : null,
                          onTap: () => context.safeNestedPop(
                            _ProxyPickerResult(
                              type: _savedNodeType,
                              savedProxyId: proxy.id,
                            ),
                          ),
                        );
                      }
                      final item = proxies[index];
                      final proxy = item.proxy;
                      final selected =
                          proxy.name == widget.selectedProxy &&
                          item.provider == widget.selectedProvider;
                      return ListTile(
                        leading: const Icon(Icons.cloud_outlined),
                        title: Text(
                          proxy.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.provider == null
                              ? proxy.type
                              : '${proxy.type} · ${item.provider}',
                        ),
                        trailing: selected ? const Icon(Icons.check) : null,
                        onTap: () => context.safeNestedPop(
                          _ProxyPickerResult(
                            type: _existingNodeType,
                            proxy: proxy.name,
                            provider: item.provider,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChainNodeFormState {
  String type;
  String? proxy;
  String? provider;
  int? savedProxyId;
  final TextEditingController serverController;
  final TextEditingController portController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  _ChainNodeFormState({
    this.type = _existingNodeType,
    this.proxy,
    this.provider,
    this.savedProxyId,
    String? server,
    int? port,
    String? username,
    String? password,
  }) : serverController = TextEditingController(text: server),
       portController = TextEditingController(text: port?.toString()),
       usernameController = TextEditingController(text: username),
       passwordController = TextEditingController(text: password);

  factory _ChainNodeFormState.fromNode(ChainProxyNode node) {
    return _ChainNodeFormState(
      type: node.type,
      proxy: node.proxy,
      provider: node.provider,
      savedProxyId: node.savedProxyId,
      server: node.server,
      port: node.port,
      username: node.username,
      password: node.password,
    );
  }

  ChainProxyNode toNode() {
    if (type == _existingNodeType) {
      return ChainProxyNode(type: type, proxy: proxy, provider: provider);
    }
    if (type == _savedNodeType) {
      return ChainProxyNode(type: type, savedProxyId: savedProxyId);
    }
    return ChainProxyNode(
      type: type,
      server: serverController.text.trim(),
      port: int.parse(portController.text),
      username: usernameController.text.trim(),
      password: passwordController.text,
    );
  }

  bool isValid({
    required List<_ProfileProxyItem> proxies,
    required List<SavedProxy> savedProxies,
  }) {
    if (type == _existingNodeType) {
      return proxy != null &&
          proxies.any(
            (item) => item.proxy.name == proxy && item.provider == provider,
          );
    }
    if (type == _savedNodeType) {
      return savedProxyId != null &&
          savedProxies.any((item) => item.id == savedProxyId);
    }
    final port = int.tryParse(portController.text);
    return serverController.text.trim().isNotEmpty &&
        port != null &&
        port >= 1 &&
        port <= 65535;
  }

  void dispose() {
    serverController.dispose();
    portController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }
}
