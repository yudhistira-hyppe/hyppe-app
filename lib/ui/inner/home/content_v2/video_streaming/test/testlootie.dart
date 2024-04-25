import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:lottie/lottie.dart';

class TestLootie extends StatefulWidget {
  const TestLootie({super.key});

  @override
  State<TestLootie> createState() => _TestLootieState();
}

class _TestLootieState extends State<TestLootie> {
  List<String> animationPaths = [
    'https://ahmadtaslimfuadi07.github.io/jsonlottie/Ketapel.json',
    'https://ahmadtaslimfuadi07.github.io/jsonlottie/meditation.json',
    'https://ahmadtaslimfuadi07.github.io/jsonlottie/success.json',
    'https://ahmadtaslimfuadi07.github.io/jsonlottie/gerabah.json',

    // Add more animation paths as needed
  ];

  int currentAnimationIndex = 0;
  Timer? _timer;
  Timer? _time2;
  bool show = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _addArray();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _time2?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      print("$currentAnimationIndex -- ${animationPaths.length}");
      setState(() {
        if (currentAnimationIndex + 1 >= animationPaths.length) {
          show = false;
          _timer?.cancel();
        } else {
          currentAnimationIndex++;
        }
      });
    });
  }

  void _addArray() {
    _time2 = Timer.periodic(const Duration(seconds: 20), (timer) {
      print(timer);
      setState(() {
        if (currentAnimationIndex == 8) {
          _addManyArray();
        }
        animationPaths.add('https://ahmadtaslimfuadi07.github.io/jsonlottie/toboni2mb.json');
        currentAnimationIndex++;
        print(animationPaths.length);
        print(currentAnimationIndex);
        show = true;
        if (_timer?.isActive ?? false) {
        } else {
          _startTimer();
        }
      });
    });
  }

  void _addManyArray() {
    setState(() {
      animationPaths.add('https://ahmadtaslimfuadi07.github.io/jsonlottie/Ketapel.json');
      animationPaths.add('https://ahmadtaslimfuadi07.github.io/jsonlottie/Ayampadang.json');
      animationPaths.add('https://ahmadtaslimfuadi07.github.io/jsonlottie/Ketapel.json');
      animationPaths.add('https://ahmadtaslimfuadi07.github.io/jsonlottie/Ayampadang.json');
      animationPaths.add('https://ahmadtaslimfuadi07.github.io/jsonlottie/Ketapel.json');
      animationPaths.add('https://ahmadtaslimfuadi07.github.io/jsonlottie/Ayampadang.json');
      currentAnimationIndex++;
      print(animationPaths.length);
      print(currentAnimationIndex);
      show = true;
      if (_timer?.isActive ?? false) {
      } else {
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 196, 199, 201),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.grey,
                child: Transform.scale(
                  scale: 1,
                  child: !show
                      ? Container(
                          color: Colors.blue,
                        )
                      : Lottie.network(
                          animationPaths[currentAnimationIndex],
                          repeat: true,
                          width: SizeConfig.screenWidth,
                          height: SizeConfig.screenHeight,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
              // Text("timer ${_time2.tick.}"),
            ],
          ),
        ),
      ),
    );
  }
}
