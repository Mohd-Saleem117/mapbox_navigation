// List<Map> destinationLocation = [
// {
//   'routeName': 'BUS NO. 21',
//   'coordinates': {
//     // 'latitude': '17.366142',
//     // 'longitude': '78.531408',
//     'latitude': '17.42396',
//     'longitude': '78.504317',
//   }
// }
// ];

// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

List<Map> destinationLocation = [
  {
    'routeName': 'BUS NO. 21',
    'coordinates': {
      // 'latitude': '17.366142',
      // 'longitude': '78.531408',
      'latitude': '17.42396',
      'longitude': '78.504317',
    },
  },
];
late DatabaseReference dbref;
String lat = "";
String lon = "";
String name = "";

void DestinationLocation() {
  DatabaseReference dbref = FirebaseDatabase.instance.reference();
  dbref
      .child("BUS ROUTES")
      .child("LOCATION")
      .child("busLatitude")
      .onValue
      .listen((event) {
    lat = event.snapshot.value.toString();
    print("Hiiii-----------------" + lat);
    // setState(() {
    // });
  });
  dbref
      .child("BUS ROUTES")
      .child("LOCATION")
      .child("busLongitude")
      .onValue
      .listen((event) {
    lon = event.snapshot.value.toString();

    print("Hiiiii-----------------" + lon);
    // setState(() {
    // });
  });
  dbref
      .child("BUS ROUTES")
      .child("LOCATION")
      .child("name")
      .onValue
      .listen((event) {
    // name1 = name;
    // setState(() {
    name = event.snapshot.value.toString();
    print("Hiiii--------------------" + name);

    // });
  });
  // name1 = name;
  // dLoc = [
  //   {
  //     'routeName': name,
  //     'coordinates': {
  //       'latitude': lat,
  //       'longitude': lon,
  //     }
  //   }
  // ];
  destinationLocation[0]['routeName'] = name;
  print("======================" + destinationLocation[0]['routeName']);
}
