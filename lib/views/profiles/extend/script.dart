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
              InfoHeader(info: Info(label: appLocalizations.extendScript)),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: generateSection(
              items: [
                for (final script in scripts)
                  _ScriptOption(
                    label: script.label,
                    isSelected: script.id == scriptId,
                    onSelected: () {
                      _handleChange(ref, profileId, script.id);
                    },
                  ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: MoreActionButton(
            label: appLocalizations.goToConfigureScript,
            onPressed: () {
              showInSheet<void>(context, builder: (_) => const ScriptsView());
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
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      isSelected: isSelected,
      title: Text(label),
      trailing: isSelected ? const SelectionCheck() : null,
      onPressed: onSelected,
    );
  }
}
