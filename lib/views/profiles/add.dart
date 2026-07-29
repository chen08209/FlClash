import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AddProfileView extends StatelessWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile() async {
    globalState.container
        .read(profilesActionProvider.notifier)
        .addProfileFormFile();
  }

  Future<void> _handleAddProfileFormURL(
    String url, {
    String sourceUrl = '',
  }) async {
    globalState.container
        .read(profilesActionProvider.notifier)
        .addProfileFormURL(url, sourceUrl: sourceUrl);
  }

  Future<void> _handleAddFreeNodesProfile() async {
    globalState.container
        .read(profilesActionProvider.notifier)
        .addFreeNodesProfile();
  }

  Future<void> _toScan() async {
    if (system.isDesktop) {
      globalState.container
          .read(profilesActionProvider.notifier)
          .addProfileFormQrCode();
      return;
    }
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAddProfileFormURL(url);
      });
    }
  }

  Future<void> _toAdd() async {
    final appLocalizations = context.appLocalizations;
    final input = await globalState.showCommonDialog<_ProfileUrlInput>(
      child: _ProfileUrlDialog(title: appLocalizations.importFromURL),
    );
    if (input != null) {
      _handleAddProfileFormURL(input.url, sourceUrl: input.sourceUrl);
    }
  }

  @override
  Widget build(context) {
    final appLocalizations = context.appLocalizations;
    return ListView(
      children: [
        ListItem(
          leading: const Icon(Icons.qr_code_sharp),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: _toScan,
        ),
        ListItem(
          leading: const Icon(Icons.upload_file_sharp),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: _handleAddProfileFormFile,
        ),
        ListItem(
          leading: const Icon(Icons.cloud_download_sharp),
          title: Text(appLocalizations.url),
          subtitle: Text(appLocalizations.urlDesc),
          onTap: _toAdd,
        ),
        ListItem(
          leading: const Icon(Icons.travel_explore_outlined),
          title: const Text('免费节点'),
          subtitle: const Text('聚合多个免费节点来源，自动检查且每日最多更新一次'),
          onTap: _handleAddFreeNodesProfile,
        ),
      ],
    );
  }
}

class _ProfileUrlInput {
  final String url;
  final String sourceUrl;

  const _ProfileUrlInput({required this.url, required this.sourceUrl});
}

class _ProfileUrlDialog extends StatefulWidget {
  final String title;

  const _ProfileUrlDialog({required this.title});

  @override
  State<_ProfileUrlDialog> createState() => _ProfileUrlDialogState();
}

class _ProfileUrlDialogState extends State<_ProfileUrlDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _sourceUrlController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _ProfileUrlInput(
        url: _urlController.text.trim(),
        sourceUrl: _sourceUrlController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _sourceUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: widget.title,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(appLocalizations.submit)),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextFormField(
              controller: _urlController,
              inputFormatters: TextInputLimits.limit(TextInputLimits.url),
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.url,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return appLocalizations.emptyTip('').trim();
                if (!text.isUrl) return appLocalizations.urlTip('').trim();
                return null;
              },
            ),
            TextFormField(
              controller: _sourceUrlController,
              inputFormatters: TextInputLimits.limit(TextInputLimits.url),
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '原订阅网站（可选）',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                if (!text.isUrl) return appLocalizations.urlTip('').trim();
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  final _urlController = TextEditingController();

  Future<void> _handleAddProfileFormURL() async {
    final url = _urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 5,
              inputFormatters: TextInputLimits.limit(TextInputLimits.url),
              onSubmitted: (_) {
                _handleAddProfileFormURL();
              },
              onEditingComplete: _handleAddProfileFormURL,
              controller: _urlController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
