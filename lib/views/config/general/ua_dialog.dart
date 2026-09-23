part of '../general.dart';

const _defaultUaValue = '';
const _customUaValue = '__custom_ua__';
const _presetUas = ['clash-verge/v2.4.2', 'ClashforWindows/0.19.23'];

class _UaDialogResult {
  final String value;
  final bool isCustom;

  const _UaDialogResult({required this.value, required this.isCustom});
}

class _UaDialog extends StatefulWidget {
  final String? value;
  final String customValue;

  const _UaDialog({this.value, required this.customValue});

  @override
  State<_UaDialog> createState() => _UaDialogState();
}

class _UaDialogState extends State<_UaDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _customController;
  late String _groupValue;

  @override
  void initState() {
    super.initState();
    final value = widget.value ?? _defaultUaValue;
    _groupValue = _presetUas.contains(value) || value.isEmpty
        ? value
        : _customUaValue;
    _customController = TextEditingController(
      text: _groupValue == _customUaValue ? value : widget.customValue,
    );
  }

  void _handleChanged(String? value) {
    if (value == null) {
      return;
    }
    if (value == _customUaValue) {
      setState(() {
        _groupValue = value;
      });
      return;
    }
    Navigator.of(context).pop(_UaDialogResult(value: value, isCustom: false));
  }

  void _handleSubmit() {
    if (_groupValue == _customUaValue &&
        _formKey.currentState?.validate() == false) {
      return;
    }
    Navigator.of(context).pop(
      _UaDialogResult(
        value: _groupValue == _customUaValue
            ? _customController.text
            : _groupValue,
        isCustom: _groupValue == _customUaValue,
      ),
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.userAgent,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: RadioGroup<String>(
          groupValue: _groupValue,
          onChanged: _handleChanged,
          child: Wrap(
            runSpacing: 8,
            children: [
              ListItem.radio(
                value: _defaultUaValue,
                onTap: () {
                  Navigator.of(context).pop(
                    const _UaDialogResult(
                      value: _defaultUaValue,
                      isCustom: false,
                    ),
                  );
                },
                title: Text(appLocalizations.defaultText),
              ),
              for (final ua in _presetUas)
                ListItem.radio(
                  value: ua,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop(_UaDialogResult(value: ua, isCustom: false));
                  },
                  title: Text(ua),
                ),
              ListItem.radio(
                value: _customUaValue,
                onTap: () {
                  setState(() {
                    _groupValue = _customUaValue;
                  });
                },
                title: Builder(
                  builder: (context) {
                    final titleStyle = DefaultTextStyle.of(context).style;
                    return TextFormField(
                      enabled: _groupValue == _customUaValue,
                      style: titleStyle,
                      maxLength: TextInputLimits.userAgent,
                      inputFormatters: TextInputLimits.limit(
                        TextInputLimits.userAgent,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        counterText: '',
                        hintStyle: titleStyle,
                        hintText: appLocalizations.custom,
                      ),
                      keyboardType: TextInputType.url,
                      maxLines: 1,
                      controller: _customController,
                      onChanged: (value) {
                        setState(() {
                          _groupValue = _customUaValue;
                        });
                      },
                      onFieldSubmitted: (_) {
                        _handleSubmit();
                      },
                      validator: (value) {
                        if (_groupValue == _customUaValue &&
                            (value == null || value.trim().isEmpty)) {
                          return appLocalizations.emptyTip(
                            appLocalizations.userAgent,
                          );
                        }
                        return null;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
