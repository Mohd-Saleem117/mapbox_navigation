import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_navigation/main.dart';

import '../constants/destinationLocation.dart';
import '../requests/mapbox_requests.dart';

Future<Map> getDirectionsAPIResponse(LatLng currentLatLng, int index) async {
  final response = await getCyclingRouteUsingMapbox(
      currentLatLng,
      LatLng(
          double.parse(destinationLocation[index]['coordinates']['latitude']),
          double.parse(
              destinationLocation[index]['coordinates']['longitude'])));
  Map geometry = response['routes'][0]['geometry'];
  num duration = response['routes'][0]['duration'];
  num distance = response['routes'][0]['distance'];
  print(
      '-------------------${destinationLocation[index]['routeName']}-------------------');
  print(distance);
  print(duration);

  Map modifiedResponse = {
    "geometry": geometry,
    "duration": duration,
    "distance": distance,
  };
  print(modifiedResponse);
  return modifiedResponse;
}

void saveDirectionsAPIResponse(int index, String response) {
  sharedPreferences.setString('destinationLocation--$index', response);
}
