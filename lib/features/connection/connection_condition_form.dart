import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<ConnectionCondition?> showConnectionConditionForm(BuildContext context) {
  return showFormSheet<ConnectionCondition>(
    context: context,
    builder: (_) => const _ConnectionConditionForm(),
  );
}

extension ConnectionFieldL10n on ConnectionField {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ConnectionField.host => appLocalizations.host,
      ConnectionField.app => appLocalizations.app,
      ConnectionField.exit => appLocalizations.outboundExit,
      ConnectionField.rule => appLocalizations.rule,
      ConnectionField.net => appLocalizations.protocol,
      ConnectionField.ip => 'IP',
    };
  }
}

class _ConnectionConditionForm extends StatefulWidget {
  const _ConnectionConditionForm();

  @override
  State<_ConnectionConditionForm> createState() =>
      _ConnectionConditionFormState();
}

class _ConnectionConditionFormState extends State<_ConnectionConditionForm> {
  final _value = TextEditingController();
  var _field = ConnectionField.host;
  var _excludes = false;
  var _attempted = false;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _value.text.trim();
    if (value.isEmpty) {
      setState(() => _attempted = true);
      return;
    }
    Navigator.of(context).pop(
      ConnectionCondition(
        _field,
        value.replaceAll('"', ''),
        excludes: _excludes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final invalid = _attempted && _value.text.trim().isEmpty;
    return FormPage(
      title: appLocalizations.addCondition,
      saveLabel: appLocalizations.add,
      onSave: _submit,
      error: invalid ? appLocalizations.emptyTip(appLocalizations.value) : null,
      children: [
        generateSection(
          footer: appLocalizations.conditionTip,
          items: [
            ListItem<ConnectionField>.options(
              title: Text(appLocalizations.conditionField),
              options: ConnectionField.values,
              value: _field,
              textBuilder: (field) => field.label,
              onChanged: (field) => setState(() => _field = field),
            ),
            FormRow(
              title: appLocalizations.value,
              invalid: invalid,
              trailing: FormRowTextField(
                controller: _value,
                autofocus: true,
                hintText: appLocalizations.required,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                onChanged: (_) {
                  if (_attempted) {
                    setState(() {});
                  }
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            ListItem.toggle(
              title: Text(appLocalizations.conditionExcludes),
              value: _excludes,
              onChanged: (value) => setState(() => _excludes = value),
            ),
          ],
        ),
      ],
    );
  }
}
