import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestManager {
  final String availableSongsUrl;
  final String availableAlbumsUrl;

  RequestManager(
      {required this.availableSongsUrl, required this.availableAlbumsUrl});

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
}
