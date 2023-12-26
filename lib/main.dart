import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:spartacus_project/constants.dart';
import 'package:spartacus_project/songcard.dart';
import 'package:spartacus_project/requestmanager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
      home: const MyHomePage(title: 'Spartacus Project Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 1;
  var quality = 0;
  final player = AudioPlayer();
  bool isPlaying = false;
  double currentPosition = 0.0;
  double bufferedPosition = 0.0;
  double maxDuration = 1.0;
  String currentSong = '';
  String currentArtist = '';
  var jsonAvailableSongs;
  var jsonAvailableAlbums;
  String urlCurrentSong = '';
  String urlCurrentCover = '';
  Color? dominantColor;

  // Fill availableSongs and availableAlbums
  Future<void> fillAvailableSongsAndAlbums() async {
    var requestManager = RequestManager(
      availableSongsUrl: availableSongsUrl,
      availableAlbumsUrl: availableAlbumsUrl,
    );
    jsonAvailableSongs = await requestManager.getRequestSongs();
    jsonAvailableAlbums = await requestManager.getRequestAlbums();
  }

  @override
  void initState() {
    super.initState();
    initAsyncState();
  }

  Future<void> initAsyncState() async {
    await fillAvailableSongsAndAlbums();
    currentSong = jsonAvailableSongs.keys.toList()[0];
    initAudio();
  }

  Future<void> initAudio() async {
    currentArtist = jsonAvailableSongs[currentSong]['artist'].toString();

    urlCurrentCover =
        url + '/' + jsonAvailableSongs[currentSong]['cover_path'].toString();
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(urlCurrentCover),
    );

    dominantColor = paletteGenerator.dominantColor?.color;

    String currentUrl = url +
        '/' +
        jsonAvailableSongs[currentSong]['file_path'].toString() +
        qualityToExtension(quality);
    print(currentUrl);
    var file;
    try {
      file = await DefaultCacheManager().getSingleFile(currentUrl);
    } catch (e) {
      print('Le fichier $currentSong n\'a pas pu être téléchargé');
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
      print('Le fichier $currentSong est vide');
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
        title: Text(widget.title),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentSong != '' && _currentIndex != 1)
            SongCard(
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                value: currentSong,
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != currentSong) {
                    setState(() {
                      isPlaying = false;
                      currentSong = newValue;
                    });
                    player.stop();
                    initAudio();
                  }
                },
                items: jsonAvailableSongs != null
                    ? jsonAvailableSongs.keys
                        .toList()
                        .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()
                    : [],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Image(
                  image: (urlCurrentCover).isNotEmpty
                      ? Image.network(urlCurrentCover).image
                      : const AssetImage('assets/images/default_cover.png'),
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: ProgressBar(
                        progress:
                            Duration(milliseconds: currentPosition.toInt()),
                        buffered:
                            Duration(milliseconds: bufferedPosition.toInt()),
                        total: Duration(milliseconds: maxDuration.toInt()),
                        onSeek: (duration) {
                          player.seek(duration);
                          setState(() {
                            currentPosition =
                                duration.inMilliseconds.toDouble();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (isPlaying) {
                    pauseAudio();
                  } else {
                    playAudio();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
