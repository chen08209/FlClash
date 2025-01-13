import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final Profile profile;
  final BuildContext context;

  const EditProfile({
    super.key,
    required this.context,
    required this.profile,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController labelController;
  late TextEditingController urlController;
  late TextEditingController autoUpdateDurationController;
  late bool autoUpdate;
  String? rawText;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final fileInfoNotifier = ValueNotifier<FileInfo?>(null);
  Uint8List? fileData;

  Profile get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.profile.label);
    urlController = TextEditingController(text: widget.profile.url);
    autoUpdate = widget.profile.autoUpdate;
    autoUpdateDurationController = TextEditingController(
      text: widget.profile.autoUpdateDuration.inMinutes.toString(),
    );
    appPath.getProfilePath(widget.profile.id).then((path) async {
      if (path == null) return;
      fileInfoNotifier.value = await _getFileInfo(path);
    });
  }

  _handleConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    final appController = globalState.appController;
    Profile profile = this.profile.copyWith(
          url: urlController.text,
          label: labelController.text,
          autoUpdate: autoUpdate,
          autoUpdateDuration: Duration(
            minutes: int.parse(
              autoUpdateDurationController.text,
            ),
          ),
        );
    final hasUpdate = widget.profile.url != profile.url;
    if (fileData != null) {
      if (profile.type == ProfileType.url && autoUpdate) {
        final res = await globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(
            text: appLocalizations.profileHasUpdate,
          ),
        );
        if (res == true) {
          profile = profile.copyWith(
            autoUpdate: false,
          );
        }
      }
      appController.setProfile(await profile.saveFile(fileData!));
    } else if (!hasUpdate) {
      appController.setProfile(profile);
    } else {
      globalState.homeScaffoldKey.currentState?.loadingRun(
        () async {
          await Future.delayed(
            commonDuration,
          );
          if (hasUpdate) {
            await appController.updateProfile(profile);
          }
        },
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  _setAutoUpdate(bool value) {
    if (autoUpdate == value) return;
    setState(() {
      autoUpdate = value;
    });
  }

  Future<FileInfo?> _getFileInfo(path) async {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    final lastModified = await file.lastModified();
    final size = await file.length();
    return FileInfo(
      size: size,
      lastModified: lastModified,
    );
  }

  _handleSaveEdit(BuildContext context, String data) async {
    final message = await globalState.safeRun<String>(
      () async {
        final message = await clashCore.validateConfig(data);
        return message;
      },
      silence: false,
    );
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

  _editProfileFile() async {
    if (rawText == null) {
      final profilePath = await appPath.getProfilePath(widget.profile.id);
      if (profilePath == null) return;
      final file = File(profilePath);
      rawText = await file.readAsString();
    }
    if (!mounted) return;
    final title = widget.profile.label ?? widget.profile.id;
    final data = await BaseNavigator.push<String>(
      globalState.homeScaffoldKey.currentContext!,
      EditorPage(
        title: title,
        content: rawText!,
        onSave: _handleSaveEdit,
        onPop: (context, data) async {
          if (data == rawText) {
            return true;
          }
          final res = await globalState.showMessage(
            title: title,
            message: TextSpan(
              text: appLocalizations.hasCacheChange,
            ),
          );
          if (res == true && context.mounted) {
            _handleSaveEdit(context, data);
          } else {
            return true;
          }
          return false;
        },
      ),
    );
    if (data == null) {
      return;
    }
    rawText = data;
    fileData = Uint8List.fromList(utf8.encode(data));
    fileInfoNotifier.value = fileInfoNotifier.value?.copyWith(
      size: fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  _uploadProfileFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile?.bytes == null) return;
    fileData = platformFile?.bytes;
    fileInfoNotifier.value = fileInfoNotifier.value?.copyWith(
      size: fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  _handleBack() async {
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
  Widget build(BuildContext context) {
    final items = [
      ListItem(
        title: TextFormField(
          controller: labelController,
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
            controller: urlController,
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
        ListItem.switchItem(
          title: Text(appLocalizations.autoUpdate),
          delegate: SwitchDelegate<bool>(
            value: autoUpdate,
            onChanged: _setAutoUpdate,
          ),
        ),
        if (autoUpdate)
          ListItem(
            title: TextFormField(
              controller: autoUpdateDurationController,
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
        valueListenable: fileInfoNotifier,
        builder: (_, fileInfo, __) {
          return FadeBox(
            child: fileInfo == null
                ? Container()
                : ListItem(
                    title: Text(
                      appLocalizations.profile,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          fileInfo.desc,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        if (didPop) return;
        if (fileData == null) {
          Navigator.of(context).pop();
          return;
        }
        _handleBack();
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
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: ListView.separated(
              padding: kMaterialListPadding.copyWith(
                bottom: 72,
              ),
              itemBuilder: (_, index) {
                return items[index];
              },
              separatorBuilder: (_, __) {
                return const SizedBox(
                  height: 24,
                );
              },
              itemCount: items.length,
            ),
          ),
        ),
      ),
    );
  }
}
