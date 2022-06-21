import 'dart:convert';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_navigation/main.dart';

LatLng getLatLngFromSharedPrefs() {
  return LatLng(sharedPreferences.getDouble('latitude')!,
      sharedPreferences.getDouble('longitude')!);
}

Map getDecodedResponseFromSharedPrefs() {
  String key = 'destinationLocation--';
  Map response = json.decode(sharedPreferences.getString(key)!);
  return response;
}

num getDistanceFromSharedPrefs() {
  num distance = getDecodedResponseFromSharedPrefs()['distance'];
  return distance;
}

num getDurationFromSharedPrefs() {
  num duration = getDecodedResponseFromSharedPrefs()['duration'];
  return duration;
}

Map getGeometryFromSharedPrefs() {
  Map geometry = getDecodedResponseFromSharedPrefs()['geometry'];
  return geometry;
}
