import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

Color buttonColor = const Color.fromARGB(255, 95, 0, 119);

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

Future<List<String>> loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  final favorites = prefs.getStringList('favorites');
  return favorites ?? [];
}

Future<void> saveFavorites(List<String> favorites) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('favorites', favorites);
}

Future<int> loadLastIdMsg() async {
  final prefs = await SharedPreferences.getInstance();
  final lastIdMsg = prefs.getInt('lastIdMsg');
  return lastIdMsg ?? 0;
}

Future<void> saveLastIdMsg(int lastIdMsg) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastIdMsg', lastIdMsg);
}
