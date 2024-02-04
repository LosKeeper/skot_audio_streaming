import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:skot/constants.dart';
import 'package:skot/audio_player_controller.dart';

class AlbumPage extends StatelessWidget {
  final Map<String, dynamic> jsonAvailableSongs;
  final Map<String, dynamic> jsonAvailableAlbums;
  final String albumRequested;
  final Function changeCurrentIndex;
  final AudioPlayerController audioPlayerController;
  final Function addToPlaylist;
  final Function addToFavorites;

  const AlbumPage(
      {super.key,
      required this.jsonAvailableSongs,
      required this.jsonAvailableAlbums,
      required this.albumRequested,
      required this.changeCurrentIndex,
      required this.audioPlayerController,
      required this.addToPlaylist,
      required this.addToFavorites});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl:
                      '$url/${jsonAvailableAlbums[albumRequested]['cover_path']}',
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_outline),
                  width: 300,
                  height: 300,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                albumRequested,
                style: const TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                jsonAvailableAlbums[albumRequested]['artist'],
                style: const TextStyle(
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 30),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: jsonAvailableAlbums[albumRequested]["songs"].length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      leading: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Text(
                        '${jsonAvailableAlbums[albumRequested]["songs"][index].keys.first}',
                      ),
                      onTap: () async {
                        await audioPlayerController.changeCurrentSong(
                            jsonAvailableAlbums[albumRequested]["songs"][index]
                                .keys
                                .first);
                        audioPlayerController.play();
                        changeCurrentIndex(3);
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                height: MediaQuery.of(context).size.height / 2,
                                child: Center(
                                  child: Material(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading:
                                              const Icon(Icons.playlist_add),
                                          title: const Text('Add to playlist'),
                                          onTap: () {
                                            addToPlaylist(jsonAvailableAlbums[
                                                        albumRequested]["songs"]
                                                    [index]
                                                .keys
                                                .first);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.favorite),
                                          title: const Text('Add to favorites'),
                                          onTap: () {
                                            addToFavorites(jsonAvailableAlbums[
                                                        albumRequested]["songs"]
                                                    [index]
                                                .keys
                                                .first);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
