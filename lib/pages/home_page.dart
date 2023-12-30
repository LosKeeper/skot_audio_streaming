import 'package:flutter/material.dart';

import 'package:spartacus_project/constants.dart';
import 'package:spartacus_project/audio_player_controller.dart';

class HomePage extends StatelessWidget {
  final AudioPlayerController audioPlayerController;

  const HomePage({super.key, required this.audioPlayerController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Welcome back !',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Card(
                color: Colors.purple.shade100, // Change the background color
                shadowColor: Colors.purple, // Change the shadow color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15), // Add rounded corners
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'The future of the music is near. You can\'t imagine how lucky you are to see this !',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Selection of the artist',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 600,
                child: StreamBuilder<bool>(
                    stream: audioPlayerController.jsonLoadedController.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData &&
                          audioPlayerController.jsonLoaded == false) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          children: List.generate(2, (index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            '$url/${audioPlayerController.requestManager.jsonAvailableSongs[audioPlayerController.requestManager.jsonAvailableSongs.keys.toList()[index]]['cover_path']}',
                                          ),
                                          // fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black,
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        icon: const Icon(Icons.play_arrow),
                                        onPressed: () async {
                                          await audioPlayerController
                                              .changeCurrentSong(
                                                  audioPlayerController
                                                      .requestManager
                                                      .jsonAvailableSongs
                                                      .keys
                                                      .toList()[index]);
                                          audioPlayerController.playAudio();
                                        },
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              audioPlayerController
                                                  .requestManager
                                                  .jsonAvailableSongs
                                                  .keys
                                                  .toList()[index]
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              audioPlayerController
                                                  .requestManager
                                                  .jsonAvailableSongs[
                                                      audioPlayerController
                                                          .requestManager
                                                          .jsonAvailableSongs
                                                          .keys
                                                          .toList()[index]]
                                                      ['artist']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      }
                    }),
              ),
            ],
          )),
    );
  }
}
