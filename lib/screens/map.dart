// ignore_for_file: deprecated_member_use, avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_navigation/helpers/commons.dart';
import 'package:mapbox_navigation/helpers/shared_prefs.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../widgets/carousel_card.dart';
import '../ui/splash.dart';
import '../main.dart';

class sampleMap extends StatefulWidget {
  const sampleMap({Key? key}) : super(key: key);

  @override
  State<sampleMap> createState() => _sampleMapState();
}

// Map destinationLocation = {
//   'routeName': "loki",
//   'latitude': '17.2345',
//   'longitude': '78.22222',
// };
final user = FirebaseAuth.instance.currentUser;
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final dbref = FirebaseDatabase.instance.reference();

class _sampleMapState extends State<sampleMap> {
  showData() {
    dbref.once().then((event) {
      final dataSnapshot = event.snapshot;
      print(dataSnapshot.value.toString());
    });
  }

  showOneChild() {
    dbref
        .child("BUS ROUTES")
        .child("LOCATION")
        .child("busLatitude")
        .once()
        .then((event) {
      final dataSnapshot = event.snapshot;
      print(dataSnapshot.value.toString());
    });
  }

  // Mapbox related
  LatLng latlng = getLatLngFromSharedPrefs();
  late CameraPosition _initialCameraPosition;
  late MapboxMapController controller;
  late CameraPosition _kDestinationsList;
  late Map carouselData;

  @override
  void initState() {
    super.initState();
    initializeDestlocation();
  }

  double? getLati;
  double? getLongi;

  void initializeDestlocation() async {
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

    print("$getLati---$getLongi");

    LatLng getLatLngFromDestinationData() {
      return desLatLng;
    }

    _initialCameraPosition = CameraPosition(target: latlng, zoom: 15);

    // Calculate the distance and time from data in SharedPreferences
    num distance = getDistanceFromSharedPrefs() / 1000;
    num duration = getDurationFromSharedPrefs() / 60;

    carouselData = {'distance': distance, 'duration': duration};

    _kDestinationsList =
        CameraPosition(target: getLatLngFromDestinationData(), zoom: 15);
  }

  _addSourceAndLineLayer(bool removeLayer) async {
    // print("------------------$name-----------------");
    // Can animate camera to focus on the item
    controller
        .animateCamera(CameraUpdate.newCameraPosition(_kDestinationsList));

    // Add a polyLine between source and destination
    Map geometry = getGeometryFromSharedPrefs();
    final _fills = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": 0,
          "properties": <String, dynamic>{},
          "geometry": geometry,
        },
      ]
    };
    // Remove lineLayer and source if it exists
    if (removeLayer == true) {
      await controller.removeLayer("lines");
      await controller.removeSource("fills");
    }
    // Add new source and lineLayer
    await controller.addSource("fills", GeojsonSourceProperties(data: _fills));
    await controller.addLineLayer(
        "fills",
        "lines",
        LineLayerProperties(
            lineColor: Colors.blue[800]!.toHexStringRGB(),
            // lineCap: "round",
            lineJoin: "round",
            lineWidth: 5));
  }

  _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;
  }

  _onStyleLoadedCallback() async {
    await controller.addSymbol(SymbolOptions(
      geometry: _kDestinationsList.target,
      iconSize: 0.2,
      iconImage: "assets/icon/busIcon.png",
      // iconColor: "Colors.amber",
    ));

    _addSourceAndLineLayer(false);
  }

  final dbReference = FirebaseDatabase.instance
      .reference()
      .child('BUS ROUTES')
      .child("LOCATION");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        centerTitle: true,
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 40),
            if (user!.email! == "mskings117@gmail.com") ...[
              Text("You signed in as Incharger",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ] else ...[
              Text("You signed in as Student",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ],
            SizedBox(height: 8),
            Text(user!.email!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: Icon(
                  Icons.arrow_back,
                  size: 32,
                ),
                label: Text("Sign Out", style: TextStyle(fontSize: 20)))
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: MapboxMap(
                accessToken:
                    'pk.eyJ1IjoibW9oZHNhbGVlbSIsImEiOiJjbDRtZHp2bmQwY2xvM2JxdXZheWRyOHJpIn0.7BzUfwdDr6UKxL-aJs2gKw',
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                minMaxZoomPreference: const MinMaxZoomPreference(14, 18),
              ),
            ),
            // snapshot.value['name']
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: carouselCard(
                  context, carouselData['distance'], carouselData['duration']),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 30,
            bottom: 10,
            child: FloatingActionButton(
              heroTag: 'my_location',
              tooltip: 'My location',
              onPressed: () {
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(_initialCameraPosition));
              },
              child: const Icon(
                Icons.my_location,
                size: 30,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 30,
            child: FloatingActionButton(
              tooltip: 'Bus location',
              heroTag: 'destination_location',
              onPressed: () {
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(_kDestinationsList));
                setState(() {});
              },
              child: const Icon(
                Icons.share_location,
                size: 30,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
