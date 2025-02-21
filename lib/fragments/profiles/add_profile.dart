import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

// 添加配置文件页面（现作为占位，实际添加逻辑移至 profiles.dart）
class AddProfile extends StatelessWidget {
  final BuildContext context;

  const AddProfile({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("配置文件已自动添加"), // 提示用户添加已后台完成
    );
  }
}
