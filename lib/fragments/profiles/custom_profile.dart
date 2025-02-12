import 'package:fl_clash/clash/clash.dart';
import 'package:flutter/cupertino.dart';

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
  @override
  void initState()  {
    super.initState();
    clashCore.getProfile(widget.profileId).then((res){
      print(res);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
