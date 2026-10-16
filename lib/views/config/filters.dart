import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FiltersView extends ConsumerStatefulWidget {
  const FiltersView({super.key});

  @override
  ConsumerState<FiltersView> createState() => _FiltersViewState();
}

class _FiltersViewState extends ConsumerState<FiltersView> {
  List<Filter> get _filters => ref.read(appSettingProvider).filters;

  void _save(List<Filter> filters) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(filters: filters));
  }

  Future<void> _handleAddOrUpdate([Filter? filter]) async {
    final res = await showFormSheet<Filter>(
      context: context,
      builder: (_) => _FilterForm(
        filter: filter,
        checkRegex: _checkRegex,
        reservedLabels: {
          for (final item in _filters)
            if (item.label != filter?.label) item.label,
        },
      ),
    );
    if (res == null || !mounted) {
      return;
    }
    final filters = _filters;
    _save(
      filter == null
          ? [...filters, res]
          : [
              for (final item in filters)
                item.label == filter.label ? res : item,
            ],
    );
  }

  Future<String?> _checkRegex(String regex) async {
    final errors = await checkFilters(ref, [regex]);
    final error = errors?.single ?? '';
    return error.isEmpty ? null : error;
  }

  void _handleDelete(Set<String> labels) {
    _save(_filters.where((item) => !labels.contains(item.label)).toList());
  }

  void _handleReorder(int oldIndex, int newIndex) {
    _save(_filters.copyAndReorder(oldIndex, newIndex));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListEditorPage<Filter, String>(
      title: appLocalizations.filters,
      idOf: (filter) => filter.label,
      itemsOf: (ref) =>
          ref.watch(appSettingProvider.select((state) => state.filters)),
      itemBuilder:
          (
            context,
            ref,
            filter,
            index,
            isEditing,
            isSelected,
            onToggleSelected,
          ) {
            return _FilterItem(
              filter: filter,
              isEditing: isEditing,
              isSelected: isSelected,
              onSelected: onToggleSelected,
              onPressed: () {
                _handleAddOrUpdate(filter);
              },
            );
          },
      onReorder: _handleReorder,
      onAdd: _handleAddOrUpdate,
      onDelete: _handleDelete,
      searchFieldsOf: (filter) => [filter.label, filter.regex],
      emptyLabel: appLocalizations.nullTip(appLocalizations.filters),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final Filter filter;
  final bool isEditing;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onPressed;

  const _FilterItem({
    required this.filter,
    required this.isEditing,
    required this.isSelected,
    required this.onSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      isSelected: isSelected,
      onPressed: isEditing ? onSelected : onPressed,
      contentPadding: const EdgeInsets.only(left: 16),
      title: TooltipText(
        text: Text(filter.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      subtitle: FilterRegexText(filter.regex),
      trailing: CommonCheckBox(
        value: isSelected,
        isCircle: true,
        onChanged: (_) => onSelected(),
      ),
    );
  }
}

enum _FilterField { label, regex }

class _FilterForm extends StatefulWidget {
  final Filter? filter;
  final Future<String?> Function(String regex) checkRegex;
  final Set<String> reservedLabels;

  const _FilterForm({
    required this.filter,
    required this.checkRegex,
    required this.reservedLabels,
  });

  @override
  State<_FilterForm> createState() => _FilterFormState();
}

class _FilterFormState extends State<_FilterForm> {
  late final TextEditingController _labelController;
  late final TextEditingController _regexController;
  String? _regexError;
  bool _checking = false;
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.filter?.label);
    _regexController = TextEditingController(text: widget.filter?.regex);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _regexController.dispose();
    super.dispose();
  }

  ({_FilterField field, String message})? _issue() {
    final appLocalizations = context.appLocalizations;
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      return (
        field: _FilterField.label,
        message: appLocalizations.emptyTip(appLocalizations.label),
      );
    }
    if (widget.reservedLabels.contains(label)) {
      return (
        field: _FilterField.label,
        message: appLocalizations.existsTip(appLocalizations.label),
      );
    }
    if (_regexController.text.trim().isEmpty) {
      return (
        field: _FilterField.regex,
        message: appLocalizations.emptyTip(appLocalizations.regex),
      );
    }
    if (_regexError case final error?) {
      return (field: _FilterField.regex, message: error);
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_checking) {
      return;
    }
    if (_issue() != null) {
      setState(() {
        _attempted = true;
      });
      return;
    }
    final filter = Filter(
      label: _labelController.text.trim(),
      regex: _regexController.text.trim(),
    );
    setState(() {
      _checking = true;
    });
    String? error;
    try {
      error = await widget.checkRegex(filter.regex);
    } finally {
      if (mounted) {
        setState(() {
          _checking = false;
          _attempted = true;
          _regexError = error;
        });
      }
    }
    if (error == null && mounted) {
      Navigator.of(context).pop(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final issue = _attempted ? _issue() : null;
    return FormPage(
      title: widget.filter == null
          ? appLocalizations.add
          : appLocalizations.edit,
      onSave: _handleSubmit,
      saving: _checking,
      error: issue?.message,
      children: [
        generateSection(
          items: [
            FormRow(
              title: appLocalizations.label,
              invalid: issue?.field == _FilterField.label,
              trailing: FormRowTextField(
                controller: _labelController,
                autofocus: widget.filter == null,
                hintText: appLocalizations.required,
                textInputAction: TextInputAction.next,
                inputFormatters: TextInputLimits.limit(TextInputLimits.name),
                onChanged: (_) {
                  if (_attempted) {
                    setState(() {});
                  }
                },
              ),
            ),
            FormRow(
              title: appLocalizations.regex,
              invalid: issue?.field == _FilterField.regex,
              trailing: FormRowTextField(
                controller: _regexController,
                hintText: r'(?i)hk|hong\s*kong',
                autocorrect: false,
                textInputAction: TextInputAction.done,
                inputFormatters: TextInputLimits.limit(TextInputLimits.filter),
                onChanged: (_) {
                  if (_attempted || _regexError != null) {
                    setState(() {
                      _regexError = null;
                    });
                  }
                },
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
