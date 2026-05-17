import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundProvider = Provider((ref) => SoundService());

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSuccess() async {
    await _player.play(AssetSource('audio/succes.mp3'));
  }

  Future<void> playError() async {
    await _player.play(AssetSource('audio/error.mp3'));
  }

  void dispose() {
    _player.dispose();
  }
}
