import 'package:flutter/widgets.dart';
import 'package:hyppe/app.dart';

mixin AfterFirstLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => afterFirstLayout(materialAppKey.currentContext!));
  }

  void afterFirstLayout(BuildContext context);
}
