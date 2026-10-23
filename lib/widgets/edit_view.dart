part of 'input.dart';

/// Public for `MapEditView`, whose entries are entered in a form.
abstract class EditViewState<W extends ConsumerStatefulWidget, T>
    extends ConsumerState<W> {
  List<T> _entries = [];
  late final List<T> _initialEntries;
  final _selectionKey = uniqueId;

  String get title;

  List<T> get initialEntries;

  String idOf(T entry);

  Widget buildTitle(T entry);

  Widget? buildSubtitle(T entry);

  bool sameEntries(List<T> a, List<T> b);

  Object popResult(List<T> entries);

  @protected
  List<T> get entries => _entries;

  /// Adds when [entry] is null and edits it otherwise; an add may return
  /// several entries from batch mode.
  Future<List<T>?> showEntryEditor(T? entry);

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
    final entries = await showEntryEditor(null);
    if (!mounted || entries == null || entries.isEmpty) return;
    _entries = [..._entries, ...entries];
    setState(() {});
  }

  Future<void> _handleEdit(T entry) async {
    final entries = await showEntryEditor(entry);
    if (!mounted || entries == null || entries.isEmpty) return;
    final next = entries.single;
    final id = idOf(entry);
    _entries = [
      for (final current in _entries)
        if (idOf(current) == id) next else current,
    ];
    setState(() {});
  }

  Future<void> _handleDelete() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.deleteMultipTip(title)),
      destructive: true,
      confirmText: context.appLocalizations.delete,
    );
    if (res != true || !mounted) {
      return;
    }
    final selected = ref.read(itemsProvider(_selectionKey));
    _entries = _entries
        .where((entry) => !selected.contains(idOf(entry)))
        .toList();
    ref.read(itemsProvider(_selectionKey).notifier).value = {};
    setState(() {});
  }

  void _handleSave() {
    Navigator.of(context).pop(popResult(_entries));
  }

  Future<void> _handleBack() async {
    final res = await dialogs.showSaveChanges();
    if (res == null || !mounted) {
      return;
    }
    if (res) {
      _handleSave();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetPageChangesTip),
      destructive: true,
      confirmText: context.appLocalizations.reset,
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
    final hasChanges = !sameEntries(_entries, _initialEntries);
    return CommonPopScope(
      onPop: isEditing
          ? (_) {
              ref.read(itemsProvider(_selectionKey).notifier).value = {};
              return false;
            }
          : hasChanges
          ? (_) {
              _handleBack();
              return false;
            }
          : null,
      child: CommonScaffold(
        title: title,
        confirmationAction: !isEditing && hasChanges
            ? IconButtonData(
                glyph: AppGlyphs.check,
                onPressed: _handleSave,
                tooltip: appLocalizations.save,
              )
            : null,
        selectionActions: [
          if (isEditing) ...[
            IconButtonData(
              glyph: AppGlyphs.delete,
              tooltip: appLocalizations.delete,
              onPressed: _handleDelete,
            ),
            IconButtonData(
              glyph: AppGlyphs.selectAll,
              tooltip: appLocalizations.selectAll,
              onPressed: _handleSelectAll,
            ),
          ],
        ],
        iconActions: [
          if (!isEditing) ...[
            if (hasChanges)
              IconButtonData(
                glyph: AppGlyphs.reset,
                tooltip: appLocalizations.reset,
                onPressed: _handleReset,
              ),
            IconButtonData(
              glyph: AppGlyphs.addCircle,
              tooltip: appLocalizations.add,
              onPressed: _handleAdd,
            ),
          ],
        ],
        body: NullStatusSwitcher(
          isEmpty: _entries.isEmpty,
          nullStatus: NullStatus(label: appLocalizations.noData),
          child: ReorderableListView.builder(
            padding: EdgeInsets.only(
              bottom: 16 + context.bottomInset,
              top: context.contentTopPadding,
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
  final int? itemMaxLength;
  final String? Function(String item)? itemValidator;

  const ListEditView({
    super.key,
    required this.title,
    required this.items,
    required this.titleBuilder,
    this.itemMaxLength,
    this.itemValidator,
  });

  @override
  ConsumerState<ListEditView> createState() => _ListEditViewState();
}

class _ListEditViewState extends EditViewState<ListEditView, String> {
  @override
  String get title => widget.title;

  @override
  List<String> get initialEntries => widget.items;

  @override
  String idOf(String entry) => entry;

  @override
  Widget buildTitle(String entry) => widget.titleBuilder(entry);

  @override
  Widget? buildSubtitle(String entry) {
    if (widget.itemValidator?.call(entry) case final error?) {
      return Text(error, style: TextStyle(color: context.colorScheme.error));
    }
    return null;
  }

  @override
  bool sameEntries(List<String> a, List<String> b) =>
      stringListEquality.equals(a, b);

  @override
  Object popResult(List<String> entries) => entries;

  @override
  Future<List<String>?> showEntryEditor(String? entry) {
    return showListEntryDialog(
      context,
      title: widget.title,
      entries: _entries,
      entry: entry,
      itemMaxLength: widget.itemMaxLength,
      itemValidator: widget.itemValidator,
    );
  }
}

Future<List<String>?> showListEntryDialog(
  BuildContext context, {
  required String title,
  required List<String> entries,
  String? entry,
  String? valueLabel,
  int? itemMaxLength,
  String? Function(String item)? itemValidator,
}) {
  final appLocalizations = context.appLocalizations;
  final label = valueLabel ?? appLocalizations.value;

  String? validator(String? value) {
    final parsed = parseListInput(value ?? '', maxLength: itemMaxLength);
    if (!parsed.isValid) {
      return appLocalizations.maxLengthTip(label, itemMaxLength!);
    }
    if (parsed.entries.isEmpty) {
      return appLocalizations.emptyTip(label);
    }
    if (parsed.entries.length > 1) {
      return appLocalizations.singleValueTip(label);
    }
    final next = parsed.entries.single;
    if (next != entry && entries.contains(next)) {
      return appLocalizations.existsTip(label);
    }
    return itemValidator?.call(next);
  }

  return dialogs.showCommonDialog<List<String>>(
    child: EntryDialog<String>(
      title: entry == null ? appLocalizations.add : appLocalizations.edit,
      valueField: Field(label: label, value: entry ?? '', validator: validator),
      valueMaxLength: itemMaxLength,
      toEntry: (value) => parseListInput(value).entries.single,
      batch: entry != null
          ? null
          : BatchInput(
              label: title,
              formatTip: appLocalizations.batchListInputTip,
              parse: (text) => parseListInput(
                text,
                existing: entries.toSet(),
                maxLength: itemMaxLength,
                isValid: itemValidator == null
                    ? null
                    : (item) => itemValidator(item) == null,
              ),
              issueMessage: (issue) => switch (issue.kind) {
                InputIssueKind.invalidValue => itemValidator!(issue.raw)!,
                _ => appLocalizations.maxLengthTip(label, itemMaxLength!),
              },
            ),
    ),
  );
}
