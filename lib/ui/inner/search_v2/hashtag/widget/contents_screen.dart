import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';

class HashtagContentsScreen extends StatefulWidget {
  final HyppeType type;
  const HashtagContentsScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<HashtagContentsScreen> createState() => _HashtagContentsScreenState();
}

class _HashtagContentsScreenState extends State<HashtagContentsScreen> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HashtagContentsScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fixType = widget.type;
    switch(fixType){
      case HyppeType.HyppeVid:
        return Center(
          child: Text(System().getTitleHyppe(fixType)),
        );
      case HyppeType.HyppeDiary:
        return Center(
          child: Text(System().getTitleHyppe(fixType)),
        );
      case HyppeType.HyppePic:
        return Center(
          child: Text(System().getTitleHyppe(fixType)),
        );
    }
  }
}
