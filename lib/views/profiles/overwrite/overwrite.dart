import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/preview.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'custom/custom.dart';
import 'script.dart';
import 'standard.dart';

class OverwriteView extends ConsumerStatefulWidget {
  final int profileId;

  const OverwriteView({super.key, required this.profileId});

  @override
  ConsumerState<OverwriteView> createState() => _OverwriteViewState();
}

class _OverwriteViewState extends ConsumerState<OverwriteView> {
  late SetupAction _setupAction;

  @override
  void initState() {
    super.initState();
    _setupAction = ref.read(setupActionProvider.notifier);
    ref.listenManual(clashConfigProvider(widget.profileId), (_, _) {});
  }

  Future<void> _handlePreview() async {
    final profile = ref.read(profileProvider(widget.profileId));
    if (profile == null) {
      return;
    }
    unawaited(
      BaseNavigator.push<String>(context, PreviewProfileView(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ProfileIdProvider(
      profileId: widget.profileId,
      child: CommonScaffold(
        title: appLocalizations.override,
        actions: [
          CommonMinFilledButtonTheme(
            child: FilledButton(
              onPressed: _handlePreview,
              child: Text(appLocalizations.preview),
            ),
          ),
          const SizedBox(width: 8),
        ],
        body: const CustomScrollView(slivers: [_Title(), _Content()]),
      ),
    );
  }

  @override
  void dispose() {
    _setupAction.autoApplyProfile();
    super.dispose();
  }
}

class _Title extends ConsumerWidget {
  const _Title();

  String _getTitle(BuildContext context, OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => context.appLocalizations.standard,
      OverwriteType.script => context.appLocalizations.script,
      OverwriteType.custom => context.appLocalizations.overwriteTypeCustom,
    };
  }

  IconData _getIcon(OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => Icons.stars,
      OverwriteType.script => Icons.rocket,
      OverwriteType.custom => Icons.dashboard_customize,
    };
  }

  String _getDesc(BuildContext context, OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => context.appLocalizations.standardModeDesc,
      OverwriteType.script => context.appLocalizations.scriptModeDesc,
      OverwriteType.custom => context.appLocalizations.overwriteTypeCustomDesc,
    };
  }

  void _handleChangeType(WidgetRef ref, int profileId, OverwriteType type) {
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      return state.copyWith(overwriteType: type);
    });
  }

  @override
  Widget build(context, ref) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final overwriteType = ref.watch(overwriteTypeProvider(profileId));
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(info: Info(label: appLocalizations.overrideMode)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 16,
              children: [
                for (final type in OverwriteType.values)
                  CommonCard(
                    isSelected: overwriteType == type,
                    onPressed: () {
                      _handleChangeType(ref, profileId, type);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(_getIcon(type)),
                          const SizedBox(width: 8),
                          Flexible(child: Text(_getTitle(context, type))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _getDesc(context, overwriteType),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant.opacity80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content();

  @override
  Widget build(BuildContext context, ref) {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final overwriteType = ref.watch(overwriteTypeProvider(profileId));
    return switch (overwriteType) {
      OverwriteType.standard => const StandardContent(),
      OverwriteType.script => const ScriptContent(),
      OverwriteType.custom => const CustomContent(),
    };
  }
}
