import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(builder: (context) {
        return Material(
            color: Colors.transparent, child: Align(alignment: Alignment.center, child: Container(height: 200.0, width: 250.0, color: Colors.white, child: Center(child: Text('Testing')))));
      }),
    );
    return Container(
      color: Colors.transparent,
      height: SizeConfig.screenHeight! * 0.8,
      width: SizeConfig.screenWidth,
      child: Stack(
        children: [
          // Positioned.fill(
          //   child: Material(
          //     color: Colors.transparent,
          //     child: InkWell(
          //       onTap: () async {
          //         print(isProcessing);
          //         if (!isProcessing) {
          //           setState(() {
          //             isProcessing = true;
          //           });
          //           await widget.onTap().whenComplete(() => isProcessing = false);
          //         }
          //       },
          //       child: Container(
          //         alignment: Alignment.center,
          //         decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
          //         padding: const EdgeInsets.all(20),
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
              bottom: 24,
              right: 16,
              left: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: context.getColorScheme().onBackground),
                  child: CustomTextWidget(
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    textToDisplay: widget.message,
                    textStyle: context.getTextTheme().bodySmall?.copyWith(color: context.getColorScheme().background, fontWeight: FontWeight.w400),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
