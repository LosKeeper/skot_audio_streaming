import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:palette_generator/palette_generator.dart';

String url = 'http://192.168.1.42';

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
  final player = AudioPlayer();
  bool isPlaying = false;
  double currentPosition = 0.0;
  double bufferedPosition = 0.0;
  double maxDuration = 1.0;
  String currentSong = '';
  List<String> songs = [
    'Resonance',
    'Line',
    'Interlude',
  ];

  Color? dominantColor;

  @override
  void initState() {
    super.initState();
    currentSong = songs[0];
    initAudio();
  }

  Future<void> initAudio() async {
    String currentUrl =
        url + "/audio/lkp/erratic/${currentSong.toLowerCase()}.wav";
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

    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(url + '/audio/lkp/erratic/cover.png'),
    );

    dominantColor = paletteGenerator.dominantColor?.color;
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    await player.play();
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> _pauseAudio() async {
    await player.pause();
    setState(() {
      isPlaying = false;
    });
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
          // Current song info
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7), // This rounds the corners
            ),
            height: 80,
            child: Card(
              color: (dominantColor ?? Colors.green).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // This rounds the corners of the Card
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image(
                              image: NetworkImage(
                                url + '/audio/lkp/erratic/cover.png',
                              ),
                              width: 72,
                              height: 72,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            currentSong,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: isPlaying ? _pauseAudio : _playAudio,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ProgressBar(
                        progress:
                            Duration(milliseconds: currentPosition.toInt()),
                        total: Duration(milliseconds: maxDuration.toInt()),
                        thumbRadius: 0,
                        thumbGlowRadius: 0,
                        barHeight: 2,
                        timeLabelLocation: TimeLabelLocation.none,
                        baseBarColor: Colors.white54,
                        progressBarColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              /// Search
              SalomonBottomBarItem(
                icon: Icon(Icons.search),
                title: Text("Search"),
                selectedColor: Colors.pinkAccent,
              ),

              /// Home
              SalomonBottomBarItem(
                icon: Icon(Icons.home),
                title: Text("Home"),
                selectedColor: Colors.purpleAccent,
              ),

              /// Profile
              SalomonBottomBarItem(
                icon: Icon(Icons.favorite),
                title: Text("Favorites"),
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
                    initAudio();
                  }
                },
                items: songs.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Image(image: NetworkImage(url + '/audio/lkp/erratic/cover.png')),
              SizedBox(height: 10),
              Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 650),
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
                onPressed: isPlaying ? _pauseAudio : _playAudio,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
