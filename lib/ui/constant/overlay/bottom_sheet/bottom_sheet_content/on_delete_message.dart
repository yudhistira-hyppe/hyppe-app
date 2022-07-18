import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/message_v2/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnDeleteMessageBottomSheet extends StatelessWidget {
  final _notifier = MessageNotifier();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<MessageNotifier>(builder: (_, notifier, __) => Padding(padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0), child: Column()));

    return ChangeNotifierProvider<MessageNotifier>(
      create: (context) => _notifier,
      child: Consumer<MessageNotifier>(
        builder: (_, notifier, __) => Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
                child: Column(
                  children: [
                    const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
                    SizedBox(height: 16 * SizeConfig.scaleDiagonal),
                    Text("${notifier.choosedisqusID}"),
                    Text("${notifier.choosePhotoReceiver}"),
                    Row(
                      children: [
                        StoryColorValidator(
                          featureType: FeatureType.other,
                          // haveStory: notifier.isHaveStory,
                          haveStory: false,
                          child: CustomProfileImage(
                            width: 35,
                            height: 35,
                            following: true,
                            imageUrl: notifier.choosePhotoReceiver,
                            // imageUrl:
                            //     notifier.photoUrl!.endsWith(JPG) || notifier.photoUrl!.endsWith(JPEG) ? notifier.photoUrl! : notifier.photoUrl! + SMALL,
                          ),
                        ),
                        sixteenPx,
                        // CustomRichTextWidget(
                        //   textSpan: TextSpan(
                        //     style: Theme.of(context).textTheme.subtitle2,
                        //     text: "${notifier.argument.usernameReceiver}\n",
                        //     children: <TextSpan>[
                        //       TextSpan(
                        //         text: notifier.argument.fullnameReceiver,
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           color: Theme.of(context).colorScheme.secondaryVariant,
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        //   textAlign: TextAlign.start,
                        //   textStyle: Theme.of(context).textTheme.overline,
                        // ),
                      ],
                    ),
                    // CustomTextWidget(
                    //   textToDisplay: notifier2.translate.about!,
                    //   textStyle: Theme.of(context).textTheme.headline6,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // SizeConfig().init(context);
    // return Consumer2<MessageNotifier, TranslateNotifierV2>(
    //   builder: (_, notifier, notifier2, __) => Column(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //     children: [
    //       const Text('asdasd')
    //       // Expanded(
    //       //   flex: 2,
    //       //   child: Padding(
    //       //     padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
    //       //     child: Column(
    //       //       children: [
    //       //         const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
    //       //         SizedBox(height: 16 * SizeConfig.scaleDiagonal),
    //       //         CustomTextWidget(
    //       //           textToDisplay: notifier.language.postTo!,
    //       //           textStyle: Theme.of(context).textTheme.headline6,
    //       //         ),
    //       //       ],
    //       //     ),
    //       //   ),
    //       // ),
    //       // Expanded(
    //       //   flex: 10,
    //       //   child: ListView(
    //       //     children: [
    //       //       ListTile(
    //       //         visualDensity: VisualDensity.adaptivePlatformDensity,
    //       //         onTap: () {
    //       //           // notifier.thumbnailLocalMedia();
    //       //           notifier.featureType = FeatureType.story;
    //       //           notifier.selectedDuration = 15;
    //       //           Routing().moveAndPop(Routes.makeContent);
    //       //         },
    //       //         dense: true,
    //       //         title: CustomTextWidget(
    //       //           textToDisplay: "HyppeStory".toLowerCase(),
    //       //           textAlign: TextAlign.start,
    //       //           textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
    //       //         ),
    //       //         subtitle: CustomTextWidget(
    //       //           textToDisplay: notifier.language.hyppeStoryCaption!,
    //       //           textAlign: TextAlign.start,
    //       //           textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
    //       //         ),
    //       //         leading: CustomIconWidget(
    //       //           iconData: "${AssetPath.vectorPath}story.svg",
    //       //           height: 27 * SizeConfig.scaleDiagonal,
    //       //           width: 27 * SizeConfig.scaleDiagonal,
    //       //           defaultColor: false,
    //       //         ),
    //       //         minLeadingWidth: 20,
    //       //       ),
    //       //       Divider(thickness: 1, color: Theme.of(context).dividerColor),
    //       //       ListTile(
    //       //         visualDensity: VisualDensity.adaptivePlatformDensity,
    //       //         onTap: () {
    //       //           // notifier.thumbnailLocalMedia();
    //       //           notifier.featureType = FeatureType.vid;
    //       //           notifier.isVideo = true;
    //       //           notifier.selectedDuration = 15;
    //       //           Routing().moveAndPop(Routes.makeContent);
    //       //         },
    //       //         dense: true,
    //       //         title: CustomTextWidget(
    //       //           textToDisplay: "HyppeVid".toLowerCase(),
    //       //           textAlign: TextAlign.start,
    //       //           textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
    //       //         ),
    //       //         subtitle: CustomTextWidget(
    //       //           textToDisplay: notifier.language.hyppeVidCaption!,
    //       //           textAlign: TextAlign.start,
    //       //           textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
    //       //         ),
    //       //         leading: CustomIconWidget(
    //       //           iconData: "${AssetPath.vectorPath}vid.svg",
    //       //           height: 27 * SizeConfig.scaleDiagonal,
    //       //           width: 27 * SizeConfig.scaleDiagonal,
    //       //           defaultColor: false,
    //       //         ),
    //       //         minLeadingWidth: 20,
    //       //       ),
    //       //       Divider(thickness: 1, color: Theme.of(context).dividerColor),
    //       //       ListTile(
    //       //         visualDensity: VisualDensity.adaptivePlatformDensity,
    //       //         onTap: () {
    //       //           // notifier.thumbnailLocalMedia();
    //       //           notifier.featureType = FeatureType.diary;
    //       //           notifier.isVideo = true;
    //       //           notifier.selectedDuration = 15;
    //       //           Routing().moveAndPop(Routes.makeContent);
    //       //         },
    //       //         dense: true,
    //       //         title: CustomTextWidget(
    //       //           textToDisplay: "HyppeDiary".toLowerCase(),
    //       //           textAlign: TextAlign.start,
    //       //           textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
    //       //         ),
    //       //         subtitle: CustomTextWidget(
    //       //           textToDisplay: notifier.language.hyppeDiaryCaption!,
    //       //           textAlign: TextAlign.start,
    //       //           textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
    //       //         ),
    //       //         leading: CustomIconWidget(
    //       //           iconData: "${AssetPath.vectorPath}diary.svg",
    //       //           height: 27 * SizeConfig.scaleDiagonal,
    //       //           width: 27 * SizeConfig.scaleDiagonal,
    //       //           defaultColor: false,
    //       //         ),
    //       //         minLeadingWidth: 20,
    //       //       ),
    //       //       Divider(thickness: 1, color: Theme.of(context).dividerColor),
    //       //       ListTile(
    //       //         visualDensity: VisualDensity.adaptivePlatformDensity,
    //       //         onTap: () {
    //       //           // notifier.thumbnailLocalMedia();
    //       //           notifier.featureType = FeatureType.pic;
    //       //           notifier.isVideo = false;
    //       //           notifier.selectedDuration = 15;
    //       //           Routing().moveAndPop(Routes.makeContent);
    //       //         },
    //       //         dense: true,
    //       //         minLeadingWidth: 20,
    //       //         title: CustomTextWidget(
    //       //           textToDisplay: "HyppePic".toLowerCase(),
    //       //           textAlign: TextAlign.start,
    //       //           textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
    //       //         ),
    //       //         subtitle: CustomTextWidget(
    //       //           textToDisplay: notifier.language.hyppePicCaption!,
    //       //           textAlign: TextAlign.start,
    //       //           textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
    //       //         ),
    //       //         leading: CustomIconWidget(
    //       //           iconData: "${AssetPath.vectorPath}pic.svg",
    //       //           height: 27 * SizeConfig.scaleDiagonal,
    //       //           width: 27 * SizeConfig.scaleDiagonal,
    //       //           defaultColor: false,
    //       //         ),
    //       //       ),
    //       //     ],
    //       //   ),
    //       // )
    //     ],
    //   ),
    // );
  }
}
