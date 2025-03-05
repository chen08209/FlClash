import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final previewCard = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CommonCard(
        onPressed: () {},
        info: Info(
          label: appLocalizations.preview,
          iconData: Icons.looks,
        ),
        child: Container(
          height: 200,
        ),
      ),
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          previewCard,
          const ThemeColorsBox(),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Widget child;
  final Info info;

  const ItemCard({
    super.key,
    required this.info,
    required this.child,
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
        // _FontFamilyItem(),
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

// class _FontFamilyItem extends ConsumerWidget {
//   const _FontFamilyItem();
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final fontFamily =
//         ref.watch(themeSettingProvider.select((state) => state.fontFamily));
//     List<FontFamilyItem> fontFamilyItems = [
//       FontFamilyItem(
//         label: appLocalizations.systemFont,
//         fontFamily: FontFamily.system,
//       ),
//       const FontFamilyItem(
//         label: "roboto",
//         fontFamily: FontFamily.roboto,
//       ),
//     ];
//     return ItemCard(
//       info: Info(
//         label: appLocalizations.fontFamily,
//         iconData: Icons.text_fields,
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(
//           left: 16,
//           right: 16,
//         ),
//         height: 48,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           itemBuilder: (_, index) {
//             final fontFamilyItem = fontFamilyItems[index];
//             return CommonCard(
//               isSelected: fontFamilyItem.fontFamily == fontFamily,
//               onPressed: () {
//                 ref.read(themeSettingProvider.notifier).updateState(
//                       (state) => state.copyWith(
//                         fontFamily: fontFamilyItem.fontFamily,
//                       ),
//                     );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         fontFamilyItem.label,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//           separatorBuilder: (_, __) {
//             return const SizedBox(
//               width: 16,
//             );
//           },
//           itemCount: fontFamilyItems.length,
//         ),
//       ),
//     );
//   }
// }

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
        height: 64,
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

class _PrimaryColorItem extends ConsumerWidget {
  const _PrimaryColorItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor =
        ref.watch(themeSettingProvider.select((state) => state.primaryColor));
    List<Color?> primaryColors = [
      null,
      defaultPrimaryColor,
      Colors.pinkAccent,
      Colors.lightBlue,
      Colors.greenAccent,
      Colors.yellowAccent,
      Colors.purple,
    ];
    return ItemCard(
      info: Info(
        label: appLocalizations.themeColor,
        iconData: Icons.palette,
      ),
      child: Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            final color = primaryColors[index];
            return ColorSchemeBox(
              isSelected: color?.value == primaryColor,
              primaryColor: color,
              onPressed: () {
                ref.read(themeSettingProvider.notifier).updateState(
                      (state) => state.copyWith(
                        primaryColor: color?.value,
                      ),
                    );
              },
            );
          },
          separatorBuilder: (_, __) {
            return const SizedBox(
              width: 16,
            );
          },
          itemCount: primaryColors.length,
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
          color: context.colorScheme.primary,
        ),
        title: Text(appLocalizations.pureBlackMode),
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
