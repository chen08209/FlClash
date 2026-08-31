import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/name_add_picker.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/name_list_editor.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProxiesView extends ConsumerWidget {
  const EditProxiesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final proxyTypeMap =
        ref.watch(
          clashConfigProvider(
            profileId,
          ).select((state) => state.value?.proxyTypeMap),
        ) ??
        {};
    return NameListEditor(
      stageTag: 'EditProxiesViewState_handleRealRemove',
      labels: NameListEditorLabels(
        title: appLocalizations.editProxy,
        section: appLocalizations.proxies,
        empty: appLocalizations.proxiesEmpty,
        includeAll: appLocalizations.includeAllProxies,
        includeAllTip: appLocalizations.includeAllProxiesTip,
      ),
      lens: NameListEditorLens(
        namesOf: (state) => state.proxies ?? const [],
        withNames: (state, names) => state.copyWith(proxies: names),
        includeAllOf: (state) => state.includeAllProxies ?? false,
        withIncludeAll: (state, includeAll) =>
            state.copyWith(includeAllProxies: includeAll),
      ),
      addViewBuilder: (_) => const _AddProxiesView(),
      isValidOf: (ref, profileId, title) =>
          ref.watch(customOverwriteTargetIsValidProvider(profileId, title)),
      invalidMessageOf: (context, title) =>
          context.appLocalizations.invalidProxy(title),
      subtitleOf: (name) =>
          proxyTypeMap[name] ??
          (RuleTarget.baseTargets.contains(name) ? name.toLowerCase() : null),
    );
  }
}

class _AddProxiesView extends ConsumerWidget {
  const _AddProxiesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    return NameAddPicker(
      title: appLocalizations.addProxies,
      stageTagPrefix: 'AddProxiesViewState_handleRealAdd',
      scenes: const ['targets', 'groups', 'proxies'],
      apply: (state, staged) =>
          state.copyWith(proxies: [...state.proxies ?? [], ...staged]),
      sectionsBuilder: (context, ref) {
        final excluded = ref
            .watch(
              proxyGroupProvider.select(
                (state) => SelectValue(<String>{...?state.proxies, state.name}),
              ),
            )
            .value;
        final overwrite = ref.watch(customOverwriteDateProvider(profileId));
        return [
          NameAddSection(
            label: appLocalizations.basicStrategy,
            scene: 'targets',
            entries: [
              for (final target in RuleTarget.baseTargetNames)
                if (!excluded.contains(target))
                  NameAddEntry(title: target, subtitle: target.toLowerCase()),
            ],
          ),
          NameAddSection(
            label: appLocalizations.proxyGroup,
            scene: 'groups',
            entries: [
              for (final group in overwrite.proxyGroups)
                if (!excluded.contains(group.name))
                  NameAddEntry(title: group.name, subtitle: group.type.value),
            ],
          ),
          NameAddSection(
            label: appLocalizations.proxies,
            scene: 'proxies',
            entries: [
              for (final name in overwrite.proxyNames)
                if (!excluded.contains(name))
                  NameAddEntry(
                    title: name,
                    subtitle: overwrite.proxyTypes[name],
                  ),
            ],
          ),
        ];
      },
    );
  }
}
