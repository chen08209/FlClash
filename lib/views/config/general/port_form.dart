part of '../general.dart';

const _minPort = 1024;
const _maxPort = 49151;

class _PortField {
  final TextEditingController controller;
  final String Function(AppLocalizations appLocalizations) label;
  final bool allowDisabled;

  const _PortField({
    required this.controller,
    required this.label,
    this.allowDisabled = true,
  });
}

class _PortForm extends ConsumerStatefulWidget {
  const _PortForm();

  @override
  ConsumerState<_PortForm> createState() => _PortFormState();
}

class _PortFormState extends ConsumerState<_PortForm> {
  late final TextEditingController _mixedPortController;
  late final TextEditingController _portController;
  late final TextEditingController _socksPortController;
  late final TextEditingController _redirPortController;
  late final TextEditingController _tProxyPortController;
  late final List<_PortField> _fields;

  @override
  void initState() {
    super.initState();
    final ports = ref.read(
      patchClashConfigProvider.select((state) {
        return (
          mixed: state.mixedPort,
          http: state.port,
          socks: state.socksPort,
          redir: state.redirPort,
          tproxy: state.tproxyPort,
        );
      }),
    );
    _mixedPortController = TextEditingController(text: ports.mixed.toString());
    _portController = TextEditingController(text: ports.http.toString());
    _socksPortController = TextEditingController(text: ports.socks.toString());
    _redirPortController = TextEditingController(text: ports.redir.toString());
    _tProxyPortController = TextEditingController(
      text: ports.tproxy.toString(),
    );
    _fields = [
      _PortField(
        controller: _mixedPortController,
        label: (appLocalizations) => appLocalizations.mixedPort,
        allowDisabled: false,
      ),
      _PortField(
        controller: _portController,
        label: (appLocalizations) => appLocalizations.port,
      ),
      _PortField(
        controller: _socksPortController,
        label: (appLocalizations) => appLocalizations.socksPort,
      ),
      _PortField(
        controller: _redirPortController,
        label: (appLocalizations) => appLocalizations.redirPort,
      ),
      _PortField(
        controller: _tProxyPortController,
        label: (appLocalizations) => appLocalizations.tproxyPort,
      ),
    ];
  }

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetTip),
      destructive: true,
      confirmText: context.appLocalizations.reset,
    );
    if (res != true) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mixedPort: 7890,
            port: 0,
            socksPort: 0,
            redirPort: 0,
            tproxyPort: 0,
          ),
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Map<_PortField, String> _issues(AppLocalizations appLocalizations) {
    return {
      for (final field in _fields)
        field: ?validatePort(field, field.controller.text, appLocalizations),
    };
  }

  void _handleUpdate() {
    if (_issues(context.appLocalizations).isNotEmpty) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mixedPort: int.parse(_mixedPortController.text),
            port: int.parse(_portController.text),
            socksPort: int.parse(_socksPortController.text),
            redirPort: int.parse(_redirPortController.text),
            tproxyPort: int.parse(_tProxyPortController.text),
          ),
        );
    Navigator.of(context).pop();
  }

  @visibleForTesting
  String? validatePort(
    _PortField field,
    String? value,
    AppLocalizations appLocalizations,
  ) {
    final label = field.label(appLocalizations);
    if (value == null || value.isEmpty) {
      return appLocalizations.emptyTip(label);
    }
    final port = int.tryParse(value);
    if (port == null) {
      return appLocalizations.numberTip(label);
    }
    if (field.allowDisabled && port == 0) {
      return null;
    }
    if (port < _minPort || port > _maxPort) {
      return appLocalizations.portTip(label);
    }
    final others = _fields
        .where((item) => item != field)
        .map((item) => int.tryParse(item.controller.text.trim()));
    if (others.contains(port)) {
      return appLocalizations.portConflictTip;
    }
    return null;
  }

  @override
  void dispose() {
    _mixedPortController.dispose();
    _portController.dispose();
    _socksPortController.dispose();
    _redirPortController.dispose();
    _tProxyPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final issues = _issues(appLocalizations);
    return FormPage(
      title: appLocalizations.port,
      onSave: _handleUpdate,
      error: issues.values.firstOrNull,
      children: [
        generateSection(
          items: [
            for (final field in _fields)
              FormRow(
                title: field.label(appLocalizations),
                invalid: issues.containsKey(field),
                trailing: FormRowTextField(
                  controller: field.controller,
                  hintText: appLocalizations.required,
                  keyboardType: TextInputType.number,
                  textInputAction: field == _fields.last
                      ? TextInputAction.done
                      : TextInputAction.next,
                  inputFormatters: TextInputLimits.digitsOnly(
                    TextInputLimits.port,
                  ),
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _handleUpdate(),
                ),
              ),
          ],
        ),
        generateSection(
          items: [
            FormRow(title: appLocalizations.reset, onPressed: _handleReset),
          ],
        ),
      ],
    );
  }
}
