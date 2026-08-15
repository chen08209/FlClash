import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
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
  late final TextEditingController _sourceUrlController;
  late final TextEditingController _autoUpdateDurationController;
  late final TextEditingController _freeNodesConcurrencyController;
  late bool _autoUpdate;
  bool _freeNodesAutoPrefer = false;
  bool _freeNodesDeleteExpiredOnPrefer = false;
  String? _rawText;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _fileInfoNotifier = ValueNotifier<FileInfo?>(null);
  Uint8List? _fileData;
  List<FreeNodeSourceOption> _freeNodeSourceOptions = const [];
  Set<String> _enabledFreeNodeSourceIds = {};
  bool _isLoadingFreeNodeSources = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.profile.label);
    _urlController = TextEditingController(text: widget.profile.url);
    _sourceUrlController = TextEditingController(
      text: widget.profile.sourceUrl,
    );
    _autoUpdate = widget.profile.autoUpdate;
    _autoUpdateDurationController = TextEditingController(
      text: widget.profile.autoUpdateDuration.inMinutes.toString(),
    );
    _freeNodesConcurrencyController = TextEditingController(text: '4');
    _updateFileInfo();
    if (widget.profile.isFreeNodesProfile) {
      _loadFreeNodeSources();
    }
  }

  Future<void> _loadFreeNodeSources() async {
    setState(() {
      _isLoadingFreeNodeSources = true;
    });
    final options = await freeNodesService.getSourceOptions();
    final enabledIds = await freeNodesService.getEnabledSourceIds();
    final preferenceState = await freeNodesService.getPreferenceState();
    if (!mounted) return;
    setState(() {
      _freeNodeSourceOptions = options;
      _enabledFreeNodeSourceIds = enabledIds;
      _freeNodesConcurrencyController.text = preferenceState.fetchConcurrency
          .toString();
      _freeNodesAutoPrefer = preferenceState.autoPrefer;
      _freeNodesDeleteExpiredOnPrefer = preferenceState.deleteExpiredOnPrefer;
      _isLoadingFreeNodeSources = false;
    });
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
    final appLocalizations = context.appLocalizations;
    if (widget.profile.isFreeNodesProfile) {
      if (_enabledFreeNodeSourceIds.isEmpty) {
        context.showNotifier(
          '\u81f3\u5c11\u5f00\u542f\u4e00\u4e2a\u8282\u70b9\u6765\u6e90',
        );
        return;
      }
      await freeNodesService.saveEnabledSourceIds(_enabledFreeNodeSourceIds);
      await freeNodesService.saveFetchConcurrency(
        int.parse(_freeNodesConcurrencyController.text),
      );
      await freeNodesService.saveAutoPrefer(_freeNodesAutoPrefer);
      await freeNodesService.saveDeleteExpiredOnPrefer(
        _freeNodesDeleteExpiredOnPrefer,
      );
    }
    var profile = widget.profile.copyWith(
      url: widget.profile.isFreeNodesProfile
          ? freeNodesProfileUrl
          : _urlController.text,
      sourceUrl: widget.profile.isFreeNodesProfile
          ? ''
          : _sourceUrlController.text.trim(),
      label: _labelController.text,
      autoUpdate: _autoUpdate,
      autoUpdateDuration: Duration(
        minutes: int.parse(_autoUpdateDurationController.text),
      ),
    );
    final profilesAction = globalState.container.read(
      profilesActionProvider.notifier,
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
      profilesAction.putProfile(await profile.saveFile(_fileData!));
    } else if (!hasUpdate) {
      profilesAction.putProfile(profile);
    } else {
      globalState.safeRun(() async {
        await Future.delayed(commonDuration);
        if (hasUpdate) {
          await profilesAction.updateProfile(profile);
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

  void _setFreeNodesAutoPrefer(bool value) {
    if (_freeNodesAutoPrefer == value) return;
    setState(() {
      _freeNodesAutoPrefer = value;
    });
  }

  void _setFreeNodesDeleteExpiredOnPrefer(bool value) {
    if (_freeNodesDeleteExpiredOnPrefer == value) return;
    setState(() {
      _freeNodesDeleteExpiredOnPrefer = value;
    });
  }

  Future<void> _handleSaveEdit(BuildContext context, String data) async {
    final message = await globalState.safeRun<String>(() async {
      final message = await coreController.validateConfigWithData(data);
      return message;
    }, silence: false);
    if (message?.isNotEmpty == true) {
      globalState.showMessage(
        title: currentAppLocalizations.tip,
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
          message: TextSpan(text: context.appLocalizations.hasCacheChange),
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

  Widget _buildFreeNodeSourcesItem() {
    if (_isLoadingFreeNodeSources) {
      return const ListItem(
        title: Text('\u8282\u70b9\u94fe\u63a5\u6e90'),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(),
        ),
      );
    }
    return ListItem(
      title: const Text('\u8282\u70b9\u94fe\u63a5\u6e90'),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            for (final option in _freeNodeSourceOptions)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _enabledFreeNodeSourceIds.contains(option.id),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _enabledFreeNodeSourceIds.add(option.id);
                    } else {
                      _enabledFreeNodeSourceIds.remove(option.id);
                    }
                  });
                },
                title: Text(option.label),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u81ea\u52a8\u66f4\u65b0\u95f4\u9694\uff1a${option.updateIntervalLabel}',
                    ),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('获取超时：${option.fetchTimeoutLabel}'),
                        Text('最近获取：${_formatFetchTime(option)}'),
                        TextButton.icon(
                          onPressed: () => _editSourceTimeout(option),
                          icon: const Icon(Icons.timer_outlined, size: 16),
                          label: const Text('设置获取超时'),
                        ),
                      ],
                    ),
                    Text(
                      option.seed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
          ],
        ),
      ),
    );
  }

  String _formatFetchTime(FreeNodeSourceOption option) {
    final lastFetchTime = option.lastFetchTime;
    if (lastFetchTime == null) return '未获取';
    return lastFetchTime.getLastUpdateTimeDesc(context);
  }

  Future<void> _editSourceTimeout(FreeNodeSourceOption option) async {
    final controller = TextEditingController(
      text: option.fetchTimeoutSeconds.toString(),
    );
    final formKey = GlobalKey<FormState>();
    final value = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${option.label} 获取超时'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '获取超时秒数',
                suffixText: '秒',
              ),
              validator: (value) {
                final intValue = int.tryParse(value ?? '');
                if (intValue == null || intValue < 3 || intValue > 120) {
                  return '请输入 3-120 秒';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.appLocalizations.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.of(context).pop(int.parse(controller.text));
              },
              child: Text(context.appLocalizations.confirm),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (value == null) return;
    await freeNodesService.saveSourceFetchTimeoutSeconds(option.id, value);
    await _loadFreeNodeSources();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _urlController.dispose();
    _sourceUrlController.dispose();
    _fileInfoNotifier.dispose();
    _autoUpdateDurationController.dispose();
    _freeNodesConcurrencyController.dispose();
    super.dispose();
    globalState.container.read(setupActionProvider.notifier).autoApplyProfile();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final items = [
      ListItem(
        title: TextFormField(
          textInputAction: TextInputAction.next,
          controller: _labelController,
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
      ),
      if (widget.profile.type == ProfileType.url &&
          !widget.profile.isFreeNodesProfile)
        ListItem(
          title: TextFormField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.url,
            controller: _urlController,
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
        ),
      if (!widget.profile.isFreeNodesProfile)
        ListItem(
          title: TextFormField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.url,
            controller: _sourceUrlController,
            maxLines: 4,
            minLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '原订阅网站（可选）',
              helperText: '订阅卡片和菜单可直接打开原订阅网站',
            ),
            validator: (String? value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              if (!text.isUrl) {
                return appLocalizations.profileUrlInvalidValidationDesc;
              }
              return null;
            },
          ),
        ),
      if (widget.profile.type == ProfileType.url) ...[
        ListItem.toggle(
          title: Text(appLocalizations.autoUpdate),
          subtitle: widget.profile.isFreeNodesProfile
              ? const Text('按每个节点来源的默认更新时间检查')
              : null,
          value: _autoUpdate,
          onChanged: _setAutoUpdate,
        ),
        if (_autoUpdate && !widget.profile.isFreeNodesProfile)
          ListItem(
            title: TextFormField(
              textInputAction: TextInputAction.next,
              controller: _autoUpdateDurationController,
              inputFormatters: TextInputLimits.digitsOnly(
                TextInputLimits.interval,
              ),
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
      if (widget.profile.isFreeNodesProfile) ...[
        ListItem(
          title: TextFormField(
            textInputAction: TextInputAction.next,
            controller: _freeNodesConcurrencyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '并发上限',
              suffixText: '源',
              helperText: '实际活跃并发会按设备性能自动调节',
            ),
            validator: (String? value) {
              final intValue = int.tryParse(value ?? '');
              final maxConcurrency = _freeNodeSourceOptions.isEmpty
                  ? intValue ?? 1
                  : _freeNodeSourceOptions.length;
              if (intValue == null ||
                  intValue < 1 ||
                  intValue > maxConcurrency) {
                return '请输入 1-$maxConcurrency';
              }
              return null;
            },
          ),
        ),
        ListItem.toggle(
          title: const Text('是否自动优选'),
          subtitle: const Text('开启后自动整合优选节点，不删除日期分类'),
          value: _freeNodesAutoPrefer,
          onChanged: _setFreeNodesAutoPrefer,
        ),
        ListItem.toggle(
          title: const Text('优选时删除旧日期分类'),
          subtitle: const Text('开启后自动或手动优选会删除非本日且超时的日期分类'),
          value: _freeNodesDeleteExpiredOnPrefer,
          onChanged: _setFreeNodesDeleteExpiredOnPrefer,
        ),
      ],
      if (widget.profile.isFreeNodesProfile) _buildFreeNodeSourcesItem(),
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
                        Text(fileInfo.getDesc(context)),
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
