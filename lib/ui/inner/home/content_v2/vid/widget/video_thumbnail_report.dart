import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/services/system.dart';

class VideoThumbnailReport extends StatelessWidget {
  final ContentData? videoData;
  final bool seeContent;
  final Function()? function;
  const VideoThumbnailReport({Key? key, this.videoData, this.seeContent = true, this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VideoThumbnailReport');
    final translate = context.read<TranslateNotifierV2>().translate;
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            // borderRadius: BorderRadius.circular(8.0),
            child: CustomBackgroundLayer(
              sigmaX: 10,
              sigmaY: 10,
              thumbnail: (videoData?.isApsara ?? false) ? (videoData?.mediaThumbEndPoint ?? '') : '${videoData?.fullThumbPath}',
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                twelvePx,
                const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}eye-off.svg",
                  defaultColor: false,
                  height: 24,
                  color: Colors.white,
                ),
                fourPx,
                Text(translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                fourPx,
                Text("${translate.contentContainsSensitiveMaterial}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    )),
                videoData?.email == SharedPreference().readStorage(SpKeys.email)
                    ? GestureDetector(
                        onTap: ()async{
                          System().checkConnections().then((value){
                            if(value){
                              Routing().move(Routes.appeal, argument: videoData);
                            }
                          });

                        },
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                            child: Text(translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                      )
                    : const SizedBox(),
                thirtyTwoPx,
              ],
            ),
          )),
        ),
        seeContent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (function != null) {
                        function!();
                      }
                      context.read<ReportNotifier>().seeContent(context, videoData!, hyppeVid);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      margin: const EdgeInsets.all(8),
                      width: SizeConfig.screenWidth,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        "${translate.see} Vid",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            : Container()
      ],
    );
  }
}
