import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tab.dart';

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key, this.picker = false});

  /// Leaves the bar only its search and delay test, for picking a proxy from a
  /// sheet.
  final bool picker;

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();

  // The same instance on every build, so the bar changing with the current
  // group or its delay test leaves the page alone.
  late final _tabView = ProxiesTabView(key: _proxiesTabKey);
  bool _isTab = false;

  void _updateStyle(
    ProxiesStyleProps Function(ProxiesStyleProps state) update,
  ) {
    ref.read(proxiesStyleSettingProvider.notifier).update(update);
  }

  List<CommonPopupMenuItem> _buildMenuItems(
    BuildContext context,
    ProxiesStyleProps style,
  ) {
    final appLocalizations = context.appLocalizations;
    return [
      _optionsMenuItem(
        glyph: AppGlyphs.appsList,
        label: appLocalizations.style,
        section: const CommonPopupMenuSection(),
        options: ProxiesType.values,
        value: style.type,
        textOf: (type) => type.label,
        onSelected: (type) =>
            _updateStyle((state) => state.copyWith(type: type)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.sort,
        label: appLocalizations.sort,
        options: ProxiesSortType.values,
        value: style.sortType,
        textOf: (type) => switch (type) {
          ProxiesSortType.none => appLocalizations.defaultText,
          ProxiesSortType.delay => appLocalizations.delay,
          ProxiesSortType.name => appLocalizations.name,
        },
        onSelected: (type) =>
            _updateStyle((state) => state.copyWith(sortType: type)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.dashboard,
        label: appLocalizations.layout,
        options: ProxiesLayout.values,
        value: style.layout,
        textOf: (layout) => switch (layout) {
          ProxiesLayout.tight => appLocalizations.tight,
          ProxiesLayout.standard => appLocalizations.standard,
          ProxiesLayout.loose => appLocalizations.loose,
        },
        onSelected: (layout) =>
            _updateStyle((state) => state.copyWith(layout: layout)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.textSize,
        label: appLocalizations.size,
        options: ProxyCardType.values,
        value: style.cardType,
        textOf: (type) => type.label,
        onSelected: (type) =>
            _updateStyle((state) => state.copyWith(cardType: type)),
      ),
      if (style.type == ProxiesType.list)
        _optionsMenuItem(
          glyph: AppGlyphs.iconTile,
          label: appLocalizations.iconStyle,
          options: ProxiesIconStyle.values,
          value: style.iconStyle,
          textOf: (iconStyle) => switch (iconStyle) {
            ProxiesIconStyle.filled => appLocalizations.iconStyleFilled,
            ProxiesIconStyle.plain => appLocalizations.iconStylePlain,
            ProxiesIconStyle.hidden => appLocalizations.iconStyleHidden,
          },
          onSelected: (iconStyle) =>
              _updateStyle((state) => state.copyWith(iconStyle: iconStyle)),
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.eyeOff,
        label: appLocalizations.hideTimeoutProxies,
        checked: style.hideTimeoutProxies,
        section: const CommonPopupMenuSection(),
        onPressed: () => _updateStyle(
          (state) =>
              state.copyWith(hideTimeoutProxies: !state.hideTimeoutProxies),
        ),
      ),
    ];
  }

  IconButtonData? _buildPrimaryAction() {
    if (!_isTab) {
      return null;
    }
    final isDelayTesting = ref.watch(currentGroupDelayTestingProvider);
    return IconButtonData(
      glyph: AppGlyphs.bolt,
      onPressed: () {
        _proxiesTabKey.currentState?.delayTestCurrentGroup();
      },
      tooltip: context.appLocalizations.delayTest,
      isLoading: isDelayTesting,
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.proxies).notifier).value = value;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      proxiesStyleSettingProvider.select(
        (state) => state.type == ProxiesType.tab,
      ),
      (prev, next) {
        if (prev != next) {
          setState(() {
            _isTab = next;
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = ref.watch(proxiesStyleSettingProvider);
    final isLoading = ref.watch(loadingProvider(LoadingTag.proxies));
    final picker = widget.picker;
    final primaryAction = _buildPrimaryAction();
    return CommonScaffold(
      isLoading: isLoading,
      resizeToAvoidBottomInset: false,
      primaryAction: primaryAction,
      searchActions: [?primaryAction],
      iconActions: [
        if (_isTab && !picker)
          IconButtonData(
            glyph: AppGlyphs.locate,
            onPressed: () {
              _proxiesTabKey.currentState?.scrollToGroupSelected();
            },
            tooltip: context.appLocalizations.scrollToSelected,
          ),
      ],
      menuItems: picker ? const [] : _buildMenuItems(context, style),
      title: context.appLocalizations.proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (style.type) {
        ProxiesType.tab => _tabView,
        ProxiesType.list => const ProxiesListView(),
      },
    );
  }
}

CommonPopupMenuItem _optionsMenuItem<T>({
  required Glyph glyph,
  required String label,
  required List<T> options,
  required T value,
  required String Function(T option) textOf,
  required ValueSetter<T> onSelected,
  CommonPopupMenuSection? section,
}) {
  return CommonPopupMenuItem(
    glyph: glyph,
    label: label,
    section: section,
    subItems: [
      for (final option in options)
        CommonPopupMenuItem(
          label: textOf(option),
          checked: option == value,
          onPressed: () => onSelected(option),
        ),
    ],
  );
}
