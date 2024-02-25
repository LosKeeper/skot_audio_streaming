import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:skot/audio_player_controller.dart';

void main() {
  group('AudioPlayerController', () {
    AudioPlayerController? controller;

    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      controller = AudioPlayerController(quality: 1);
    });

    test('initial state', () {
      expect(controller!.quality, 1);
      expect(controller!.player.playing, false);
    });

    tearDown(() {
      controller!.player.dispose();
    });
  });
}
