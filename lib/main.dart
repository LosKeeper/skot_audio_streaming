import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:audio_service/audio_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:universal_io/io.dart';

import 'package:skot/constants.dart';
import 'package:skot/current_song_card.dart';
import 'package:skot/audio_player_controller.dart';
import 'package:skot/network_request_manager.dart';

import 'package:skot/pages/current_song_page.dart';
import 'package:skot/pages/settings_page.dart';
import 'package:skot/pages/search_page.dart';
import 'package:skot/pages/home_page.dart';
import 'package:skot/pages/album_page.dart';
import 'package:skot/pages/favorites_page.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    BackgroundFetch.finish(taskId);
    return;
  }
  var requestManager = RequestManager(
      availableSongsUrl: '$url/audio/available_songs.json',
      availableAlbumsUrl: '$url/audio/available_albums.json',
      messagesUrl: '$url/audio/messages.json',
      selectionUrl: '$url/audio/selection.json');
  await requestManager.printNotification();
  BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  int quality = await loadQuality();
  int lastIdMsg = await loadLastIdMsg();
  List<String> favorites = await loadFavorites();

  AwesomeNotifications().initialize(
    'resource://mipmap/launcher_icon',
    [
      NotificationChannel(
        channelKey: 'default_channel',
        channelName: 'Channel for notifications',
        channelDescription: 'Notification channel for SKOT',
        defaultColor: Colors.pink,
        ledColor: Colors.purple,
        playSound: true,
        enableVibration: true,
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'grp_skot',
        channelGroupName: 'Skot',
      )
    ],
    debug: true,
  );
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  var audioPlayerController = await AudioService.init(
    builder: () => AudioPlayerController(quality: quality),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.loskeeper.skot.aud',
      androidNotificationChannelName: 'SKOT Audio Player',
      androidNotificationOngoing: true,
      androidNotificationIcon: "mipmap/player_icon",
    ),
  );

  runApp(MyApp(
      quality: quality,
      favorites: favorites,
      audioPlayerController: audioPlayerController,
      lastIdMsg: lastIdMsg));
  if (Platform.isAndroid || Platform.isIOS) {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }
}

class MyApp extends StatelessWidget {
  final int quality;
  final AudioPlayerController audioPlayerController;
  final List<String> favorites;
  final int lastIdMsg;
  const MyApp(
      {super.key,
      required this.quality,
      required this.audioPlayerController,
      required this.favorites,
      required this.lastIdMsg});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKOT',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(
          title: 'SKOT',
          quality: quality,
          audioPlayerController: audioPlayerController,
          favorites: favorites,
          lastIdMsg: lastIdMsg),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.title,
      required this.quality,
      required this.favorites,
      required this.audioPlayerController,
      required this.lastIdMsg});

  final String title;
  final int quality;
  final int lastIdMsg;
  final AudioPlayerController audioPlayerController;
  final List<String> favorites;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 1;
  String _albumRequested = '';
  List<String> _favorites = [];

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

  Future<void> addToFavorites(String song) async {
    setState(() {
      if (_favorites.contains(song)) {
        return;
      } else {
        _favorites.add(song);
      }
    });
    await saveFavorites(_favorites);
  }

  Future<void> removeFromFavorites(String song) async {
    setState(() {
      if (_favorites.contains(song)) {
        _favorites.remove(song);
      } else {
        return;
      }
    });
    await saveFavorites(_favorites);
  }

  @override
  void initState() {
    super.initState();
    _favorites = widget.favorites;
    widget.audioPlayerController.init();
    widget.audioPlayerController.requestManager
        .getMessages()
        .then((listMessages) {
      if (widget.lastIdMsg < listMessages.last["id"]) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDialog();
          saveLastIdMsg(listMessages.last["id"]);
        });
      }
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: widget
                  .audioPlayerController.requestManager.listMessages.isNotEmpty
              ? Text(
                  widget.audioPlayerController.requestManager.listMessages
                      .last["title"],
                  style: const TextStyle(fontSize: 24),
                )
              : const Text(''),
          content: widget
                  .audioPlayerController.requestManager.listMessages.isNotEmpty
              ? Text(
                  widget.audioPlayerController.requestManager.listMessages
                      .last["message"],
                  style: const TextStyle(fontSize: 16),
                )
              : const Text(''),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
                return PopScope(
                  canPop: false,
                  onPopInvoked: (bool didPop) {
                    if (didPop) {
                      changeCurrentIndex(1);
                    } else {
                      changeCurrentIndex(1);
                    }
                  },
                  child: SearchPage(
                    jsonAvailableSongs: widget.audioPlayerController
                        .requestManager.jsonAvailableSongs,
                    jsonAvailableAlbums: widget.audioPlayerController
                        .requestManager.jsonAvailableAlbums,
                    changeCurrentSong:
                        widget.audioPlayerController.changeCurrentSong,
                    changeCurrentIndex: changeCurrentIndex,
                    changeAlbumRequested: changeAlbumRequested,
                    playSong: widget.audioPlayerController.play,
                  ),
                );
              case 1:
                return HomePage(
                    audioPlayerController: widget.audioPlayerController);

              case 2:
                return PopScope(
                  canPop: false,
                  onPopInvoked: (bool didPop) {
                    changeCurrentIndex(1);
                  },
                  child: FavoritesPage(
                    favorites: _favorites,
                    changeCurrentSong:
                        widget.audioPlayerController.changeCurrentSong,
                    play: widget.audioPlayerController.play,
                    removeFavorite: removeFromFavorites,
                    addToPlaylist: widget.audioPlayerController.addNextSong,
                    jsonAvailableSongs: widget.audioPlayerController
                        .requestManager.jsonAvailableSongs,
                  ),
                );
              case 3:
                return StreamBuilder<double>(
                    stream: widget.audioPlayerController.positionStream,
                    builder: (context, snapshot) {
                      double position = snapshot.data ?? 0.0;
                      return PopScope(
                        canPop: false,
                        onPopInvoked: (bool didPop) {
                          changeCurrentIndex(1);
                        },
                        child: CurrentSongPage(
                          audioPlayerController: widget.audioPlayerController,
                          position: position,
                          addToFavorites: addToFavorites,
                          removeFromFavorites: removeFromFavorites,
                          favorites: _favorites,
                        ),
                      );
                    });
              case 4:
                return PopScope(
                  canPop: false,
                  onPopInvoked: (bool didPop) {
                    changeCurrentIndex(1);
                  },
                  child: SettingsPage(
                    quality: widget.audioPlayerController.quality,
                    changeQuality: widget.audioPlayerController.changeQuality,
                  ),
                );
              case 5:
                return PopScope(
                  canPop: false,
                  onPopInvoked: (bool didPop) {
                    changeCurrentIndex(0);
                  },
                  child: AlbumPage(
                    jsonAvailableSongs: widget.audioPlayerController
                        .requestManager.jsonAvailableSongs,
                    jsonAvailableAlbums: widget.audioPlayerController
                        .requestManager.jsonAvailableAlbums,
                    albumRequested: _albumRequested,
                    changeCurrentIndex: changeCurrentIndex,
                    audioPlayerController: widget.audioPlayerController,
                    addToPlaylist: widget.audioPlayerController.addNextSong,
                    addToFavorites: addToFavorites,
                  ),
                );
              default:
                return Container();
            }
          }(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StreamBuilder<String>(
              stream: widget.audioPlayerController.currentSongStream,
              builder: (context, snapshot) {
                return Column(
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
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
