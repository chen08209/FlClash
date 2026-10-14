import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'script.dart';
import 'standard.dart';

class ExtendView extends ConsumerStatefulWidget {
  final int profileId;

  const ExtendView({super.key, required this.profileId});

  @override
  ConsumerState<ExtendView> createState() => _ExtendViewState();
}

class _ExtendViewState extends ConsumerState<ExtendView> {
  late SetupAction _setupAction;

  @override
  void initState() {
    super.initState();
    _setupAction = ref.read(setupActionProvider.notifier);
    ref.listenManual(clashConfigProvider(widget.profileId), (_, _) {});
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ProfileIdProvider(
      profileId: widget.profileId,
      child: CommonScaffold(
        title: appLocalizations.extend,
        body: ScrollConfiguration(
          behavior: const ShowBarScrollBehavior(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: context.appBarInset)),
              const _Title(),
              const _Content(),
            ],
          ),
        ),
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

  String _getTitle(BuildContext context, ExtendType type) {
    return switch (type) {
      ExtendType.standard => context.appLocalizations.standard,
      ExtendType.script => context.appLocalizations.script,
    };
  }

  Glyph _getIcon(ExtendType type) {
    return switch (type) {
      ExtendType.standard => AppGlyphs.star,
      ExtendType.script => AppGlyphs.code,
    };
  }

  String _getDesc(BuildContext context, ExtendType type) {
    return switch (type) {
      ExtendType.standard => context.appLocalizations.standardModeDesc,
      ExtendType.script => context.appLocalizations.scriptModeDesc,
    };
  }

  void _handleChangeType(WidgetRef ref, int profileId, ExtendType type) {
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      return state.copyWith(extendType: type);
    });
  }

  @override
  Widget build(context, ref) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final extendType = ref.watch(extendTypeProvider(profileId));
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(info: Info(label: appLocalizations.extendMode)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 16,
              children: [
                for (final type in ExtendType.values)
                  CommonCard(
                    isSelected: extendType == type,
                    onPressed: () {
                      _handleChangeType(ref, profileId, type);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GlyphIcon(_getIcon(type)),
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
              _getDesc(context, extendType),
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
    final extendType = ref.watch(extendTypeProvider(profileId));
    return switch (extendType) {
      ExtendType.standard => const StandardContent(),
      ExtendType.script => const ScriptContent(),
    };
  }
}
