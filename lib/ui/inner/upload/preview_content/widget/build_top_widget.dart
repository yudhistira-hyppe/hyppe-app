import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildTopWidget extends StatelessWidget {
  final GlobalKey? globalKey;
  const BuildTopWidget({Key? key, this.globalKey}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<PreviewContentNotifier>(
        builder: (context, notifier, child) => SafeArea(
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIconButtonWidget(
                  onPressed: () => notifier.onWillPop(context),
                  defaultColor: true,
                  iconData: "${AssetPath.vectorPath}back-arrow.svg",
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 81,
                    height: 30,
                    child: notifier.showNext
                        ? CustomTextButton(
                            child: CustomTextWidget(
                              textToDisplay: notifier.addTextItemMode ? (notifier.language.save ?? 'save') : notifier.featureType == FeatureType.story ? (notifier.language.post  ?? 'post') : (notifier.language.next ?? 'next'),
                              textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                              padding: MaterialStateProperty.all(const EdgeInsets.only(top: 0.0, bottom: 0.0)),
                            ),
                            onPressed: (){

                              if(notifier.addTextItemMode){
                                notifier.applyTextItem(globalKey);
                              }else if(notifier.featureType == FeatureType.story){
                                notifier.postStoryContent(context);
                              }else{
                                notifier.forceResetPlayer(true);
                                notifier.navigateToPreUploaded(context);
                              }
                            },)
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
