import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';

class CustomProfile extends StatefulWidget {
  final String profileId;

  const CustomProfile({
    super.key,
    required this.profileId,
  });

  @override
  State<CustomProfile> createState() => _CustomProfileState();
}

class _CustomProfileState extends State<CustomProfile> {
  final _currentClashConfigNotifier = ValueNotifier<ClashConfig?>(null);

  @override
  void initState() {
    super.initState();
    _initCurrentClashConfig();
  }

  _initCurrentClashConfig() async {
    // final currentProfileId = globalState.config.currentProfileId;
    // if (currentProfileId == null) {
    //   return;
    // }
    // _currentClashConfigNotifier.value =
    //     await clashCore.getProfile(currentProfileId);
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
