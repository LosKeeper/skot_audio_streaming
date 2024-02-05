import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:universal_io/io.dart';

import 'package:skot/constants.dart';

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
  // ignore: library_private_types_in_public_api
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Map<String, Future<Color>> _colorCache = {};
  bool _isEditing = false;

  void _toggleEditingMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = widget.favorites.removeAt(oldIndex);
      widget.favorites.insert(newIndex, item);

      saveFavorites(widget.favorites);
    });
  }

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
    return Stack(
      children: [
        _isEditing
            ? Column(
                children: [
                  Expanded(
                    child: ReorderableListView(
                      onReorder: _onReorder,
                      children: widget.favorites.map((item) {
                        return ListTile(
                          key: Key(item),
                          leading: const Icon(Icons.album),
                          title: Text(item),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    widget.favorites.remove(item);
                                  });
                                },
                              ),
                              if (Platform.isAndroid)
                                ReorderableDragStartListener(
                                  index: widget.favorites.indexOf(item),
                                  child: const Icon(Icons.menu),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              )
            : CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const Text(
                          'Favorites',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 30,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FutureBuilder<Color>(
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
                          ),
                        );
                      },
                      childCount: widget.favorites.length,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 80,
                    ),
                  ),
                ],
              ),
        Positioned(
          right: 0,
          bottom: 80,
          child: GestureDetector(
            onTap: _toggleEditingMode,
            child: Container(
              width: 56, // same as FloatingActionButton
              height: 56, // same as FloatingActionButton
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Icon(_isEditing ? Icons.done : Icons.edit,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
