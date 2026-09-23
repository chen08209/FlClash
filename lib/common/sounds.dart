import 'package:audioplayers/audioplayers.dart';

class Sounds {
  static final _player = AudioPlayer();

  static Future<void> playNotify() async {
    await _player.play(
      AssetSource('sounds/notify.wav'),
      volume: 1.0,
    );
  }
}