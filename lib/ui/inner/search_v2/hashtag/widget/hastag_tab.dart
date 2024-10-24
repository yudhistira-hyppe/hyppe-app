import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../../../core/constants/enum.dart';

class HashtagTab extends StatelessWidget {
  final bool isActive;
  final HyppeType type;
  final Function(HyppeType)? onTap;
  const HashtagTab(
      {Key? key, required this.isActive, required this.type, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HashtagTab');
    // return Column(
    //   children: [
    //     Material(
    //       color: Colors.transparent,
    //       child: Ink(
    //         decoration: BoxDecoration(
    //           color: context.getColorScheme().background,
    //         ),
    //         child: InkWell(
    //           splashColor: context.getColorScheme().primary,
    //           onTap: (){
    //             if(onTap != null){
    //               onTap!(type);
    //             }
    //           },
    //           child: Container(
    //             padding: const EdgeInsets.only( bottom: 12),
    //             alignment: Alignment.bottomCenter,
    //             width: double.infinity,
    //             height: 52,
    //             child: CustomTextWidget(
    //               textToDisplay: System().getTitleHyppe(type),
    //               textStyle: context.getTextTheme().bodyMedium?.copyWith(
    //                   color: isActive
    //                       ? context.getColorScheme().primary
    //                       : context.getColorScheme().secondary,
    //                 fontWeight: isActive ? FontWeight.w700 : FontWeight.w400
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //     Container(
    //       height: 3,
    //       margin: const EdgeInsets.symmetric(horizontal: 14),
    //       decoration: BoxDecoration(
    //           color:
    //               isActive ? context.getColorScheme().primary : kHyppeBorderTab,
    //           borderRadius: const BorderRadius.all(Radius.circular(2))),
    //     )
    //   ],
    // );

    return Container(
        child: Material(
            color: Colors.transparent,
            child: Ink(
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? context.getColorScheme().primary
                    : context.getColorScheme().background,
                borderRadius: const BorderRadius.all(Radius.circular(18)),
              ),
              child: InkWell(
                onTap: () {
                  if (onTap != null) {
                    onTap!(type);
                  }
                },
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                splashColor: context.getColorScheme().primary,
                child: Container(
                  alignment: Alignment.center,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  child: CustomTextWidget(
                    textToDisplay: System().getTitleHyppe(type),
                    textStyle: context.getTextTheme().bodyMedium?.copyWith(
                        color: isActive
                            ? context.getColorScheme().background
                            : context.getColorScheme().secondary),
                  ),
                ),
              ),
            )));
  }
}
