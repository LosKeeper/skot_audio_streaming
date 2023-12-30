import 'package:flutter/material.dart';

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
    return Padding(
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
          },
          suggestionsBuilder:
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
                    },
                  );
                },
              ),
            ];
          },
        ),
      ),
    );
  }
}
