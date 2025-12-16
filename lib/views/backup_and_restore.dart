import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/dav_client.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:fl_clash/widgets/input.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BackupAndRestore extends ConsumerWidget {
  const BackupAndRestore({super.key});

  Future<void> _showAddWebDAV(DAVProps? dav) async {
    await globalState.showCommonDialog<String>(
      child: WebDAVFormDialog(dav: dav?.copyWith()),
    );
  }

  Future<void> _backupOnWebDAV(DAVClient client) async {
    final res = await appController.loadingRun<bool>(
      () async {
        final path = await appController.backup();
        if (path.isEmpty) {
          return false;
        }
        return await client.backup(path);
      },
      tag: LoadingTag.backup_restore,
      title: appLocalizations.backup,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.backup,
      message: TextSpan(text: appLocalizations.backupSuccess),
    );
  }

  Future<void> _restoreOnWebDAV(
    BuildContext context,
    DAVClient client,
    RestoreOption option,
  ) async {
    final res = await appController.loadingRun<bool>(
      () async {
        await client.restore();
        await appController.restore(option);
        return true;
      },
      tag: LoadingTag.backup_restore,
      title: appLocalizations.restore,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.restore,
      message: TextSpan(text: appLocalizations.restoreSuccess),
    );
  }

  Future<void> _handleRestoreOnWebDAV(
    BuildContext context,
    DAVClient client,
  ) async {
    final restoreOption = await globalState.showCommonDialog<RestoreOption>(
      child: const RestoreOptionsDialog(),
    );
    if (restoreOption == null || !context.mounted) return;
    _restoreOnWebDAV(context, client, restoreOption);
  }

  Future<void> _backupOnLocal(BuildContext context) async {
    final res = await appController.loadingRun<bool>(
      () async {
        final path = await appController.backup();
        if (path.isEmpty) {
          return false;
        }
        final value = await picker.saveFileWithPath(
          utils.getBackupFileName(),
          path,
        );
        if (value == null) return false;
        return true;
      },
      title: appLocalizations.backup,
      tag: LoadingTag.backup_restore,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.backup,
      message: TextSpan(text: appLocalizations.backupSuccess),
    );
  }

  Future<void> _restoreOnLocal(RestoreOption option) async {
    final file = await picker.pickerFile(withData: false);
    final path = file?.path;
    if (path == null) return;
    await File(path).safeCopy(await appPath.backupFilePath);
    final res = await appController.loadingRun<bool>(
      () async {
        await appController.restore(option);
        return true;
      },
      tag: LoadingTag.backup_restore,
      title: appLocalizations.restore,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.restore,
      message: TextSpan(text: appLocalizations.restoreSuccess),
    );
  }

  Future<void> _handleRestoreOnLocal(BuildContext context) async {
    final option = await globalState.showCommonDialog<RestoreOption>(
      child: const RestoreOptionsDialog(),
    );
    if (option == null || !context.mounted) return;
    _restoreOnLocal(option);
  }

  void _handleChange(String? value, WidgetRef ref) {
    if (value == null) {
      return;
    }
    ref
        .read(davSettingProvider.notifier)
        .update((state) => state?.copyWith(fileName: value));
  }

  Future<void> _handleUpdateRestoreStrategy(WidgetRef ref) async {
    final restoreStrategy = ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final res = await globalState.showCommonDialog(
      child: OptionsDialog<RestoreStrategy>(
        title: appLocalizations.restoreStrategy,
        options: RestoreStrategy.values,
        textBuilder: (mode) => Intl.message('restoreStrategy_${mode.name}'),
        value: restoreStrategy,
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(restoreStrategy: res));
  }

  @override
  Widget build(BuildContext context, ref) {
    final dav = ref.watch(davSettingProvider);
    final isLoading = ref.watch(loadingProvider(LoadingTag.backup_restore));
    final client = dav != null ? DAVClient(dav) : null;
    return CommonScaffold(
      isLoading: isLoading,
      title: appLocalizations.backupAndRestore,
      body: ListView(
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
                child: Text(appLocalizations.bind),
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
                          child: FadeThroughBox(
                            child:
                                snapshot.connectionState != ConnectionState.done
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
                child: Text(appLocalizations.edit),
              ),
            ),
            const SizedBox(height: 4),
            ListItem.input(
              title: Text(appLocalizations.file),
              subtitle: Text(dav.fileName),
              delegate: InputDelegate(
                title: appLocalizations.file,
                value: dav.fileName,
                resetValue: defaultDavFileName,
                onChanged: (value) {
                  _handleChange(value, ref);
                },
              ),
            ),
            ListItem(
              onTap: () {
                _backupOnWebDAV(client);
              },
              title: Text(appLocalizations.backup),
              subtitle: Text(appLocalizations.remoteBackupDesc),
            ),
            ListItem(
              onTap: () {
                _handleRestoreOnWebDAV(context, client);
              },
              title: Text(appLocalizations.restore),
              subtitle: Text(appLocalizations.restoreFromWebDAVDesc),
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
              _handleRestoreOnLocal(context);
            },
            title: Text(appLocalizations.restore),
            subtitle: Text(appLocalizations.restoreFromFileDesc),
          ),
          ListHeader(title: appLocalizations.options),
          Consumer(
            builder: (_, ref, _) {
              final restoreStrategy = ref.watch(
                appSettingProvider.select((state) => state.restoreStrategy),
              );
              return ListItem(
                onTap: () {
                  _handleUpdateRestoreStrategy(ref);
                },
                title: Text(appLocalizations.restoreStrategy),
                trailing: FilledButton(
                  onPressed: () {
                    _handleUpdateRestoreStrategy(ref);
                  },
                  child: Text(
                    Intl.message('restoreStrategy_${restoreStrategy.name}'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RestoreOptionsDialog extends StatefulWidget {
  const RestoreOptionsDialog({super.key});

  @override
  State<RestoreOptionsDialog> createState() => _RestoreOptionsDialogState();
}

class _RestoreOptionsDialogState extends State<RestoreOptionsDialog> {
  void _handleOnTab(RestoreOption? option) {
    if (option == null) return;
    Navigator.of(context).pop(option);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.restore,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Wrap(
        children: [
          ListItem(
            onTap: () {
              _handleOnTab(RestoreOption.onlyProfiles);
            },
            title: Text(appLocalizations.restoreOnlyConfig),
          ),
          ListItem(
            onTap: () {
              _handleOnTab(RestoreOption.all);
            },
            title: Text(appLocalizations.restoreAllData),
          ),
        ],
      ),
    );
  }
}

class WebDAVFormDialog extends ConsumerStatefulWidget {
  final DAVProps? dav;

  const WebDAVFormDialog({super.key, this.dav});

  @override
  ConsumerState<WebDAVFormDialog> createState() => _WebDAVFormDialogState();
}

class _WebDAVFormDialogState extends ConsumerState<WebDAVFormDialog> {
  late TextEditingController _uriController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  final _obscureController = ValueNotifier<bool>(true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _uriController = TextEditingController(text: widget.dav?.uri);
    _userController = TextEditingController(text: widget.dav?.user);
    _passwordController = TextEditingController(text: widget.dav?.password);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(davSettingProvider.notifier).value = DAVProps(
      uri: _uriController.text,
      user: _userController.text,
      password: _passwordController.text,
    );
    Navigator.pop(context);
  }

  void _delete() {
    ref.read(davSettingProvider.notifier).value = null;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _obscureController.dispose();
    _uriController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.webDAVConfiguration,
      actions: [
        if (widget.dav != null)
          TextButton(onPressed: _delete, child: Text(appLocalizations.delete)),
        TextButton(onPressed: _submit, child: Text(appLocalizations.save)),
      ],
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextFormField(
              controller: _uriController,
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
              controller: _userController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_circle),
                border: const OutlineInputBorder(),
                labelText: appLocalizations.account,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(appLocalizations.account);
                }
                return null;
              },
            ),
            ValueListenableBuilder(
              valueListenable: _obscureController,
              builder: (_, obscure, _) {
                return TextFormField(
                  controller: _passwordController,
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
                      return appLocalizations.emptyTip(
                        appLocalizations.password,
                      );
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
