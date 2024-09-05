import 'dart:typed_data';

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

class BackupAndRecovery extends StatelessWidget {
  const BackupAndRecovery({super.key});

  _showAddWebDAV(DAV? dav) async {
    await globalState.showCommonDialog<String>(
      child: WebDAVFormDialog(
        dav: dav?.copyWith(),
      ),
    );
  }

  _backupOnWebDAV(BuildContext context, DAVClient client) async {
    final commonScaffoldState = context.commonScaffoldState;
    final res = await commonScaffoldState?.loadingRun<bool>(
      () async {
        final backupData = await globalState.appController.backupData();
        return await client.backup(Uint8List.fromList(backupData));
      },
      title: appLocalizations.backup,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.backup,
      message: TextSpan(text: appLocalizations.backupSuccess),
    );
  }

  _recoveryOnWebDAV(
    BuildContext context,
    DAVClient client,
    RecoveryOption recoveryOption,
  ) async {
    final commonScaffoldState = context.commonScaffoldState;
    final res = await commonScaffoldState?.loadingRun<bool>(
      () async {
        final data = await client.recovery();
        await globalState.appController.recoveryData(data, recoveryOption);
        return true;
      },
      title: appLocalizations.recovery,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.recovery,
      message: TextSpan(text: appLocalizations.recoverySuccess),
    );
  }

  _handleRecoveryOnWebDAV(BuildContext context, DAVClient client) async {
    final recoveryOption = await globalState.showCommonDialog<RecoveryOption>(
      child: const RecoveryOptionsDialog(),
    );
    if (recoveryOption == null || !context.mounted) return;
    _recoveryOnWebDAV(context, client, recoveryOption);
  }

  _backupOnLocal(BuildContext context) async {
    final commonScaffoldState = context.commonScaffoldState;
    final res = await commonScaffoldState?.loadingRun<bool>(
      () async {
        final backupData = await globalState.appController.backupData();
        final value = await picker.saveFile(
          other.getBackupFileName(),
          Uint8List.fromList(backupData),
        );
        if (value == null) return false;
        return true;
      },
      title: appLocalizations.backup,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.backup,
      message: TextSpan(text: appLocalizations.backupSuccess),
    );
  }

  _recoveryOnLocal(
    BuildContext context,
    RecoveryOption recoveryOption,
  ) async {
    final file = await picker.pickerFile();
    final data = file?.bytes;
    if (data == null || !context.mounted) return;
    final commonScaffoldState = context.commonScaffoldState;
    final res = await commonScaffoldState?.loadingRun<bool>(
      () async {
        await globalState.appController.recoveryData(
          List<int>.from(data),
          recoveryOption,
        );
        return true;
      },
      title: appLocalizations.recovery,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.recovery,
      message: TextSpan(text: appLocalizations.recoverySuccess),
    );
  }

  _handleRecoveryOnLocal(BuildContext context) async {
    final recoveryOption = await globalState.showCommonDialog<RecoveryOption>(
      child: const RecoveryOptionsDialog(),
    );
    if (recoveryOption == null || !context.mounted) return;
    _recoveryOnLocal(context, recoveryOption);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Config, DAV?>(
      selector: (_, config) => config.dav,
      builder: (_, dav, __) {
        final client = dav != null ? DAVClient(dav) : null;
        return ListView(
          children: [
            ListHeader(title: appLocalizations.remote),
            if (dav == null)
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
              )
            else ...[
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
                        future: client!.pingCompleter.future,
                        builder: (_, snapshot) {
                          return Center(
                            child: FadeBox(
                              child: snapshot.connectionState ==
                                      ConnectionState.waiting
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
              const SizedBox(
                height: 4,
              ),
              ListItem.input(
                title: Text(appLocalizations.file),
                subtitle: Text(dav.fileName),
                delegate: InputDelegate(
                  title: appLocalizations.file,
                  value: dav.fileName,
                  resetValue: defaultDavFileName,
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    globalState.appController.config.dav =
                        globalState.appController.config.dav?.copyWith(
                      fileName: value,
                    );
                  },
                ),
              ),
              ListItem(
                onTap: () {
                  _backupOnWebDAV(context, client);
                },
                title: Text(appLocalizations.backup),
                subtitle: Text(appLocalizations.remoteBackupDesc),
              ),
              ListItem(
                onTap: () {
                  _handleRecoveryOnWebDAV(context, client);
                },
                title: Text(appLocalizations.recovery),
                subtitle: Text(appLocalizations.remoteRecoveryDesc),
              ),
            ],
            ListHeader(title: appLocalizations.local),
            ListItem(
              onTap: () {
                _backupOnLocal(context);
              },
              title: Text(appLocalizations.backup),
              subtitle: Text(appLocalizations.localBackupDesc),
            ),
            ListItem(
              onTap: () {
                _handleRecoveryOnLocal(context);
              },
              title: Text(appLocalizations.recovery),
              subtitle: Text(appLocalizations.localRecoveryDesc),
            ),
          ],
        );
      },
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
                maxLines: 5,
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
