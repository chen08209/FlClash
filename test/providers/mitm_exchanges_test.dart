import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

final _start = DateTime.utc(2026, 10, 29);

MitmExchangeList _list({required bool closed, required bool pending}) =>
    MitmExchangeList(
      capturing: true,
      closed: closed,
      exchanges: [
        MitmExchangeSummary(
          id: 1,
          start: _start,
          pending: pending,
          method: 'GET',
          url: 'https://a.test/',
        ),
      ],
    );

void main() {
  testWidgets('requests are fetched again until the connection settles', (
    tester,
  ) async {
    final answers = [
      _list(closed: false, pending: false),
      _list(closed: true, pending: true),
      _list(closed: true, pending: false),
    ];
    var calls = 0;
    final core = _MockCoreHandlerInterface();
    when(
      () => core.getMitmExchanges('connection-1'),
    ).thenAnswer((_) async => answers[(calls++).clamp(0, answers.length - 1)]);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(mitmExchangesProvider('connection-1'), (_, _) {});

    for (var second = 0; second < 12; second++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(calls, answers.length);
    expect(
      container.read(mitmExchangesProvider('connection-1')).value,
      answers.last,
    );
  });
}
