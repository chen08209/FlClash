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

class _PortDialog extends ConsumerStatefulWidget {
  const _PortDialog();

  @override
  ConsumerState<_PortDialog> createState() => _PortDialogState();
}

class _PortDialogState extends ConsumerState<_PortDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isMore = false;

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

  void _handleUpdate() {
    final appLocalizations = context.appLocalizations;
    final hasInvalid = _fields.any(
      (field) =>
          validatePort(field, field.controller.text, appLocalizations) != null,
    );
    if (hasInvalid) {
      if (_isMore) {
        _formKey.currentState?.validate();
        return;
      }
      setState(() {
        _isMore = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _formKey.currentState?.validate();
      });
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

  void _handleMore() {
    setState(() {
      _isMore = !_isMore;
    });
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
        .map((item) => item.controller.text.trim());
    if (others.contains(value.trim())) {
      return appLocalizations.portConflictTip;
    }
    return null;
  }

  Widget _buildField(_PortField field, AppLocalizations appLocalizations) {
    return TextFormField(
      keyboardType: TextInputType.number,
      maxLines: 1,
      minLines: 1,
      inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.port),
      controller: field.controller,
      onFieldSubmitted: (_) {
        _handleUpdate();
      },
      decoration: InputDecoration(labelText: field.label(appLocalizations)),
      validator: (value) => validatePort(field, value, appLocalizations),
    );
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
    return CommonDialog(
      title: appLocalizations.port,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              tooltip: _isMore
                  ? context.appLocalizations.showLess
                  : context.appLocalizations.showMore,
              onPressed: _handleMore,
              icon: CommonExpandIcon(expand: _isMore),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _handleReset,
                  child: Text(appLocalizations.reset),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _handleUpdate,
                  child: Text(appLocalizations.submit),
                ),
              ],
            ),
          ],
        ),
      ],
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AnimatedSize(
            duration: midDuration,
            curve: Curves.easeOutQuad,
            alignment: Alignment.topCenter,
            child: Column(
              spacing: 24,
              children: [
                _buildField(_fields.first, appLocalizations),
                if (_isMore)
                  ..._fields
                      .skip(1)
                      .map((field) => _buildField(field, appLocalizations)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
