import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:material_ui/material_ui.dart';

import 'rules.dart';

class AdvancedConfigView extends StatelessWidget {
  const AdvancedConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final items = [
      ListItem.open(
        title: Text(appLocalizations.network),
        leading: const GlyphIcon(AppGlyphs.key),
        widget: BaseScaffold(
          title: appLocalizations.network,
          body: const NetworkListView(),
        ),
      ),
      ListItem.open(
        title: const Text('DNS'),
        leading: const GlyphIcon(AppGlyphs.dns),
        widget: const DnsView(),
      ),
      ListItem.open(
        title: Text(appLocalizations.addedRules),
        leading: const GlyphIcon(AppGlyphs.rules),
        widget: const AddedRulesView(),
      ),
      ListItem.open(
        title: Text(appLocalizations.script),
        leading: const GlyphIcon(AppGlyphs.code),
        widget: const ScriptsView(),
      ),
    ];
    return BaseScaffold(
      title: appLocalizations.advancedConfig,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 16),
        children: [generateSection(items: items)],
      ),
    );
  }
}
