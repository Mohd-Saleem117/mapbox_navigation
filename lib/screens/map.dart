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

List<Map> destinationLocation = [
  {
    'routeName': 'BUS NO. 21',
    'latitude': '17.42396',
    'longitude': '78.504317',
  }
];

class _sampleMapState extends State<sampleMap> {
  String _name = "";
  String _lat = "";
  String _lon = "";
  final dbref = FirebaseDatabase.instance.reference();
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

  // List<Map> dLoc = [
  //   {
  //     'routeName': 'loki',
  //     'coordinates': {
  //       'latitude': '17.2345',
  //       'longitude': '78.22222',
  //     }
  //   }
  // ];

  // Carousel related
  int pageIndex = 0;
  late List<Widget> carouselItems;

  @override
  void initState() {
    super.initState();
    _activateListeners();

    // DestinationLocation();

    // dbref
    //     .child("BUS ROUTES")
    //     .child("LOCATION")
    //     .child("busLatitude")
    //     .onValue
    //     .listen((event) {
    //   lat = event.snapshot.value.toString();
    //   // destinationLocation.update('latitude', lat);
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

    destinationLocation[0].update('routeName', (value) => _name);
    destinationLocation[0].update('latitude', (value) => _lat);
    destinationLocation[0].update('longitude', (value) => _lon);
    print("Hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" +
        destinationLocation[0]['routeName']);

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
  }

  void _activateListeners() {
    dbref
        .child("BUS ROUTES")
        .child("LOCATION")
        .child("busLatitude")
        .onValue
        .listen((event) {
      String lati = event.snapshot.value.toString();
      print("Hiiii-----------------" + lati);
      setState(() {
        _lat = lati;
      });
    });

    dbref
        .child("BUS ROUTES")
        .child("LOCATION")
        .child("busLongitude")
        .onValue
        .listen((event) {
      String longi = event.snapshot.value.toString();
      print("Hiiiii-----------------" + longi);
      setState(() {
        _lon = longi;
      });
    });

    dbref
        .child("BUS ROUTES")
        .child("LOCATION")
        .child("name")
        .onValue
        .listen((event) {
      setState(() {});
      String busName = event.snapshot.value.toString();
      print("Hiiii--------------------" + busName);
      setState(() {
        _name = busName;
      });
    });

    // setState(() {
    //   destinationLocation[0].update('routeName', (value) => _name);
    //   destinationLocation[0].update('latitude', (value) => _lat);
    //   destinationLocation[0].update('longitude', (value) => _lon);
    //   print("Hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" +
    //       destinationLocation[0]['routeName']);
    // });
  }

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
        title: Text('Map $_name'),
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

                        // print("12345678910" + _name);
                        // destinationLocation[0]['routeName'] = _name;
                        // destinationLocation[0]['latitude'] = _lat;
                        // destinationLocation[0]['longitude'] = _lon;
                      });
                      _addSourceAndLineLayer(index, true);
                    })),
          ),
        ],
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 30,
            bottom: 10,
            child: FloatingActionButton(
              heroTag: 'my_location',
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
              heroTag: 'destination_location',
              onPressed: () {
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(_kDestinationsList[0]));
                // print("-------------" +
                //     _name +
                //     "---------------" +
                //     _lat +
                //     "------------" +
                //     _lon);
                setState(() {
                  // destinationLocation[0]['routeName'] = _name;
                  // destinationLocation[0]['latitude'] = _lat;
                  // destinationLocation[0]['longitude'] = _lon;
                  // destinationLocation.add({
                  //   'routeName': _name,
                  //   'latitude': _lat,
                  //   'longitude': _lon,
                  // });
                  // destinationLocation[0].update('routeName', (value) => _name);
                  // destinationLocation[0].update('latitude', (value) => _lat);
                  // destinationLocation[0].update('longitude', (value) => _lon);
                  // print("Hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" +
                  //     destinationLocation[0]['routeName']);
                });
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
