// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

class DatabaseHelper {
  String? busLatitude;
  String? busLongitude;
  String? busStatus;
  String? name;

  DatabaseHelper({
    this.busLatitude,
    this.busLongitude,
    this.busStatus,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        "busLatitude": busLatitude,
        "busLongitude": busLongitude,
        "busStatus": busStatus,
        "name": name,
      };

  static DatabaseHelper fromJson(Map<String, dynamic> json) => DatabaseHelper(
        busLatitude: json['busLatitude'],
        busLongitude: json['busLongitude'],
        busStatus: json['busStatus'],
        name: json['name'],
      );
}
