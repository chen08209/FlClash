import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'grid.dart';

class ColorSchemeBox extends StatelessWidget {
  final Color? primaryColor;
  final bool? isSelected;
  final void Function()? onPressed;

  const ColorSchemeBox({
    super.key,
    required this.primaryColor,
    this.onPressed,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PrimaryColorBox(
        primaryColor: primaryColor,
        child: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return Stack(
              children: [
                CommonCard(
                  isSelected: isSelected,
                  onPressed: onPressed,
                  selectWidget: Container(
                    alignment: Alignment.center,
                    child: const SelectIcon(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: Grid(
                          crossAxisCount: 2,
                          children: [
                            GridItem(
                              mainAxisCellCount: 2,
                              child: Container(
                                color: colorScheme.primary,
                              ),
                            ),
                            GridItem(
                              mainAxisCellCount: 1,
                              child: Container(
                                color: colorScheme.secondary,
                              ),
                            ),
                            GridItem(
                              mainAxisCellCount: 1,
                              child: Container(
                                color: colorScheme.tertiary,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (primaryColor == null)
                  const Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(
                      Icons.colorize,
                      size: 20,
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}

class PrimaryColorBox extends ConsumerWidget {
  final Color? primaryColor;
  final Widget child;
  final Brightness? brightness;
  final bool ignoreConfig;

  const PrimaryColorBox({
    super.key,
    required this.primaryColor,
    required this.child,
    this.brightness,
    this.ignoreConfig = true,
  });

  @override
  Widget build(BuildContext context, ref) {
    final themeData = Theme.of(context);
    final colorScheme = ref.watch(
      genColorSchemeProvider(
        brightness ?? themeData.brightness,
        color: primaryColor,
        ignoreConfig: ignoreConfig,
      ),
    );
    return Theme(
      data: themeData.copyWith(
        colorScheme: colorScheme,
      ),
      child: child,
    );
  }
}
