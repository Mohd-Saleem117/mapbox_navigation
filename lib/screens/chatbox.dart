import 'package:flutter/material.dart';

class chatBox extends StatefulWidget {
  const chatBox({Key? key}) : super(key: key);

  @override
  State<chatBox> createState() => _chatBoxState();
}

class _chatBoxState extends State<chatBox> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat Box"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Chatting or Emergency needs"), Text("In Progress")],
        ),
      ),
    );
  }
}
