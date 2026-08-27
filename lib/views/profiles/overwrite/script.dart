import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
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
              InfoHeader(info: Info(label: appLocalizations.overrideScript)),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: scripts.length,
            itemBuilder: (_, index) {
              final script = scripts[index];
              return _ScriptOption(
                label: script.label,
                value: script.id,
                groupValue: scriptId,
                onSelected: () {
                  _handleChange(ref, profileId, script.id);
                },
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _ConfigureScriptsCard(
              label: appLocalizations.goToConfigureScript,
              onPressed: () {
                BaseNavigator.push(context, const ScriptsView());
              },
            ),
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
    required this.groupValue,
    required this.onSelected,
  });

  final String label;
  final int value;
  final int? groupValue;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CommonCard(
        type: CommonCardType.filled,
        radius: AppCorner.md,
        child: RadioGroup<int>(
          groupValue: groupValue,
          onChanged: (_) {
            onSelected();
          },
          child: ListTile(
            minLeadingWidth: 0,
            minTileHeight: 0,
            minVerticalPadding: 16,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: Row(
              children: [
                SizedBox(
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
                const SizedBox(width: 8),
                Flexible(child: Text(label)),
              ],
            ),
            onTap: onSelected,
          ),
        ),
      ),
    );
  }
}

class _ConfigureScriptsCard extends StatelessWidget {
  const _ConfigureScriptsCard({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      radius: AppCorner.md,
      onPressed: onPressed,
      child: ListTile(
        minTileHeight: 0,
        minVerticalPadding: 0,
        titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: context.textTheme.bodyLarge)),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
