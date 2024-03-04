import 'package:flutter/foundation.dart';

String url = 'https://loskeeper.fr:42024';
String liveUrl = kDebugMode
    ? 'https://loskeeper.fr:42002/debug'
    : 'https://loskeeper.fr:42002/stream';
String liveUrlInfo = 'https://loskeeper.fr:42002/status.xsl';

String availableSongsUrl = '$url/audio/available_songs.json';
String availableAlbumsUrl = '$url/audio/available_albums.json';

String mountPointName =
    kDebugMode ? 'Mount Point /debug' : 'Mount Point /stream';
