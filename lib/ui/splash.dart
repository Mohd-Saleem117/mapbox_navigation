// import 'dart:html';

// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
// import 'package:lottie/lottie.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
// import 'package:mapbox_navigation/constants/destinationLocation.dart';
import 'package:mapbox_navigation/helpers/directions_handler.dart';
import 'package:mapbox_navigation/main.dart';
import 'package:mapbox_navigation/mainPage.dart';
import 'package:mapbox_navigation/screens/map.dart';
import '../authentication/login.dart';

import '../screens/home_management.dart';
// import '../screens/map.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    initializeLocationAndSave();
  }

  double? getLati;
  double? getLongi;

  void initializeLocationAndSave() async {
    // Ensure all permissions are collected for Locations
    Location _location = Location();
    bool? _serviceEnabled;
    PermissionStatus? _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }

    // Get capture the current user location
    LocationData _locationData = await _location.getLocation();
    LatLng currentLatLng =
        LatLng(_locationData.latitude!, _locationData.longitude!);

    // Store the user location in sharedPreferences
    sharedPreferences.setDouble('latitude', _locationData.latitude!);
    sharedPreferences.setDouble('longitude', _locationData.longitude!);

    // Get and store the directions API response in sharedPreferences

    // If we have multiple routes
    // for (int i = 0; i < destinationLocation.length; i++) {
    //   Map modifiedResponse = await getDirectionsAPIResponse(currentLatLng, i);
    //   saveDirectionsAPIResponse(i, json.encode(modifiedResponse));
    // }
    final dbref = FirebaseDatabase.instance.reference();

    // Get the firebase destination location
    await dbref
        .child("BUS ROUTES")
        .child("LOCATION")
        .child("busLatitude")
        .once()
        .then((event) {
      setState(() {
        final dataSnapshot = event.snapshot;
        print(dataSnapshot.value.toString());
        getLati = double.parse(dataSnapshot.value.toString());
      });
    });
    await dbref
        .child("BUS ROUTES")
        .child("LOCATION")
        .child("busLongitude")
        .once()
        .then((event) {
      setState(() {
        final dataSnapshot = event.snapshot;
        print(dataSnapshot.value.toString());
        getLongi = double.parse(dataSnapshot.value.toString());
      });
    });
    LatLng desLatLng = LatLng(getLati!, getLongi!);
    // // If we have only single route
    Map modifiedResponse =
        await getDirectionsAPIResponse(currentLatLng, desLatLng);
    print("$getLati--" + "--$getLongi");

    saveDirectionsAPIResponse(json.encode(modifiedResponse));

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MainPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text("ACE"),
            // Text("Bus Tracker"),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 50, 8, 50),
              child: Image.asset("assets/image/bus1.png"),
            ),
            // SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: Image.asset("assets/image/bus4.jpg"),
            ),
            // SizedBox(
            //     height: 300,
            //     width: 400,
            //     child: Lottie.asset("assets/image/busLottie.json")),
          ],
        ),
      ),
    );
  }
}
