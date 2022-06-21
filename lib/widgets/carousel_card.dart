import 'package:flutter/material.dart';
import 'package:mapbox_navigation/screens/map.dart';



Widget carouselCard(context, num distance, num duration) {
  final size = MediaQuery.of(context).size;
  return Align(
    alignment: Alignment.topCenter,
    child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      child: Container(
        height: 50,
        width: size.width / 2,
        color: Color.fromRGBO(6, 17, 60, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "name",
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
    ),
  );
}
