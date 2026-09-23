import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/name_add_picker.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/name_list_editor.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProxyProvidersView extends ConsumerWidget {
  const EditProxyProvidersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return NameListEditor(
      stageTag: 'EditProxyProvidersViewState_handleRealRemove',
      dragIconPadding: 16,
      labels: NameListEditorLabels(
        title: appLocalizations.editProxy,
        section: appLocalizations.proxyProviders,
        empty: appLocalizations.proxyProvidersEmpty,
        includeAll: appLocalizations.includeAllProxyProviders,
        includeAllTip: appLocalizations.includeAllProxyProvidersTip,
      ),
      lens: NameListEditorLens(
        namesOf: (state) => state.use ?? const [],
        withNames: (state, names) => state.copyWith(use: names),
        includeAllOf: (state) => state.includeAllProviders ?? false,
        withIncludeAll: (state, includeAll) =>
            state.copyWith(includeAllProviders: includeAll),
      ),
      addViewBuilder: (_) => const AddProxyProvidersView(),
      isValidOf: (ref, profileId, title) => ref.watch(
        customOverwriteProxyProviderIsValidProvider(profileId, title),
      ),
      invalidMessageOf: (context, title) =>
          context.appLocalizations.invalidProxyProvider(title),
    );
  }
}

class AddProxyProvidersView extends ConsumerWidget {
  const AddProxyProvidersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    return NameAddPicker(
      title: appLocalizations.addProxyProviders,
      stageTagPrefix: 'AddProxyProvidersViewState_handleRealAdd',
      apply: (state, staged) =>
          state.copyWith(use: [...state.use ?? [], ...staged]),
      sectionsBuilder: (context, ref) {
        final allProxyProviders = ref
            .watch(
              clashConfigProvider(profileId).select(
                (state) => SelectValue(state.value?.proxyProviders ?? []),
              ),
            )
            .value;
        final excluded = ref
            .watch(
              proxyGroupProvider.select(
                (state) => SelectValue([...?state.use]),
              ),
            )
            .value;
        final appProxyProviders = ref.watch(
          appProviderNamesProvider(ProviderKind.proxy),
        );
        return [
          NameAddSection(
            label: appLocalizations.proxyProviders,
            entries: [
              for (final name in allProxyProviders)
                if (!excluded.contains(name) &&
                    !appProxyProviders.contains(name))
                  NameAddEntry(title: name),
            ],
          ),
          NameAddSection(
            label: appLocalizations.appProxyProviders,
            entries: [
              for (final name in appProxyProviders)
                if (!excluded.contains(name)) NameAddEntry(title: name),
            ],
          ),
        ];
      },
    );
  }
}
