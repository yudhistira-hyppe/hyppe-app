import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ux/routing.dart';

import '../../../widget/custom_text_widget.dart';

class ToastAlert extends StatefulWidget {
  final String message;
  final Future<dynamic> Function() onTap;
  const ToastAlert({Key? key, required this.message, required this.onTap}) : super(key: key);

  @override
  _ToastAlert createState() => _ToastAlert();
}

class _ToastAlert extends State<ToastAlert> {
  var isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(seconds: 2), () {
        Routing().moveBack();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: SizeConfig.screenWidth,
                margin: const EdgeInsets.only(bottom: 30, right: 16, left: 16),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: context.getColorScheme().onBackground),
                child: CustomTextWidget(
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  textToDisplay: widget.message,
                  textStyle: context.getTextTheme().bodySmall?.copyWith(color: context.getColorScheme().background, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}