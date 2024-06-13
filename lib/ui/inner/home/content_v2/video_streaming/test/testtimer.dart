import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class TestTimer extends StatefulWidget {
  const TestTimer({super.key});

  @override
  State<TestTimer> createState() => _TestTimerState();
}

class _TestTimerState extends State<TestTimer> {
  List data = [];
  List dataTemp = [];

  Timer? _timer;
  int _start = 3;
  int variabel = 0;

  @override
  void initState() {
    super.initState();
  }

  void tapFunction() {
    print('variabel $_start $variabel');
    setState(() {
      variabel++;
    });
    print('variabel ${data.isEmpty} |||| $data --- $_start $variabel');

    if (data.isEmpty) {
      _start = 3;
      data.add(variabel);
      startTimer();
    } else {
      dataTemp.add(variabel);
    }
  }

  void addData() {}

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) async {
      if (_start == 0) {
        data = [];
        if (dataTemp.isNotEmpty) {
          data.add(dataTemp[0]);
          dataTemp.removeAt(0);
          _start = 3;
          setState(() {});
        } else {
          setState(() {
            timer.cancel();
          });
        }
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            twentyFourPx,
            GestureDetector(
                onTap: () {
                  print("=========hahahah");
                  tapFunction();
                },
                child: Text("sentuh aku ")),
            twentyFourPx,
            Text("Timer $_start"),
            if (data.isNotEmpty) Text("variabel ${data[0]}"),
          ],
        ),
      ),
    );
  }
}
