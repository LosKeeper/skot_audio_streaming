import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:skot/constants.dart';

class SearchPage extends StatelessWidget {
  final Map<String, dynamic> jsonAvailableSongs;
  final Map<String, dynamic> jsonAvailableAlbums;
  final Function changeCurrentSong;
  final Function changeCurrentIndex;
  final Function changeAlbumRequested;
  final Function playSong;

  const SearchPage(
      {super.key,
      required this.jsonAvailableSongs,
      required this.jsonAvailableAlbums,
      required this.changeCurrentSong,
      required this.changeCurrentIndex,
      required this.changeAlbumRequested,
      required this.playSong});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0)),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
                hintText: 'Search',
              );
            }, suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
              var filteredSongs = jsonAvailableSongs.keys
                  .where((song) => song
                      .toLowerCase()
                      .contains(controller.value.text.toLowerCase()))
                  .toSet();

              var filteredAlbums = jsonAvailableAlbums.keys
                  .where((album) => album
                      .toLowerCase()
                      .contains(controller.value.text.toLowerCase()))
                  .toSet();

              var combined = {...filteredSongs, ...filteredAlbums}.toList();
              combined
                  .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

              return [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: combined.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          title: Text(
                            combined[index],
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          leading: const Icon(Icons.music_note),
                          onTap: () async {
                            controller.closeView(controller.value.text);
                            controller.clear();
                            if (jsonAvailableSongs[combined[index]] != null) {
                              await changeCurrentSong(
                                  combined[index].toString());
                              changeCurrentIndex(3);
                              playSong();
                            } else {
                              changeAlbumRequested(combined[index].toString());
                              changeCurrentIndex(5);
                            }
                          });
                    }),
              ];
            }),
          ),
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.topCenter,
          child: Text(
            'Albums / Songs',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 600,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1,
              children: List.generate(jsonAvailableAlbums.length, (index) {
                return InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    changeAlbumRequested(
                        jsonAvailableAlbums.keys.toList()[index].toString());
                    changeCurrentIndex(5);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                '$url/${jsonAvailableAlbums[jsonAvailableAlbums.keys.toList()[index]]['cover_path']}',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    jsonAvailableAlbums.keys
                                        .toList()[index]
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    jsonAvailableAlbums[jsonAvailableAlbums.keys
                                            .toList()[index]]['artist']
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 100),
      ]),
    );
  }
}
