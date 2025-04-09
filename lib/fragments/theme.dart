import 'dart:math';

import 'dart:ui' as ui;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/selector.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ThemeModeItem {
  final ThemeMode themeMode;
  final IconData iconData;
  final String label;

  const ThemeModeItem({
    required this.themeMode,
    required this.iconData,
    required this.label,
  });
}

class FontFamilyItem {
  final FontFamily fontFamily;
  final String label;

  const FontFamilyItem({
    required this.fontFamily,
    required this.label,
  });
}

class ThemeFragment extends StatelessWidget {
  const ThemeFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: ThemeColorsBox());
  }
}

class ItemCard extends StatelessWidget {
  final Widget child;
  final Info info;
  final List<Widget> actions;

  const ItemCard({
    super.key,
    required this.info,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
      ),
      child: Wrap(
        runSpacing: 16,
        children: [
          InfoHeader(
            info: info,
            actions: actions,
          ),
          child,
        ],
      ),
    );
  }
}

class ThemeColorsBox extends ConsumerStatefulWidget {
  const ThemeColorsBox({super.key});

  @override
  ConsumerState<ThemeColorsBox> createState() => _ThemeColorsBoxState();
}

class _ThemeColorsBoxState extends ConsumerState<ThemeColorsBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ThemeModeItem(),
        _PrimaryColorItem(),
        _PrueBlackItem(),
        const SizedBox(
          height: 64,
        ),
      ],
    );
  }
}

class _ThemeModeItem extends ConsumerWidget {
  const _ThemeModeItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeSettingProvider.select((state) => state.themeMode));
    List<ThemeModeItem> themeModeItems = [
      ThemeModeItem(
        iconData: Icons.auto_mode,
        label: appLocalizations.auto,
        themeMode: ThemeMode.system,
      ),
      ThemeModeItem(
        iconData: Icons.light_mode,
        label: appLocalizations.light,
        themeMode: ThemeMode.light,
      ),
      ThemeModeItem(
        iconData: Icons.dark_mode,
        label: appLocalizations.dark,
        themeMode: ThemeMode.dark,
      ),
    ];
    return ItemCard(
      info: Info(
        label: appLocalizations.themeMode,
        iconData: Icons.brightness_high,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: themeModeItems.length,
          itemBuilder: (_, index) {
            final themeModeItem = themeModeItems[index];
            return CommonCard(
              isSelected: themeModeItem.themeMode == themeMode,
              onPressed: () {
                ref.read(themeSettingProvider.notifier).updateState(
                      (state) => state.copyWith(
                        themeMode: themeModeItem.themeMode,
                      ),
                    );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Icon(themeModeItem.iconData),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child: Text(
                        themeModeItem.label,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) {
            return const SizedBox(
              width: 16,
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryColorItem extends ConsumerStatefulWidget {
  const _PrimaryColorItem();

  @override
  ConsumerState<_PrimaryColorItem> createState() => _PrimaryColorItemState();
}

class _PrimaryColorItemState extends ConsumerState<_PrimaryColorItem> {
  int? _removablePrimaryColor;

  int _calcColumns(double maxWidth) {
    return max((maxWidth / 96).ceil(), 3);
  }

  _handleReset() async {
    final res = await globalState.showMessage(
      message: TextSpan(
        text: appLocalizations.resetTip,
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).updateState(
      (state) {
        return state.copyWith(
          primaryColors: defaultPrimaryColors,
          primaryColor: defaultPrimaryColor,
          schemeVariant: DynamicSchemeVariant.tonalSpot,
        );
      },
    );
  }

  _handleDel() async {
    if (_removablePrimaryColor == null) {
      return;
    }
    final res = await globalState.showMessage(
        message: TextSpan(text: appLocalizations.deleteColorTip));
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).updateState(
      (state) {
        final newPrimaryColors = List<int>.from(state.primaryColors)
          ..remove(_removablePrimaryColor);
        int? newPrimaryColor = state.primaryColor;
        if (state.primaryColor == _removablePrimaryColor) {
          if (newPrimaryColors.contains(defaultPrimaryColor)) {
            newPrimaryColor = defaultPrimaryColor;
          } else {
            newPrimaryColor = null;
          }
        }
        return state.copyWith(
          primaryColors: newPrimaryColors,
          primaryColor: newPrimaryColor,
        );
      },
    );
    setState(() {
      _removablePrimaryColor = null;
    });
  }

  _handleAdd() async {
    final res = await globalState.showCommonDialog<int>(
      child: _PaletteDialog(),
    );
    if (res == null) {
      return;
    }
    final isExists = ref.read(
      themeSettingProvider.select((state) => state.primaryColors.contains(res)),
    );
    if (isExists && mounted) {
      context.showNotifier(appLocalizations.colorExists);
      return;
    }
    ref.read(themeSettingProvider.notifier).updateState(
      (state) {
        return state.copyWith(
          primaryColors: List.from(
            state.primaryColors,
          )..add(res),
        );
      },
    );
  }

  _handleChangeSchemeVariant() async {
    final schemeVariant = ref.read(
      themeSettingProvider.select(
        (state) => state.schemeVariant,
      ),
    );
    final value = await globalState.showCommonDialog<DynamicSchemeVariant>(
      child: OptionsDialog<DynamicSchemeVariant>(
        title: appLocalizations.colorSchemes,
        options: DynamicSchemeVariant.values,
        textBuilder: (item) => Intl.message("${item.name}Scheme"),
        value: schemeVariant,
      ),
    );
    if (value == null) {
      return;
    }
    ref.read(themeSettingProvider.notifier).updateState(
      (state) {
        return state.copyWith(
          schemeVariant: value,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm3 = ref.watch(
      themeSettingProvider.select(
        (state) => VM3(
          a: state.primaryColor,
          b: state.primaryColors,
          c: state.schemeVariant,
        ),
      ),
    );
    final primaryColor = vm3.a;
    final primaryColors = [null, ...vm3.b];
    final schemeVariant = vm3.c;

    return ItemCard(
      info: Info(
        label: appLocalizations.themeColor,
        iconData: Icons.palette,
      ),
      actions: genActions(
        [
          if (_removablePrimaryColor == null)
            FilledButton(
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
              onPressed: _handleChangeSchemeVariant,
              child: Text(Intl.message("${schemeVariant.name}Scheme")),
            ),
          _removablePrimaryColor != null
              ? FilledButton(
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    setState(() {
                      _removablePrimaryColor = null;
                    });
                  },
                  child: Text(appLocalizations.cancel),
                )
              : IconButton.filledTonal(
                  iconSize: 20,
                  padding: EdgeInsets.all(4),
                  visualDensity: VisualDensity.compact,
                  onPressed: _handleReset,
                  icon: Icon(Icons.replay),
                )
        ],
        space: 8,
      ),
      child: Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final columns = _calcColumns(constraints.maxWidth);
            final itemWidth =
                (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final color in primaryColors)
                  Container(
                    clipBehavior: Clip.none,
                    width: itemWidth,
                    height: itemWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        EffectGestureDetector(
                          child: ColorSchemeBox(
                            isSelected: color == primaryColor,
                            primaryColor: color != null ? Color(color) : null,
                            onPressed: () {
                              ref
                                  .read(themeSettingProvider.notifier)
                                  .updateState(
                                    (state) => state.copyWith(
                                      primaryColor: color,
                                    ),
                                  );
                            },
                          ),
                          onLongPress: () {
                            setState(() {
                              _removablePrimaryColor = color;
                            });
                          },
                        ),
                        if (_removablePrimaryColor != null &&
                            _removablePrimaryColor == color)
                          Container(
                            color: Colors.white.opacity0,
                            padding: EdgeInsets.all(8),
                            child: IconButton.filledTonal(
                              onPressed: _handleDel,
                              padding: EdgeInsets.all(12),
                              iconSize: 30,
                              icon: Icon(
                                color: context.colorScheme.primary,
                                Icons.delete,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (_removablePrimaryColor == null)
                  Container(
                    width: itemWidth,
                    height: itemWidth,
                    padding: EdgeInsets.all(
                      4,
                    ),
                    child: IconButton.filledTonal(
                      onPressed: _handleAdd,
                      iconSize: 32,
                      icon: Icon(
                        color: context.colorScheme.primary,
                        Icons.add,
                      ),
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

class _PrueBlackItem extends ConsumerWidget {
  const _PrueBlackItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prueBlack =
        ref.watch(themeSettingProvider.select((state) => state.pureBlack));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListItem.switchItem(
        leading: Icon(
          Icons.contrast,
        ),
        horizontalTitleGap: 12,
        title: Text(
          appLocalizations.pureBlackMode,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
        ),
        delegate: SwitchDelegate(
          value: prueBlack,
          onChanged: (value) {
            ref.read(themeSettingProvider.notifier).updateState(
                  (state) => state.copyWith(
                    pureBlack: value,
                  ),
                );
          },
        ),
      ),
    );
  }
}

class _PaletteDialog extends StatefulWidget {
  const _PaletteDialog();

  @override
  State<_PaletteDialog> createState() => _PaletteDialogState();
}

class _PaletteDialogState extends State<_PaletteDialog> {
  final _controller = ValueNotifier<ui.Color>(Colors.transparent);

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.palette,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.value.toARGB32());
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        children: [
          SizedBox(
            height: 8,
          ),
          SizedBox(
            width: 250,
            height: 250,
            child: Palette(
              controller: _controller,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, color, __) {
              return PrimaryColorBox(
                primaryColor: color,
                child: FilledButton(
                  onPressed: () {},
                  child: Text(
                    _controller.value.hex,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
