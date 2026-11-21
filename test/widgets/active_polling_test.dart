import 'package:fl_clash/widgets/active_polling.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _Poller extends StatefulWidget {
  final List<SchedulerPhase> phases;

  const _Poller(this.phases);

  @override
  State<_Poller> createState() => _PollerState();
}

class _PollerState extends State<_Poller>
    with WidgetsBindingObserver, ActivePollingMixin<_Poller> {
  @override
  Duration get pollInterval => const Duration(hours: 1);

  @override
  Future<void> poll(PollGuard isCurrent) async {
    widget.phases.add(SchedulerBinding.instance.schedulerPhase);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  testWidgets('a page made active again polls after the frame, not inside '
      'the build that made it so', (tester) async {
    final phases = <SchedulerPhase>[];
    Widget page({required bool active}) => Directionality(
      textDirection: TextDirection.ltr,
      child: TickerMode(enabled: active, child: _Poller(phases)),
    );

    await tester.pumpWidget(page(active: true));
    await tester.pump();
    expect(phases, hasLength(1));

    await tester.pumpWidget(page(active: false));
    await tester.pumpWidget(page(active: true));
    expect(phases, hasLength(2));
    expect(phases.last, isNot(SchedulerPhase.persistentCallbacks));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
