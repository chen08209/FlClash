import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
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
  late final TextEditingController _ageSecretKeyController;
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
    _ageSecretKeyController = TextEditingController(
      text: widget.profile.ageSecretKey,
    );
    _autoUpdate = widget.profile.autoUpdate;
    _autoUpdateDurationController = TextEditingController(
      text: widget.profile.autoUpdateDuration.inMinutes.toString(),
    );
    _setupAction = ref.read(setupActionProvider.notifier);
    if (widget.profile.type != ProfileType.custom) {
      _updateFileInfo();
    }
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
      ageSecretKey: _ageSecretKeyController.text.trim(),
      label: _labelController.text,
      autoUpdate: _autoUpdate,
      autoUpdateDuration: Duration(
        minutes: int.parse(_autoUpdateDurationController.text),
      ),
    );
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final hasUpdate =
        widget.profile.url != profile.url ||
        widget.profile.ageSecretKey != profile.ageSecretKey;
    if (_fileData != null) {
      if (profile.type == ProfileType.url && _autoUpdate) {
        final res = await dialogs.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: appLocalizations.profileHasUpdate),
        );
        if (res == true) {
          profile = profile.copyWith(autoUpdate: false);
        }
      }
      final savedProfile = await globalState.safeRun(
        () => profile.saveFile(
          _fileData!,
          validate: (path, key) =>
              ref.read(coreHandlerProvider).validateProfile(path, key),
        ),
      );
      if (savedProfile == null) {
        return;
      }
      profilesAction.putProfile(savedProfile);
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
    final title = widget.profile.label.takeFirstValid([
      widget.profile.id.toString(),
    ]);
    final editorPage = EditorPage(
      title: title,
      load: () async => _rawText ??=
          await readTextFileTask(
            await appPath.getProfilePath(widget.profile.id.toString()),
          ) ??
          '',
      onSave: (context, _, content) => _handleSaveEdit(context, content),
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
    _ageSecretKeyController.dispose();
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
      if (widget.profile.type == ProfileType.url)
        _ProfileUrlField(controller: _urlController),
      if (widget.profile.type != ProfileType.custom)
        _AgeSecretKeyField(controller: _ageSecretKeyController),
      if (widget.profile.type == ProfileType.url) ...[
        ListItem.toggle(
          title: Text(appLocalizations.autoUpdate),
          value: _autoUpdate,
          onChanged: _setAutoUpdate,
        ),
        if (_autoUpdate)
          _AutoUpdateIntervalField(controller: _autoUpdateDurationController),
      ],
      if (widget.profile.type != ProfileType.custom)
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
          child: CommonScaffold(
            title: appLocalizations.edit,
            iconActions: [
              IconButtonData(
                glyph: AppGlyphs.check,
                onPressed: _handleConfirm,
                tooltip: appLocalizations.save,
              ),
            ],
            body: Form(
              key: _formKey,
              child: Builder(
                builder: (context) => ListView.separated(
                  padding: kMaterialListPadding.copyWith(
                    top: context.contentTopPadding,
                    bottom: BottomInsetScope.of(context) + 16,
                  ),
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

String? validateProfileName(AppLocalizations appLocalizations, String? value) {
  if (value == null || value.isEmpty) {
    return appLocalizations.profileNameNullValidationDesc;
  }
  return null;
}

Future<void> renameProfile(
  BuildContext context,
  WidgetRef ref,
  Profile profile, {
  bool selectAll = false,
}) async {
  final appLocalizations = context.appLocalizations;
  final profilesAction = ref.read(profilesActionProvider.notifier);
  final label = await dialogs.showCommonDialog<String>(
    child: InputDialog(
      title: appLocalizations.rename,
      labelText: appLocalizations.name,
      value: profile.label,
      selectAll: selectAll,
      inputFormatters: TextInputLimits.limit(TextInputLimits.name),
      validator: (value) => validateProfileName(appLocalizations, value),
    ),
  );
  if (label == null || label == profile.label) {
    return;
  }
  profilesAction.putProfile(profile.copyWith(label: label));
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
        decoration: InputDecoration(labelText: appLocalizations.name),
        validator: (value) => validateProfileName(appLocalizations, value),
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
        decoration: InputDecoration(labelText: appLocalizations.url),
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

class _AgeSecretKeyField extends StatelessWidget {
  const _AgeSecretKeyField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListItem(
      title: SecretTextFormField(
        textInputAction: TextInputAction.next,
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          labelText: appLocalizations.ageSecretKey,
          hintText: appLocalizations.optional,
        ),
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

  Widget _buildSubtitle(BuildContext context, FileInfo fileInfo) {
    final style = context.listCaptionStyle;
    final lastModified = fileInfo.lastModified;
    if (lastModified == null) {
      return Text(context.appLocalizations.unknown, style: style);
    }
    return LastUpdateTimeText(lastUpdateDate: lastModified, style: style);
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.edit,
        label: appLocalizations.edit,
        onPressed: onEdit,
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.upload,
        label: appLocalizations.upload,
        onPressed: onUpload,
      ),
    ];
  }

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
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ItemPositionProvider(
                    position: ItemPosition.startAndEnd,
                    child: ContextMenuRegion(
                      menuItems: _menuItems(context),
                      child: DecorationListItem(
                        contentPadding: const EdgeInsets.only(left: 16),
                        title: Text(appLocalizations.profile),
                        subtitle: _buildSubtitle(context, fileInfo),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              fileInfo.size.traffic.show,
                              style: context.listCaptionStyle,
                            ),
                            const DisclosureIndicator(),
                          ],
                        ),
                        onPressed: onEdit,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
