import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

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
  final CodeLineEditingController _controller = CodeLineEditingController();
  final key = GlobalKey<CommonScaffoldState>();
  final _focusNode = FocusNode();
  String? rawText;

  @override
  void initState() {
    super.initState();
    appPath.getProfilePath(widget.profile.id).then((path) async {
      if (path == null) return;
      final file = File(path);
      rawText = await file.readAsString();
      _controller.text = rawText ?? "";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Profile get profile => widget.profile;

  _handleChangeReadOnly() async {
    if (readOnly == true) {
      setState(() {
        readOnly = false;
      });
    } else {
      if (_controller.text == rawText) return;
      final newProfile = await key.currentState?.loadingRun<Profile>(() async {
        return await profile.saveFileWithString(_controller.text);
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
          onPressed: _controller.undo,
          icon: const Icon(Icons.undo),
        ),
        IconButton(
          onPressed: _controller.redo,
          icon: const Icon(Icons.redo),
        ),
        IconButton(
          onPressed: _handleChangeReadOnly,
          icon: readOnly ? const Icon(Icons.edit) : const Icon(Icons.save),
        ),
      ],
      body: CodeEditor(
        readOnly: readOnly,
        focusNode: _focusNode,
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
        controller: _controller,
        shortcutsActivatorsBuilder:
            const DefaultCodeShortcutsActivatorsBuilder(),
        indicatorBuilder: (
          context,
          editingController,
          chunkController,
          notifier,
        ) {
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
        toolbarController:
            !readOnly ? ContextMenuControllerImpl(_focusNode) : null,
        style: CodeEditorStyle(
          fontSize: 14,
          codeTheme: CodeHighlightTheme(
            languages: {
              'yaml': CodeHighlightThemeMode(
                mode: langYaml,
              )
            },
            theme: atomOneLightTheme,
          ),
        ),
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
  OverlayEntry? _overlayEntry;

  final FocusNode focusNode;

  ContextMenuControllerImpl(
    this.focusNode,
  );

  _removeOverLayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void hide(BuildContext context) {
    // _removeOverLayEntry();
  }

  // _handleCut(CodeLineEditingController controller) {
  //   controller.cut();
  //   _removeOverLayEntry();
  // }
  //
  // _handleCopy(CodeLineEditingController controller) async {
  //   await controller.copy();
  //   _removeOverLayEntry();
  // }
  //
  // _handlePaste(CodeLineEditingController controller) {
  //   controller.paste();
  //   _removeOverLayEntry();
  // }

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
    _removeOverLayEntry();
    final relativeRect = RelativeRect.fromSize(
      (anchors.primaryAnchor) &
          const Size(150, double.infinity),
      MediaQuery.of(context).size,
    );
    _overlayEntry ??= OverlayEntry(
      builder: (context) => ValueListenableBuilder<CodeLineEditingValue>(
        valueListenable: controller,
        builder: (_, __, child) {
          if (controller.selectedText.isEmpty) {
            _removeOverLayEntry();
          }
          return child!;
        },
        child: Positioned(
          left: relativeRect.left,
          top: relativeRect.top,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(focusNode);
              },
              child: Container(
                width: 200,
                height: 200,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
}
