import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileView extends ConsumerStatefulWidget {
  final Profile profile;
  final BuildContext context;

  const EditProfileView({
    super.key,
    required this.context,
    required this.profile,
  });

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;
  late final TextEditingController _autoUpdateDurationController;
  late bool _autoUpdate;
  String? _rawText;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _fileInfoNotifier = ValueNotifier<FileInfo?>(null);
  late SetupAction _setupAction;
  Uint8List? _fileData;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.profile.label);
    _urlController = TextEditingController(text: widget.profile.url);
    _autoUpdate = widget.profile.autoUpdate;
    _autoUpdateDurationController = TextEditingController(
      text: widget.profile.autoUpdateDuration.inMinutes.toString(),
    );
    _setupAction = ref.read(setupActionProvider.notifier);
    _updateFileInfo();
  }

  Future<void> _updateFileInfo() async {
    final file = await widget.profile.file;
    final fileInfo = await file.getFileInfo();
    if (!mounted) {
      return;
    }
    _fileInfoNotifier.value = fileInfo;
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
    );
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final hasUpdate = widget.profile.url != profile.url;
    if (_fileData != null) {
      if (profile.type == ProfileType.url && _autoUpdate) {
        final appLocalizations = context.appLocalizations;
        final res = await dialogs.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: appLocalizations.profileHasUpdate),
        );
        if (res == true) {
          profile = profile.copyWith(autoUpdate: false);
        }
      }
      profilesAction.putProfile(
        await profile.saveFile(
          _fileData!,
          validate: (path) =>
              ref.read(coreHandlerProvider).validateConfig(path),
        ),
      );
    } else if (!hasUpdate) {
      profilesAction.putProfile(profile);
    } else {
      unawaited(
        globalState.safeRun(() async {
          await Future.delayed(commonDuration);
          if (hasUpdate) {
            await profilesAction.updateProfile(profile);
          }
        }),
      );
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
    final message = await globalState.safeRun<String>(() async {
      final message = await ref
          .read(profilesActionProvider.notifier)
          .validateConfigWithData(data);
      return message;
    }, silence: false);
    if (message?.isNotEmpty == true) {
      unawaited(
        dialogs.showMessage(
          title: currentAppLocalizations.tip,
          message: TextSpan(text: message),
        ),
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
        final res = await dialogs.showMessage(
          title: title,
          message: TextSpan(text: context.appLocalizations.hasCacheChange),
        );
        if (res == true && context.mounted) {
          unawaited(_handleSaveEdit(context, content));
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
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    _fileData = await platformFile.readBytes();
    if (!mounted) {
      return;
    }
    _fileInfoNotifier.value = _fileInfoNotifier.value?.copyWith(
      size: _fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  Future<void> _handleBack() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.fileIsUpdate),
    );
    if (res == true) {
      unawaited(_handleConfirm());
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
    _fileInfoNotifier.dispose();
    _autoUpdateDurationController.dispose();
    super.dispose();
    _setupAction.autoApplyProfile();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final items = <Widget>[
      _ProfileNameField(controller: _labelController),
      if (widget.profile.type == ProfileType.url) ...[
        _ProfileUrlField(controller: _urlController),
        ListItem.toggle(
          title: Text(appLocalizations.autoUpdate),
          value: _autoUpdate,
          onChanged: _setAutoUpdate,
        ),
        if (_autoUpdate)
          _AutoUpdateIntervalField(controller: _autoUpdateDurationController),
      ],
      _ProfileFileItem(
        fileInfoNotifier: _fileInfoNotifier,
        onEdit: _editProfileFile,
        onUpload: _uploadProfileFile,
      ),
    ];
    return FocusTraversalGroup(
      policy: PageTraversalPolicy(),
      child: PageFocusScope(
        child: CommonPopScope(
          onPop: (context) {
            if (_fileData == null) {
              return true;
            }
            _handleBack();
            return false;
          },
          child: FloatLayout(
            floatingWidget: FloatWrapper(
              child: CommonFloatingActionButton(
                onPressed: _handleConfirm,
                icon: const Icon(Icons.save),
                label: appLocalizations.save,
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
        ),
      ),
    );
  }
}

class _ProfileNameField extends StatelessWidget {
  const _ProfileNameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      title: TextFormField(
        textInputAction: TextInputAction.next,
        controller: controller,
        inputFormatters: TextInputLimits.limit(TextInputLimits.name),
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
    );
  }
}

class _ProfileUrlField extends StatelessWidget {
  const _ProfileUrlField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      title: TextFormField(
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.url,
        controller: controller,
        inputFormatters: TextInputLimits.limit(TextInputLimits.url),
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
    );
  }
}

class _AutoUpdateIntervalField extends StatelessWidget {
  const _AutoUpdateIntervalField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      title: TextFormField(
        textInputAction: TextInputAction.next,
        controller: controller,
        inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.interval),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: appLocalizations.autoUpdateInterval,
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.profileAutoUpdateIntervalNullValidationDesc;
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
    );
  }
}

class _ProfileFileItem extends StatelessWidget {
  const _ProfileFileItem({
    required this.fileInfoNotifier,
    required this.onEdit,
    required this.onUpload,
  });

  final ValueNotifier<FileInfo?> fileInfoNotifier;
  final VoidCallback onEdit;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ValueListenableBuilder<FileInfo?>(
      valueListenable: fileInfoNotifier,
      builder: (context, fileInfo, _) {
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
                      Text(fileInfo.getDesc(context)),
                      const SizedBox(height: 8),
                      Wrap(
                        runSpacing: 6,
                        spacing: 12,
                        children: [
                          CommonChip(
                            avatar: const Icon(Icons.edit),
                            label: appLocalizations.edit,
                            onPressed: onEdit,
                          ),
                          CommonChip(
                            avatar: const Icon(Icons.upload),
                            label: appLocalizations.upload,
                            onPressed: onUpload,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
