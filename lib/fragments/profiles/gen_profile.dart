import 'package:fl_clash/clash/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';

class GenProfile extends StatefulWidget {
  final String profileId;

  const GenProfile({
    super.key,
    required this.profileId,
  });

  @override
  State<GenProfile> createState() => _GenProfileState();
}

class _GenProfileState extends State<GenProfile> {
  final _currentClashConfigNotifier = ValueNotifier<ClashConfig?>(null);

  @override
  void initState() {
    super.initState();
    _initCurrentClashConfig();
  }

  _initCurrentClashConfig() async {
    final currentProfileId = globalState.config.currentProfileId;
    if (currentProfileId == null) {
      return;
    }
    _currentClashConfigNotifier.value =
        await clashCore.getProfile(currentProfileId);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      body: ValueListenableBuilder(
        valueListenable: _currentClashConfigNotifier,
        builder: (_, clashConfig, ___) {
          if (clashConfig == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [],
          );
        },
      ),
      title: "自定义",
    );
  }
}
