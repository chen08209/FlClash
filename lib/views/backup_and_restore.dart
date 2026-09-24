import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/dav_client.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/navigation_dock.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:fl_clash/widgets/input.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:fl_clash/widgets/loading.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupAndRestore extends ConsumerStatefulWidget {
  const BackupAndRestore({super.key});

  @override
  ConsumerState<BackupAndRestore> createState() => _BackupAndRestoreState();
}

class _BackupAndRestoreState extends ConsumerState<BackupAndRestore>
    with UniqueKeyStateMixin {
  final _davConnection = DAVConnectionController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(davSettingProvider, (_, _) {
      _updateDAVClient();
    }, fireImmediately: true);
  }

  void _updateDAVClient() {
    unawaited(_davConnection.update(ref.read(davSettingProvider)));
  }

  @override
  void dispose() {
    _davConnection.dispose();
    super.dispose();
  }

  Future<void> _showAddWebDAV(DAVProps? dav) async {
    await dialogs.showCommonDialog<String>(
      child: WebDAVFormDialog(dav: dav?.copyWith()),
    );
  }

  Future<void> _run({
    required String title,
    required String successMessage,
    required Future<bool> Function() task,
  }) async {
    final res = await globalState.loadingRun<bool>(
      task,
      tag: LoadingTag.backup_restore,
      title: title,
    );
    if (res != true) return;
    unawaited(
      dialogs.showMessage(
        title: title,
        message: TextSpan(text: successMessage),
      ),
    );
  }

  Future<void> _backup(BackupDelivery deliver) {
    final appLocalizations = context.appLocalizations;
    return _run(
      title: appLocalizations.backup,
      successMessage: appLocalizations.backupSuccess,
      task: () => ref.read(backupActionProvider.notifier).backup(deliver),
    );
  }

  Future<void> _restore(RestoreOption option, BackupFetch fetch) {
    final appLocalizations = context.appLocalizations;
    return _run(
      title: appLocalizations.restore,
      successMessage: appLocalizations.restoreSuccess,
      task: () =>
          ref.read(backupActionProvider.notifier).restore(option, fetch),
    );
  }

  Future<RestoreOption?> _pickRestoreOption() {
    return dialogs.showCommonDialog<RestoreOption>(
      child: const RestoreOptionsDialog(),
    );
  }

  Future<void> _backupOnWebDAV() async {
    final client = _davConnection.client;
    if (client == null) return;
    await _backup((archivePath) async {
      await client.upload(archivePath);
      return true;
    });
  }

  Future<void> _restoreOnWebDAV() async {
    final client = _davConnection.client;
    if (client == null) return;
    final option = await _pickRestoreOption();
    if (option == null || !mounted) return;
    await _restore(option, (downloadPath) async {
      await client.download(downloadPath);
      return downloadPath;
    });
  }

  Future<void> _backupOnLocal() {
    return _backup((archivePath) async {
      final savedPath = await picker.saveFileWithPath(
        getBackupFileName(),
        archivePath,
      );
      return savedPath != null;
    });
  }

  Future<void> _restoreOnLocal() async {
    final option = await _pickRestoreOption();
    if (option == null || !mounted) return;
    final file = await picker.pickerFile();
    final path = file?.path;
    if (path == null || !mounted) return;
    await _restore(option, (_) async => path);
  }

  void _handleChange(String? value, WidgetRef ref) {
    if (value == null) {
      return;
    }
    ref
        .read(davSettingProvider.notifier)
        .update((state) => state?.copyWith(fileName: value));
  }

  Future<void> _handleUpdateRestoreStrategy() async {
    final restoreStrategy = ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final res = await dialogs.showCommonDialog(
      child: OptionsDialog<RestoreStrategy>(
        title: currentAppLocalizations.restoreStrategy,
        options: RestoreStrategy.values,
        textBuilder: (mode) => mode.label,
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
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final dav = ref.watch(davSettingProvider);
    final isLoading = ref.watch(loadingProvider(LoadingTag.backup_restore));
    return CommonScaffold(
      isLoading: isLoading,
      title: appLocalizations.backupAndRestore,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.appBarInset, bottom: 16),
        children: [
          generateSectionV3(
            title: appLocalizations.remote,
            items: [
              if (dav == null)
                ListItem(
                  leading: const GlyphIcon(AppGlyphs.account),
                  title: Text(appLocalizations.noInfo),
                  subtitle: Text(appLocalizations.pleaseBindWebDAV),
                  trailing: ElasticButton(
                    child: FilledButton.tonal(
                      onPressed: () {
                        _showAddWebDAV(dav);
                      },
                      child: Text(appLocalizations.bind),
                    ),
                  ),
                )
              else ...[
                ListItem(
                  leading: const GlyphIcon(AppGlyphs.account),
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
                        _DavConnectionIndicator(connection: _davConnection),
                      ],
                    ),
                  ),
                  trailing: ElasticButton(
                    child: FilledButton.tonal(
                      onPressed: () {
                        _showAddWebDAV(dav);
                      },
                      child: Text(appLocalizations.edit),
                    ),
                  ),
                ),
                ListItem.input(
                  title: Text(appLocalizations.file),
                  subtitle: Text(dav.fileName),
                  dialogTitle: appLocalizations.file,
                  value: dav.fileName,
                  resetValue: defaultDavFileName,
                  maxLength: TextInputLimits.fileName,
                  onChanged: (value) {
                    _handleChange(value, ref);
                  },
                ),
                ListItem(
                  onTap: () {
                    _backupOnWebDAV();
                  },
                  title: Text(appLocalizations.backup),
                ),
                ListItem(
                  onTap: () {
                    _restoreOnWebDAV();
                  },
                  title: Text(appLocalizations.restore),
                ),
              ],
            ],
          ),
          generateSectionV3(
            title: appLocalizations.local,
            items: [
              ListItem(
                onTap: () {
                  _backupOnLocal();
                },
                title: Text(appLocalizations.backup),
              ),
              ListItem(
                onTap: () {
                  _restoreOnLocal();
                },
                title: Text(appLocalizations.restore),
              ),
            ],
          ),
          generateSectionV3(
            title: appLocalizations.options,
            items: [
              _RestoreStrategyItem(onPressed: _handleUpdateRestoreStrategy),
            ],
          ),
        ],
      ),
    );
  }
}

class _DavConnectionIndicator extends StatelessWidget {
  const _DavConnectionIndicator({required this.connection});

  final ValueNotifier<bool?> connection;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: connection,
      builder: (context, isConnected, _) {
        return Center(
          child: FadeThroughBox(
            child: isConnected == null
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CommonCircleLoading(),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !isConnected
                          ? context.colorScheme.error
                          : context.colorScheme.success,
                    ),
                    width: 12,
                    height: 12,
                  ),
          ),
        );
      },
    );
  }
}

class _RestoreStrategyItem extends ConsumerWidget {
  const _RestoreStrategyItem({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreStrategy = ref.watch(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    return ListItem(
      onTap: onPressed,
      title: Text(context.appLocalizations.restoreStrategy),
      trailing: ElasticButton(
        child: FilledButton(
          onPressed: onPressed,
          child: Text(restoreStrategy.label),
        ),
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
    final appLocalizations = context.appLocalizations;
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
    ref
        .read(davSettingProvider.notifier)
        .update(
          (_) => DAVProps(
            uri: _uriController.text,
            user: _userController.text,
            password: _passwordController.text,
            fileName: widget.dav?.fileName ?? defaultDavFileName,
          ),
        );
    Navigator.pop(context);
  }

  void _delete() {
    ref.read(davSettingProvider.notifier).update((_) => null);
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
    final appLocalizations = context.appLocalizations;
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
              inputFormatters: TextInputLimits.limit(TextInputLimits.uri),
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: const GlyphIcon(AppGlyphs.link),
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
              inputFormatters: TextInputLimits.limit(TextInputLimits.userName),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: const GlyphIcon(AppGlyphs.account),
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
                  inputFormatters: TextInputLimits.limit(
                    TextInputLimits.password,
                  ),
                  obscureText: obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _submit();
                  },
                  decoration: InputDecoration(
                    prefixIcon: const GlyphIcon(AppGlyphs.password),
                    suffixIcon: IconButton(
                      tooltip: obscure
                          ? context.appLocalizations.showPassword
                          : context.appLocalizations.hidePassword,
                      icon: GlyphIcon(
                        obscure ? AppGlyphs.eye : AppGlyphs.eyeOff,
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
