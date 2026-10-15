import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxiesSetting extends ConsumerWidget {
  const ProxiesSetting({super.key});

  static ConfigWriter<T> _writer<T>(
    ProxiesStyleProps Function(ProxiesStyleProps state, T value) update,
  ) {
    return (ref, value) => ref
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => update(state, value));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isList = ref.watch(
      proxiesStyleSettingProvider.select(
        (state) => state.type == ProxiesType.list,
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(top: context.contentTopPadding, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          generateSection(
            items: [
              ConfigOptionsItem<ProxiesType>(
                title: (l) => l.style,
                options: ProxiesType.values,
                textBuilder: (type) => type.label,
                selector: proxiesStyleSettingProvider.select(
                  (state) => state.type,
                ),
                onChanged: _writer(
                  (state, value) => state.copyWith(type: value),
                ),
              ),
              ConfigOptionsItem<ProxiesSortType>(
                title: (l) => l.sort,
                options: ProxiesSortType.values,
                textBuilder: (type) => switch (type) {
                  ProxiesSortType.none => appLocalizations.defaultText,
                  ProxiesSortType.delay => appLocalizations.delay,
                  ProxiesSortType.name => appLocalizations.name,
                },
                selector: proxiesStyleSettingProvider.select(
                  (state) => state.sortType,
                ),
                onChanged: _writer(
                  (state, value) => state.copyWith(sortType: value),
                ),
              ),
              ConfigOptionsItem<ProxiesLayout>(
                title: (l) => l.layout,
                options: ProxiesLayout.values,
                textBuilder: (layout) => switch (layout) {
                  ProxiesLayout.tight => appLocalizations.tight,
                  ProxiesLayout.standard => appLocalizations.standard,
                  ProxiesLayout.loose => appLocalizations.loose,
                },
                selector: proxiesStyleSettingProvider.select(
                  (state) => state.layout,
                ),
                onChanged: _writer(
                  (state, value) => state.copyWith(layout: value),
                ),
              ),
              ConfigOptionsItem<ProxyCardType>(
                title: (l) => l.size,
                options: ProxyCardType.values,
                textBuilder: (type) => type.label,
                selector: proxiesStyleSettingProvider.select(
                  (state) => state.cardType,
                ),
                onChanged: _writer(
                  (state, value) => state.copyWith(cardType: value),
                ),
              ),
              if (isList)
                ConfigOptionsItem<ProxiesIconStyle>(
                  title: (l) => l.iconStyle,
                  options: ProxiesIconStyle.values,
                  textBuilder: (style) => switch (style) {
                    ProxiesIconStyle.filled => appLocalizations.iconStyleFilled,
                    ProxiesIconStyle.plain => appLocalizations.iconStylePlain,
                    ProxiesIconStyle.hidden => appLocalizations.iconStyleHidden,
                  },
                  selector: proxiesStyleSettingProvider.select(
                    (state) => state.iconStyle,
                  ),
                  onChanged: _writer(
                    (state, value) => state.copyWith(iconStyle: value),
                  ),
                ),
            ],
          ),
          generateSection(
            title: appLocalizations.filter,
            footer: appLocalizations.hideTimeoutProxiesDesc,
            items: [
              ConfigToggleItem(
                title: (l) => l.hideTimeoutProxies,
                selector: proxiesStyleSettingProvider.select(
                  (state) => state.hideTimeoutProxies,
                ),
                onChanged: _writer(
                  (state, value) => state.copyWith(hideTimeoutProxies: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
