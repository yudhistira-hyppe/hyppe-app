import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/test/testlootie.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/test/testtimer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class SelfProfileBottom extends StatefulWidget {
  const SelfProfileBottom({Key? key}) : super(key: key);

  @override
  _SelfProfileBottomState createState() => _SelfProfileBottomState();
}

class _SelfProfileBottomState extends State<SelfProfileBottom> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SelfProfileBottom');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelfProfileNotifier>(
      builder: (_, notifier, __) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              // GestureDetector(
              //     onTap: () {
              //       // Routing().move(Routes.verificationSupportSuccess, argument: GeneralArgument(isTrue: true));
              //       // Routing().move(Routes.verificationSupportSuccess);
              //       // Routing().move(Routes.streamer);
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => TestTimer(),
              //           ));
              //     },
              //     child: Text("hahaha")),
              CustomTextButton(
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}pic.svg",
                      width: 20 * SizeConfig.scaleDiagonal,
                      height: 20 * SizeConfig.scaleDiagonal,
                      defaultColor: false,
                      color: notifier.pageIndex == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor,
                    ),
                    SizedBox(width: 8 * SizeConfig.scaleDiagonal),
                    CustomTextWidget(
                      textToDisplay: "Pic",
                      textStyle: TextStyle(fontSize: 14, color: notifier.pageIndex == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor),
                    ),
                  ],
                ),
                onPressed: () {
                  notifier.pageIndex = 0;
                  notifier.getDataPerPgage(context);
                },
              ),
              SizedBox(
                height: 2 * SizeConfig.scaleDiagonal,
                width: 125 * SizeConfig.scaleDiagonal,
                child: Container(color: notifier.pageIndex == 0 ? Theme.of(context).colorScheme.primary : null),
              )
            ],
          ),
          // Column(
          //   children: [
          //     CustomTextButton(
          //       child: Row(
          //         children: [
          //           CustomIconWidget(
          //             iconData: "${AssetPath.vectorPath}diary.svg",
          //             width: 20 * SizeConfig.scaleDiagonal,
          //             height: 20 * SizeConfig.scaleDiagonal,
          //             defaultColor: false,
          //             color: notifier.pageIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor,
          //           ),
          //           SizedBox(width: 8 * SizeConfig.scaleDiagonal),
          //           CustomTextWidget(
          //             textToDisplay: "Diary",
          //             textStyle: TextStyle(fontSize: 14, color: notifier.pageIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor),
          //           ),
          //         ],
          //       ),
          //       onPressed: () {
          //         notifier.pageIndex = 1;
          //         notifier.getDataPerPgage(context);
          //       },
          //     ),
          //     SizedBox(
          //       height: 2 * SizeConfig.scaleDiagonal,
          //       width: 125 * SizeConfig.scaleDiagonal,
          //       child: Container(color: notifier.pageIndex == 1 ? Theme.of(context).colorScheme.primary : null),
          //     ),
          //   ],
          // ),
          Column(
            children: [
              CustomTextButton(
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}vid.svg",
                      width: 20 * SizeConfig.scaleDiagonal,
                      height: 20 * SizeConfig.scaleDiagonal,
                      defaultColor: false,
                      color: notifier.pageIndex == 2 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor,
                    ),
                    SizedBox(width: 8 * SizeConfig.scaleDiagonal),
                    CustomTextWidget(
                      textToDisplay: "Vid",
                      textStyle: TextStyle(fontSize: 14, color: notifier.pageIndex == 2 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor),
                    ),
                  ],
                ),
                onPressed: () {
                  notifier.pageIndex = 2;
                  notifier.getDataPerPgage(context);
                },
              ),
              SizedBox(
                height: 2 * SizeConfig.scaleDiagonal,
                width: 125 * SizeConfig.scaleDiagonal,
                child: Container(color: notifier.pageIndex == 2 ? Theme.of(context).colorScheme.primary : null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
