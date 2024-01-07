import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:spartacus_project/constants.dart';

class FavoritesPage extends StatelessWidget {
  final List<String> favorites;
  final Function removeFavorite;
  final Function changeCurrentSong;
  final Function addToPlaylist;
  final Function play;
  final Map<String, dynamic> jsonAvailableSongs;

  const FavoritesPage(
      {super.key,
      required this.favorites,
      required this.removeFavorite,
      required this.changeCurrentSong,
      required this.addToPlaylist,
      required this.play,
      required this.jsonAvailableSongs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Favorites',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: favorites.isEmpty
                    ? const Text(
                        'No favorites yet !',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<Color>(
                            future: PaletteGenerator.fromImageProvider(
                              NetworkImage(
                                  '$url/${jsonAvailableSongs[favorites[index]]['cover_path']}'),
                            ).then((value) =>
                                value.dominantColor?.color ??
                                Colors.green.withOpacity(0.8)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // Affiche un indicateur de progression pendant le chargement
                              } else {
                                return SizedBox(
                                  height: 70,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(7),
                                    onTap: () async {
                                      await changeCurrentSong(favorites[index]);
                                      play();
                                    },
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            content: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2,
                                              child: Center(
                                                child: Material(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      ListTile(
                                                        leading: const Icon(
                                                            Icons.playlist_add),
                                                        title: const Text(
                                                            'Add to playlist'),
                                                        onTap: () {
                                                          addToPlaylist(
                                                              favorites[index]);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(
                                                            Icons.delete),
                                                        title: const Text(
                                                            'Remove from favorites'),
                                                        onTap: () {
                                                          removeFavorite(
                                                              favorites[index]);
                                                          Navigator.of(context)
                                                              .pop();
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
                                    child: Card(
                                      color: snapshot.data ??
                                          Colors.green.withOpacity(0.8),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            child: Image.network(
                                                '$url/${jsonAvailableSongs[favorites[index]]['cover_path']}'),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              title: Text(
                                                favorites[index],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: snapshot.data!
                                                              .computeLuminance() >
                                                          0.5
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
