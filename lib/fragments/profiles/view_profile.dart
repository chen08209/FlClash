import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/intellij-light.dart';

class ViewProfile extends StatefulWidget {
  final Profile profile;

  const ViewProfile({
    super.key,
    required this.profile,
  });

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  bool readOnly = true;
  CodeLineEditingController? controller;
  final contentNotifier = ValueNotifier<String>("");
  final key = GlobalKey<CommonScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profilePath = await appPath.getProfilePath(widget.profile.id);
      if (profilePath == null) {
        return;
      }
      final file = File(profilePath);
      final text = await file.readAsString();
      contentNotifier.value = text;
    });
  }

  @override
  void dispose() {
    super.dispose();
    contentNotifier.dispose();
    controller?.dispose();
  }

  Profile get profile => widget.profile;

  _handleChangeReadOnly() async {
    if (readOnly == true) {
      setState(() {
        readOnly = false;
      });
    } else {
      final text = controller?.text;
      if (text == null || text == contentNotifier.value) {
        setState(() {
          readOnly = true;
        });
        return;
      }
      contentNotifier.value = text;
      final newProfile = await key.currentState?.loadingRun<Profile>(() async {
        return await profile.saveFileWithString(text);
      });
      if (newProfile == null) return;
      globalState.appController.config.setProfile(newProfile);
      setState(() {
        readOnly = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      key: key,
      actions: [
        IconButton(
          onPressed: controller?.undo,
          icon: const Icon(Icons.undo),
        ),
        IconButton(
          onPressed: controller?.redo,
          icon: const Icon(Icons.redo),
        ),
        if (!widget.profile.realAutoUpdate)
          IconButton(
            onPressed: _handleChangeReadOnly,
            icon: readOnly ? const Icon(Icons.edit) : const Icon(Icons.save),
          ),
        const SizedBox(
          width: 8,
        )
      ],
      body: ValueListenableBuilder(
        valueListenable: contentNotifier,
        builder: (_, value, __) {
          if (value.isEmpty) return Container();
          controller = CodeLineEditingController.fromText(value);
          return CodeEditor(
            autofocus: false,
            readOnly: readOnly,
            scrollbarBuilder: (context, child, details) {
              return Scrollbar(
                controller: details.controller,
                thickness: 8,
                radius: const Radius.circular(2),
                interactive: true,
                child: child,
              );
            },
            showCursorWhenReadOnly: false,
            controller: controller,
            toolbarController:
                !readOnly ? const ContextMenuControllerImpl() : null,
            shortcutsActivatorsBuilder:
                const DefaultCodeShortcutsActivatorsBuilder(),
            indicatorBuilder:
                (context, editingController, chunkController, notifier) {
              return Row(
                children: [
                  DefaultCodeLineNumber(
                    controller: editingController,
                    notifier: notifier,
                  ),
                  DefaultCodeChunkIndicator(
                    width: 20,
                    controller: chunkController,
                    notifier: notifier,
                  )
                ],
              );
            },
            style: CodeEditorStyle(
              fontSize: 14,
              codeTheme: CodeHighlightTheme(
                languages: {
                  'yaml': CodeHighlightThemeMode(
                    mode: langYaml,
                  )
                },
                theme: intellijLightTheme,
              ),
            ),
          );
        },
      ),
      title: widget.profile.label ?? widget.profile.id,
    );
  }
}

class ContextMenuItemWidget extends PopupMenuItem<void> {
  ContextMenuItemWidget({
    super.key,
    required String text,
    required VoidCallback super.onTap,
  }) : super(child: Text(text));
}

class ContextMenuControllerImpl implements SelectionToolbarController {
  const ContextMenuControllerImpl();

  @override
  void hide(BuildContext context) {}

  @override
  void show({
    required BuildContext context,
    required CodeLineEditingController controller,
    required TextSelectionToolbarAnchors anchors,
    Rect? renderRect,
    required LayerLink layerLink,
    required ValueNotifier<bool> visibility,
  }) {
    if (controller.selectedText.isEmpty) {
      return;
    }
    showMenu(
      context: context,
      position: RelativeRect.fromSize(
        (anchors.secondaryAnchor ?? anchors.primaryAnchor) &
            const Size(150, double.infinity),
        MediaQuery.of(context).size,
      ),
      items: [
        ContextMenuItemWidget(
          text: appLocalizations.cut,
          onTap: controller.cut,
        ),
        ContextMenuItemWidget(
          text: appLocalizations.copy,
          onTap: controller.copy,
        ),
        ContextMenuItemWidget(
          text: appLocalizations.paste,
          onTap: controller.paste,
        ),
      ],
    );
  }
}
