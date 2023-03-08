import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class DiaryPlayerPage11 extends StatefulWidget {
  final ContentData? data;
  final PageController? controller;
  const DiaryPlayerPage11({super.key, this.data, this.controller});

  @override
  State<DiaryPlayerPage11> createState() => _DiaryPlayerPage11State();
}

class _DiaryPlayerPage11State extends State<DiaryPlayerPage11> {
  @override
  void initState() {
    super.initState();

    widget.controller?.addListener(() {
      print("${widget.controller?.page?.round()}");
    });

    print("${widget.controller?.position.userScrollDirection}");

    print('build ulang');
  }

  _listener() {
    if (widget.controller?.position.userScrollDirection == ScrollDirection.reverse) {
      print('swiped to right');
    } else {
      print('swiped to left');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text("asdasd");
  }
}
