part of 'input.dart';

abstract class _EditViewState<W extends ConsumerStatefulWidget, T>
    extends ConsumerState<W> {
  List<T> _entries = [];
  late final List<T> _initialEntries;
  final _selectionKey = uniqueId;

  String get title;

  List<T> get initialEntries;

  String idOf(T entry);

  Widget buildTitle(T entry);

  Widget? buildSubtitle(T entry);

  Widget? buildLeading(T entry);

  bool sameEntries(List<T> a, List<T> b);

  Object popResult(List<T> entries);

  /// Adds when [entry] is null and edits it otherwise; an add may return
  /// several entries from batch mode.
  Future<List<T>?> showEntryDialog(T? entry);

  @override
  void initState() {
    super.initState();
    _entries = List<T>.from(initialEntries);
    _initialEntries = List<T>.from(_entries);
  }

  void _handleReorder(int oldIndex, int newIndex) {
    _entries = _entries.copyAndReorder(oldIndex, newIndex);
    setState(() {});
  }

  void _handleSelected(T entry) {
    ref.read(itemsProvider(_selectionKey).notifier).update((state) {
      final newState = Set<String>.from(state)..addOrRemove(idOf(entry));
      return newState;
    });
  }

  void _handleSelectAll() {
    final ids = _entries.map(idOf).toSet();
    ref.read(itemsProvider(_selectionKey).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleAdd() async {
    final entries = await showEntryDialog(null);
    if (!mounted || entries == null || entries.isEmpty) return;
    _entries = [..._entries, ...entries];
    setState(() {});
  }

  Future<void> _handleEdit(T entry) async {
    final entries = await showEntryDialog(entry);
    if (!mounted || entries == null || entries.isEmpty) return;
    final next = entries.single;
    final id = idOf(entry);
    _entries = [
      for (final current in _entries)
        if (idOf(current) == id) next else current,
    ];
    setState(() {});
  }

  void _handleDelete() {
    final selected = ref.read(itemsProvider(_selectionKey));
    _entries = _entries
        .where((entry) => !selected.contains(idOf(entry)))
        .toList();
    ref.read(itemsProvider(_selectionKey).notifier).value = {};
    setState(() {});
  }

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetPageChangesTip),
    );
    if (!mounted || res != true) {
      return;
    }
    _entries = _initialEntries;
    setState(() {});
  }

  Widget _buildEntry({
    required T entry,
    required int index,
    required int length,
    required bool isSelected,
    required bool isEditing,
  }) {
    final position = ItemPosition.get(index, length);
    return ReorderableDelayedDragStartListener(
      key: ValueKey(idOf(entry)),
      index: index,
      child: ItemPositionProvider(
        position: position,
        child: SelectedDecorationListItem(
          title: buildTitle(entry),
          leading: buildLeading(entry),
          subtitle: buildSubtitle(entry),
          isSelected: isSelected,
          isEditing: isEditing,
          onSelected: () {
            _handleSelected(entry);
          },
          onPressed: () {
            _handleEdit(entry);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final selected = ref.watch(itemsProvider(_selectionKey));
    final isEditing = selected.isNotEmpty;
    return CommonPopScope(
      onPop: (_) {
        if (isEditing) {
          ref.read(itemsProvider(_selectionKey).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop(popResult(_entries));
        return false;
      },
      child: CommonScaffold(
        title: title,
        actions: [
          if (isEditing)
            IconButton(
              tooltip: appLocalizations.delete,
              onPressed: _handleDelete,
              icon: const GlyphIcon(AppGlyphs.delete),
            )
          else if (!sameEntries(_entries, _initialEntries))
            IconButton(
              tooltip: appLocalizations.reset,
              onPressed: _handleReset,
              icon: const GlyphIcon(AppGlyphs.reset),
            ),
          if (isEditing)
            FilledButton(
              onPressed: _handleSelectAll,
              child: Text(appLocalizations.selectAll),
            )
          else
            FilledButton.tonal(
              onPressed: _handleAdd,
              child: Text(appLocalizations.add),
            ),
        ],
        body: NullStatusSwitcher(
          isEmpty: _entries.isEmpty,
          nullStatus: NullStatus(label: appLocalizations.noData),
          child: ReorderableListView.builder(
            padding: EdgeInsets.only(
              bottom: 16 + 64,
              top: context.appBarInset + 16,
              left: 16,
              right: 16,
            ),
            buildDefaultDragHandles: false,
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return _buildEntry(
                entry: entry,
                index: index,
                length: _entries.length,
                isSelected: selected.contains(idOf(entry)),
                isEditing: isEditing,
              );
            },
            proxyDecorator: (child, index, animation) {
              final entry = _entries[index];
              return commonProxyDecorator(
                _buildEntry(
                  entry: entry,
                  index: index,
                  length: _entries.length,
                  isSelected: selected.contains(idOf(entry)),
                  isEditing: isEditing,
                ),
                index,
                animation,
              );
            },
            onReorderItem: _handleReorder,
          ),
        ),
      ),
    );
  }
}

class ListEditView extends ConsumerStatefulWidget {
  final String title;
  final List<String> items;
  final Widget Function(String item) titleBuilder;
  final Widget Function(String item)? subtitleBuilder;
  final Widget Function(String item)? leadingBuilder;
  final String? valueLabel;
  final int? itemMaxLength;

  const ListEditView({
    super.key,
    required this.title,
    required this.items,
    required this.titleBuilder,
    this.leadingBuilder,
    this.valueLabel,
    this.subtitleBuilder,
    this.itemMaxLength,
  });

  @override
  ConsumerState<ListEditView> createState() => _ListEditViewState();
}

class _ListEditViewState extends _EditViewState<ListEditView, String> {
  @override
  String get title => widget.title;

  @override
  List<String> get initialEntries => widget.items;

  @override
  String idOf(String entry) => entry;

  @override
  Widget buildTitle(String entry) => widget.titleBuilder(entry);

  @override
  Widget? buildSubtitle(String entry) => widget.subtitleBuilder?.call(entry);

  @override
  Widget? buildLeading(String entry) => widget.leadingBuilder?.call(entry);

  @override
  bool sameEntries(List<String> a, List<String> b) =>
      stringListEquality.equals(a, b);

  @override
  Object popResult(List<String> entries) => entries;

  String get _valueLabel => widget.valueLabel ?? context.appLocalizations.value;

  ParsedInput<String> _parseBatch(String text) {
    return parseListInput(
      text,
      existing: _entries.toSet(),
      maxLength: widget.itemMaxLength,
    );
  }

  String _issueMessage(InputIssue issue) {
    return context.appLocalizations.maxLengthTip(
      _valueLabel,
      widget.itemMaxLength!,
    );
  }

  String _toEntry(String? key, String value) =>
      parseListInput(value).entries.single;

  @override
  Future<List<String>?> showEntryDialog(String? entry) {
    final appLocalizations = context.appLocalizations;
    final label = _valueLabel;

    String? validator(String? value) {
      final parsed = parseListInput(
        value ?? '',
        maxLength: widget.itemMaxLength,
      );
      if (!parsed.isValid) {
        return appLocalizations.maxLengthTip(label, widget.itemMaxLength!);
      }
      if (parsed.entries.isEmpty) {
        return appLocalizations.emptyTip(label);
      }
      if (parsed.entries.length > 1) {
        return appLocalizations.singleValueTip(label);
      }
      final next = parsed.entries.single;
      if (next != entry && _entries.contains(next)) {
        return appLocalizations.existsTip(label);
      }
      return null;
    }

    return dialogs.showCommonDialog<List<String>>(
      child: EntryDialog<String>(
        title: entry == null ? appLocalizations.add : appLocalizations.edit,
        valueField: Field(
          label: label,
          value: entry ?? '',
          validator: validator,
        ),
        valueMaxLength: widget.itemMaxLength,
        toEntry: _toEntry,
        batch: entry != null
            ? null
            : BatchInput(
                label: widget.title,
                formatTip: appLocalizations.batchListInputTip,
                parse: _parseBatch,
                issueMessage: _issueMessage,
              ),
      ),
    );
  }
}

class MapEditView extends ConsumerStatefulWidget {
  final String title;
  final Map<String, String> entries;
  final Widget Function(MapEntry<String, String> item) titleBuilder;
  final Widget Function(MapEntry<String, String> item)? subtitleBuilder;
  final Widget Function(MapEntry<String, String> item)? leadingBuilder;
  final String? keyLabel;
  final String? valueLabel;
  final int? keyMaxLength;
  final int? valueMaxLength;

  const MapEditView({
    super.key,
    required this.title,
    required this.entries,
    required this.titleBuilder,
    this.leadingBuilder,
    this.keyLabel,
    this.valueLabel,
    this.subtitleBuilder,
    this.keyMaxLength,
    this.valueMaxLength,
  });

  @override
  ConsumerState<MapEditView> createState() => _MapEditViewState();
}

class _MapEditViewState
    extends _EditViewState<MapEditView, MapEntry<String, String>> {
  @override
  String get title => widget.title;

  @override
  List<MapEntry<String, String>> get initialEntries =>
      widget.entries.entries.toList();

  @override
  String idOf(MapEntry<String, String> entry) => entry.key;

  @override
  Widget buildTitle(MapEntry<String, String> entry) =>
      widget.titleBuilder(entry);

  @override
  Widget? buildSubtitle(MapEntry<String, String> entry) =>
      widget.subtitleBuilder?.call(entry);

  @override
  Widget? buildLeading(MapEntry<String, String> entry) =>
      widget.leadingBuilder?.call(entry);

  @override
  bool sameEntries(
    List<MapEntry<String, String>> a,
    List<MapEntry<String, String>> b,
  ) => stringAndStringMapEntryListEquality.equals(a, b);

  @override
  Object popResult(List<MapEntry<String, String>> entries) =>
      Map<String, String>.fromEntries(entries);

  String get _keyLabel => widget.keyLabel ?? context.appLocalizations.key;

  String get _valueLabel => widget.valueLabel ?? context.appLocalizations.value;

  ParsedInput<MapEntry<String, String>> _parseBatch(String text) {
    return parseMapInput(
      text,
      existingKeys: _entries.map(idOf).toSet(),
      keyMaxLength: widget.keyMaxLength,
      valueMaxLength: widget.valueMaxLength,
    );
  }

  String _issueMessage(InputIssue issue) {
    final appLocalizations = context.appLocalizations;
    return switch (issue.kind) {
      InputIssueKind.keyTooLong => appLocalizations.maxLengthTip(
        _keyLabel,
        widget.keyMaxLength!,
      ),
      InputIssueKind.valueTooLong => appLocalizations.maxLengthTip(
        _valueLabel,
        widget.valueMaxLength!,
      ),
      InputIssueKind.missingValue => appLocalizations.emptyTip(_valueLabel),
    };
  }

  static MapEntry<String, String> _toEntry(String? key, String value) =>
      MapEntry(key!, value);

  @override
  Future<List<MapEntry<String, String>>?> showEntryDialog(
    MapEntry<String, String>? entry,
  ) {
    final appLocalizations = context.appLocalizations;

    String? keyValidator(String? value) {
      final taken = value != entry?.key && _entries.any((e) => e.key == value);
      return taken ? appLocalizations.existsTip(_keyLabel) : null;
    }

    return dialogs.showCommonDialog<List<MapEntry<String, String>>>(
      child: EntryDialog<MapEntry<String, String>>(
        title: entry == null ? appLocalizations.add : appLocalizations.edit,
        keyField: Field(
          label: _keyLabel,
          value: entry?.key ?? '',
          validator: keyValidator,
        ),
        valueField: Field(label: _valueLabel, value: entry?.value ?? ''),
        keyMaxLength: widget.keyMaxLength,
        valueMaxLength: widget.valueMaxLength,
        toEntry: _toEntry,
        batch: entry != null
            ? null
            : BatchInput(
                label: widget.title,
                formatTip: appLocalizations.batchMapInputTip,
                parse: _parseBatch,
                issueMessage: _issueMessage,
              ),
      ),
    );
  }
}
