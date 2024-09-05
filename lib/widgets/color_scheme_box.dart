import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'card.dart';
import 'grid.dart';

class ColorSchemeBox extends StatelessWidget {
  final Color? primaryColor;
  final bool? isSelected;
  final void Function()? onPressed;

  const ColorSchemeBox({
    super.key,
    this.primaryColor,
    this.onPressed,
    this.isSelected,
  });

  ThemeData _getTheme(BuildContext context) {
    if (primaryColor != null) {
      return Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor!,
          brightness: Theme.of(context).brightness,
        ),
      );
    } else {
      return Theme.of(context).copyWith(
        colorScheme: globalState.appController.appState.systemColorSchemes
            .getSystemColorSchemeForBrightness(Theme.of(context).brightness),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 1,
      child: Theme(
        data: _getTheme(context),
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
