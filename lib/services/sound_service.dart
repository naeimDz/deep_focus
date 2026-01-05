import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentSound;
  bool _isPlaying = false;

  final Map<String, String> sounds = {
    'None': '',
    'Rain': 'sounds/Rain.mp3', // Note capital R
    'White Noise': 'sounds/white.mp3',
    'Forest': 'sounds/forest.mp3',
  };

  String? get currentSound => _currentSound;
  bool get isPlaying => _isPlaying;

  Future<void> playSound(String name) async {
    if (name == 'None' || !sounds.containsKey(name)) {
      await stop();
      return;
    }

    final path = sounds[name]!;
    if (path.isEmpty) return;

    try {
      // In a real app we would play the asset.
      // For MVP without assets, we just log.
      // await _audioPlayer.play(AssetSource(path));
      // await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      debugPrint("Playing sound: $name ($path)");

      _currentSound = name;
      _isPlaying = true;
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSound = null;
    _isPlaying = false;
    debugPrint("Sound stopped");
  }
}
