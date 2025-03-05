import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:flutter/material.dart';

import 'card.dart';
import 'float_layout.dart';
import 'list.dart';

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
    return AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      content: SizedBox(
        width: 250,
        child: Wrap(
          children: [
            for (final option in options)
              ListItem.radio(
                delegate: RadioDelegate(
                  value: option,
                  groupValue: value,
                  onChanged: (T? value) {
                    Navigator.of(context).pop(value);
                  },
                ),
                title: Text(
                  this.textBuilder(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InputDialog extends StatefulWidget {
  final String title;
  final String value;
  final String? suffixText;
  final String? resetValue;

  const InputDialog({
    super.key,
    required this.title,
    required this.value,
    this.suffixText,
    this.resetValue,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late TextEditingController textController;

  String get value => widget.value;

  String get title => widget.title;

  String? get suffixText => widget.suffixText;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(
      text: value,
    );
  }

  _handleUpdate() async {
    final text = textController.value.text;
    Navigator.of(context).pop<String>(text);
  }

  _handleReset() async {
    if (widget.resetValue == null) {
      return;
    }
    Navigator.of(context).pop<String>(widget.resetValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              maxLines: 1,
              minLines: 1,
              controller: textController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixText: suffixText,
              ),
              onSubmitted: (_) {
                _handleUpdate();
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.resetValue != null &&
            textController.value.text != widget.resetValue) ...[
          TextButton(
            onPressed: _handleReset,
            child: Text(appLocalizations.reset),
          ),
          const SizedBox(
            width: 4,
          ),
        ],
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        )
      ],
    );
  }
}

class ListPage<T> extends StatelessWidget {
  final String title;
  final Iterable<T> items;
  final Key Function(T item)? keyBuilder;
  final Widget Function(T item) titleBuilder;
  final Widget Function(T item)? subtitleBuilder;
  final Widget Function(T item)? leadingBuilder;
  final String? keyLabel;
  final String? valueLabel;
  final Function(Iterable<T> items) onChange;

  const ListPage({
    super.key,
    required this.title,
    required this.items,
    this.keyBuilder,
    required this.titleBuilder,
    required this.onChange,
    this.leadingBuilder,
    this.keyLabel,
    this.valueLabel,
    this.subtitleBuilder,
  });

  bool get isMap => items is Iterable<MapEntry>;

  _handleAddOrEdit([T? item]) async {
    final value = await globalState.showCommonDialog<T>(
      child: AddDialog(
        keyField: isMap
            ? Field(
                label: this.keyLabel ?? appLocalizations.key,
                value:
                    item == null ? "" : (item as MapEntry<String, String>).key,
              )
            : null,
        valueField: Field(
          label: this.valueLabel ?? appLocalizations.value,
          value: item == null
              ? ""
              : isMap
                  ? (item as MapEntry<String, String>).value
                  : item as String,
        ),
        title: title,
      ),
    );
    if (value == null) return;
    final entries = List<T>.from(
      items,
    );
    if (item != null) {
      final index = entries.indexWhere(
        (entry) {
          if (isMap) {
            return (entry as MapEntry<String, String>).key ==
                (item as MapEntry<String, String>).key;
          }
          return entry == item;
        },
      );
      if (index != -1) {
        entries[index] = value;
      }
    } else {
      entries.add(value);
    }
    onChange(entries);
  }

  _handleDelete(T item) {
    final entries = List<T>.from(
      items,
    );
    final index = entries.indexWhere(
      (entry) {
        if (isMap) {
          return (entry as MapEntry<String, String>).key ==
              (item as MapEntry<String, String>).key;
        }
        return entry == item;
      },
    );
    if (index != -1) {
      entries.removeAt(index);
    }
    onChange(entries);
  }

  Widget _buildList() {
    final items = this.items.toList();
    if (this.keyBuilder != null) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.only(
          bottom: 16 + 64,
          left: 16,
          right: 16,
        ),
        buildDefaultDragHandles: false,
        itemCount: items.length,
        itemBuilder: (_, index) {
          final e = items[index];
          return Padding(
            key: keyBuilder!(e),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ReorderableDragStartListener(
              index: index,
              child: CommonCard(
                child: ListItem(
                  leading: leadingBuilder != null ? leadingBuilder!(e) : null,
                  title: titleBuilder(e),
                  subtitle:
                      subtitleBuilder != null ? subtitleBuilder!(e) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _handleDelete(e);
                    },
                  ),
                ),
                onPressed: () {
                  _handleAddOrEdit(e);
                },
              ),
            ),
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final nextItems = List<T>.from(items);
          final item = nextItems.removeAt(oldIndex);
          nextItems.insert(newIndex, item);
          onChange(nextItems);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(
          bottom: 16 + 64,
          left: 16,
          right: 16,
        ),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final e = items[index];
          return Padding(
            key: ObjectKey(e.toString()),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CommonCard(
              child: ListItem(
                leading: leadingBuilder != null ? leadingBuilder!(e) : null,
                title: titleBuilder(e),
                subtitle: subtitleBuilder != null ? subtitleBuilder!(e) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _handleDelete(e);
                  },
                ),
              ),
              onPressed: () {
                _handleAddOrEdit(e);
              },
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton(
          onPressed: () async {
            _handleAddOrEdit();
          },
          child: const Icon(Icons.add),
        ),
      ),
      child: items.isEmpty
          ? NullStatus(label: appLocalizations.noData)
          : _buildList(),
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
      keyController = TextEditingController(
        text: keyField!.value,
      );
    }
    valueController = TextEditingController(
      text: valueField.value,
    );
  }

  _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (keyField != null) {
      Navigator.of(context).pop<MapEntry<String, String>>(
        MapEntry(
          keyController!.text,
          valueController.text,
        ),
      );
    } else {
      Navigator.of(context).pop<String>(
        valueController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: dialogCommonWidth,
          child: Wrap(
            runSpacing: 16,
            children: [
              if (keyField != null)
                TextFormField(
                  maxLines: 2,
                  minLines: 1,
                  controller: keyController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: keyField!.label,
                  ),
                  validator: (String? value) {
                    if (keyField!.validator != null) {
                      return keyField!.validator!(value);
                    }
                    if (value == null || value.isEmpty) {
                      return appLocalizations.notEmpty;
                    }
                    return null;
                  },
                ),
              TextFormField(
                maxLines: 3,
                minLines: 1,
                controller: valueController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: valueField.label,
                ),
                validator: (String? value) {
                  if (valueField.validator != null) {
                    return valueField.validator!(value);
                  }
                  if (value == null || value.isEmpty) {
                    return appLocalizations.notEmpty;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submit,
          child: Text(appLocalizations.confirm),
        )
      ],
    );
  }
}
