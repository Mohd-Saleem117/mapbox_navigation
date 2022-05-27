import 'package:mapbox_gl/mapbox_gl.dart';

import '../constants/destinationLocation.dart';
import '../screens/map.dart';

LatLng getLatLngFromDestinationData(int index) {
  return LatLng(
      double.parse(destinationLocation[index]['latitude']),
      double.parse(destinationLocation[index]['longitude']));
}
