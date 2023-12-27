import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spartacus_project/constants.dart';
import 'package:spartacus_project/current_song_card.dart';
import 'package:spartacus_project/network_request_manager.dart';
import 'package:spartacus_project/current_song_page.dart';
import 'package:spartacus_project/settings_page.dart';

Future<void> saveQuality(int quality) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('quality', quality);
}

Future<int> loadQuality() async {
  final prefs = await SharedPreferences.getInstance();
  final quality = prefs.getInt('quality');
  return quality ?? 0;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var quality = await loadQuality();
  runApp(MyApp(quality: quality));
}

class MyApp extends StatelessWidget {
  final int quality;
  const MyApp({super.key, required this.quality});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spartacus Project',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'LKP Streaming', quality: quality),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.quality});

  final String title;
  final int quality;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 1;
  int quality = 0;
  final player = AudioPlayer();
  bool isPlaying = false;
  double currentPosition = 0.0;
  double bufferedPosition = 0.0;
  double maxDuration = 1.0;
  String currentSong = '';
  String currentArtist = '';
  Map<String, dynamic> jsonAvailableSongs = {};
  Map<String, dynamic> jsonAvailableAlbums = {};
  String urlCurrentSong = '';
  String urlCurrentCover = '';
  Color? dominantColor;
  Color? textColor;

  // Fill availableSongs and availableAlbums
  Future<void> fillAvailableSongsAndAlbums() async {
    var requestManager = RequestManager(
      availableSongsUrl: availableSongsUrl,
      availableAlbumsUrl: availableAlbumsUrl,
    );
    jsonAvailableSongs = await requestManager.getRequestSongs();
    jsonAvailableAlbums = await requestManager.getRequestAlbums();
  }

  Future<void> changeQuality(int newQuality) async {
    player.stop();
    setState(() {
      isPlaying = false;
      quality = newQuality;
    });
    await saveQuality(newQuality);
    initAudio();
  }

  Future<void> changeCurrentIndex(int newIndex) async {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  Future<void> changeCurrentSong(String newSong) async {
    setState(() {
      isPlaying = false;
      currentSong = newSong;
    });
    await player.stop();
    await initAudio();
  }

  Future<void> changeCurrentPosition(double newPosition) async {
    await player.seek(Duration(milliseconds: newPosition.toInt()));
  }

  @override
  void initState() {
    super.initState();
    initAsyncState();
  }

  Future<void> initAsyncState() async {
    await fillAvailableSongsAndAlbums();
    currentSong = jsonAvailableSongs.keys.toList()[0];
    quality = widget.quality;
    initAudio();
  }

  Future<void> initAudio() async {
    currentArtist = jsonAvailableSongs[currentSong]['artist'].toString();

    urlCurrentCover = '$url/${jsonAvailableSongs[currentSong]['cover_path']}';
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(urlCurrentCover),
    );

    dominantColor = paletteGenerator.dominantColor?.color;

    if (dominantColor != null) {
      textColor =
          dominantColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    String currentUrl = '$url/${jsonAvailableSongs[currentSong]['file_path']}' +
        qualityToExtension(quality);
    dynamic file;
    try {
      file = await DefaultCacheManager().getSingleFile(currentUrl);
    } catch (e) {
      print(e);
    }
    if (file != null) {
      await player.setFilePath(file.path);
      player.positionStream.listen((duration) {
        setState(() {
          currentPosition = duration.inMilliseconds.toDouble();
          maxDuration = player.duration?.inMilliseconds.toDouble() ?? 0.0;
        });
      });
      player.bufferedPositionStream.listen((duration) {
        setState(() {
          bufferedPosition =
              min(duration.inMilliseconds.toDouble(), maxDuration);
        });
      });
      maxDuration = player.duration?.inMilliseconds.toDouble() ?? 0.0;
    } else {
      print('File is null');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> playAudio() async {
    setState(() {
      isPlaying = true;
    });
    await player.play();
  }

  Future<void> pauseAudio() async {
    setState(() {
      isPlaying = false;
    });
    await player.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => changeCurrentIndex(3),
            icon: const Icon(Icons.music_note),
          ),
          IconButton(
              onPressed: () => changeCurrentIndex(4),
              icon: const Icon(Icons.settings))
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentSong != '' && _currentIndex != 3)
            CurrentSongCard(
              currentSong: currentSong,
              currentArtist: currentArtist,
              isPlaying: isPlaying,
              pauseAudio: pauseAudio,
              playAudio: playAudio,
              currentPosition: currentPosition,
              maxDuration: maxDuration,
              dominantColor: dominantColor,
              urlCurrentSong: urlCurrentSong,
              urlCurrentCover: urlCurrentCover,
              changeCurrentIndex: changeCurrentIndex,
              textColor: textColor,
            ),

          // Bottom bar
          SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              /// Search
              SalomonBottomBarItem(
                icon: const Icon(Icons.search),
                title: const Text("Search"),
                selectedColor: Colors.pinkAccent,
              ),

              /// Home
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text("Home"),
                selectedColor: Colors.purpleAccent,
              ),

              /// Profile
              SalomonBottomBarItem(
                icon: const Icon(Icons.favorite),
                title: const Text("Favorites"),
                selectedColor: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
      body: () {
        switch (_currentIndex) {
          case 0:
            return const Center(
              child: Text('Search'),
            );
          case 1:
            return const Center(
              child: Text('Home'),
            );
          case 2:
            return const Center(
              child: Text('Favorites'),
            );
          case 3:
            return CurrentSongPage(
              currentSong: currentSong,
              jsonAvailableSongs: jsonAvailableSongs,
              playAudio: playAudio,
              pauseAudio: pauseAudio,
              initAudio: initAudio,
              player: player,
              currentPosition: currentPosition,
              bufferedPosition: bufferedPosition,
              maxDuration: maxDuration,
              changeCurrentSong: changeCurrentSong,
              changeCurrentPosition: changeCurrentPosition,
              isPlaying: isPlaying,
              urlCurrentCover: urlCurrentCover,
            );
          case 4:
            return SettingsPage(
              quality: quality,
              changeQuality: changeQuality,
            );
          default:
            return const Center(
              child: Text('Error'),
            );
        }
      }(),
    );
  }
}
