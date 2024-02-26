import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:skot/audio_player_controller.dart';

void main() {
  group('AudioPlayerController', () {
    AudioPlayerController? controller;

    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      controller = AudioPlayerController(quality: 0);
      controller!.init();
    });

    test('initial state', () {
      expect(controller!.quality, 0);
      expect(controller!.player.playing, false);
    });

    test('Change song and play', () async {
      controller!.changeCurrentSong('Shift');
      controller!.play();
      expect(controller!.player.playing, true);
    });

    test('Change song and pause', () async {
      controller!.changeCurrentSong('Shift');
      controller!.play();
      controller!.pause();
      expect(controller!.player.playing, false);
    });

    test('Change song and stop', () async {
      controller!.changeCurrentSong('Shift');
      controller!.play();
      controller!.stop();
      expect(controller!.player.playing, false);
    });

    test('Change song and seek', () async {
      controller!.changeCurrentSong('Shift');
      controller!.play();
      controller!.seek(const Duration(seconds: 10));
      expect(controller!.player.position, const Duration(seconds: 10));
    });

    test('Playlist add song', () async {
      controller!.changeCurrentSong('Shift');
      controller!.play();
      controller!.addNextSong('Interlude');
      controller!.skipToNext();
      expect(controller!.currentSong, 'Interlude');
    });

    test('Playlist previous song', () async {
      controller!.changeCurrentSong('Shift');
      controller!.play();
      controller!.addNextSong('Interlude');
      controller!.skipToPrevious();
      expect(controller!.currentSong, 'Shift');
      expect(controller!.nextSongs, ['Interlude']);
      expect(controller!.previousSongs, []);
    });

    tearDown(() {
      controller!.player.dispose();
    });
  });
}
