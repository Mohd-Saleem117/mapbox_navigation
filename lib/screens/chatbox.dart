// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_navigation/screens/AvailableChats.dart';
import 'package:mapbox_navigation/screens/chatRoom.dart';
import 'package:uuid/uuid.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({Key? key}) : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isloading = false;
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final searchController = TextEditingController();

  List<Map<String, dynamic>> chatList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("online");
    // getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        chatList.add({
          "name": map["name"],
          "email": map["email"],
          "uid": map["uid"],
          "isAdmin": true,
        });
      });
      print("================" + chatList[0]['name']);
    });
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1.toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isloading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: searchController.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isloading = false;
      });
      searchController.clear();
      print(userMap);

      // userMap = null;
    });
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = _firestore.collection('chatList');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }

  Future onResultTap(chatId) async {
    bool docExists = await checkIfDocExists(chatId);
    print(docExists);

    if (!docExists) {
      createChat(chatId);
      return true;
    } else {
      print("Already Exist Chat");
      return false;
    }
  }

  void createChat(chatId) async {
    bool docExists = await checkIfDocExists(chatId);
    print(docExists);
    if (!docExists) {
      await _firestore.collection('chatList').doc(chatId).set({
        "chatId": chatId,
        "userId": userMap!['uid'],
        "userName": userMap!["name"],
      });
      print("[[[[[[[[[[" + userMap!['uid']);
      print("Chat created successfully");
    } else {
      print("Already Exist Chat");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Box"),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              cursorColor: Colors.black87,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            isloading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ElevatedButton(
                    onPressed: onSearch,
                    child: Text(
                      "Search",
                    )),
            SizedBox(
              height: 20,
            ),
            userMap != null
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade600, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      onTap: () async {
                        print("-----------" + userMap!['uid']);
                        print("===========" + _auth.currentUser!.uid);
                        String roomId =
                            chatRoomId(_auth.currentUser!.uid, userMap!['uid']);
                        print("----------------------------Room id " + roomId);

                        createChat(roomId);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatRoom(
                              chatRoomId: roomId,
                              userMap: userMap!,
                            ),
                          ),
                        );
                      },
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.account_circle_rounded,
                        ),
                      ),
                      title: Text(userMap!['name'],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(userMap!['email']),
                      trailing: Icon(
                        Icons.chat,
                      ),
                    ),
                  )
                : Container(
                    child: Center(
                        child:
                            Text("Please search the user by their Email Id")),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.select_all_rounded),
        onPressed: () {
          // print(chatList[0]["chatId"]);
          print("Successful");

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AvailableChats(),
            ),
          );
        },
        tooltip: "Recent Chats",
      ),
    );
  }
}
