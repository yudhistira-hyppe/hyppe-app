import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

class PichTumbnailReport extends StatelessWidget {
  final ContentData? pictData;
  const PichTumbnailReport({Key? key, this.pictData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = context.read<TranslateNotifierV2>().translate;
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CustomBackgroundLayer(
              sigmaX: 30,
              sigmaY: 30,
              // thumbnail: picData!.content[arguments].contentUrl,
              thumbnail: pictData!.isApsara! ? pictData!.mediaThumbEndPoint : '${pictData?.fullThumbPath}',
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}valid-invert.svg",
                defaultColor: false,
                height: 30,
              ),
              Text(translate.reportReceived!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              Text(translate.yourReportWillbeHandledImmediately!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  )),
              thirtyTwoPx,
            ],
          )),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                context.read<ReportNotifier>().seeContent(context, pictData!, hyppePic);
              },
              child: Container(
                padding: const EdgeInsets.only(top: 14, bottom: 14),
                margin: const EdgeInsets.only(bottom: 8),
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
                  "${translate.see} HyppePic",
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        sixPx,
      ],
    );
  }
}
