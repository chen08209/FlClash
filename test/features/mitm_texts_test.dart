import 'package:fl_clash/features/connection/mitm_texts.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  MitmExchangeSummary exchange({
    List<String> actionKinds = const [],
    String answer = '',
  }) => MitmExchangeSummary(
    id: 1,
    start: DateTime.utc(2026, 11, 22),
    actionKinds: actionKinds,
    answer: answer,
  );

  test('a row is marked by what answered in place of the server, else by its '
      'first action, with how many other kinds acted', () {
    expect(exchangeMark(l10n, exchange()), isNull);
    expect(
      exchangeMark(l10n, exchange(actionKinds: ['header-rewrite'])),
      l10n.headerRewrite,
    );
    expect(
      exchangeMark(
        l10n,
        exchange(actionKinds: ['header-rewrite', 'script', 'body-rewrite']),
      ),
      '${l10n.headerRewrite} +2',
    );
    expect(
      exchangeMark(l10n, exchange(answer: 'reject')),
      l10n.httpAnswerReject,
    );
    expect(
      exchangeMark(
        l10n,
        exchange(actionKinds: ['url-rewrite'], answer: 'reject'),
      ),
      l10n.httpAnswerReject,
    );
    expect(
      exchangeMark(
        l10n,
        exchange(
          actionKinds: ['header-rewrite', 'map-local'],
          answer: 'map-local',
        ),
      ),
      '${l10n.mapLocal} +1',
    );
    expect(
      exchangeMark(l10n, exchange(actionKinds: ['script'], answer: 'script')),
      l10n.httpAnswerScript,
    );
  });

  test('a header rewrite puts its line keyword in words; other details stay '
      'as the Core wrote them', () {
    String detail(String kind, String text) =>
        mitmActionDetail(l10n, MitmAction(kind: kind, detail: text));

    expect(
      detail('header-rewrite', 'header-del X-Forwarded-For'),
      '${l10n.delete} X-Forwarded-For',
    );
    expect(
      detail('header-rewrite', 'header-add X-Added yes'),
      '${l10n.add} X-Added yes',
    );
    expect(
      detail('header-rewrite', 'header-replace-regex X-A ^a b'),
      '${l10n.regexReplace} X-A ^a b',
    );
    expect(detail('body-rewrite', 'jq .a'), 'jq .a');
    expect(detail('url-rewrite', 'header'), 'header');
  });

  test('a status reads with its reason phrase when the Core gives one', () {
    expect(httpStatusText(200, 'OK'), '200 OK');
    expect(httpStatusText(599, ''), '599');
  });
}
