import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'added_rules.dart';
import 'script.dart';

/// Long enough that a quick apply still reads as one, not as a flicker.
const _minApplyingDuration = Duration(milliseconds: 600);

class ExtendView extends ConsumerStatefulWidget {
  final int profileId;

  const ExtendView({super.key, required this.profileId});

  @override
  ConsumerState<ExtendView> createState() => _ExtendViewState();
}

class _ExtendViewState extends ConsumerState<ExtendView> {
  late SetupAction _setupAction;
  List<Object?>? _applied;
  var _unappliedOnOpen = false;
  var _applying = false;

  @override
  void initState() {
    super.initState();
    _setupAction = ref.read(setupActionProvider.notifier);
    ref.listenManual(clashConfigProvider(widget.profileId), (_, _) {});
    if (ref.read(currentProfileIdProvider) == widget.profileId) {
      unawaited(_checkUnappliedOnOpen());
    }
  }

  Future<void> _checkUnappliedOnOpen() async {
    final applied = await _setupAction.inputsApplied();
    if (!applied && mounted) {
      setState(() {
        _unappliedOnOpen = true;
      });
    }
  }

  List<Object?>? _watchInputs() {
    final profileId = widget.profileId;
    final profile = ref.watch(
      profileProvider(
        profileId,
      ).select((state) => (state?.scriptId, state?.exitTargets)),
    );
    final rules = ref.watch(profileRulesProvider(profileId)).value;
    final disabledRuleIds = ref
        .watch(profileDisabledRuleIdsProvider(profileId))
        .value;
    if (rules == null || disabledRuleIds == null) {
      return null;
    }
    return [profile, rules, disabledRuleIds];
  }

  Future<void> _handleApplyNow(List<Object?> inputs) async {
    final appLocalizations = context.appLocalizations;
    setState(() {
      _applying = true;
    });
    try {
      final (applied, _) = await (
        globalState.safeRun(_setupAction.applyProfile),
        Future<void>.delayed(_minApplyingDuration),
      ).wait;
      if (applied != true || !mounted) {
        return;
      }
      _applied = inputs;
      _unappliedOnOpen = false;
      dialogs.showBanner(appLocalizations.applied, level: BannerLevel.success);
    } finally {
      if (mounted) {
        setState(() {
          _applying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final inputs = _watchInputs();
    if (inputs != null) {
      _applied ??= inputs;
    }
    final isCurrent = ref.watch(currentProfileIdProvider) == widget.profileId;
    final hasChanges =
        isCurrent &&
        inputs != null &&
        (_unappliedOnOpen ||
            !const DeepCollectionEquality().equals(_applied, inputs));
    return ArrivalHold(
      ready: inputs != null,
      child: ProfileIdProvider(
        profileId: widget.profileId,
        child: Scaffold(
          title: appLocalizations.extend,
          isLoading: _applying,
          actions: [
            if (hasChanges || _applying)
              FilledButton(
                onPressed: _applying || inputs == null
                    ? null
                    : () => _handleApplyNow(inputs),
                child: Text(appLocalizations.applyNow),
              ),
          ],
          body: ScrollConfiguration(
            behavior: const ShowBarScrollBehavior(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: context.sectionsTopPadding),
                ),
                const ScriptContent(),
                const AddedRulesContent(),
                SliverToBoxAdapter(
                  child: SizedBox(height: context.bottomInset),
                ),
              ],
            ),
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
