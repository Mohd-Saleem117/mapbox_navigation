// import 'dart:html';

// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
// import 'package:lottie/lottie.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
// import 'package:mapbox_navigation/constants/destinationLocation.dart';
import 'package:mapbox_navigation/helpers/directions_handler.dart';
import 'package:mapbox_navigation/main.dart';

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

    // If we have multiple ruotes
    // for (int i = 0; i < destinationLocation.length; i++) {
    //   Map modifiedResponse = await getDirectionsAPIResponse(currentLatLng, i);
    //   saveDirectionsAPIResponse(i, json.encode(modifiedResponse));
    // }

    // If we have only single route
    Map modifiedResponse = await getDirectionsAPIResponse(currentLatLng, 0);
    saveDirectionsAPIResponse(0, json.encode(modifiedResponse));

    Future.delayed(
        const Duration(seconds: 1),
        () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeManagement()),
            (route) => false));
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
