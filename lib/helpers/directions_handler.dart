import 'package:firebase_database/firebase_database.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_navigation/main.dart';
import 'package:mapbox_navigation/screens/map.dart';


import '../requests/mapbox_requests.dart';

Future<Map> getDirectionsAPIResponse(
    LatLng currentLatLng, LatLng destinationLatLng) async {
  final response =
      await getCyclingRouteUsingMapbox(currentLatLng, destinationLatLng);
  Map geometry = response['routes'][0]['geometry'] as Map;
  num duration = response['routes'][0]['duration'];
  num distance = response['routes'][0]['distance'];
  // print(
  //     '-------------------${destinationLocation[index]['routeName']}-------------------');
  // print(distance);
  // print(duration);

  Map modifiedResponse = {
    "geometry": geometry,
    "duration": duration,
    "distance": distance,
  };
  print(modifiedResponse);
  return modifiedResponse;
}

void saveDirectionsAPIResponse(String response) {
  sharedPreferences.setString('destinationLocation--', response);
}
