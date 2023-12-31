import 'package:flutter/material.dart';

import 'package:spartacus_project/constants.dart';

class SearchPage extends StatelessWidget {
  final Map<String, dynamic> jsonAvailableSongs;
  final Map<String, dynamic> jsonAvailableAlbums;
  final Function changeCurrentSong;
  final Function changeCurrentIndex;

  const SearchPage(
      {super.key,
      required this.jsonAvailableSongs,
      required this.jsonAvailableAlbums,
      required this.changeCurrentSong,
      required this.changeCurrentIndex});

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
                          onTap: () {
                            controller.closeView(controller.value.text);
                            controller.clear();
                            if (jsonAvailableSongs[combined[index]] != null) {
                              changeCurrentSong(combined[index].toString());
                              changeCurrentIndex(3);
                            } else {
                              //TODO: implement album selection
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
                //TODO: Sort albums by date
                return InkWell(
                  onTap: () {
                    //TODO: implement album selection
                    print(
                        '${jsonAvailableAlbums.keys.toList()[index]} album requested');
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
                              image: NetworkImage(
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
      ]),
    );
  }
}
