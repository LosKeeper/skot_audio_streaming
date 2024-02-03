import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:spartacus_project/constants.dart';
import 'package:spartacus_project/audio_player_controller.dart';

class HomePage extends StatelessWidget {
  final AudioPlayerController audioPlayerController;

  const HomePage({super.key, required this.audioPlayerController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
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
                  color: Colors.purple.shade100,
                  shadowColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: StreamBuilder<bool>(
                      stream: audioPlayerController.jsonLoadedController.stream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData &&
                            audioPlayerController.jsonLoaded == false) {
                          return const Text(
                            'Loading...',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          );
                        } else {
                          return Text(
                            audioPlayerController
                                .requestManager.listMessages[0]["message"]
                                .toString(),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Selection of the moment',
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
                              child: SpinKitFadingCube(
                            color: Colors.purpleAccent,
                            size: 80.0,
                          ));
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
                                            image: CachedNetworkImageProvider(
                                              '$url/${audioPlayerController.requestManager.jsonAvailableSongs[audioPlayerController.requestManager.listSelection[index]]['cover_path']}',
                                            ),
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
                                            audioPlayerController
                                                .changeCurrentSong(
                                                    audioPlayerController
                                                        .requestManager
                                                        .listSelection[index]);
                                            audioPlayerController.play();
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
                                                    .listSelection[index]
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
                                                                .listSelection[
                                                            index]]['artist']
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
            ),
          )),
    );
  }
}
