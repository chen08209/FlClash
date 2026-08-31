import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScriptContent extends ConsumerWidget {
  const ScriptContent({super.key});

  void _handleChange(WidgetRef ref, int profileId, int scriptId) {
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      return state.copyWith(
        scriptId: state.scriptId == scriptId ? null : scriptId,
      );
    });
  }

  void _handleRadioChange(WidgetRef ref, int profileId, int? scriptId) {
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
    final scripts = ref.watch(scriptsProvider).value ?? [];
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Column(
            children: [
              InfoHeader(info: Info(label: appLocalizations.overrideScript)),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RadioGroup<int>(
              groupValue: scriptId,
              onChanged: (value) {
                _handleRadioChange(ref, profileId, value);
              },
              child: generateSectionV3(
                items: [
                  for (final script in scripts)
                    _ScriptOption(
                      label: script.label,
                      value: script.id,
                      isSelected: script.id == scriptId,
                      onSelected: () {
                        _handleChange(ref, profileId, script.id);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MoreActionButton(
            label: appLocalizations.goToConfigureScript,
            onPressed: () {
              BaseNavigator.push(context, const ScriptsView());
            },
          ),
        ),
      ],
    );
  }
}

class _ScriptOption extends StatelessWidget {
  const _ScriptOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      isSelected: isSelected,
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: SizedBox(
        width: 24,
        height: 24,
        child: ExcludeFocus(
          child: Radio<int>(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            toggleable: true,
            value: value,
          ),
        ),
      ),
      title: Text(label),
      onPressed: onSelected,
    );
  }
}
