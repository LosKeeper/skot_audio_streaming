import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestManager {
  final String availableSongsUrl;
  final String availableAlbumsUrl;

  Map<String, dynamic> jsonAvailableSongs = {};
  Map<String, dynamic> jsonAvailableAlbums = {};

  RequestManager(
      {required this.availableSongsUrl, required this.availableAlbumsUrl});

  Future<void> fillAvailableSongsAndAlbums() async {
    jsonAvailableSongs = await getRequestSongs();
    jsonAvailableAlbums = await getRequestAlbums();
    jsonAvailableSongs = sortJsonByDate(jsonAvailableSongs);
    jsonAvailableAlbums = sortJsonByDate(jsonAvailableAlbums);
  }

  Future<Map<String, dynamic>> getRequestSongs() async {
    var response = await http.get(Uri.parse(availableSongsUrl));
    var json = jsonDecode(response.body);
    return json;
  }

  Future<Map<String, dynamic>> getRequestAlbums() async {
    var response = await http.get(Uri.parse(availableAlbumsUrl));
    var json = jsonDecode(response.body);
    return json;
  }

  Map<String, dynamic> sortJsonByDate(Map<String, dynamic> jsonData) {
    List<MapEntry<String, dynamic>> itemList = jsonData.entries.toList();

    itemList.sort((a, b) => b.value['date'].compareTo(a.value['date']));

    Map<String, dynamic> sortedData = {};
    for (var itemEntry in itemList) {
      sortedData[itemEntry.key] = itemEntry.value;
    }

    return sortedData;
  }
}
