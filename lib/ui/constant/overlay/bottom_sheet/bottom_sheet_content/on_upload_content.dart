import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnUploadContentBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<MakeContentNotifier>(
      builder: (_, notifier, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
              child: Column(
                children: [
                  const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}handler.svg"),
                  SizedBox(height: 16 * SizeConfig.scaleDiagonal),
                  CustomTextWidget(
                    textToDisplay: notifier.language.postTo!,
                    textStyle: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: ListView(
              children: [
                ListTile(
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  onTap: () {
                    // notifier.thumbnailLocalMedia();
                    notifier.featureType = FeatureType.story;
                    notifier.selectedDuration = 15;
                    Routing().moveAndPop(Routes.makeContent);
                  },
                  dense: true,
                  title: CustomTextWidget(
                    textToDisplay: "HyppeStory".toLowerCase(),
                    textAlign: TextAlign.start,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  subtitle: CustomTextWidget(
                    textToDisplay: notifier.language.hyppeStoryCaption!,
                    textAlign: TextAlign.start,
                    textStyle:
                        const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
                  ),
                  leading: CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}story.svg",
                    height: 27 * SizeConfig.scaleDiagonal,
                    width: 27 * SizeConfig.scaleDiagonal,
                    defaultColor: false,
                  ),
                  minLeadingWidth: 20,
                ),
                Divider(thickness: 1, color: Theme.of(context).dividerColor),
                ListTile(
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  onTap: () {
                    // notifier.thumbnailLocalMedia();
                    notifier.featureType = FeatureType.vid;
                    notifier.isVideo = true;
                    notifier.selectedDuration = 15;
                    Routing().moveAndPop(Routes.makeContent);
                  },
                  dense: true,
                  title: CustomTextWidget(
                    textToDisplay: "HyppeVid".toLowerCase(),
                    textAlign: TextAlign.start,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  subtitle: CustomTextWidget(
                    textToDisplay: notifier.language.hyppeVidCaption!,
                    textAlign: TextAlign.start,
                    textStyle:
                        const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
                  ),
                  leading: CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}vid.svg",
                    height: 27 * SizeConfig.scaleDiagonal,
                    width: 27 * SizeConfig.scaleDiagonal,
                    defaultColor: false,
                  ),
                  minLeadingWidth: 20,
                ),
                Divider(thickness: 1, color: Theme.of(context).dividerColor),
                ListTile(
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  onTap: () {
                    // notifier.thumbnailLocalMedia();
                    notifier.featureType = FeatureType.diary;
                    notifier.isVideo = true;
                    notifier.selectedDuration = 15;
                    Routing().moveAndPop(Routes.makeContent);
                  },
                  dense: true,
                  title: CustomTextWidget(
                    textToDisplay: "HyppeDiary".toLowerCase(),
                    textAlign: TextAlign.start,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  subtitle: CustomTextWidget(
                    textToDisplay: notifier.language.hyppeDiaryCaption!,
                    textAlign: TextAlign.start,
                    textStyle:
                        const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
                  ),
                  leading: CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}diary.svg",
                    height: 27 * SizeConfig.scaleDiagonal,
                    width: 27 * SizeConfig.scaleDiagonal,
                    defaultColor: false,
                  ),
                  minLeadingWidth: 20,
                ),
                Divider(thickness: 1, color: Theme.of(context).dividerColor),
                ListTile(
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  onTap: () {
                    // notifier.thumbnailLocalMedia();
                    notifier.featureType = FeatureType.pic;
                    notifier.isVideo = false;
                    notifier.selectedDuration = 15;
                    Routing().moveAndPop(Routes.makeContent);
                  },
                  dense: true,
                  minLeadingWidth: 20,
                  title: CustomTextWidget(
                    textToDisplay: "HyppePic".toLowerCase(),
                    textAlign: TextAlign.start,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  subtitle: CustomTextWidget(
                    textToDisplay: notifier.language.hyppePicCaption!,
                    textAlign: TextAlign.start,
                    textStyle:
                        const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
                  ),
                  leading: CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}pic.svg",
                    height: 27 * SizeConfig.scaleDiagonal,
                    width: 27 * SizeConfig.scaleDiagonal,
                    defaultColor: false,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
