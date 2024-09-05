import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

import '../common/app_localizations.dart';
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
    if (text.isEmpty) return;
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

class UpdatePage<T> extends StatelessWidget {
  final String title;
  final Iterable<T> items;
  final Widget Function(T item) titleBuilder;
  final Widget Function(T item)? subtitleBuilder;
  final Function(T item) onAdd;
  final Function(T item) onRemove;
  final bool isMap;

  const UpdatePage({
    super.key,
    required this.title,
    required this.items,
    required this.titleBuilder,
    required this.onRemove,
    required this.onAdd,
    this.isMap = false,
    this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton(
          onPressed: () async {
            final value = await globalState.showCommonDialog<T>(
              child: AddDialog(
                isMap: isMap,
                title: title,
              ),
            );
            if (value == null) return;
            onAdd(value);
          },
          child: const Icon(Icons.add),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          bottom: 16 + 64,
          left: 16,
          right: 16,
        ),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final e = items.toList()[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CommonCard(
              child: ListItem(
                title: titleBuilder(e),
                subtitle: subtitleBuilder != null ? subtitleBuilder!(e) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    onRemove(e);
                  },
                ),
              ),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}

class AddDialog extends StatefulWidget {
  final String title;
  final bool isMap;

  const AddDialog({
    super.key,
    required this.title,
    required this.isMap,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  late TextEditingController keyController;
  late TextEditingController valueController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    keyController = TextEditingController();
    valueController = TextEditingController();
  }

  _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.isMap) {
      Navigator.of(context).pop<MapEntry<String, String>>(
        MapEntry(
          keyController.text,
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
              if (widget.isMap)
                TextFormField(
                  maxLines: 2,
                  minLines: 1,
                  controller: keyController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.key),
                    border: const OutlineInputBorder(),
                    labelText: appLocalizations.key,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.keyNotEmpty;
                    }
                    return null;
                  },
                ),
              TextFormField(
                maxLines: 3,
                minLines: 1,
                controller: valueController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.label),
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.value,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.valueNotEmpty;
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
