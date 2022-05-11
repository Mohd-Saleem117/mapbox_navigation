// ignore_for_file: deprecated_member_use, avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_navigation/constants/destinationLocation.dart';
import 'package:mapbox_navigation/helpers/commons.dart';
import 'package:mapbox_navigation/helpers/shared_prefs.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../widgets/carousel_card.dart';

class sampleMap extends StatefulWidget {
  const sampleMap({Key? key}) : super(key: key);

  @override
  State<sampleMap> createState() => _sampleMapState();
}

class _sampleMapState extends State<sampleMap> {
  // late final dref = FirebaseDatabase.instance.reference();
  late DatabaseReference dbref;
  // String databasejson = "";

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
  late List<CameraPosition> _kDestinationsList;
  List<Map> carouselData = [];

  List<Map> dLoc = [
    {
      'routeName': 'loki',
      'coordinates': {
        'latitude': '17.2345',
        'longitude': '78.22222',
      }
    }
  ];
  String name = "";
  String lat = "";
  String lon = "";

  // Carousel related
  int pageIndex = 0;
  late List<Widget> carouselItems;

  @override
  void initState() {
    super.initState();
    DestinationLocation();
    // dbref = FirebaseDatabase.instance.reference();

    // dbref
    //     .child("BUS ROUTES")
    //     .child("LOCATION")
    //     .child("busLatitude")
    //     .onValue
    //     .listen((event) {
    //   lat = event.snapshot.value.toString();
    //   print("Hiiii-----------------" + event.snapshot.value.toString());
    // });
    // dbref
    //     .child("BUS ROUTES")
    //     .child("LOCATION")
    //     .child("busLongitude")
    //     .onValue
    //     .listen((event) {
    //   lon = event.snapshot.value.toString();
    //   print("Hiiiii-----------------" + lon);
    // });

    // dbref
    //     .child("BUS ROUTES")
    //     .child("LOCATION")
    //     .child("name")
    //     .onValue
    //     .listen((event) {
    //   setState(() {});
    //   name = event.snapshot.value.toString();
    //   print("Hiiii--------------------" + name);
    // });

    _initialCameraPosition = CameraPosition(target: latlng, zoom: 15);

    // Calculate the distance and time from data in SharedPreferences
    num distance = getDistanceFromSharedPrefs(0) / 1000;
    num duration = getDurationFromSharedPrefs(0) / 60;

    carouselData.add({'index': 0, 'distance': distance, 'duration': duration});

    // Generate the list of carousel widgets
    carouselItems = List<Widget>.generate(
        destinationLocation.length,
        (index) => carouselCard(carouselData[index]['index'],
            carouselData[index]['distance'], carouselData[index]['duration']));

    // initialize map symbols in the same order as carousel widgets
    _kDestinationsList = List<CameraPosition>.generate(
        destinationLocation.length,
        (index) => CameraPosition(
            target: getLatLngFromDestinationData(carouselData[index]['index']),
            zoom: 15));

    // setState(() {
    //   dLoc = [
    //     {
    //       'routeName': name,
    //       'coordinates': {
    //         'latitude': lat,
    //         'longitude': lon,
    //       }
    //     }
    //   ];
    //   print("===========================" + dLoc[0]['routeName']);
    // });
    // addToDB();
  }

  // addToDB() {
  //   setState(() {
  //     print("===========================" +
  //         dLoc[0]['coordinates']['latitude'] +
  //         "================" +
  //         name);
  //     dLoc[0]['routeName'] = name;
  //   });
  // }

  _addSourceAndLineLayer(int index, bool removeLayer) async {
    // print("------------------$name-----------------");
    // Can animate camera to focus on the item
    controller.animateCamera(
        CameraUpdate.newCameraPosition(_kDestinationsList[index]));

    // Add a polyLine between source and destination
    Map geometry = getGeometryFromSharedPrefs(carouselData[index]['index']);
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
    for (CameraPosition _kDestination in _kDestinationsList) {
      await controller.addSymbol(SymbolOptions(
        geometry: _kDestination.target,
        iconSize: 0.2,
        iconImage: "assets/icon/busIcon.png",
        // iconColor: "Colors.amber",
      ));
    }
    _addSourceAndLineLayer(0, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map $name'),
        actions: [
          TextButton(onPressed: showData, child: Text("ShowData")),
          TextButton(onPressed: showOneChild, child: Text("ShowOneChild"))
        ],
      ),
      body: SafeArea(
          child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: MapboxMap(
              accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN'],
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoadedCallback,
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
              minMaxZoomPreference: const MinMaxZoomPreference(14, 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: CarouselSlider(
                items: carouselItems,
                options: CarouselOptions(
                    height: 50,
                    viewportFraction: 0.6,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    // scrollDirection: Axis.horizontal,
                    onPageChanged:
                        (int index, CarouselPageChangedReason reason) {
                      setState(() {
                        pageIndex = index;
                      });
                      _addSourceAndLineLayer(index, true);
                    })),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.animateCamera(
              CameraUpdate.newCameraPosition(_initialCameraPosition));
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
