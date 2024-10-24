import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherProfileBottom extends StatefulWidget {
  final String? email;
  final UserInfoModel? userData;
  final Function()? notifyParent;
  const OtherProfileBottom({super.key, this.email, this.notifyParent, this.userData});

  @override
  State<OtherProfileBottom> createState() => _OtherProfileBottomState();
}

class _OtherProfileBottomState extends State<OtherProfileBottom> {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OtherProfileBottom');
    return Consumer<OtherProfileNotifier>(
      builder: (_, notifier, __) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
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
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: notifier.pageIndex == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  notifier.pageIndex = 0;
                  if (widget.userData!.pics!.isEmpty){
                    notifier.getDataPerPgage(context, email: widget.email);
                  }
                  // final OtherProfileScreenState? state = context.findAncestorStateOfType<OtherProfileScreenState>();
                  // state?.userData?.pics = notifier.user.pics;
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
          //             textStyle: TextStyle(
          //               fontSize: 14,
          //               color: notifier.pageIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor,
          //             ),
          //           ),
          //         ],
          //       ),
          //       onPressed: () async {
          //         notifier.pageIndex = 1;
          //         await notifier.getDataPerPgage(context, email: widget.email);
          //         // final OtherProfileScreenState? state = context.findAncestorStateOfType<OtherProfileScreenState>();
          //         // state?.userData?.diaries = notifier.user.diaries;
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
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: notifier.pageIndex == 2 ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor,
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  notifier.pageIndex = 2;
                  // print('print ${widget.userData!.vidsh}');
                  if (widget.userData!.vids == null){
                    await notifier.getDataPerPgage(context, email: widget.email);
                  }
                  // if (widget.userData!.vids!.isEmpty){
                    print('video tabs');
                    
                  // }
                  
                  // final OtherProfileScreenState? state = context.findAncestorStateOfType<OtherProfileScreenState>();
                  // state?.userData?.vids = notifier.user.vids;
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
