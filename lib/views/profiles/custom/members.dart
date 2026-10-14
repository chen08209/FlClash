import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `proxies` names a group's proxies, `use` its providers, `use-position` where
/// those sit among the proxies, and `filter` what of the providers' proxies it
/// takes. `exclude-filter` drops whatever matches it, named members too.
enum _MemberKind {
  proxy,
  provider,
  filter,
  excludeFilter;

  bool get isFilter => this == filter || this == excludeFilter;

  _MemberKind get run => this == provider ? proxy : this;

  (Color, Color) chipColorsOf(ColorScheme colorScheme) => switch (this) {
    proxy || provider => (
      colorScheme.secondaryContainer,
      colorScheme.onSecondaryContainer,
    ),
    filter => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
    excludeFilter => (colorScheme.errorContainer, colorScheme.onErrorContainer),
  };

  List<String> partsOf(String name) => isFilter ? filterParts(name) : [name];

  bool isValid(WidgetRef ref, int profileId, String name) => switch (this) {
    proxy => ref.watch(
      customProfileDataProvider(profileId).select(
        (state) =>
            state == null ||
            state.ruleTargets.contains(name) ||
            state.proxies.contains(name),
      ),
    ),
    provider => ref.watch(
      customProfileProxyProviderIsValidProvider(profileId, name),
    ),
    filter || excludeFilter => true,
  };

  String invalidMessage(BuildContext context, String name) => switch (this) {
    proxy => context.appLocalizations.invalidProxy(name),
    provider => context.appLocalizations.invalidProxyProvider(name),
    filter || excludeFilter => '',
  };
}

typedef _Member = ({_MemberKind kind, String name});

/// The form state of type [M] whose [kinds] of members are listed.
abstract class _MemberHost<M> {
  const _MemberHost();

  List<_MemberKind> get kinds;

  ProviderListenable<M> get state;

  AutoDisposeNotifierMixin<M> notifierOf(WidgetRef ref);

  String title(AppLocalizations appLocalizations);

  String addLabel(AppLocalizations appLocalizations);

  List<String> namesOf(M model, _MemberKind kind);

  M withNames(M model, _MemberKind kind, List<String> names);

  List<String>? layoutOf(M model);

  M withLayout(M model, List<String>? layout);

  /// What the picker no longer offers as a [kind].
  Set<String> takenIn(M model, _MemberKind kind) => {...namesOf(model, kind)};

  Iterable<_MemberKind> get _runs => {for (final kind in kinds) kind.run};

  List<_Member> runOf(M model, _MemberKind run) => [
    for (final name in namesOf(model, run)) (kind: run, name: name),
  ];

  /// The core reads each run's own order only, so the rows take a run each
  /// as [layoutOf] names it, and the rest follow run by run.
  List<_Member> membersOf(M model) {
    final runs = {
      for (final run in _runs) run.name: runOf(model, run).iterator,
    };
    final members = <_Member>[];
    for (final name in layoutOf(model) ?? const <String>[]) {
      final run = runs[name];
      if (run != null && run.moveNext()) {
        members.add(run.current);
      }
    }
    for (final run in runs.values) {
      while (run.moveNext()) {
        members.add(run.current);
      }
    }
    return members;
  }

  M withMembers(M model, Iterable<_Member> members) {
    var next = model;
    for (final kind in kinds) {
      final names = [
        for (final member in members)
          if (member.kind == kind) member.name,
      ];
      if (!const ListEquality<String>().equals(namesOf(model, kind), names)) {
        next = withNames(next, kind, names);
      }
    }
    final layout = _layoutOf(members);
    if (const ListEquality<String>().equals(layoutOf(model), layout)) {
      return next;
    }
    return withLayout(next, layout);
  }

  /// Leaves out the trailing rows [membersOf] would put there anyway.
  List<String>? _layoutOf(Iterable<_Member> members) {
    final order = _runs.toList();
    final runs = [for (final member in members) order.indexOf(member.kind.run)];
    var end = runs.length;
    while (end > 0 && (end == runs.length || runs[end - 1] <= runs[end])) {
      end--;
    }
    return end == 0
        ? null
        : [for (final run in runs.take(end)) order[run].name];
  }
}

class _GroupMembers extends _MemberHost<ProxyGroup> {
  const _GroupMembers();

  @override
  List<_MemberKind> get kinds => _MemberKind.values;

  @override
  ProviderListenable<ProxyGroup> get state => proxyGroupProvider;

  @override
  AutoDisposeNotifierMixin<ProxyGroup> notifierOf(WidgetRef ref) =>
      ref.read(proxyGroupProvider.notifier);

  @override
  String title(AppLocalizations appLocalizations) => appLocalizations.nodes;

  @override
  String addLabel(AppLocalizations appLocalizations) =>
      appLocalizations.addNodes;

  @override
  List<String> namesOf(ProxyGroup group, _MemberKind kind) => switch (kind) {
    _MemberKind.proxy => group.proxies ?? const [],
    _MemberKind.provider => group.use ?? const [],
    _MemberKind.filter => filterParts(group.filter),
    _MemberKind.excludeFilter => filterParts(group.excludeFilter),
  };

  @override
  ProxyGroup withNames(
    ProxyGroup group,
    _MemberKind kind,
    List<String> names,
  ) => switch (kind) {
    _MemberKind.proxy => group.copyWith(proxies: names.isEmpty ? null : names),
    _MemberKind.provider => group.copyWith(use: names.isEmpty ? null : names),
    _MemberKind.filter => group.copyWith(filter: joinFilterParts(names)),
    _MemberKind.excludeFilter => group.copyWith(
      excludeFilter: joinFilterParts(names),
    ),
  };

  @override
  List<String>? layoutOf(ProxyGroup group) => group.memberLayout;

  @override
  ProxyGroup withLayout(ProxyGroup group, List<String>? layout) =>
      group.copyWith(memberLayout: layout);

  @override
  Set<String> takenIn(ProxyGroup group, _MemberKind kind) => {
    ...super.takenIn(group, kind),
    if (kind == _MemberKind.proxy) group.name,
  };

  @override
  List<_Member> runOf(ProxyGroup group, _MemberKind run) {
    if (run != _MemberKind.proxy) {
      return super.runOf(group, run);
    }
    final proxies = group.proxies ?? const <String>[];
    final positions = group.effectiveUsePosition ?? const <String, int>{};
    final before = [for (var i = 0; i <= proxies.length; i++) <_Member>[]];
    for (final name in group.use ?? const <String>[]) {
      before[positions[name] ?? proxies.length].add((
        kind: _MemberKind.provider,
        name: name,
      ));
    }
    return [
      for (final (index, providers) in before.indexed) ...[
        ...providers,
        if (index < proxies.length)
          (kind: _MemberKind.proxy, name: proxies[index]),
      ],
    ];
  }

  @override
  ProxyGroup withMembers(ProxyGroup group, Iterable<_Member> members) {
    final next = super.withMembers(group, members);
    final count = members
        .where((member) => member.kind == _MemberKind.proxy)
        .length;
    var seen = 0;
    final positions = <String, int>{};
    for (final member in members) {
      if (member.kind == _MemberKind.proxy) {
        seen++;
      } else if (member.kind == _MemberKind.provider && seen < count) {
        positions[member.name] = seen;
      }
    }
    final usePosition = positions.isEmpty ? null : positions;
    if (const MapEquality<String, int>().equals(
      group.usePosition,
      usePosition,
    )) {
      return next;
    }
    return next.copyWith(usePosition: usePosition);
  }
}

class _ProviderFilters extends _MemberHost<ProxyProviderOptions> {
  const _ProviderFilters();

  @override
  List<_MemberKind> get kinds => const [
    _MemberKind.filter,
    _MemberKind.excludeFilter,
  ];

  @override
  ProviderListenable<ProxyProviderOptions> get state =>
      proxyProviderOptionsProvider;

  @override
  AutoDisposeNotifierMixin<ProxyProviderOptions> notifierOf(WidgetRef ref) =>
      ref.read(proxyProviderOptionsProvider.notifier);

  @override
  String title(AppLocalizations appLocalizations) => appLocalizations.filters;

  @override
  String addLabel(AppLocalizations appLocalizations) =>
      appLocalizations.addFilters;

  @override
  List<String> namesOf(ProxyProviderOptions options, _MemberKind kind) =>
      switch (kind) {
        _MemberKind.excludeFilter => filterParts(options.excludeFilter),
        _ => filterParts(options.filter),
      };

  @override
  ProxyProviderOptions withNames(
    ProxyProviderOptions options,
    _MemberKind kind,
    List<String> names,
  ) => switch (kind) {
    _MemberKind.excludeFilter => options.copyWith(
      excludeFilter: joinFilterParts(names),
    ),
    _ => options.copyWith(filter: joinFilterParts(names)),
  };

  @override
  List<String>? layoutOf(ProxyProviderOptions options) => options.memberLayout;

  @override
  ProxyProviderOptions withLayout(
    ProxyProviderOptions options,
    List<String>? layout,
  ) => options.copyWith(memberLayout: layout);
}

Map<String, String> _providerTypes(
  WidgetRef ref,
  AppLocalizations appLocalizations,
) {
  final profiles = ref.watch(profilesProvider);
  return {
    for (final profile in profiles)
      if (profile.type != ProfileType.custom)
        profile.realLabel: profile.type == ProfileType.url
            ? appLocalizations.url
            : appLocalizations.file,
  };
}

Map<String, String> _nodeTypes(WidgetRef ref) => {
  for (final proxy
      in ref.watch(customProxiesProvider).value ?? const <CustomProxy>[])
    proxy.name: proxy.type,
};

class ProxyGroupMembersSliver extends StatelessWidget {
  const ProxyGroupMembersSliver({super.key});

  @override
  Widget build(BuildContext context) => const _MembersSliver(_GroupMembers());
}

class ProxyProviderFiltersSliver extends StatelessWidget {
  const ProxyProviderFiltersSliver({super.key});

  @override
  Widget build(BuildContext context) =>
      const _MembersSliver(_ProviderFilters());
}

class _MembersSliver<M> extends ConsumerStatefulWidget {
  final _MemberHost<M> host;

  const _MembersSliver(this.host);

  @override
  ConsumerState<_MembersSliver<M>> createState() => _MembersSliverState<M>();
}

class _MembersSliverState<M> extends ConsumerState<_MembersSliver<M>>
    with TickerProviderStateMixin {
  late final _host = widget.host;
  late final _transitions = EntryTransitions<_Member>(
    vsync: this,
    onLeft: _handleLeft,
  );
  late var _members = _host.membersOf(ref.read(_host.state));

  /// [_members] with the removed ones still collapsing.
  late var _entries = _members;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      _host.state.select((state) => SelectValue(_host.membersOf(state))),
      (_, next) => _handleMembers(next.value),
    );
  }

  @override
  void dispose() {
    _transitions.dispose();
    super.dispose();
  }

  void _handleMembers(List<_Member> members) {
    setState(() {
      _members = members;
      _entries = _transitions.sync(
        _entries,
        members,
        (member) => member,
        context.motionDuration(commonDuration),
      );
    });
  }

  void _handleLeft(_Member member) {
    if (!mounted || _members.contains(member)) {
      return;
    }
    setState(() {
      _entries = [
        for (final entry in _entries)
          if (entry != member) entry,
      ];
    });
  }

  void _handleToPicker() {
    Navigator.of(
      context,
    ).push(PagedSheetRoute(builder: (_) => _MemberPicker(_host)));
  }

  void _update(List<_Member> Function(List<_Member> members) apply) {
    _host
        .notifierOf(ref)
        .update(
          (state) => _host.withMembers(state, apply(_host.membersOf(state))),
        );
  }

  /// [oldIndex] and [newIndex] count the rows still collapsing too.
  void _handleReorder(int oldIndex, int newIndex) {
    final rest = [..._entries];
    final moved = rest.removeAt(oldIndex);
    final target = rest
        .take(newIndex)
        .where((member) => !_transitions.isLeaving(member))
        .length;
    _update(
      (_) => [
        for (final member in rest)
          if (!_transitions.isLeaving(member)) member,
      ]..insert(target, moved),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final members = _members;
    final hasProxies = _host.kinds.contains(_MemberKind.proxy);
    final groupTypes = hasProxies
        ? ref
              .watch(
                customProfileDataProvider(profileId).select(
                  (state) => SelectValue({
                    for (final group
                        in state?.proxyGroups ?? const <ProxyGroup>[])
                      group.name: group.type.value,
                  }),
                ),
              )
              .value
        : const <String, String>{};
    final nodeTypes = hasProxies ? _nodeTypes(ref) : const <String, String>{};
    final presets = {
      for (final filter in ref.watch(
        appSettingProvider.select((state) => state.filters),
      ))
        filter.regex: filter.label,
    };
    final count = members.length + 1;
    final entries = _entries;
    _transitions.place(entries, trailing: 1);
    Widget itemAt(int index) {
      final member = entries[index];
      final name = member.name;
      return EntryTransition(
        key: ValueKey(member),
        animation: _transitions.animationOf(member),
        leaving: _transitions.isLeaving(member),
        child: ItemPositionProvider(
          position: _transitions.positionOf(member),
          child: _MemberRow(
            member: member,
            index: index,
            title: member.kind.isFilter ? presets[name] ?? name : name,
            subtitle: switch (member.kind) {
              _MemberKind.proxy =>
                groupTypes[name] ??
                    nodeTypes[name] ??
                    (RuleTarget.baseTargets.contains(name)
                        ? appLocalizations.basicStrategy
                        : null),
              _MemberKind.provider => appLocalizations.proxyProviders,
              _MemberKind.filter => appLocalizations.filters,
              _MemberKind.excludeFilter => appLocalizations.excludeFilter,
            },
            onRemove: () => _update((state) => state..remove(member)),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: ListHeader(title: _host.title(appLocalizations)),
        ),
        SuperSliverReorderableList(
          itemBuilder: (_, index) => itemAt(index),
          itemCount: entries.length,
          proxyDecorator: (child, index, animation) =>
              commonProxyDecorator(itemAt(index), index, animation),
          onReorderItem: _handleReorder,
        ),
        SliverToBoxAdapter(
          child: ItemPositionProvider(
            position: ItemPosition.get(members.length, count),
            child: FormRow(
              leading: EntryButton.add(onPressed: _handleToPicker),
              title: _host.addLabel(appLocalizations),
              titleStyle: TextStyle(color: context.colorScheme.primary),
              onPressed: _handleToPicker,
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberRow extends ConsumerWidget {
  final _Member member;
  final int index;
  final String title;
  final String? subtitle;
  final VoidCallback onRemove;

  const _MemberRow({
    required this.member,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final isValid = member.kind.isValid(ref, profileId, member.name);
    final subtitle = this.subtitle;
    final (chipColor, chipForeground) = member.kind.chipColorsOf(
      context.colorScheme,
    );
    return DecorationListItem(
      invalid: !isValid,
      contentPadding: const EdgeInsets.only(left: 16),
      leading: EntryButton.remove(onPressed: onRemove),
      title: TooltipText(
        text: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      subtitle: subtitle == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 2),
              child: Row(
                children: [
                  Flexible(
                    child: TonalChip(
                      label: subtitle,
                      color: chipColor,
                      foregroundColor: chipForeground,
                    ),
                  ),
                ],
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isValid)
            InfoMessageButton(
              message: member.kind.invalidMessage(context, member.name),
            ),
          SortHandle(index: index),
        ],
      ),
    );
  }
}

typedef _Entry = ({String name, String title, String? subtitle});

_Entry _named(String name, String? subtitle) =>
    (name: name, title: name, subtitle: subtitle);

class _Category {
  final String label;
  final _MemberKind kind;
  final List<_Entry> entries;

  const _Category({
    required this.label,
    required this.kind,
    required this.entries,
  });
}

class _MemberPicker<M> extends ConsumerStatefulWidget {
  final _MemberHost<M> host;

  const _MemberPicker(this.host);

  @override
  ConsumerState<_MemberPicker<M>> createState() => _MemberPickerState<M>();
}

class _MemberPickerState<M> extends ConsumerState<_MemberPicker<M>> {
  late final _host = widget.host;

  /// Picks go into the form as they are made, since closing the sheet from
  /// here saves the form without popping this page first; the list keeps to
  /// the form as it was, so a pick stays there to be undone.
  late final _origin = ref.read(_host.state);
  var _selected = <_Member>[];
  var _query = SearchQuery('');

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  void _handleToggle(_Member member) {
    setState(() {
      _selected = [
        for (final item in _selected)
          if (item != member) item,
        if (!_selected.contains(member)) member,
      ];
    });
    var next = _origin;
    for (final kind in _host.kinds) {
      final picked = [
        for (final member in _selected)
          if (member.kind == kind) ...kind.partsOf(member.name),
      ];
      if (picked.isNotEmpty) {
        next = _host.withNames(next, kind, [
          ...{..._host.namesOf(next, kind), ...picked},
        ]);
      }
    }
    _host.notifierOf(ref).value = next;
  }

  List<_Category> _categories(AppLocalizations appLocalizations) {
    final kinds = _host.kinds;
    final filters = ref.watch(
      appSettingProvider.select((state) => state.filters),
    );
    List<_Entry> presetsMissingFrom(_MemberKind kind) {
      final value = joinFilterParts(_host.namesOf(_origin, kind));
      return [
        for (final filter in filters)
          if (!filter.isAppliedTo(value))
            (name: filter.regex, title: filter.label, subtitle: filter.regex),
      ];
    }

    return [
      if (kinds.contains(_MemberKind.proxy))
        ..._proxyCategories(appLocalizations),
      if (kinds.contains(_MemberKind.provider))
        _providerCategory(appLocalizations),
      if (kinds.contains(_MemberKind.filter))
        _Category(
          label: appLocalizations.filters,
          kind: _MemberKind.filter,
          entries: presetsMissingFrom(_MemberKind.filter),
        ),
      if (kinds.contains(_MemberKind.excludeFilter))
        _Category(
          label: appLocalizations.excludeFilter,
          kind: _MemberKind.excludeFilter,
          entries: presetsMissingFrom(_MemberKind.excludeFilter),
        ),
    ];
  }

  List<_Category> _proxyCategories(AppLocalizations appLocalizations) {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final proxies = _host.takenIn(_origin, _MemberKind.proxy);
    final groups = ref.watch(
      customProfileDataProvider(profileId).select(
        (state) => SelectValue(state?.proxyGroups ?? const <ProxyGroup>[]),
      ),
    );
    final nodes = _nodeTypes(ref);
    return [
      _Category(
        label: appLocalizations.basicStrategy,
        kind: _MemberKind.proxy,
        entries: [
          for (final target in RuleTarget.baseTargetNames)
            if (!proxies.contains(target)) _named(target, null),
        ],
      ),
      _Category(
        label: appLocalizations.localProxies,
        kind: _MemberKind.proxy,
        entries: [
          for (final MapEntry(key: name, value: description) in nodes.entries)
            if (!proxies.contains(name)) _named(name, description),
        ],
      ),
      _Category(
        label: appLocalizations.proxyGroup,
        kind: _MemberKind.proxy,
        entries: [
          for (final item in groups.value)
            if (!proxies.contains(item.name))
              _named(item.name, item.type.value),
        ],
      ),
    ];
  }

  _Category _providerCategory(AppLocalizations appLocalizations) {
    final use = _host.takenIn(_origin, _MemberKind.provider);
    final providerNames = ref.watch(
      appProviderNamesProvider(ProviderKind.proxy),
    );
    final providers = _providerTypes(ref, appLocalizations);
    return _Category(
      label: appLocalizations.proxyProviders,
      kind: _MemberKind.provider,
      entries: [
        for (final name in providerNames)
          if (!use.contains(name)) _named(name, providers[name]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final categories = [
      for (final category in _categories(appLocalizations))
        _Category(
          label: category.label,
          kind: category.kind,
          entries: category.entries
              .whereMatches(_query, (entry) => [entry.title, entry.subtitle])
              .toList(),
        ),
    ].where((category) => category.entries.isNotEmpty).toList();
    final total = categories.fold(
      0,
      (count, category) => count + category.entries.length,
    );
    return CommonScaffold(
      title: _host.addLabel(appLocalizations),
      searchState: _query.isNotEmpty || total >= sheetSearchMinItemCount
          ? AppBarSearchState(onSearch: _handleSearch)
          : null,
      body: Builder(
        builder: (context) => NullStatusSwitcher(
          isEmpty: categories.isEmpty,
          isSearching: _query.isNotEmpty,
          nullStatus: NullStatus(label: appLocalizations.noData),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  context.contentTopPadding,
                  16,
                  16 + BottomInsetScope.of(context),
                ),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    for (final category in categories)
                      SliverCollapsibleSection(
                        key: ValueKey(category.label),
                        label: category.label,
                        collapsible: _query.isEmpty,
                        initiallyExpanded: false,
                        itemCount: category.entries.length,
                        itemBuilder: (_, index) =>
                            _buildEntry(category.kind, category.entries[index]),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(_MemberKind kind, _Entry entry) {
    final member = (kind: kind, name: entry.name);
    final isSelected = _selected.contains(member);
    final subtitle = entry.subtitle;
    return DecorationListItem(
      isSelected: isSelected,
      onPressed: () => _handleToggle(member),
      title: TooltipText(
        text: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      subtitle: switch (subtitle) {
        null => null,
        _ when kind.isFilter => FilterRegexText(subtitle),
        _ => TooltipLabel(subtitle, maxLines: 1),
      },
      trailing: isSelected ? const GlyphIcon(AppGlyphs.check) : null,
    );
  }
}
