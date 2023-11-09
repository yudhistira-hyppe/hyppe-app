import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class EmptyOtherWidget extends StatelessWidget {
  const EmptyOtherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    FirebaseCrashlytics.instance.setCustomKey('layout', 'EmptyOtherWidget');
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        children: <Widget>[
          Expanded(
              child: SizedBox(
            // width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  textToDisplay: tn.translate.noPostsYet ?? '',
                  maxLines: 2,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                eightPx,
                CustomTextWidget(
                  textToDisplay: tn.translate.thisAccountHasNoPostsYet ?? '',
                  maxLines: 2,
                  textStyle: const TextStyle(color: kHyppeSecondary),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
