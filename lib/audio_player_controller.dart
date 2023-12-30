import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:math';

import 'package:spartacus_project/network_request_manager.dart';
import 'package:spartacus_project/constants.dart';

class AudioPlayerController extends ChangeNotifier {
  final StreamController<double> _positionController =
      StreamController<double>.broadcast();

  Stream<double> get positionStream => _positionController.stream;

  final player = AudioPlayer();
  RequestManager requestManager = RequestManager(
    availableSongsUrl: '$url/audio/available_songs.json',
    availableAlbumsUrl: '$url/audio/available_albums.json',
  );
  bool isPlaying = false;
  double currentPosition = 0.0;
  double bufferedPosition = 0.0;
  double maxDuration = 1.0;
  String currentArtist = '';
  Color? dominantColor;
  Color? textColor;
  ImageProvider currentCover =
      const AssetImage('assets/images/default_cover.png');
  Map<String, dynamic> jsonAvailableSongs = {};
  Map<String, dynamic> jsonAvailableAlbums = {};
  String currentSong = '';
  bool jsonLoaded = false;

  int quality = 0;
  AudioPlayerController({
    required this.quality,
  });

  Future<void> init() async {
    await initJson();
    await initAudio();
  }

  Future<void> initJson() async {
    await requestManager.fillAvailableSongsAndAlbums();
    jsonLoaded = true;
    jsonAvailableSongs = requestManager.jsonAvailableSongs;
    jsonAvailableAlbums = requestManager.jsonAvailableAlbums;
    currentSong = jsonAvailableSongs.keys.toList()[0];
  }

  Future<void> initAudio() async {
    // Wait until json is loaded
    while (!jsonLoaded) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    currentArtist = jsonAvailableSongs[currentSong]['artist'].toString();

    currentCover =
        NetworkImage('$url/${jsonAvailableSongs[currentSong]['cover_path']}');

    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(currentCover);

    dominantColor = paletteGenerator.dominantColor?.color;

    if (dominantColor != null) {
      textColor =
          dominantColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    // ignore: prefer_interpolation_to_compose_strings
    await player.setUrl('$url/${jsonAvailableSongs[currentSong]['file_path']}' +
        qualityToExtension(quality));
    player.positionStream.listen((duration) {
      currentPosition = duration.inMilliseconds.toDouble();
      maxDuration = player.duration?.inMilliseconds.toDouble() ?? 0.0;
    });
    player.bufferedPositionStream.listen((duration) {
      bufferedPosition = min(duration.inMilliseconds.toDouble(), maxDuration);
    });
    maxDuration = player.duration?.inMilliseconds.toDouble() ?? 0.0;

    player.positionStream.listen((duration) {
      currentPosition = duration.inMilliseconds.toDouble();
      _positionController.add(currentPosition);
    });
  }

  Future<void> changeCurrentSong(String newSong) async {
    isPlaying = false;
    currentSong = newSong;
    await player.stop();
    await initAudio();
  }

  Future<void> changeQuality(int newQuality) async {
    player.stop();
    isPlaying = false;
    quality = newQuality;
    await saveQuality(newQuality);
    initAudio();
  }

  Future<void> changeCurrentPosition(double newPosition) async {
    await player.seek(Duration(milliseconds: newPosition.toInt()));
  }

  Future<void> playAudio() async {
    isPlaying = true;

    await player.play();
  }

  Future<void> pauseAudio() async {
    isPlaying = false;

    await player.pause();
  }
}
