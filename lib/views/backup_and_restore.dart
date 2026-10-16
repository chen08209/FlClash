import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/dav_client.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/widgets/config_item.dart';
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
    await showFormSheet<void>(
      context: context,
      builder: (_) => WebDAVForm(dav: dav?.copyWith()),
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
          generateSection(
            title: appLocalizations.remote,
            items: [
              if (dav == null)
                ListItem(
                  leading: const GlyphIcon(AppGlyphs.account),
                  title: Text(appLocalizations.noInfo),
                  subtitle: Text(appLocalizations.pleaseBindWebDAV),
                  trailing: TonalButton(
                    label: appLocalizations.bind,
                    onPressed: () {
                      _showAddWebDAV(dav);
                    },
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
                  trailing: TonalButton(
                    label: appLocalizations.edit,
                    onPressed: () {
                      _showAddWebDAV(dav);
                    },
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
          generateSection(
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
          generateSection(
            title: appLocalizations.options,
            items: [
              ConfigOptionsItem<RestoreStrategy>(
                title: (l) => l.restoreStrategy,
                options: RestoreStrategy.values,
                textBuilder: (strategy) => strategy.label,
                selector: appSettingProvider.select(
                  (state) => state.restoreStrategy,
                ),
                onChanged: (ref, value) => ref
                    .read(appSettingProvider.notifier)
                    .update((state) => state.copyWith(restoreStrategy: value)),
              ),
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
                ? const CommonCircleLoading(size: 12)
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

enum _DavField { uri, user, password }

class WebDAVForm extends ConsumerStatefulWidget {
  final DAVProps? dav;

  const WebDAVForm({super.key, this.dav});

  @override
  ConsumerState<WebDAVForm> createState() => _WebDAVFormState();
}

class _WebDAVFormState extends ConsumerState<WebDAVForm> {
  late final TextEditingController _uriController;
  late final TextEditingController _userController;
  late final TextEditingController _passwordController;
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    _uriController = TextEditingController(text: widget.dav?.uri);
    _userController = TextEditingController(text: widget.dav?.user);
    _passwordController = TextEditingController(text: widget.dav?.password);
  }

  @override
  void dispose() {
    _uriController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  ({_DavField field, String message})? _issue(
    AppLocalizations appLocalizations,
  ) {
    final uri = _uriController.text;
    if (uri.isEmpty || !uri.isUrl) {
      return (field: _DavField.uri, message: appLocalizations.addressTip);
    }
    if (_userController.text.isEmpty) {
      return (
        field: _DavField.user,
        message: appLocalizations.emptyTip(appLocalizations.account),
      );
    }
    if (_passwordController.text.isEmpty) {
      return (
        field: _DavField.password,
        message: appLocalizations.emptyTip(appLocalizations.password),
      );
    }
    return null;
  }

  void _handleChanged(String _) {
    if (_attempted) {
      setState(() {});
    }
  }

  void _submit() {
    if (_issue(context.appLocalizations) != null) {
      setState(() {
        _attempted = true;
      });
      return;
    }
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
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final issue = _attempted ? _issue(appLocalizations) : null;
    return FormPage(
      title: appLocalizations.webDAVConfiguration,
      onSave: _submit,
      error: issue?.message,
      children: [
        generateSection(
          footer: appLocalizations.addressHelp,
          items: [
            FormRow(
              title: appLocalizations.address,
              invalid: issue?.field == _DavField.uri,
              trailing: FormRowTextField(
                controller: _uriController,
                hintText: appLocalizations.required,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                inputFormatters: TextInputLimits.limit(TextInputLimits.uri),
                onChanged: _handleChanged,
              ),
            ),
            FormRow(
              title: appLocalizations.account,
              invalid: issue?.field == _DavField.user,
              trailing: FormRowTextField(
                controller: _userController,
                hintText: appLocalizations.required,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                inputFormatters: TextInputLimits.limit(
                  TextInputLimits.userName,
                ),
                onChanged: _handleChanged,
              ),
            ),
            FormRow(
              title: appLocalizations.password,
              invalid: issue?.field == _DavField.password,
              trailing: FormRowSecretTextField(
                controller: _passwordController,
                hintText: appLocalizations.required,
                textInputAction: TextInputAction.done,
                inputFormatters: TextInputLimits.limit(
                  TextInputLimits.password,
                ),
                onChanged: _handleChanged,
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
          ],
        ),
        if (widget.dav != null)
          generateSection(
            items: [
              FormRow(
                title: appLocalizations.delete,
                titleStyle: TextStyle(color: context.colorScheme.error),
                onPressed: _delete,
              ),
            ],
          ),
      ],
    );
  }
}
