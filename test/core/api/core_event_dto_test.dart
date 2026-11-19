import 'package:fl_clash/core/api/dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a script notification reads its url and joins what it has', () {
    final event = CoreEventDto.fromJson({
      'type': 'scriptNotification',
      'script': 'notes',
      'title': 'Signed in',
      'body': '3 days in a row',
      'url': 'https://a.test/',
    });
    expect(event, isA<ScriptNotificationEvent>());
    final notice = event as ScriptNotificationEvent;
    expect(notice.script, 'notes');
    expect(notice.url, 'https://a.test/');
    expect(notice.text, 'Signed in\n3 days in a row');
  });

  test('a script notification without a url or subtitle still reads', () {
    final notice =
        CoreEventDto.fromJson({
              'type': 'scriptNotification',
              'script': 'notes',
              'title': 'Done',
            })
            as ScriptNotificationEvent;
    expect((notice.url, notice.text), ('', 'Done'));
  });
}
