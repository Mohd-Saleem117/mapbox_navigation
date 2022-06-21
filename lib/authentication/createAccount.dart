// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_navigation/helpers/snackbar.dart';
import 'package:mapbox_navigation/main.dart';
import 'package:email_validator/email_validator.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

bool invisible = true;

class _CreateAccountState extends State<CreateAccount> {
  final formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final verifyPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  SizedBox(
                    height: 64,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    cursorColor: Colors.black87,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    cursorColor: Colors.black87,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Mail id',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                            : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    cursorColor: Colors.black87,
                    textInputAction: TextInputAction.next,
                    obscureText: invisible,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: GestureDetector(
                        child: Icon(
                          Icons.remove_red_eye,
                        ),
                        onTapDown: inContact, //call this method when incontact
                        onTapUp:
                            outContact, //call this method when contact with screen is removed
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length < 6
                        ? 'Password length must be greater than 5'
                        : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: verifyPasswordController,
                    cursorColor: Colors.black87,
                    textInputAction: TextInputAction.done,
                    obscureText: invisible,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Verify Password',
                      suffixIcon: GestureDetector(
                        child: Icon(
                          Icons.remove_red_eye,
                        ),
                        onTapDown: inContact, //call this method when incontact
                        onTapUp:
                            outContact, //call this method when contact with screen is removed
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length < 6
                        ? 'Password length must be greater than 5'
                        : null,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: createAccount,
                      icon: Icon(Icons.lock_open),
                      label: Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text("Already have an account?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text("Login",
                        style: TextStyle(fontSize: 20, color: Colors.blue)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void inContact(TapDownDetails details) {
    setState(() {
      invisible = false;
    });
  }

  void outContact(TapUpDetails details) {
    setState(() {
      invisible = true;
    });
  }

  Future<User?> createAccount() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final isValid = formkey.currentState!.validate();
    if (!isValid) return null;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()));

    if (passwordController.text.trim() ==
        verifyPasswordController.text.trim()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim());
        print("------------------Account Created Successfull");

        userCredential.user!.updateDisplayName(nameController.text.trim());

        await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "uid": _auth.currentUser!.uid,
          "status": "Offline",
        });
        // Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        print("-----------------An error occurred");
        print(e);

        GlobalSnackBar.showsnackbar(e.message);
      }
    } else {
      GlobalSnackBar.showsnackbar('Check Your Password');
      print("Check Your Password");
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
