import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:background_fetch/background_fetch.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:universal_io/io.dart';

import 'package:skot/constants.dart';

class RequestManager {
  final String availableSongsUrl;
  final String availableAlbumsUrl;
  final String messagesUrl;
  final String selectionUrl;

  Map<String, dynamic> jsonAvailableSongs = {};
  Map<String, dynamic> jsonAvailableAlbums = {};
  List<dynamic> listMessages = [];
  List<String> listSelection = [];

  RequestManager(
      {required this.availableSongsUrl,
      required this.availableAlbumsUrl,
      required this.messagesUrl,
      required this.selectionUrl}) {
    if (Platform.isAndroid || Platform.isIOS) {
      initBackgroundFetch();
    }
  }

  Future<void> fillAvailableSongsAndAlbums() async {
    jsonAvailableSongs = await getRequestSongs();
    jsonAvailableAlbums = await getRequestAlbums();
    listMessages = await getMessages();
    listSelection = await getSelection();
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

  Future<List<dynamic>> getMessages() async {
    var response = await http.get(Uri.parse(messagesUrl));
    var json = jsonDecode(response.body);
    listMessages = json;
    return listMessages;
  }

  Future<List<String>> getSelection() async {
    var response = await http.get(Uri.parse(selectionUrl));
    var json = jsonDecode(response.body);
    List<String> titles =
        json.map<String>((item) => item['title'].toString()).toList();
    return titles;
  }

  Future<void> printNotification() async {
    // Retrieve the ID of the last notification received
    int? lastNotificationId = await loadLastIdMsg();

    // Update the notification from the server
    listMessages = await getMessages();

    if (lastNotificationId < listMessages.last['id']) {
      // Display the notification
      bool printed = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: listMessages.last['title'],
          body: listMessages.last['message'],
        ),
      );

      if (printed) {
        // Save the ID of the last notification received
        await saveLastIdMsg(listMessages.last['id']);
      }
    }
  }

  void initBackgroundFetch() {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        await printNotification();
        BackgroundFetch.finish(taskId);
      },
    );
  }
}
