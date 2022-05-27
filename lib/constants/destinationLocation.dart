
// // ignore_for_file: deprecated_member_use, non_constant_identifier_names

// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_core/firebase_core.dart';

// List<Map> destinationLocation = [
//   {
//     'routeName': 'BUS NO',
//     'latitude': '17.42396',
//     'longitude': '78.504317',
//   },
// ];

// // List<Map> destinationLocation = [];
// late DatabaseReference dbref;
// String _lat = "";
// String _lon = "";
// String _name = "";

// void DestinationLocation() {
//   DatabaseReference dbref = FirebaseDatabase.instance.reference();
//   dbref
//       .child("BUS ROUTES")
//       .child("LOCATION")
//       .child("busLatitude")
//       .onValue
//       .listen((event) {
//     String lati = event.snapshot.value.toString();
//     print("Hiiii-----------------" + lati);

//     _lat = lati;
//   });

//   dbref
//       .child("BUS ROUTES")
//       .child("LOCATION")
//       .child("busLongitude")
//       .onValue
//       .listen((event) {
//     String longi = event.snapshot.value.toString();
//     print("Hiiiii-----------------" + longi);

//     _lon = longi;
//   });

//   dbref
//       .child("BUS ROUTES")
//       .child("LOCATION")
//       .child("name")
//       .onValue
//       .listen((event) {
//     String busName = event.snapshot.value.toString();
//     print("Hiiii--------------------" + busName);

//     _name = busName;
//   });

//   destinationLocation[0].update('routeName', (value) => _name);
//   destinationLocation[0].update('latitude', (value) => _lat);
//   destinationLocation[0].update('longitude', (value) => _lon);
//   print("Hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" + _name);

//   // print("00000000000000000000000000000000000099999999999999" + lat);
//   // print("0------------------------------0" +
//   //     dbref
//   //         .child('BUS ROUTES')
//   //         .child('LOCATION')
//   //         .child('name')
//   //         .onValue
//   //         .listen((event) {
//   //       event.snapshot.value.toString();
//   //     }).toString());
// // List<Map> destinationLocation = [
// //   {
// //     'routeName': dbref.child('BUS ROUTES').child('LOCATION').child('name'),
// //     'latitude': '17.42396',
// //     'longitude': '78.504317',
// //   },
// // ];
// }
