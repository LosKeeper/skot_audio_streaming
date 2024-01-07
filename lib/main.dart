import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:audio_service/audio_service.dart';

import 'package:spartacus_project/constants.dart';
import 'package:spartacus_project/current_song_card.dart';
import 'package:spartacus_project/audio_player_controller.dart';

import 'package:spartacus_project/pages/current_song_page.dart';
import 'package:spartacus_project/pages/settings_page.dart';
import 'package:spartacus_project/pages/search_page.dart';
import 'package:spartacus_project/pages/home_page.dart';
import 'package:spartacus_project/pages/album_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var quality = await loadQuality();
  var audioPlayerController = await AudioService.init(
    builder: () => AudioPlayerController(
      quality: quality,
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Spartacus Project Audio Service',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp(quality: quality, audioPlayerController: audioPlayerController));
}

class MyApp extends StatelessWidget {
  final int quality;
  final AudioPlayerController audioPlayerController;
  const MyApp(
      {super.key, required this.quality, required this.audioPlayerController});

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
      home: MyHomePage(
          title: 'LKP Streaming',
          quality: quality,
          audioPlayerController: audioPlayerController),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.title,
      required this.quality,
      required this.audioPlayerController});

  final String title;
  final int quality;
  final AudioPlayerController audioPlayerController;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 1;
  String _albumRequested = '';

  Future<void> changeCurrentIndex(int newIndex) async {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  Future<void> changeAlbumRequested(String albumRequested) async {
    setState(() {
      _albumRequested = albumRequested;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.audioPlayerController.init();
  }

  @override
  void dispose() {
    widget.audioPlayerController.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
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

              /// Favorites
              SalomonBottomBarItem(
                icon: const Icon(Icons.favorite),
                title: const Text("Favorites"),
                selectedColor: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          () {
            switch (_currentIndex) {
              case 0:
                return SearchPage(
                  jsonAvailableSongs: widget
                      .audioPlayerController.requestManager.jsonAvailableSongs,
                  jsonAvailableAlbums: widget
                      .audioPlayerController.requestManager.jsonAvailableAlbums,
                  changeCurrentSong:
                      widget.audioPlayerController.changeCurrentSong,
                  changeCurrentIndex: changeCurrentIndex,
                  changeAlbumRequested: changeAlbumRequested,
                  playSong: widget.audioPlayerController.play,
                );
              case 1:
                return HomePage(
                  audioPlayerController: widget.audioPlayerController,
                );

              case 2:
                return const Center(
                  child: Text('Favorites'),
                );
              case 3:
                return StreamBuilder<double>(
                    stream: widget.audioPlayerController.positionStream,
                    builder: (context, snapshot) {
                      double position = snapshot.data ?? 0.0;
                      return CurrentSongPage(
                        audioPlayerController: widget.audioPlayerController,
                        position: position,
                      );
                    });
              case 4:
                return SettingsPage(
                  quality: widget.audioPlayerController.quality,
                  changeQuality: widget.audioPlayerController.changeQuality,
                );
              case 5:
                return AlbumPage(
                  jsonAvailableSongs: widget
                      .audioPlayerController.requestManager.jsonAvailableSongs,
                  jsonAvailableAlbums: widget
                      .audioPlayerController.requestManager.jsonAvailableAlbums,
                  albumRequested: _albumRequested,
                  changeCurrentIndex: changeCurrentIndex,
                  audioPlayerController: widget.audioPlayerController,
                  addToPlaylist: widget.audioPlayerController.addNextSong,
                );
              default:
                return Container();
            }
          }(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.audioPlayerController.currentSong != '' &&
                    _currentIndex != 3)
                  StreamBuilder<double>(
                    stream: widget.audioPlayerController.positionStream,
                    builder: (context, snapshot) {
                      double position = snapshot.data ?? 0.0;
                      return CurrentSongCard(
                        audioPlayerController: widget.audioPlayerController,
                        changeCurrentIndex: changeCurrentIndex,
                        position: position,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
