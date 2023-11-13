import 'package:flutter/material.dart';

import '../../../../constant/widget/custom_spacer.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../notifier.dart';

class BuildNextStep extends StatelessWidget {
  final MakeContentNotifier? notifier;
  const BuildNextStep({Key? key, this.notifier}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnable = (notifier?.elapsedProgress ?? 0) > 15;
    final background = isEnable ? Colors.white : const Color(0xffCECECE);
    final textColor = isEnable ? Colors.black : Colors.white;
    return GestureDetector(
      onTap: (){
        if(isEnable){
          notifier?.clearPreviewVideo(goView: true);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomTextWidget(
              textToDisplay: notifier?.language.next ?? 'Next',
              textStyle:  TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w700),),
            fourPx,
            Icon(Icons.arrow_forward_ios, size: 16, color: textColor,)
          ],
        ),
      ),
    );
  }
}
