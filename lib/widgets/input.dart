import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'effect.dart';
import 'list.dart';
import 'theme.dart';

class OptionsDialog<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;

  const OptionsDialog({
    super.key,
    required this.title,
    required this.options,
    required this.textBuilder,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: title,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: RadioGroup(
        onChanged: (value) {
          Navigator.of(context).pop(value);
        },
        groupValue: value,
        child: Wrap(
          children: [
            for (final option in options)
              Builder(
                builder: (context) {
                  if (value == option) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Scrollable.ensureVisible(context);
                    });
                  }
                  return ListItem.radio(
                    delegate: RadioDelegate(
                      value: option,
                      onTab: () {
                        Navigator.of(context).pop(option);
                      },
                    ),
                    title: Text(textBuilder(option)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class CommonCheckBox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool isCircle;

  const CommonCheckBox({
    required this.value,
    required this.onChanged,
    this.isCircle = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      shape: isCircle ? const CircleBorder() : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

class InputDialog extends StatefulWidget {
  final String title;
  final String value;
  final String? suffixText;
  final String? labelText;
  final String? resetValue;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? obscureText;

  const InputDialog({
    super.key,
    required this.title,
    required this.value,
    this.suffixText,
    this.resetValue,
    this.hintText,
    this.validator,
    this.obscureText,
    this.labelText,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController textController;

  String get value => widget.value;

  String get title => widget.title;

  String? get suffixText => widget.suffixText;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: value);
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() == false) return;
    final text = textController.value.text;
    Navigator.of(context).pop<String>(text);
  }

  Future<void> _handleReset() async {
    if (widget.resetValue == null) {
      return;
    }
    Navigator.of(context).pop<String>(widget.resetValue);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: title,
      actions: [
        if (widget.resetValue != null &&
            textController.value.text != widget.resetValue) ...[
          TextButton(
            onPressed: _handleReset,
            child: Text(appLocalizations.reset),
          ),
          const SizedBox(width: 4),
        ],
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Form(
        autovalidateMode: widget.autovalidateMode,
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextFormField(
              obscureText: widget.obscureText ?? false,
              keyboardType: TextInputType.url,
              maxLines: widget.obscureText == true ? 1 : 5,
              minLines: 1,
              controller: textController,
              onFieldSubmitted: (_) {
                _handleUpdate();
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixText: suffixText,
                hintText: widget.hintText,
                labelText: widget.labelText,
              ),
              validator: widget.validator,
            ),
          ],
        ),
      ),
    );
  }
}

class ListInputPage extends ConsumerStatefulWidget {
  final String title;
  final List<String> items;
  final Widget Function(String item) titleBuilder;
  final Widget Function(String item)? subtitleBuilder;
  final Widget Function(String item)? leadingBuilder;
  final String? valueLabel;

  const ListInputPage({
    super.key,
    required this.title,
    required this.items,
    required this.titleBuilder,
    this.leadingBuilder,
    this.valueLabel,
    this.subtitleBuilder,
  });

  @override
  ConsumerState createState() => _ListInputPageState();
}

class _ListInputPageState extends ConsumerState<ListInputPage> {
  List<String> _items = [];
  late List<String> _originItems;
  final _key = utils.id;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _originItems = List<String>.from(_items);
  }

  void _handleReorder(int oldIndex, newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final nextItems = List<String>.from(_items);
    final item = nextItems.removeAt(oldIndex);
    nextItems.insert(newIndex, item);
    _items = nextItems;
    setState(() {});
  }

  void _handleSelected(String value) {
    ref.read(selectedItemsProvider(_key).notifier).update((state) {
      final newState = Set<String>.from(state)..addOrRemove(value);
      return newState;
    });
  }

  void _handleSelectAll() {
    final ids = _items.toSet();
    ref.read(selectedItemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleAddOrEdit([String? item]) async {
    uniqueValidator(String? value) {
      final index = _items.indexWhere((entry) {
        return entry == value;
      });
      final current = item == value;
      if (index != -1 && !current) {
        return appLocalizations.existsTip(appLocalizations.value);
      }
      return null;
    }

    final value = await globalState.showCommonDialog<String>(
      child: AddDialog(
        valueField: Field(
          label: widget.valueLabel ?? appLocalizations.value,
          value: item ?? '',
          validator: uniqueValidator,
        ),
        title: item != null ? appLocalizations.edit : appLocalizations.add,
      ),
    );

    if (value == null) return;
    final index = _items.indexWhere((entry) {
      return entry == item;
    });
    final nextItems = List<String>.from(_items);
    if (item != null) {
      nextItems[index] = value;
    } else {
      nextItems.add(value);
    }
    _items = nextItems;
    setState(() {});
  }

  void _handleDelete() {
    final selectedItems = ref.read(selectedItemsProvider(_key));
    final newItems = _items
        .where((item) => !selectedItems.contains(item))
        .toList();
    _items = newItems;
    ref.read(selectedItemsProvider(_key).notifier).value = {};
    setState(() {});
  }

  Future<void> _handleReset() async {
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.resetPageChangesTip),
    );
    if (res != true) {
      return;
    }
    _items = _originItems;
    setState(() {});
  }

  Widget _buildItem({
    required String value,
    required int index,
    required int totalLength,
    required bool isSelected,
    required bool isEditing,
    isDecorator = false,
  }) {
    final isFirst = index == 0;
    final isLast = index == totalLength - 1;
    return ReorderableDelayedDragStartListener(
      key: ValueKey(value),
      index: index,
      child: CommonSelectedInputListItem(
        isDecorator: isDecorator,
        isLast: isLast,
        isFirst: isFirst,
        title: widget.titleBuilder(value),
        isSelected: isSelected,
        isEditing: isEditing,
        onSelected: () {
          _handleSelected(value);
        },
        onPressed: () {
          _handleAddOrEdit(value);
        },
        leading: widget.leadingBuilder != null
            ? widget.leadingBuilder!(value)
            : null,
        subtitle: widget.subtitleBuilder != null
            ? widget.subtitleBuilder!(value)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(selectedItemsProvider(_key));
    return CommonPopScope(
      onPop: (_) {
        if (selectedItems.isNotEmpty) {
          ref.read(selectedItemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop(_items);
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        actions: [
          if (selectedItems.isNotEmpty) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                onPressed: _handleDelete,
                icon: Icon(Icons.delete),
              ),
            ),
            SizedBox(width: 2),
          ] else if (!stringListEquality.equals(_items, _originItems)) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                onPressed: _handleReset,
                icon: const Icon(Icons.replay),
              ),
            ),
            SizedBox(width: 2),
          ],
          CommonMinFilledButtonTheme(
            child: selectedItems.isNotEmpty
                ? FilledButton(
                    onPressed: _handleSelectAll,
                    child: Text(appLocalizations.selectAll),
                  )
                : FilledButton.tonal(
                    onPressed: () {
                      _handleAddOrEdit();
                    },
                    child: Text(appLocalizations.add),
                  ),
          ),
          SizedBox(width: 8),
        ],
        body: _items.isEmpty
            ? NullStatus(label: appLocalizations.noData)
            : ReorderableListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 16 + 64,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                buildDefaultDragHandles: false,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final value = _items[index];
                  return _buildItem(
                    value: value,
                    index: index,
                    totalLength: _items.length,
                    isSelected: selectedItems.contains(value),
                    isEditing: selectedItems.isNotEmpty,
                  );
                },
                proxyDecorator: (child, index, animation) {
                  final value = _items[index];
                  return commonProxyDecorator(
                    _buildItem(
                      value: value,
                      index: index,
                      totalLength: _items.length,
                      isDecorator: true,
                      isSelected: selectedItems.contains(value),
                      isEditing: selectedItems.isNotEmpty,
                    ),
                    index,
                    animation,
                  );
                },
                onReorder: _handleReorder,
              ),
      ),
    );
  }
}

class MapInputPage extends ConsumerStatefulWidget {
  final String title;
  final Map<String, String> map;
  final Widget Function(MapEntry<String, String> item) titleBuilder;
  final Widget Function(MapEntry<String, String> item)? subtitleBuilder;
  final Widget Function(MapEntry<String, String> item)? leadingBuilder;
  final String? keyLabel;
  final String? valueLabel;

  const MapInputPage({
    super.key,
    required this.title,
    required this.map,
    required this.titleBuilder,
    this.leadingBuilder,
    this.keyLabel,
    this.valueLabel,
    this.subtitleBuilder,
  });

  @override
  ConsumerState<MapInputPage> createState() => _MapInputPageState();
}

class _MapInputPageState extends ConsumerState<MapInputPage> {
  List<MapEntry<String, String>> _items = [];
  late final List<MapEntry<String, String>> _originItems;
  final _key = utils.id;

  @override
  void initState() {
    super.initState();
    _items = List<MapEntry<String, String>>.from(widget.map.entries);
    _originItems = List<MapEntry<String, String>>.from(_items);
  }

  void _handleReorder(int oldIndex, newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final nextItems = List<MapEntry<String, String>>.from(_items);
    final item = nextItems.removeAt(oldIndex);
    nextItems.insert(newIndex, item);
    _items = nextItems;
    setState(() {});
  }

  void _handleSelected(MapEntry<String, String> value) {
    ref.read(selectedItemsProvider(_key).notifier).update((state) {
      final newState = Set<String>.from(state)..addOrRemove(value.key);
      return newState;
    });
  }

  void _handleSelectAll() {
    final ids = _items.map((item) => item.key).toSet();
    ref.read(selectedItemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleAddOrEdit([MapEntry<String, String>? item]) async {
    uniqueValidator(String? value) {
      final index = _items.indexWhere((entry) {
        return entry.key == value;
      });
      final current = item?.key == value;
      if (index != -1 && !current) {
        return appLocalizations.existsTip(appLocalizations.key);
      }
      return null;
    }

    final keyField = Field(
      label: widget.keyLabel ?? appLocalizations.key,
      value: item == null ? '' : item.key,
      validator: uniqueValidator,
    );

    final valueField = Field(
      label: widget.valueLabel ?? appLocalizations.value,
      value: item == null ? '' : item.value,
    );

    final value = await globalState.showCommonDialog<MapEntry<String, String>>(
      child: AddDialog(
        keyField: keyField,
        valueField: valueField,
        title: item != null ? appLocalizations.edit : appLocalizations.add,
      ),
    );
    if (value == null) return;
    final index = _items.indexWhere((entry) {
      return entry.key == item?.key;
    });

    final nextItems = List<MapEntry<String, String>>.from(_items);
    if (item != null) {
      nextItems[index] = value;
    } else {
      nextItems.add(value);
    }
    _items = nextItems;
    setState(() {});
  }

  void _handleDelete() {
    final selectedItems = ref.read(selectedItemsProvider(_key));
    final newItems = _items
        .where((item) => !selectedItems.contains(item.key))
        .toList();
    _items = newItems;
    ref.read(selectedItemsProvider(_key).notifier).value = {};
    setState(() {});
  }

  Future<void> _handleReset() async {
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.resetPageChangesTip),
    );
    if (res != true) {
      return;
    }
    _items = _originItems;
    setState(() {});
  }

  Widget _buildItem({
    required MapEntry<String, String> value,
    required int index,
    required int totalLength,
    required bool isSelected,
    required bool isEditing,
    isDecorator = false,
  }) {
    final isFirst = index == 0;
    final isLast = index == totalLength - 1;
    return ReorderableDelayedDragStartListener(
      key: ValueKey(value),
      index: index,
      child: CommonSelectedInputListItem(
        isDecorator: isDecorator,
        isLast: isLast,
        isFirst: isFirst,
        title: widget.titleBuilder(value),
        leading: widget.leadingBuilder != null
            ? widget.leadingBuilder!(value)
            : null,
        subtitle: widget.subtitleBuilder != null
            ? widget.subtitleBuilder!(value)
            : null,
        isSelected: isSelected,
        isEditing: isEditing,
        onSelected: () {
          _handleSelected(value);
        },
        onPressed: () {
          _handleAddOrEdit(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(selectedItemsProvider(_key));
    return CommonPopScope(
      onPop: (_) {
        if (selectedItems.isNotEmpty) {
          ref.read(selectedItemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop(Map<String, String>.fromEntries(_items));
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        actions: [
          if (selectedItems.isNotEmpty) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                onPressed: _handleDelete,
                icon: Icon(Icons.delete),
              ),
            ),
            SizedBox(width: 2),
          ] else if (!stringAndStringMapEntryListEquality.equals(
            _items,
            _originItems,
          )) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                onPressed: _handleReset,
                icon: const Icon(Icons.replay),
              ),
            ),
            SizedBox(width: 2),
          ],
          CommonMinFilledButtonTheme(
            child: selectedItems.isNotEmpty
                ? FilledButton(
                    onPressed: _handleSelectAll,
                    child: Text(appLocalizations.selectAll),
                  )
                : FilledButton.tonal(
                    onPressed: () {
                      _handleAddOrEdit();
                    },
                    child: Text(appLocalizations.add),
                  ),
          ),
          SizedBox(width: 8),
        ],
        body: _items.isEmpty
            ? NullStatus(label: appLocalizations.noData)
            : ReorderableListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 16 + 64,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                buildDefaultDragHandles: false,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final value = _items[index];
                  return _buildItem(
                    value: value,
                    index: index,
                    totalLength: _items.length,
                    isSelected: selectedItems.contains(value.key),
                    isEditing: selectedItems.isNotEmpty,
                  );
                },
                proxyDecorator: (child, index, animation) {
                  final value = _items[index];
                  return commonProxyDecorator(
                    _buildItem(
                      value: value,
                      index: index,
                      totalLength: _items.length,
                      isDecorator: true,
                      isSelected: selectedItems.contains(value.key),
                      isEditing: selectedItems.isNotEmpty,
                    ),
                    index,
                    animation,
                  );
                },
                onReorder: _handleReorder,
              ),
      ),
    );
  }
}

class AddDialog extends StatefulWidget {
  final String title;
  final Field? keyField;
  final Field valueField;

  const AddDialog({
    super.key,
    required this.title,
    this.keyField,
    required this.valueField,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController? keyController;
  late TextEditingController valueController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Field? get keyField => widget.keyField;

  Field get valueField => widget.valueField;

  @override
  void initState() {
    super.initState();
    if (keyField != null) {
      keyController = TextEditingController(text: keyField!.value);
    }
    valueController = TextEditingController(text: valueField.value);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (keyField != null) {
      Navigator.of(context).pop<MapEntry<String, String>>(
        MapEntry(keyController!.text, valueController.text),
      );
    } else {
      Navigator.of(context).pop<String>(valueController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.title,
      actions: [
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            if (keyField != null)
              TextFormField(
                maxLines: 3,
                minLines: 1,
                controller: keyController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: keyField!.label,
                ),
                validator: (String? value) {
                  String? res;
                  if (keyField!.validator != null) {
                    res = keyField!.validator!(value);
                  }
                  if (res != null) {
                    return res;
                  }
                  if (value == null || value.isEmpty) {
                    return appLocalizations.emptyTip(appLocalizations.key);
                  }
                  return null;
                },
              ),
            TextFormField(
              maxLines: 3,
              minLines: 1,
              keyboardType: TextInputType.text,
              controller: valueController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: valueField.label,
              ),
              onFieldSubmitted: (_) {
                _submit();
              },
              validator: (String? value) {
                String? res;
                if (valueField.validator != null) {
                  res = valueField.validator!(value);
                }
                if (res != null) {
                  return res;
                }
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(appLocalizations.value);
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
