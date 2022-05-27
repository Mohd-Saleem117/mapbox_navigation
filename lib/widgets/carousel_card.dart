import 'package:flutter/material.dart';
import 'package:mapbox_navigation/screens/map.dart';

import '../constants/destinationLocation.dart';

Widget carouselCard(int index, num distance, num duration) {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(50)),
    child: Container(
      color: Color.fromRGBO(6, 17, 60, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            destinationLocation[index]['routeName'],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('${distance.toStringAsFixed(2)} kms'),
              Text('${duration.toStringAsFixed(2)} mins')
            ],
          ),
        ],
      ),
    ),
  );
}
