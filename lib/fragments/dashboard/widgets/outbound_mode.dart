import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OutboundMode extends StatelessWidget {
  const OutboundMode({super.key});

  @override
  Widget build(BuildContext context) {
    final height = getWidgetHeight(2);
    return SizedBox(
      height: height,
      child: Consumer(
        builder: (_, ref, __) {
          final mode =
              ref.watch(patchClashConfigProvider.select((state) => state.mode));
          return CommonCard(
            onPressed: () {},
            info: Info(
              label: appLocalizations.outboundMode,
              iconData: Icons.call_split_sharp,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (final item in Mode.values)
                    Flexible(
                      child: ListItem.radio(
                        dense: true,
                        horizontalTitleGap: 4,
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 16,
                        ),
                        delegate: RadioDelegate(
                          value: item,
                          groupValue: mode,
                          onChanged: (value) async {
                            if (value == null) {
                              return;
                            }
                            globalState.appController.changeMode(value);
                          },
                        ),
                        title: Text(
                          Intl.message(item.name),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.toSoftBold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OutboundModeV2 extends StatelessWidget {
  const OutboundModeV2({super.key});

  @override
  Widget build(BuildContext context) {
    final height = getWidgetHeight(0.72);
    return SizedBox(
      height: height,
      child: CommonCard(
        child: Consumer(
          builder: (_, ref, __) {
            final mode = ref.watch(
              patchClashConfigProvider.select(
                (state) => state.mode,
              ),
            );
            final thumbColor = switch (mode) {
              Mode.rule => context.colorScheme.secondaryContainer,
              Mode.global => globalState.theme.darken3PrimaryContainer,
              Mode.direct => context.colorScheme.tertiaryContainer,
            };
            return Container(
              constraints: BoxConstraints.expand(),
              child: CommonTabBar<Mode>(
                children: Map.fromEntries(
                  Mode.values.map(
                    (item) => MapEntry(
                      item,
                      Container(
                        alignment: Alignment.center,
                        height: height - 16,
                        child: Text(
                          Intl.message(item.name),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.adjustSize(1),
                        ),
                      ),
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8),
                groupValue: mode,
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  globalState.appController.changeMode(value);
                },
                thumbColor: thumbColor,
              ),
            );
          },
        ),
      ),
    );
  }
}
