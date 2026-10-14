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
    final res = await dialogs.showCommonDialog<Filter>(
      child: _FilterDialog(
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
      selectionEnabled: true,
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

class _FilterDialog extends StatefulWidget {
  final Filter? filter;
  final Future<String?> Function(String regex) checkRegex;
  final Set<String> reservedLabels;

  const _FilterDialog({
    required this.filter,
    required this.checkRegex,
    required this.reservedLabels,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _regexController;
  String? _regexError;
  bool _checking = false;

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

  String? _validateLabel(String? value) {
    final appLocalizations = context.appLocalizations;
    final label = value?.trim() ?? '';
    if (label.isEmpty) {
      return appLocalizations.emptyTip(appLocalizations.label);
    }
    if (widget.reservedLabels.contains(label)) {
      return appLocalizations.existsTip(appLocalizations.label);
    }
    return null;
  }

  String? _validateRegex(String? value) {
    final appLocalizations = context.appLocalizations;
    if (value == null || value.trim().isEmpty) {
      return appLocalizations.emptyTip(appLocalizations.regex);
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_checking || _formKey.currentState?.validate() == false) {
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
    return CommonDialog(
      title: widget.filter == null
          ? appLocalizations.add
          : appLocalizations.edit,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _checking ? null : _handleSubmit,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextFormField(
              controller: _labelController,
              autofocus: widget.filter == null,
              validator: _validateLabel,
              inputFormatters: TextInputLimits.limit(TextInputLimits.name),
              decoration: InputDecoration(labelText: appLocalizations.label),
            ),
            TextFormField(
              controller: _regexController,
              validator: _validateRegex,
              forceErrorText: _regexError,
              onChanged: (_) {
                if (_regexError != null) {
                  setState(() {
                    _regexError = null;
                  });
                }
              },
              minLines: 1,
              maxLines: 3,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              inputFormatters: TextInputLimits.limit(TextInputLimits.filter),
              onFieldSubmitted: (_) => _handleSubmit(),
              decoration: InputDecoration(
                labelText: appLocalizations.regex,
                hintText: r'(?i)hk|hong\s*kong',
                errorMaxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
