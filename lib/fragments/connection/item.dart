import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionItem extends ConsumerWidget {
  final Connection connection;
  final Function(String)? onClickKeyword;
  final Widget? trailing;

  const ConnectionItem({
    super.key,
    required this.connection,
    this.onClickKeyword,
    this.trailing,
  });

  Future<ImageProvider?> _getPackageIcon(Connection connection) async {
    return await app?.getPackageIcon(connection.metadata.process);
  }

  String _getSourceText(Connection connection) {
    final metadata = connection.metadata;
    if (metadata.process.isEmpty) {
      return connection.start.lastUpdateTimeDesc;
    }
    return "${metadata.process} · ${connection.start.lastUpdateTimeDesc}";
  }

  @override
  Widget build(BuildContext context, ref) {
    final value = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            state.findProcessMode == FindProcessMode.always &&
            Platform.isAndroid,
      ),
    );
    final title = Text(
      connection.desc,
      style: context.textTheme.bodyLarge,
    );
    final subTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Text(
          _getSourceText(connection),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          runSpacing: 6,
          spacing: 6,
          children: [
            for (final chain in connection.chains)
              CommonChip(
                label: chain,
                onPressed: () {
                  if (onClickKeyword == null) return;
                  onClickKeyword!(chain);
                },
              ),
          ],
        ),
      ],
    );
    return CommonPopupBox(
      targetBuilder: (open) {
        return ListItem(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          tileTitleAlignment: ListTileTitleAlignment.titleHeight,
          leading: value
              ? GestureDetector(
            onTap: () {
              if (onClickKeyword == null) return;
              final process = connection.metadata.process;
              if (process.isEmpty) return;
              onClickKeyword!(process);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              width: 48,
              height: 48,
              child: FutureBuilder<ImageProvider?>(
                future: _getPackageIcon(connection),
                builder: (_, snapshot) {
                  if (!snapshot.hasData && snapshot.data == null) {
                    return Container();
                  } else {
                    return Image(
                      image: snapshot.data!,
                      gaplessPlayback: true,
                      width: 48,
                      height: 48,
                    );
                  }
                },
              ),
            ),
          )
              : null,
          title: title,
          subtitle: subTitle,
          trailing: trailing,
        );
        // return InkWell(
        //   child: GestureDetector(
        //     onLongPressStart: (details) {
        //       if (!system.isDesktop) {
        //         return;
        //       }
        //       open(
        //         offset: details.localPosition.translate(
        //           0,
        //           -12,
        //         ),
        //       );
        //     },
        //     onSecondaryTapDown: (details) {
        //       if (!system.isDesktop) {
        //         return;
        //       }
        //       open(
        //         offset: details.localPosition.translate(
        //           0,
        //           -12,
        //         ),
        //       );
        //     },
        //     child: ListItem(
        //       padding: const EdgeInsets.symmetric(
        //         horizontal: 16,
        //         vertical: 4,
        //       ),
        //       tileTitleAlignment: ListTileTitleAlignment.titleHeight,
        //       leading: value
        //           ? GestureDetector(
        //               onTap: () {
        //                 if (onClickKeyword == null) return;
        //                 final process = connection.metadata.process;
        //                 if (process.isEmpty) return;
        //                 onClickKeyword!(process);
        //               },
        //               child: Container(
        //                 margin: const EdgeInsets.only(top: 4),
        //                 width: 48,
        //                 height: 48,
        //                 child: FutureBuilder<ImageProvider?>(
        //                   future: _getPackageIcon(connection),
        //                   builder: (_, snapshot) {
        //                     if (!snapshot.hasData && snapshot.data == null) {
        //                       return Container();
        //                     } else {
        //                       return Image(
        //                         image: snapshot.data!,
        //                         gaplessPlayback: true,
        //                         width: 48,
        //                         height: 48,
        //                       );
        //                     }
        //                   },
        //                 ),
        //               ),
        //             )
        //           : null,
        //       title: title,
        //       subtitle: subTitle,
        //       trailing: trailing,
        //     ),
        //   ),
        //   onTap: () {},
        // );
      },
      popup: CommonPopupMenu(
        minWidth: 160,
        items: [
          PopupMenuItemData(
            label: "编辑规则",
            onPressed: () {
              // _handleShowEditExtendPage(context);
            },
          ),
          PopupMenuItemData(
            label: "设置直连",
            onPressed: () {},
          ),
          PopupMenuItemData(
            label: "一键屏蔽",
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
