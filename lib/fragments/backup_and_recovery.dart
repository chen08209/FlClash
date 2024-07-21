import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/dav_client.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/models/dav.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackupAndRecovery extends StatefulWidget {
  const BackupAndRecovery({super.key});

  @override
  State<BackupAndRecovery> createState() => _BackupAndRecoveryState();
}

class _BackupAndRecoveryState extends State<BackupAndRecovery> {
  DAVClient? _client;

  _showAddWebDAV(DAV? dav) async {
    await globalState.showCommonDialog<String>(
      child: WebDAVFormDialog(
        dav: dav?.copyWith(),
      ),
    );
  }

  _backup() async {
    final commonScaffoldState = context.commonScaffoldState;
    final res = await commonScaffoldState?.loadingRun<bool>(() async {
      return await _client?.backup();
    });
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.backup,
      message: TextSpan(text: appLocalizations.backupSuccess),
    );
  }

  _recovery(RecoveryOption recoveryOption) async {
    final commonScaffoldState = context.commonScaffoldState;
    final res = await commonScaffoldState?.loadingRun<bool>(() async {
      return await _client?.recovery(recoveryOption: recoveryOption);
    });
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.recovery,
      message: TextSpan(text: appLocalizations.recoverySuccess),
    );
  }

  _handleRecovery() async {
    final recoveryOption = await globalState.showCommonDialog<RecoveryOption>(
      child: const RecoveryOptionsDialog(),
    );
    if (recoveryOption == null) return;
    _recovery(recoveryOption);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Config, DAV?>(
      selector: (_, config) => config.dav,
      builder: (_, dav, __) {
        if (dav == null) {
          return ListView(
            children: [
              ListHeader(
                title: appLocalizations.account,
              ),
              ListItem(
                leading: const Icon(Icons.account_box),
                title: Text(appLocalizations.noInfo),
                subtitle: Text(appLocalizations.pleaseBindWebDAV),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    _showAddWebDAV(dav);
                  },
                  child: Text(
                    appLocalizations.bind,
                  ),
                ),
              ),
            ],
          );
        }
        _client = DAVClient(dav);
        final pingFuture = _client!.pingCompleter.future;
        return ListView(
          children: [
            ListHeader(title: appLocalizations.account),
            ListItem(
              leading: const Icon(Icons.account_box),
              title: TooltipText(
                text: Text(
                  dav.user,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(appLocalizations.connectivity),
                    FutureBuilder<bool>(
                      future: pingFuture,
                      builder: (_, snapshot) {
                        return Center(
                          child: FadeBox(
                            key: const Key("fade_box_1"),
                            child: snapshot.connectionState == ConnectionState.waiting
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: snapshot.data == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    width: 12,
                                    height: 12,
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              trailing: FilledButton.tonal(
                onPressed: () {
                  _showAddWebDAV(dav);
                },
                child: Text(
                  appLocalizations.edit,
                ),
              ),
            ),
            FutureBuilder<bool>(
              future: pingFuture,
              builder: (_, snapshot) {
                return FadeBox(
                  key: const Key("fade_box_2"),
                  child: snapshot.data == true
                      ? Column(
                          children: [
                            ListHeader(
                                title: appLocalizations.backupAndRecovery),
                            ListItem(
                              onTap: _backup,
                              title: Text(appLocalizations.backup),
                              subtitle: Text(appLocalizations.backupDesc),
                            ),
                            ListItem(
                              onTap: _handleRecovery,
                              title: Text(appLocalizations.recovery),
                              subtitle: Text(appLocalizations.recoveryDesc),
                            ),
                          ],
                        )
                      : Container(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class WebDAVFormDialog extends StatefulWidget {
  final DAV? dav;

  const WebDAVFormDialog({super.key, this.dav});

  @override
  State<WebDAVFormDialog> createState() => _WebDAVFormDialogState();
}

class _WebDAVFormDialogState extends State<WebDAVFormDialog> {
  late TextEditingController uriController;
  late TextEditingController userController;
  late TextEditingController passwordController;
  final _obscureController = ValueNotifier<bool>(true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    uriController = TextEditingController(text: widget.dav?.uri);
    userController = TextEditingController(text: widget.dav?.user);
    passwordController = TextEditingController(text: widget.dav?.password);
  }

  _submit() {
    if (!_formKey.currentState!.validate()) return;
    globalState.appController.config.dav = DAV(
      uri: uriController.text,
      user: userController.text,
      password: passwordController.text,
    );
    Navigator.pop(context);
  }

  _delete() {
    globalState.appController.config.dav = null;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    _obscureController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(appLocalizations.webDAVConfiguration),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: dialogCommonWidth,
          child: Wrap(
            runSpacing: 16,
            children: [
              TextFormField(
                controller: uriController,
                maxLines: 2,
                minLines: 1,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.address,
                  helperText: appLocalizations.addressHelp,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty || !value.isUrl) {
                    return appLocalizations.addressTip;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: userController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.account_circle),
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.account,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.accountTip;
                  }
                  return null;
                },
              ),
              ValueListenableBuilder(
                valueListenable: _obscureController,
                builder: (_, obscure, __) {
                  return TextFormField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _obscureController.value = !obscure;
                        },
                      ),
                      labelText: appLocalizations.password,
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.passwordTip;
                      }
                      return null;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.dav != null)
          TextButton(
            onPressed: _delete,
            child: Text(appLocalizations.delete),
          ),
        TextButton(
          onPressed: _submit,
          child: Text(appLocalizations.save),
        )
      ],
    );
  }
}

class RecoveryOptionsDialog extends StatefulWidget {
  const RecoveryOptionsDialog({super.key});

  @override
  State<RecoveryOptionsDialog> createState() => _RecoveryOptionsDialogState();
}

class _RecoveryOptionsDialogState extends State<RecoveryOptionsDialog> {
  _handleOnTab(RecoveryOption? value) {
    if (value == null) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(appLocalizations.recovery),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      content: SizedBox(
        width: 250,
        child: Wrap(
          children: [
            ListItem(
              onTap: () {
                _handleOnTab(RecoveryOption.onlyProfiles);
              },
              title: Text(appLocalizations.recoveryProfiles),
            ),
            ListItem(
              onTap: () {
                _handleOnTab(RecoveryOption.all);
              },
              title: Text(appLocalizations.recoveryAll),
            )
          ],
        ),
      ),
    );
  }
}
