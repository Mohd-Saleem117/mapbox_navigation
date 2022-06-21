// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GlobalSnackBar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static showsnackbar(String? message) {
    if (message == null) return null;

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 5),
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
