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
        builder: (_, ref, _) {
          final mode = ref.watch(
            patchClashConfigProvider.select((state) => state.mode),
          );
          return Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: CommonCard(
              onPressed: () {},
              info: Info(
                label: appLocalizations.outboundMode,
                iconData: Icons.call_split_sharp,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: RadioGroup<Mode>(
                  groupValue: mode,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    globalState.appController.changeMode(value);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final item in Mode.values)
                        Flexible(
                          fit: FlexFit.tight,
                          child: ListItem.radio(
                            dense: true,
                            horizontalTitleGap: 4,
                            padding: EdgeInsets.only(left: 12.ap, right: 16.ap),
                            delegate: RadioDelegate(
                              onTab: () {
                                globalState.appController.changeMode(item);
                              },
                              value: item,
                            ),
                            title: Text(
                              Intl.message(item.name),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.toSoftBold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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

  Color _getTextColor(BuildContext context, Mode mode) {
    return switch (mode) {
      Mode.rule => context.colorScheme.onSecondaryContainer,
      Mode.global => context.colorScheme.onPrimaryContainer,
      Mode.direct => context.colorScheme.onTertiaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final height = getWidgetHeight(1);
    return SizedBox(
      height: height,
      child: CommonCard(
        padding: EdgeInsets.zero,
        child: Consumer(
          builder: (_, ref, _) {
            final mode = ref.watch(
              patchClashConfigProvider.select((state) => state.mode),
            );
            final thumbColor = switch (mode) {
              Mode.rule => context.colorScheme.secondaryContainer,
              Mode.global => globalState.theme.darken3PrimaryContainer,
              Mode.direct => context.colorScheme.tertiaryContainer,
            };
            return LayoutBuilder(
              builder: (_, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints.expand(),
                        child: CommonTabBar<Mode>(
                          children: Map.fromEntries(
                            Mode.values.map(
                              (item) => MapEntry(
                                item,
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(),
                                  height: height - 8.ap - 24,
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    Intl.message(item.name),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.adjustSize(1)
                                        .copyWith(
                                          color: item == mode
                                              ? _getTextColor(context, item)
                                              : null,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          groupValue: mode,
                          onValueChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            globalState.appController.changeMode(value);
                          },
                          thumbColor: thumbColor,
                        ),
                      ),
                    ),
                    Container(
                      color: thumbColor.opacity50,
                      height: 8.ap,
                      width: constraints.maxWidth,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      // child: Row(
                      //   children: [
                      //     Container(
                      //       width: (constraints.maxWidth - 32) / 3,
                      //       height: 3,
                      //       decoration: BoxDecoration(
                      //         color: _getTextColor(context, mode),
                      //         borderRadius: BorderRadius.circular(2),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
