import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app.dart';

class OnUploadContentBottomSheet extends StatefulWidget {
  final bool isStory;
  final bool isPict;
  final bool isDiary;
  final bool isVid;
  const OnUploadContentBottomSheet({
    super.key,
    this.isDiary = true,
    this.isPict = true,
    this.isStory = true,
    this.isVid = true,
  });

  @override
  State<OnUploadContentBottomSheet> createState() => _OnUploadContentBottomSheetState();
}

class _OnUploadContentBottomSheetState extends State<OnUploadContentBottomSheet> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<MakeContentNotifier>(
      builder: (_, notifier, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
                sixteenPx,
                CustomTextWidget(
                  textToDisplay: notifier.language.postTo ?? '',
                  textStyle: Theme.of(context).textTheme.headline6,
                ),

                // Expanded(
                //   flex: 2,
                //   child: Padding(
                //     padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
                //     child: Column(
                //       children: [
                //         const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
                //         SizedBox(height: 16 * SizeConfig.scaleDiagonal),
                //         CustomTextWidget(
                //           textToDisplay: notifier.language.postTo ?? '',
                //           textStyle: Theme.of(context).textTheme.headline6,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    widget.isStory
                        ? Column(
                            children: [
                              ListTile(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                onTap: () async {
                                  // notifier.thumbnailLocalMedia();
                                  context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                                  notifier.featureType = FeatureType.story;
                                  notifier.selectedDuration = 15;
                                  final tempIsHome = isHomeScreen;
                                  if (tempIsHome) {
                                    isHomeScreen = false;
                                  }
                                  await Routing().moveAndPop(Routes.makeContent);
                                  if (tempIsHome) {
                                    isHomeScreen = true;
                                  }
                                },
                                dense: true,
                                title: CustomTextWidget(
                                  textToDisplay: "HyppeStory".toLowerCase(),
                                  textAlign: TextAlign.start,
                                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                subtitle: CustomTextWidget(
                                  textToDisplay: notifier.language.shareYourMoment ?? '',
                                  textAlign: TextAlign.start,
                                  textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
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
                            ],
                          )
                        : Container(),
                    widget.isVid
                        ? Column(
                            children: [
                              ListTile(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                onTap: () {
                                  context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                                  // notifier.thumbnailLocalMedia();
                                  notifier.featureType = FeatureType.vid;
                                  notifier.isVideo = true;
                                  notifier.selectedDuration = 15;
                                  final tempIsHome = isHomeScreen;
                                  if (tempIsHome) {
                                    isHomeScreen = false;
                                  }
                                  Routing().moveAndPop(Routes.makeContent);
                                  if (tempIsHome) {
                                    isHomeScreen = true;
                                  }
                                },
                                dense: true,
                                title: CustomTextWidget(
                                  textToDisplay: "HyppeVid".toLowerCase(),
                                  textAlign: TextAlign.start,
                                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                subtitle: CustomTextWidget(
                                  textToDisplay: notifier.language.shareWithUsYourCreatifity ?? '',
                                  textAlign: TextAlign.start,
                                  textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
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
                            ],
                          )
                        : Container(),
                    widget.isDiary
                        ? Column(
                            children: [
                              ListTile(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                onTap: () {
                                  context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                                  // notifier.thumbnailLocalMedia();
                                  notifier.featureType = FeatureType.diary;
                                  notifier.isVideo = true;
                                  notifier.selectedDuration = 15;
                                  final tempIsHome = isHomeScreen;
                                  if (tempIsHome) {
                                    isHomeScreen = false;
                                  }
                                  Routing().moveAndPop(Routes.makeContent);
                                  if (tempIsHome) {
                                    isHomeScreen = true;
                                  }
                                },
                                dense: true,
                                title: CustomTextWidget(
                                  textToDisplay: "HyppeDiary".toLowerCase(),
                                  textAlign: TextAlign.start,
                                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                subtitle: CustomTextWidget(
                                  textToDisplay: notifier.language.howAreYouToday ?? '',
                                  textAlign: TextAlign.start,
                                  textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
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
                            ],
                          )
                        : Container(),
                    widget.isPict
                        ? ListTile(
                            visualDensity: VisualDensity.adaptivePlatformDensity,
                            onTap: () {
                              context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                              // notifier.thumbnailLocalMedia();
                              notifier.featureType = FeatureType.pic;
                              notifier.isVideo = false;
                              notifier.selectedDuration = 15;
                              final tempIsHome = isHomeScreen;
                              if (tempIsHome) {
                                isHomeScreen = false;
                              }
                              Routing().moveAndPop(Routes.makeContent);
                              if (tempIsHome) {
                                isHomeScreen = true;
                              }
                              // Future.delayed(const Duration(seconds: 1), (){
                              //   Routing().moveAndPop(Routes.makeContent);
                              //   if(tempIsHome){
                              //     isHomeScreen = true;
                              //   }
                              // });
                            },
                            dense: true,
                            minLeadingWidth: 20,
                            title: CustomTextWidget(
                              textToDisplay: "HyppePic".toLowerCase(),
                              textAlign: TextAlign.start,
                              textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            subtitle: CustomTextWidget(
                              textToDisplay: notifier.language.captureYourMoment ?? '',
                              textAlign: TextAlign.start,
                              textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
                            ),
                            leading: CustomIconWidget(
                              iconData: "${AssetPath.vectorPath}pic.svg",
                              height: 27 * SizeConfig.scaleDiagonal,
                              width: 27 * SizeConfig.scaleDiagonal,
                              defaultColor: false,
                            ),
                          )
                        : Container(),
                    thirtyTwoPx,
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
