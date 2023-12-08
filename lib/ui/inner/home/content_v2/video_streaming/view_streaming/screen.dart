import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_livepush_plugin/live_pusher_preview.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [],
          ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
