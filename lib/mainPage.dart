import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:mapbox_navigation/authentication/login.dart';
import 'package:mapbox_navigation/screens/home_management.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HomeManagement();
              } else {
                return Login();
              }
            }));
  }
}
