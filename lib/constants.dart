String url = 'http://192.168.1.42';

String availableSongsUrl = url + '/audio/available_songs.json';
String availableAlbumsUrl = url + '/audio/available_albums.json';

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
