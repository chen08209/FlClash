import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/widgets/loading.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';

class PreviewProfileView extends StatefulWidget {
  final Profile profile;

  const PreviewProfileView({super.key, required this.profile});

  @override
  State<PreviewProfileView> createState() => _PreviewProfileViewState();
}

class _PreviewProfileViewState extends State<PreviewProfileView> {
  final contentNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configMap = await appController.getProfileWithId(widget.profile.id);
      final content = await encodeYamlTask(configMap);
      if (!mounted) {
        return;
      }
      contentNotifier.value = content;
    });
  }

  @override
  void dispose() {
    contentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: contentNotifier,
      builder: (_, content, _) {
        final title = widget.profile.realLabel;
        if (content == null) {
          return CommonScaffold(
            title: title,
            body: Center(
              child: SizedBox.square(
                dimension: 200,
                child: CommonCircleLoading(),
              ),
            ),
          );
        }
        return EditorPage(title: title, content: content);
      },
    );
  }
}
