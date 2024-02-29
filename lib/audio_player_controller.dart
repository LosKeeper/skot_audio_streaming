// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:skot/network_request_manager.dart';
import 'package:skot/constants.dart';
import 'package:skot/url.dart';

class AudioPlayerController extends BaseAudioHandler {
  final StreamController<double> _positionController =
      StreamController<double>.broadcast();

  Stream<double> get positionStream => _positionController.stream;
  StreamController<bool> jsonLoadedController =
      StreamController<bool>.broadcast();

  final StreamController<String> _currentSongController =
      StreamController<String>.broadcast();
  Stream<String> get currentSongStream => _currentSongController.stream;

  final player = AudioPlayer();
  RequestManager requestManager = RequestManager(
      availableSongsUrl: '$url/audio/available_songs.json',
      availableAlbumsUrl: '$url/audio/available_albums.json',
      messagesUrl: '$url/audio/messages.json',
      selectionUrl: '$url/audio/selection.json');
  MediaItem _mediaItem = const MediaItem(
    id: 'default',
    title: 'default',
    album: 'default',
    artUri: null,
  );
  double currentPosition = 0.0;
  double bufferedPosition = 0.0;
  double maxDuration = 1.0;
  String currentArtist = '';
  Color? dominantColor;
  Color? textColor;
  ImageProvider currentCover =
      const AssetImage('assets/images/default_cover.png');
  String currentSong = '';
  bool jsonLoaded = false;

  List<String> previousSongs = [];
  List<String> nextSongs = [];
  bool changedSong = false;

  int quality = 0;

  bool random = false;

  bool liveSelected = false;
  bool livePlaying = false;

  AudioPlayerController({required this.quality}) {
    player.positionStream.listen((duration) {
      currentPosition = duration.inMilliseconds.toDouble();
      maxDuration = player.duration?.inMilliseconds.toDouble() ?? 0.0;

      if (player.playing &&
          currentPosition >= maxDuration &&
          maxDuration > 0 &&
          !changedSong) {
        if (nextSongs.isNotEmpty) {
          changeCurrentSong(nextSongs[0]);
          nextSongs.removeAt(0);
          changedSong = true;
        } else {
          var nextSong = getNextSong(currentSong);
          changeCurrentSong(nextSong);
          changedSong = true;
        }
      }
    });
  }

  String getNextSong(String currentSong) {
    if (random) {
      return requestManager.jsonAvailableSongs.keys
          .toList()[Random().nextInt(requestManager.jsonAvailableSongs.length)];
    }

    var currentSongDetails = requestManager.jsonAvailableSongs[currentSong];
    if (currentSongDetails == null) {
      return requestManager.jsonAvailableSongs.keys
          .toList()[Random().nextInt(requestManager.jsonAvailableSongs.length)];
    }

    var lastAlbum = currentSongDetails['album'];
    var albumDetails = requestManager.jsonAvailableAlbums[lastAlbum];
    if (albumDetails == null) {
      return requestManager.jsonAvailableSongs.keys
          .toList()[Random().nextInt(requestManager.jsonAvailableSongs.length)];
    }

    var songList = albumDetails['songs'];
    var track =
        songList.indexWhere((curSong) => curSong.keys.first == currentSong) + 1;

    if (track >= 0 && track < songList.length) {
      return songList[track].keys.first;
    } else {
      // Return the first song of the next album
      var albumList = requestManager.jsonAvailableAlbums.keys.toList();
      var albumIndex = albumList.indexOf(lastAlbum);
      if (albumIndex >= 0 && albumIndex < albumList.length - 1) {
        var nextAlbum = albumList[albumIndex + 1];
        var nextAlbumDetails = requestManager.jsonAvailableAlbums[nextAlbum];
        if (nextAlbumDetails != null) {
          var nextSongList = nextAlbumDetails['songs'];
          if (nextSongList.isNotEmpty) {
            return nextSongList[0].keys.first;
          }
        }
      } else {
        // Return the first song of the first album
        var firstAlbum = albumList[0];
        var firstAlbumDetails = requestManager.jsonAvailableAlbums[firstAlbum];
        if (firstAlbumDetails != null) {
          var firstSongList = firstAlbumDetails['songs'];
          if (firstSongList.isNotEmpty) {
            return firstSongList[0].keys.first;
          }
        }
      }
    }
    return requestManager.jsonAvailableSongs.keys
        .toList()[Random().nextInt(requestManager.jsonAvailableSongs.length)];
  }

  void changeRandom() {
    random = !random;
  }

  bool getRandom() {
    return random;
  }

  Future<void> init() async {
    await initJson();
    await player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    await initAudio();
  }

  Future<void> initJson() async {
    await requestManager.fillAvailableSongsAndAlbums();
    jsonLoaded = true;
    jsonLoadedController.add(true);
  }

  // ignore: duplicate_ignore
  Future<void> initAudio() async {
    // Wait until json is loaded
    while (!jsonLoaded) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!liveSelected) {
      // Wait until current song is set
      if (currentSong == '') {
        return;
      }
      livePlaying = false;
      currentArtist =
          requestManager.jsonAvailableSongs[currentSong]['artist'].toString();

      currentCover = CachedNetworkImageProvider(
          '$url/${requestManager.jsonAvailableSongs[currentSong]['cover_path']}');

      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(currentCover);

      dominantColor = paletteGenerator.dominantColor?.color;

      if (dominantColor != null) {
        textColor = dominantColor!.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white;
      }

      await player.setUrl(
          '$url/${requestManager.jsonAvailableSongs[currentSong]['file_path']}' +
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

      _mediaItem = MediaItem(
        id: currentSong,
        title: currentSong,
        album: currentArtist,
        artUri: Uri.parse(
            '$url/${requestManager.jsonAvailableSongs[currentSong]['cover_path']}'),
        duration: Duration(milliseconds: maxDuration.toInt()),
      );

      if (previousSongs.isEmpty) {
        previousSongs.add(currentSong);
      } else if (previousSongs.last != currentSong) {
        previousSongs.add(currentSong);
      }

      if (changedSong) {
        changedSong = false;
        play();
      }

      super.mediaItem.add(_mediaItem);

      _currentSongController.add(currentSong);
    } else if (await requestManager.isOnLive()) {
      currentArtist = 'SKOT';
      currentSong = 'SKOT Live';
      currentCover = const AssetImage('assets/images/skot.png');

      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(currentCover);
      dominantColor = paletteGenerator.dominantColor?.color;

      await player.setUrl(liveUrl);

      // Unkown duration for live
      maxDuration = 0.0;

      player.positionStream.listen((duration) {
        currentPosition = duration.inMilliseconds.toDouble();
        _positionController.add(currentPosition);
      });

      _mediaItem = MediaItem(
        id: 'live',
        title: currentSong,
        album: currentArtist,
        artUri: Uri.parse('$url/audio/skot.png'),
      );

      super.mediaItem.add(_mediaItem);

      _currentSongController.add('live');

      livePlaying = true;

      await play();
    } else {
      liveSelected = false;
      livePlaying = false;

      showSimpleNotification(
        const Text(
          'Not on live yet, please try again later or select an another song.',
          style: TextStyle(color: Colors.white),
        ),
        background: Colors.red,
      );
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (event.processingState == ProcessingState.ready) ...[
          MediaControl.pause,
        ] else ...[
          MediaControl.play,
        ],
        MediaControl.skipToNext
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[event.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
    );
  }

  bool getLivePlaying() {
    return livePlaying;
  }

  Future<void> setLiveSelected() async {
    await player.stop();
    liveSelected = true;
    await initAudio();
  }

  Future<void> changeCurrentSong(String newSong) async {
    liveSelected = false;
    currentSong = newSong;
    player.stop();
    initAudio();
    // Wait until audio is loaded for windows
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> addNextSong(String newSong) async {
    nextSongs.add(newSong);
  }

  Future<void> addAllToPlaylist(List<String> songs) async {
    nextSongs.addAll(songs);
  }

  Future<void> changeQuality(int newQuality) async {
    player.stop();
    quality = newQuality;
    await saveQuality(newQuality);
    initAudio();
  }

  Future<void> changeCurrentPosition(double newPosition) async {
    await player.seek(Duration(milliseconds: newPosition.toInt()));
  }

  @override
  Future<void> play() async {
    await player.play();
    await super.play();
  }

  @override
  Future<void> pause() async {
    await player.pause();
    await super.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await changeCurrentPosition(position.inMilliseconds.toDouble());
    await super.seek(position);
  }

  @override
  Future<void> stop() async {
    currentPosition = 0.0;
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (livePlaying) {
      return;
    }
    if (nextSongs.isNotEmpty) {
      await changeCurrentSong(nextSongs[0]);
      nextSongs.removeAt(0);
    } else {
      await changeCurrentSong(getNextSong(currentSong));
    }
    await Future.delayed(const Duration(milliseconds: 10));
    await play();
    await super.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (livePlaying) {
      return;
    }
    if (previousSongs.length > 1) {
      nextSongs.insert(0, previousSongs.last);
      previousSongs.removeLast();
      await changeCurrentSong(previousSongs[previousSongs.length - 1]);
    } else {
      await changeCurrentSong(currentSong);
    }
    await Future.delayed(const Duration(milliseconds: 10));
    await play();
    await super.skipToPrevious();
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    if (button == MediaButton.media) {
      if (player.playing) {
        await pause();
      } else {
        await play();
      }
    }
    await super.click(button);
  }
}
