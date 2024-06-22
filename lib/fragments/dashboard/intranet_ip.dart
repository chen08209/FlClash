import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class IntranetIp extends StatefulWidget {
  const IntranetIp({super.key});

  @override
  State<IntranetIp> createState() => _IntranetIpState();
}

class _IntranetIpState extends State<IntranetIp> {
  final ipNotifier = ValueNotifier<String>("");

  Future<String?> getLocalIpAddress() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list();
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback) {
          return address.address;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    ipNotifier.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ipNotifier.value = await getLocalIpAddress() ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      info: Info(
        label: appLocalizations.intranetIp,
        iconData: Icons.devices,
      ),
      child: Container(
        padding: const EdgeInsets.all(16).copyWith(top: 0),
        height: globalState.appController.measure.titleLargeHeight + 24 - 1,
        child: ValueListenableBuilder(
          valueListenable: ipNotifier,
          builder: (_, value, __) {
            return FadeBox(
              child: value.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          flex: 1,
                          child: TooltipText(
                            text: Text(
                              value,
                              style: context.textTheme.titleLarge?.toSoftBold.toMinus,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.all(2),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CircularProgressIndicator(),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
