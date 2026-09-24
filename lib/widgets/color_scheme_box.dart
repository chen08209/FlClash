import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/common/shape.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';

class ColorSchemeBox extends StatelessWidget {
  final Color? primaryColor;
  final bool? isSelected;
  final void Function()? onPressed;
  final double size;

  const ColorSchemeBox({
    super.key,
    required this.primaryColor,
    this.onPressed,
    this.isSelected,
    this.size = 48,
  });

  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final selected = isSelected ?? false;
    final ring = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      child: SizedBox.square(
        dimension: size,
        child: PrimaryColorBox(
          primaryColor: primaryColor,
          child: Builder(
            builder: (context) {
              final colorScheme = Theme.of(context).colorScheme;
              return Material(
                type: MaterialType.transparency,
                shape: AppShape.circle,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: AppShape.circle,
                  onTap: onPressed,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: _duration,
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.all(selected ? 5 : 0),
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(
                              color: selected ? ring : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: ClipOval(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ColoredBox(color: colorScheme.primary),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ColoredBox(
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    Expanded(
                                      child: ColoredBox(
                                        color: colorScheme.tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedScale(
                        duration: _duration,
                        curve: Curves.easeOutBack,
                        scale: selected ? 1 : 0,
                        child: const SelectIcon(),
                      ),
                      if (primaryColor == null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: ShapeDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              shape: AppShape.circle,
                            ),
                            child: GlyphIcon(
                              AppGlyphs.eyedropper,
                              size: size / 4,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
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
      data: themeData.copyWith(colorScheme: colorScheme),
      child: child,
    );
  }
}
