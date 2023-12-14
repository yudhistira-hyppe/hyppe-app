import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';

class PauseLive extends StatelessWidget {
  const PauseLive({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: ClipRect(
        child: new BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: new Container(
            width: 200.0,
            height: 200.0,
            decoration: new BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: new Center(
              child: new Text('Frosted'),
            ),
          ),
        ),
      ),
    );
  }
}
