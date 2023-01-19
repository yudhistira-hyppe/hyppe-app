import 'package:flutter/widgets.dart';

mixin AfterFirstLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(mounted){
        afterFirstLayout(context);
      }
    });
  }

  void afterFirstLayout(BuildContext context);
}
