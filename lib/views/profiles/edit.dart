import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EditProfileView extends StatefulWidget {
  final Profile profile;
  final BuildContext context;

  const EditProfileView({
    super.key,
    required this.context,
    required this.profile,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;
  late final TextEditingController _loginPasswordController;
  late final TextEditingController _autoUpdateDurationController;
  late bool _autoUpdate;
  String? _rawText;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _fileInfoNotifier = ValueNotifier<FileInfo?>(null);
  Uint8List? _fileData;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.profile.label);
    _urlController = TextEditingController(text: widget.profile.url);
    _loginPasswordController = TextEditingController(text: widget.profile.loginPassword ?? '');
    _autoUpdate = widget.profile.autoUpdate;
    _autoUpdateDurationController = TextEditingController(
      text: widget.profile.autoUpdateDuration.inMinutes.toString(),
    );
    _updateFileInfo();
  }

  Future<void> _updateFileInfo() async {
    final file = await widget.profile.file;
    if (!await file.exists()) {
      return;
    }
    final lastModified = await file.lastModified();
    final size = await file.length();
    if (!mounted) {
      return;
    }
    _fileInfoNotifier.value = FileInfo(size: size, lastModified: lastModified);
  }

  Future<void> _handleConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    var profile = widget.profile.copyWith(
      url: _urlController.text,
      label: _labelController.text,
      autoUpdate: _autoUpdate,
      autoUpdateDuration: Duration(
        minutes: int.parse(_autoUpdateDurationController.text),
      ),
      loginPassword: _loginPasswordController.text.isEmpty ? null : _loginPasswordController.text,
    );
    final hasUpdate = widget.profile.url != profile.url;
    if (_fileData != null) {
      if (profile.type == ProfileType.url && _autoUpdate) {
        final res = await globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: appLocalizations.profileHasUpdate),
        );
        if (res == true) {
          profile = profile.copyWith(autoUpdate: false);
        }
      }
      appController.putProfile(await profile.saveFile(_fileData!));
    } else if (!hasUpdate) {
      appController.putProfile(profile);
    } else {
      appController.safeRun(() async {
        await Future.delayed(commonDuration);
        if (hasUpdate) {
          await appController.updateProfile(profile);
        }
      });
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _setAutoUpdate(bool value) {
    if (_autoUpdate == value) return;
    setState(() {
      _autoUpdate = value;
    });
  }

  Future<void> _handleSaveEdit(BuildContext context, String data) async {
    final message = await appController.safeRun<String>(() async {
      final message = await coreController.validateConfigWithData(data);
      return message;
    }, silence: false);
    if (message?.isNotEmpty == true) {
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: message),
      );
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pop(data);
    }
  }

  Future<void> _editProfileFile() async {
    if (_rawText == null) {
      final profilePath = await appPath.getProfilePath(
        widget.profile.id.toString(),
      );
      final file = File(profilePath);
      if (await file.exists()) {
        _rawText = await file.readAsString();
      }
    }
    if (!mounted) return;
    final title = widget.profile.label.takeFirstValid([
      widget.profile.id.toString(),
    ]);
    final editorPage = EditorPage(
      title: title,
      content: _rawText!,
      onSave: (context, _, content) {
        _handleSaveEdit(context, content);
      },
      onPop: (context, _, content) async {
        if (content == _rawText) {
          return true;
        }
        final res = await globalState.showMessage(
          title: title,
          message: TextSpan(text: appLocalizations.hasCacheChange),
        );
        if (res == true && context.mounted) {
          _handleSaveEdit(context, content);
        } else {
          return true;
        }
        return false;
      },
    );
    final data = await BaseNavigator.push<String>(context, editorPage);
    if (data == null) {
      return;
    }
    _rawText = data;
    _fileData = Uint8List.fromList(utf8.encode(data));
    _fileInfoNotifier.value = _fileInfoNotifier.value?.copyWith(
      size: _fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  Future<void> _uploadProfileFile() async {
    final platformFile = await appController.safeRun(picker.pickerFile);
    if (platformFile?.bytes == null) return;
    _fileData = platformFile?.bytes;
    if (!mounted) {
      return;
    }
    _fileInfoNotifier.value = _fileInfoNotifier.value?.copyWith(
      size: _fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  Future<void> _handleBack() async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.fileIsUpdate),
    );
    if (res == true) {
      _handleConfirm();
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _urlController.dispose();
    _loginPasswordController.dispose();
    _fileInfoNotifier.dispose();
    _autoUpdateDurationController.dispose();
    super.dispose();
    appController.autoApplyProfile();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ListItem(
        title: TextFormField(
          textInputAction: TextInputAction.next,
          controller: _labelController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: appLocalizations.name,
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return appLocalizations.profileNameNullValidationDesc;
            }
            return null;
          },
        ),
      ),
      if (widget.profile.type == ProfileType.url) ...[
        ListItem(
          title: TextFormField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.url,
            controller: _urlController,
            maxLines: 5,
            minLines: 1,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.url,
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return appLocalizations.profileUrlNullValidationDesc;
              }
              if (!value.isUrl) {
                return appLocalizations.profileUrlInvalidValidationDesc;
              }
              return null;
            },
          ),
        ),
        ListItem(
          title: TextFormField(
            textInputAction: TextInputAction.next,
            obscureText: true,
            controller: _loginPasswordController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.subscriptionLoginPassword,
              hintText: appLocalizations.subscriptionLoginPasswordHint,
            ),
          ),
        ),
        ListItem.switchItem(
          title: Text(appLocalizations.autoUpdate),
          delegate: SwitchDelegate<bool>(
            value: _autoUpdate,
            onChanged: _setAutoUpdate,
          ),
        ),
        if (_autoUpdate)
          ListItem(
            title: TextFormField(
              textInputAction: TextInputAction.next,
              controller: _autoUpdateDurationController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.autoUpdateInterval,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations
                      .profileAutoUpdateIntervalNullValidationDesc;
                }
                try {
                  int.parse(value);
                } catch (_) {
                  return appLocalizations
                      .profileAutoUpdateIntervalInvalidValidationDesc;
                }
                return null;
              },
            ),
          ),
      ],
      ValueListenableBuilder<FileInfo?>(
        valueListenable: _fileInfoNotifier,
        builder: (_, fileInfo, _) {
          return FadeThroughBox(
            alignment: Alignment.centerLeft,
            child: fileInfo == null
                ? Container()
                : ListItem(
                    title: Text(appLocalizations.profile),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(fileInfo.desc),
                        const SizedBox(height: 8),
                        Wrap(
                          runSpacing: 6,
                          spacing: 12,
                          children: [
                            CommonChip(
                              avatar: const Icon(Icons.edit),
                              label: appLocalizations.edit,
                              onPressed: _editProfileFile,
                            ),
                            CommonChip(
                              avatar: const Icon(Icons.upload),
                              label: appLocalizations.upload,
                              onPressed: _uploadProfileFile,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    ];
    return CommonPopScope(
      onPop: (context) {
        if (_fileData == null) {
          return true;
        }
        _handleBack();
        return false;
      },
      child: FloatLayout(
        floatingWidget: FloatWrapper(
          child: FloatingActionButton.extended(
            heroTag: null,
            onPressed: _handleConfirm,
            label: Text(appLocalizations.save),
            icon: const Icon(Icons.save),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.separated(
              padding: kMaterialListPadding.copyWith(bottom: 72),
              itemBuilder: (_, index) {
                return items[index];
              },
              separatorBuilder: (_, _) {
                return const SizedBox(height: 24);
              },
              itemCount: items.length,
            ),
          ),
        ),
      ),
    );
  }
}
