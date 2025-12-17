import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntranetIP extends ConsumerWidget {
  const IntranetIP({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localIp = ref.watch(localIpProvider);
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );

    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard(
        info: Info(label: appLocalizations.intranetIP, iconData: Icons.devices),
        onPressed: localIp != null && localIp.isNotEmpty
            ? () async {
                final url = 'http://$localIp:$mixedPort';
                await Clipboard.setData(ClipboardData(text: url));
                globalState.showMessage(
                  title: appLocalizations.tip,
                  message: TextSpan(text: '${appLocalizations.copied}\n$url'),
                );
              }
            : null,
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: globalState.measure.bodyMediumHeight + 2,
                child: FadeThroughBox(
                  child: localIp != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: TooltipText(
                                text: Text(
                                  localIp.isNotEmpty
                                      ? localIp
                                      : appLocalizations.noNetwork,
                                  style: context.textTheme.bodyMedium?.toLight
                                      .adjustSize(1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (localIp.isNotEmpty)
                              Icon(
                                Icons.content_copy,
                                size: 16,
                                color: context.colorScheme.onSurfaceVariant
                                    .withOpacity(0.6),
                              ),
                          ],
                        )
                      : Container(
                          padding: EdgeInsets.all(2),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
