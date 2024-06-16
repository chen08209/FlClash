import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
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
  final controller = CodeLineEditingController();

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
      controller.text = text;
      // _codeController.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      actions: [
        IconButton(
          onPressed: controller.undo,
          icon: const Icon(Icons.undo),
        ),
        IconButton(
          onPressed: controller.redo,
          icon: const Icon(Icons.redo),
        ),
        const SizedBox(
          width: 8,
        )
      ],
      body: CodeEditor(
        autofocus: false,
        readOnly: readOnly,
        scrollbarBuilder: (context, child, details) {
          return Scrollbar(
            controller: details.controller,
            thumbVisibility: true,
            interactive: true,
            child: child,
          );
        },
        showCursorWhenReadOnly: false,
        controller: controller,
        toolbarController: const ContextMenuControllerImpl(),
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
      ),
      title: "查看",
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            readOnly = !readOnly;
          });
        },
        child: readOnly ? const Icon(Icons.edit) : const Icon(Icons.save),
      ),
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
      popUpAnimationStyle: AnimationStyle.noAnimation,
      position: RelativeRect.fromSize(
        (anchors.secondaryAnchor ?? anchors.primaryAnchor) &
            const Size(150, double.infinity),
        MediaQuery.of(context).size,
      ),
      items: [
        ContextMenuItemWidget(
          text: 'Cut',
          onTap: () {
            controller.cut();
          },
        ),
        ContextMenuItemWidget(
          text: 'Copy',
          onTap: () {
            controller.copy();
          },
        ),
        ContextMenuItemWidget(
          text: 'Paste',
          onTap: () {
            controller.paste();
          },
        ),
      ],
    );
  }
}
