import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScriptContent extends ConsumerWidget {
  const ScriptContent({super.key});

  void _handleChange(WidgetRef ref, int profileId, int? scriptId) {
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      return state.copyWith(scriptId: scriptId);
    });
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final scriptId = ref.watch(
      profileProvider(profileId).select((state) => state?.scriptId),
    );
    final labels = {
      for (final script in ref.watch(scriptsProvider).value ?? const [])
        script.id: script.label,
    };
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: generateSection(
          title: appLocalizations.script,
          items: [
            ListItem<int?>.options(
              title: Text(appLocalizations.extendScript),
              options: [null, ...labels.keys],
              sectionStarts: {...labels.keys.take(1)},
              value: labels.containsKey(scriptId) ? scriptId : null,
              textBuilder: (id) => labels[id] ?? appLocalizations.none,
              onChanged: (id) => _handleChange(ref, profileId, id),
            ),
            ListItem.open(
              title: Text(appLocalizations.goToConfigureScript),
              widget: const ScriptsView(),
            ),
          ],
        ),
      ),
    );
  }
}
