import 'package:shared_preferences/shared_preferences.dart';

String url = 'http://loskeeper.fr:42024';

String availableSongsUrl = '$url/audio/available_songs.json';
String availableAlbumsUrl = '$url/audio/available_albums.json';

qualityToExtension(int quality) {
  switch (quality) {
    case 0:
      return '.aac';
    case 1:
      return '.flac';
    case 2:
      return '.wav';
    default:
      return 'wav';
  }
}

Future<void> saveQuality(int quality) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('quality', quality);
}

Future<int> loadQuality() async {
  final prefs = await SharedPreferences.getInstance();
  final quality = prefs.getInt('quality');
  return quality ?? 0;
}
