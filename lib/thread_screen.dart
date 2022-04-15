import 'package:flutter/material.dart';

class ThreadScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ThreadScreenState();
}

class ThreadScreenState extends State<ThreadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thread"),
      ),
    );
  }
}
