import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../constant/widget/custom_profile_image.dart';

class StoryTutor extends StatefulWidget {
  const StoryTutor({Key? key}) : super(key: key);

  @override
  _StoryTutorState createState() => _StoryTutorState();
}

class _StoryTutorState extends State<StoryTutor> {
  List storyData = [
    {
      'user': 'a',
      'image': "${AssetPath.pngPath}tutorstory1.png",
    },
    {
      'user': 'nataliajonson',
      'image': "${AssetPath.pngPath}tutorstory2.png",
    },
    {
      'user': 'herlambada',
      'image': "${AssetPath.pngPath}tutorstory3.png",
    },
    {
      'user': 'nadinherlianto',
      'image': "${AssetPath.pngPath}tutorstory4.png",
    },
    {
      'user': 'michaeljiraya20',
      'image': "${AssetPath.pngPath}avatar_ads_exp.png",
    },
  ];

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'StoryTutor');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth,
      height: SizeWidget.barStoriesCircleHome,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollStartNotification) {
            Future.delayed(const Duration(milliseconds: 100), () {
              print('hariyanto1');
              // notifier.initialPeopleStories(context);
            });
          }
          return true;
        },
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 0, right: 0.0),
          itemCount: storyData.length,
          itemBuilder: (context, index) {
            if(index == 0){
              return MyFrameStoryTutor(
                image: storyData[index]['image'],
                user: storyData[index]['user'],
              );
            }
            return FrameStory(
              image: storyData[index]['image'],
              user: storyData[index]['user'],
            );
          },
        ),
      ),
    );
  }
}

class MyFrameStoryTutor extends StatelessWidget {
  final String? image;
  final String? user;
  const MyFrameStoryTutor({super.key, this.image, this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        sixteenPx,
        // Text("${notifier.isloading}"),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  // padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        width: 2.0,
                        color: kHyppeBorderTab),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: SizedBox(
                      width: SizeWidget.circleDiameterOutside,
                      height: SizeWidget.circleDiameterOutside,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(SizeWidget.circleDiameterOutside * 0.08),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(SizeWidget.circleDiameterOutside * 0.25),
                              child: Image.asset(
                                image ?? '',
                                width: SizeWidget.circleDiameterOutside,
                                height: SizeWidget.circleDiameterOutside,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth);
                                },
                                fit: BoxFit.cover,
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
                const CustomIconWidget(
                  defaultColor: false,
                  iconData: '${AssetPath.vectorPath}add-story.svg',
                )
              ],
            ),
            fourPx,
            SizedBox(
              width: 43,
              child: CustomTextWidget(
                maxLines: 1,
                textToDisplay: user == 'a' ? (context.read<TranslateNotifierV2>().translate.yourStory ?? '') : user ?? '',
                textStyle: Theme.of(context).textTheme.overline?.copyWith(letterSpacing: 1.0),
              ),
            )
          ],
        ),
      ],
    );
  }
}


class FrameStory extends StatelessWidget {
  final String? image;
  final String? user;

  const FrameStory({super.key, this.image, this.user});
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MyFrameStory');
    SizeConfig().init(context);

    return Row(
      children: [
        eightPx,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 2, color: kHyppePrimary),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: SizeWidget.circleDiameterOutside,
                  height: SizeWidget.circleDiameterOutside,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(SizeWidget.circleDiameterOutside * 0.08),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(SizeWidget.circleDiameterOutside * 0.25),
                          child: Image.asset(
                            image ?? '',
                            width: SizeWidget.circleDiameterOutside,
                            height: SizeWidget.circleDiameterOutside,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth);
                            },
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                ),
              ),
            ),
            fourPx,
            SizedBox(
              width: 43,
              child: CustomTextWidget(
                maxLines: 1,
                textToDisplay: user == 'a' ? (context.read<TranslateNotifierV2>().translate.yourStory ?? '') : user ?? '',
                textStyle: Theme.of(context).textTheme.overline?.copyWith(letterSpacing: 1.0),
              ),
            )
          ],
        ),
      ],
    );
  }
}
