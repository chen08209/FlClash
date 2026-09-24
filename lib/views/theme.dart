import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/views/theme_preview.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/hct/hct.dart';

class FontFamilyItem {
  final FontFamily fontFamily;
  final String label;

  const FontFamilyItem({required this.fontFamily, required this.label});
}

class ThemeView extends StatelessWidget {
  const ThemeView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return BaseScaffold(
      title: appLocalizations.theme,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: context.appBarInset)),
          const SliverToBoxAdapter(child: ThemeLivePreview()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _ThemeModeItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _PureBlackItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _PrimaryColorItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _NavigationBarItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _TabAnimationItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _SidebarBlurItem(),
          const _TextScaleFactorItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Widget child;
  final Info info;
  final List<Widget> actions;
  final double? space;

  const ItemCard({
    super.key,
    required this.info,
    required this.child,
    this.actions = const [],
    this.space,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 16,
      children: [
        InfoHeader(info: info, actions: actions, space: space),
        child,
      ],
    );
  }
}

class _ThemeModeItem extends ConsumerWidget {
  const _ThemeModeItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    final light = MiniScreen(
      colorScheme: ref.watch(genColorSchemeProvider(Brightness.light)),
      floatingBar: floatingBar,
    );
    final dark = MiniScreen(
      colorScheme: ref.watch(genColorSchemeProvider(Brightness.dark)),
      floatingBar: floatingBar,
    );
    return SliverToBoxAdapter(
      child: PreviewChoiceGroup<ThemeMode>(
        info: Info(label: appLocalizations.themeMode, glyph: AppGlyphs.sun),
        value: themeMode,
        choices: [
          PreviewChoice(
            value: ThemeMode.system,
            label: appLocalizations.auto,
            pictogram: MiniScreenThumb(
              screen: MiniSplitScreen(light: light, dark: dark),
            ),
          ),
          PreviewChoice(
            value: ThemeMode.light,
            label: appLocalizations.light,
            pictogram: MiniScreenThumb(screen: light),
          ),
          PreviewChoice(
            value: ThemeMode.dark,
            label: appLocalizations.dark,
            pictogram: MiniScreenThumb(screen: dark),
          ),
        ],
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(themeMode: value));
        },
      ),
    );
  }
}

const double _headerButtonHeight = 32;

final _headerButtonStyle = FilledButton.styleFrom(
  minimumSize: const Size(0, _headerButtonHeight),
  padding: const EdgeInsets.symmetric(horizontal: 14),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.standard,
);

class _PrimaryColorItem extends ConsumerStatefulWidget {
  const _PrimaryColorItem();

  @override
  ConsumerState<_PrimaryColorItem> createState() => _PrimaryColorItemState();
}

class _PrimaryColorItemState extends ConsumerState<_PrimaryColorItem> {
  int? _removablePrimaryColor;

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(
        primaryColors: defaultPrimaryColors,
        primaryColor: defaultPrimaryColor,
        schemeVariant: DynamicSchemeVariant.content,
      );
    });
  }

  Future<void> _handleDel() async {
    final appLocalizations = context.appLocalizations;
    if (_removablePrimaryColor == null) {
      return;
    }
    final res = await dialogs.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.colorSchemes),
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
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
    });
    setState(() {
      _removablePrimaryColor = null;
    });
  }

  Future<void> _handleAdd() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showCommonDialog<int>(
      child: const _PaletteDialog(),
    );
    if (res == null) {
      return;
    }
    final isExists = ref.read(
      themeSettingProvider.select((state) => state.primaryColors.contains(res)),
    );
    if (isExists && mounted) {
      context.showNotifier(
        appLocalizations.existsTip(appLocalizations.colorSchemes),
        level: MessageLevel.warning,
      );
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(
        primaryColors: List.from(state.primaryColors)..add(res),
      );
    });
  }

  Future<void> _handleChangeSchemeVariant() async {
    final schemeVariant = ref.read(
      themeSettingProvider.select((state) => state.schemeVariant),
    );
    final value = await dialogs.showCommonDialog<DynamicSchemeVariant>(
      child: OptionsDialog<DynamicSchemeVariant>(
        title: context.appLocalizations.colorSchemes,
        options: DynamicSchemeVariant.values,
        textBuilder: (item) => item.label,
        value: schemeVariant,
      ),
    );
    if (value == null) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(schemeVariant: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final themeColors = ref.watch(
      themeSettingProvider.select(
        (state) => ThemeColorsSelectorState(
          primaryColor: state.primaryColor,
          primaryColors: state.primaryColors,
          schemeVariant: state.schemeVariant,
          isDefault:
              state.primaryColor == defaultPrimaryColor &&
              intListEquality.equals(
                state.primaryColors,
                defaultPrimaryColors,
              ) &&
              state.schemeVariant == DynamicSchemeVariant.content,
        ),
      ),
    );
    final primaryColor = themeColors.primaryColor;
    final primaryColors = [null, ...themeColors.primaryColors];
    final schemeVariant = themeColors.schemeVariant;
    final isEquals = themeColors.isDefault;

    return SliverToBoxAdapter(
      child: CommonPopScope(
        onPop: _removablePrimaryColor == null
            ? null
            : (_) {
                _clearRemovable();
                return false;
              },
        child: ItemCard(
          info: Info(
            label: appLocalizations.themeColor,
            glyph: AppGlyphs.palette,
          ),
          space: 8,
          actions: [
            if (_removablePrimaryColor == null)
              ElasticButton(
                child: FilledButton.tonal(
                  style: _headerButtonStyle,
                  onPressed: _handleChangeSchemeVariant,
                  child: Text(schemeVariant.label),
                ),
              ),
            if (_removablePrimaryColor != null)
              ElasticButton(
                child: FilledButton(
                  style: _headerButtonStyle,
                  onPressed: _clearRemovable,
                  child: Text(appLocalizations.cancel),
                ),
              ),
            if (_removablePrimaryColor == null && !isEquals)
              ElasticButton(
                child: IconButton.filledTonal(
                  tooltip: context.appLocalizations.reset,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: _headerButtonHeight,
                    height: _headerButtonHeight,
                  ),
                  visualDensity: VisualDensity.standard,
                  onPressed: _handleReset,
                  icon: const GlyphIcon(AppGlyphs.reset, fill: 1),
                ),
              ),
          ],
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _PrimaryColorGrid(
              colors: primaryColors,
              selectedColor: primaryColor,
              removableColor: _removablePrimaryColor,
              onSelect: _handleSelectColor,
              onRequestRemove: _markRemovable,
              onDelete: _handleDel,
              onAdd: _handleAdd,
            ),
          ),
        ),
      ),
    );
  }

  void _clearRemovable() {
    setState(() {
      _removablePrimaryColor = null;
    });
  }

  void _markRemovable(int? color) {
    setState(() {
      _removablePrimaryColor = color;
    });
  }

  void _handleSelectColor(int? color) {
    _clearRemovable();
    ref
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(primaryColor: color));
  }
}

class _PrimaryColorGrid extends StatelessWidget {
  const _PrimaryColorGrid({
    required this.colors,
    required this.selectedColor,
    required this.removableColor,
    required this.onSelect,
    required this.onRequestRemove,
    required this.onDelete,
    required this.onAdd,
  });

  static const double _size = 48;

  final List<int?> colors;
  final int? selectedColor;
  final int? removableColor;
  final void Function(int? color) onSelect;
  final void Function(int? color) onRequestRemove;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in colors)
          _PrimaryColorTile(
            color: color,
            isSelected: color == selectedColor,
            isRemovable: removableColor != null && removableColor == color,
            onSelect: () => onSelect(color),
            onRequestRemove: () => onRequestRemove(color),
            onDelete: onDelete,
          ),
        if (removableColor == null)
          SizedBox.square(
            dimension: _size,
            child: IconButton.filledTonal(
              tooltip: context.appLocalizations.add,
              onPressed: onAdd,
              icon: const GlyphIcon(AppGlyphs.add, fill: 1),
            ),
          ),
      ],
    );
  }
}

class _PrimaryColorTile extends StatelessWidget {
  const _PrimaryColorTile({
    required this.color,
    required this.isSelected,
    required this.isRemovable,
    required this.onSelect,
    required this.onRequestRemove,
    required this.onDelete,
  });

  final int? color;
  final bool isSelected;
  final bool isRemovable;
  final VoidCallback onSelect;
  final VoidCallback onRequestRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Stack(
      children: [
        EffectGestureDetector(
          onLongPress: onRequestRemove,
          child: ColorSchemeBox(
            isSelected: isSelected,
            primaryColor: color != null ? Color(color!) : null,
            onPressed: onSelect,
            size: _PrimaryColorGrid._size,
          ),
        ),
        if (isRemovable)
          Positioned.fill(
            child: Tooltip(
              message: context.appLocalizations.delete,
              child: Material(
                color: colorScheme.errorContainer.withValues(alpha: 0.9),
                shape: AppShape.circle,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: AppShape.circle,
                  onTap: onDelete,
                  child: Center(
                    child: GlyphIcon(
                      AppGlyphs.delete,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

final _floatingBarProvider = appSettingProvider.select(
  (state) => state.floatingNavigationBar,
);

class _PureBlackItem extends ConsumerWidget {
  const _PureBlackItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final pureBlack = ref.watch(
      themeSettingProvider.select((state) => state.pureBlack),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    Widget preview(bool pureBlack) => MiniScreenThumb(
      screen: MiniScreen(
        colorScheme: ref.watch(
          genColorSchemeProvider(Brightness.dark, pureBlack: pureBlack),
        ),
        floatingBar: floatingBar,
      ),
    );
    return SliverToBoxAdapter(
      child: PreviewChoiceGroup<bool>(
        info: Info(
          label: appLocalizations.pureBlackMode,
          glyph: AppGlyphs.pureBlack,
        ),
        value: pureBlack,
        choices: [
          PreviewChoice(
            value: false,
            label: appLocalizations.standard,
            pictogram: preview(false),
          ),
          PreviewChoice(
            value: true,
            label: appLocalizations.pureBlack,
            pictogram: preview(true),
          ),
        ],
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(pureBlack: value));
        },
      ),
    );
  }
}

class _NavigationBarItem extends ConsumerWidget {
  const _NavigationBarItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final floatingBar = ref.watch(_floatingBarProvider);
    final colorScheme = context.colorScheme;
    return SliverToBoxAdapter(
      child: PreviewChoiceGroup<bool>(
        info: Info(
          label: appLocalizations.navigationBarStyle,
          glyph: AppGlyphs.layers,
        ),
        value: floatingBar,
        choices: [
          PreviewChoice(
            value: true,
            label: appLocalizations.floating,
            pictogram: MiniScreenThumb(
              screen: MiniScreen(colorScheme: colorScheme, floatingBar: true),
            ),
          ),
          PreviewChoice(
            value: false,
            label: appLocalizations.docked,
            pictogram: MiniScreenThumb(
              screen: MiniScreen(colorScheme: colorScheme, floatingBar: false),
            ),
          ),
        ],
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(floatingNavigationBar: value));
        },
      ),
    );
  }
}

class _TabAnimationItem extends ConsumerWidget {
  const _TabAnimationItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final tabAnimation = ref.watch(
      appSettingProvider.select((state) => state.tabAnimation),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    final colorScheme = context.colorScheme;
    Widget switching(TabAnimation tabAnimation) => MiniScreenThumb(
      screen: MiniScreen(
        colorScheme: colorScheme,
        floatingBar: floatingBar,
        selected: 1,
        previous: 0,
        progress: 0.55,
        tabAnimation: tabAnimation,
      ),
    );
    return SliverToBoxAdapter(
      child: PreviewChoiceGroup<TabAnimation>(
        info: Info(
          label: appLocalizations.tabAnimation,
          glyph: AppGlyphs.motion,
        ),
        value: tabAnimation,
        choices: [
          PreviewChoice(
            value: TabAnimation.slide,
            label: appLocalizations.slide,
            pictogram: switching(TabAnimation.slide),
          ),
          PreviewChoice(
            value: TabAnimation.fade,
            label: appLocalizations.fade,
            pictogram: switching(TabAnimation.fade),
          ),
        ],
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(tabAnimation: value));
        },
      ),
    );
  }
}

class _SidebarBlurItem extends ConsumerWidget {
  const _SidebarBlurItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!feature.sidebarBlur || (!system.isMacOS && !system.isWindows)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final appLocalizations = context.appLocalizations;
    final sidebarBlur = ref.watch(
      themeSettingProvider.select((state) => state.sidebarBlur),
    );
    return SliverToBoxAdapter(
      child: ListItem.toggle(
        leading: const GlyphIcon(AppGlyphs.blur),
        horizontalTitleGap: 12,
        title: Text(
          appLocalizations.sidebarBlur,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(appLocalizations.sidebarBlurDesc),
        value: sidebarBlur,
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(sidebarBlur: value));
        },
      ),
    );
  }
}

class _TextScaleFactorItem extends ConsumerStatefulWidget {
  const _TextScaleFactorItem();

  static const _step = 0.05;

  @override
  ConsumerState<_TextScaleFactorItem> createState() =>
      _TextScaleFactorItemState();
}

class _TextScaleFactorItemState extends ConsumerState<_TextScaleFactorItem> {
  double? _draft;

  void _update(TextScale Function(TextScale textScale) update) {
    setState(() => _draft = null);
    ref
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(textScale: update(state.textScale)));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final textScale = ref.watch(
      themeSettingProvider.select((state) => state.textScale),
    );
    final systemScale = defaultTextScaleFactor
        .clamp(minTextScale, maxTextScale)
        .toDouble();
    final scale = _draft ?? (textScale.enable ? textScale.scale : systemScale);
    final percent = '${(scale * 100).round()}%';
    final divisions =
        ((maxTextScale - minTextScale) / _TextScaleFactorItem._step).round();
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(
            info: Info(
              label: appLocalizations.textScale,
              glyph: AppGlyphs.textSize,
            ),
            actions: [
              if (textScale.enable && textScale.scale != 1)
                ElasticButton(
                  child: IconButton.filledTonal(
                    tooltip: appLocalizations.reset,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: _headerButtonHeight,
                      height: _headerButtonHeight,
                    ),
                    visualDensity: VisualDensity.standard,
                    onPressed: () =>
                        _update((state) => state.copyWith(scale: 1)),
                    icon: const GlyphIcon(AppGlyphs.reset, fill: 1),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              spacing: 8,
              children: [
                _SegmentedToggle(
                  value: textScale.enable,
                  offLabel: appLocalizations.followSystem,
                  onLabel: appLocalizations.custom,
                  onChanged: (value) =>
                      _update((state) => state.copyWith(enable: value)),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: ShapeDecoration(
                    color: colorScheme.surfaceContainerLow,
                    shape: AppShape.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Expanded(
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topLeft,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaler: TextScaler.linear(scale),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      'Aa',
                                      style: context.textTheme.titleLarge,
                                    ),
                                    Text(
                                      appLocalizations.textScalePreview,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: ShapeDecoration(
                              color: colorScheme.secondaryContainer,
                              shape: AppShape.full,
                            ),
                            child: Text(
                              percent,
                              style: context.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MediaQuery.withNoTextScaling(
                        child: Row(
                          spacing: 12,
                          children: [
                            ExcludeSemantics(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderDefaultsM3(context),
                                child: Slider(
                                  padding: EdgeInsets.zero,
                                  min: minTextScale,
                                  max: maxTextScale,
                                  divisions: divisions,
                                  value: scale,
                                  label: percent,
                                  onChanged: textScale.enable
                                      ? (value) =>
                                            setState(() => _draft = value)
                                      : null,
                                  onChangeEnd: (value) => _update(
                                    (state) => state.copyWith(scale: value),
                                  ),
                                ),
                              ),
                            ),
                            ExcludeSemantics(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.value,
    required this.offLabel,
    required this.onLabel,
    required this.onChanged,
  });

  static const double _height = 44;
  static const double _inset = 4;

  final bool value;
  final String offLabel;
  final String onLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      height: _height,
      padding: const EdgeInsets.all(_inset),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHigh,
        shape: AppShape.full,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: colorScheme.secondaryContainer,
                  shape: AppShape.full,
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (option, label) in [
                (false, offLabel),
                (true, onLabel),
              ])
                Expanded(
                  child: Semantics(
                    selected: option == value,
                    button: true,
                    child: Material(
                      type: MaterialType.transparency,
                      shape: AppShape.full,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        customBorder: AppShape.full,
                        onTap: option == value ? null : () => onChanged(option),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: context.textTheme.labelLarge!.copyWith(
                              color: option == value
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: option == value
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
  final _controller = ValueNotifier<Color>(Color(Hct.from(0, 0, 60).toInt()));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
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
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 300, child: Palette(controller: _controller)),
        ],
      ),
    );
  }
}
