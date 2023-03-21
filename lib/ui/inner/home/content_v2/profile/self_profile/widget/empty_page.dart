import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'EmptyWidget');
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        children: <Widget>[
          Expanded(
              child: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<TranslateNotifierV2>(
                  builder: (_, notifier, __) => CustomTextWidget(
                    textToDisplay: notifier.translate.youDontHaveAnyPostsYetCreateOneNow ?? '',
                    maxLines: 2,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => ShowBottomSheet.onUploadContent(context),
                      child: const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}add-content.svg",
                        defaultColor: false,
                      ),
                    ))
              ],
            ),
          )),
        ],
      ),
    );
  }
}
