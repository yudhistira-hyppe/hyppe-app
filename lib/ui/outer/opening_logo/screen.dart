import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/initial/hyppe/notifier.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class OpeningLogo extends StatefulWidget {
  @override
  _OpeningLogoState createState() => _OpeningLogoState();
}

class _OpeningLogoState extends State<OpeningLogo> {
  @override
  void initState() {
    final _notifier = Provider.of<HyppeNotifier>(context, listen: false);
    Timer(Duration.zero, () async => await _notifier.handleStartUp(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CustomIconWidget(
          defaultColor: false,
          iconData: '${AssetPath.vectorPath}logo.svg',
        ),
      ),
    );
  }
}
