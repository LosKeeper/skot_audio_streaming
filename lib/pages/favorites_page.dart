import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:spartacus_project/constants.dart';

class FavoritesPage extends StatefulWidget {
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
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Map<String, Future<Color>> _colorCache = {};

  Future<Color> _getColor(String imageUrl) {
    return _colorCache.putIfAbsent(
      imageUrl,
      () => PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(imageUrl),
      ).then((value) =>
          value.dominantColor?.color ?? Colors.green.withOpacity(0.8)),
    );
  }

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
                child: widget.favorites.isEmpty
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
                        itemCount: widget.favorites.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<Color>(
                            future: _getColor(
                                '$url/${widget.jsonAvailableSongs[widget.favorites[index]]['cover_path']}'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 70,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.black),
                                    ),
                                  ),
                                );
                              } else {
                                return SizedBox(
                                  height: 70,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(7),
                                    onTap: () async {
                                      await widget.changeCurrentSong(
                                          widget.favorites[index]);
                                      widget.play();
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
                                                          widget.addToPlaylist(
                                                              widget.favorites[
                                                                  index]);
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
                                                          widget.removeFavorite(
                                                              widget.favorites[
                                                                  index]);
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
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '$url/${widget.jsonAvailableSongs[widget.favorites[index]]['cover_path']}',
                                              )),
                                          Expanded(
                                            child: ListTile(
                                              title: Text(
                                                widget.favorites[index],
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
