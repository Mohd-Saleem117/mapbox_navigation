// ignore_for_file: prefer_const_constructors

import 'chatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AvailableChats extends StatefulWidget {
  // final List<Map<String, dynamic>> chatList;
  // final String userId;
  const AvailableChats({Key? key}) : super(key: key);

  @override
  State<AvailableChats> createState() => _AvailableChatsState();
}

class _AvailableChatsState extends State<AvailableChats> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Stream<List<ChatList>> readChatList() =>
        _firestore.collection('chatList').snapshots().map((snapshot) =>
            snapshot.docs.map((doc) => ChatList.fromJson(doc.data())).toList());

    Widget buildChatList(ChatList chatlist) {
      Map<String, dynamic>? userMap;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade600, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            onTap: () async {
              print("came");
              await _firestore
                  .collection('users')
                  .where("uid", isEqualTo: chatlist.userId.toString())
                  .get()
                  .then((value) {
                setState(() {
                  userMap = value.docs[0].data();
                });
                print(userMap);

                // userMap = null;
              });
              print("-----------------------1" + chatlist.userId.toString());
              print("-----------------------" + chatlist.chatId.toString());
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoom(
                    chatRoomId: chatlist.chatId.toString(),
                    userMap: userMap!,
                  ),
                ),
              );
            },
            leading: Icon(
              Icons.account_circle_rounded,
            ),
            title: Text(
              chatlist.userName.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              Icons.chat,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Recent Chats"),
      ),
      body: StreamBuilder<List<ChatList>>(
          stream: readChatList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final chatlist = snapshot.data!;
              return ListView(
                children: chatlist.map(buildChatList).toList(),
              );
            } else {
              return Text("loading");
            }
          }),
    );
  }
}

class ChatList {
  String? chatId;
  String? userId;
  String? userName;

  ChatList({
    required this.chatId,
    required this.userId,
    required this.userName,
  });

  Map<String, dynamic> toJson() => {
        "chatId": chatId,
        "userId": userId,
        "userName": userName,
      };

  static ChatList fromJson(Map<String, dynamic> json) => ChatList(
        chatId: json['chatId'],
        userId: json['userId'],
        userName: json['userName'],
      );
}
