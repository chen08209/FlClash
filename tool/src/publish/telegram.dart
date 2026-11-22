import 'dart:convert';
import 'dart:io';

const telegramChannel = '@FlClash';

Uri releasePageUri(String repository, String tag) {
  return Uri.https('github.com', '/$repository/releases/tag/$tag');
}

Map<String, Object> telegramReleaseMessage(String repository, String tag) {
  return {
    'chat_id': telegramChannel,
    'text': 'FlClash $tag\n${releasePageUri(repository, tag)}',
  };
}

/// Null once Telegram took the post, else why not, with [token] taken out:
/// an HttpException names the URL, which carries it.
Future<String?> postToTelegram(
  Map<String, Object> message,
  String token, {
  Uri? api,
  Duration timeout = const Duration(seconds: 30),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final (status, body) = await () async {
      final request = await client.postUrl(
        (api ?? Uri.https('api.telegram.org')).replace(
          path: '/bot$token/sendMessage',
        ),
      );
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(message));
      final response = await request.close();
      return (
        response.statusCode,
        await response.transform(utf8.decoder).join(),
      );
    }().timeout(timeout);
    final ok = switch (jsonDecode(body)) {
      {'ok': true} => true,
      _ => false,
    };
    if (status != HttpStatus.ok || !ok) {
      return 'Telegram rejected the release post: $body';
    }
    return null;
  } on FormatException catch (error) {
    return 'Telegram answered with no JSON: $error';
  } on Exception catch (error) {
    return 'Telegram could not be reached: '
        '${'$error'.replaceAll(token, '<token>')}';
  } finally {
    client.close(force: true);
  }
}
