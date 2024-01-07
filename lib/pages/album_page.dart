import 'package:flutter/material.dart';

import 'package:spartacus_project/constants.dart';
import 'package:spartacus_project/audio_player_controller.dart';

class AlbumPage extends StatelessWidget {
  final Map<String, dynamic> jsonAvailableSongs;
  final Map<String, dynamic> jsonAvailableAlbums;
  final String albumRequested;
  final Function changeCurrentIndex;
  final AudioPlayerController audioPlayerController;

  const AlbumPage(
      {super.key,
      required this.jsonAvailableSongs,
      required this.jsonAvailableAlbums,
      required this.albumRequested,
      required this.changeCurrentIndex,
      required this.audioPlayerController});

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
                child: Image.network(
                  '$url/${jsonAvailableAlbums[albumRequested]['cover_path']}',
                  height: 300,
                  width: 300,
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
                        audioPlayerController.changeCurrentSong(
                            jsonAvailableAlbums[albumRequested]["songs"][index]
                                .keys
                                .first);
                        audioPlayerController.play();
                        changeCurrentIndex(3);
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
