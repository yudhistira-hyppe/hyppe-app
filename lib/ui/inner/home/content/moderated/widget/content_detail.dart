import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/thumb/hyppe_diary.dart';
import 'package:hyppe/core/constants/thumb/hyppe_pic.dart';
import 'package:hyppe/core/constants/thumb/hyppe_vid.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class ContentDetail extends StatelessWidget {
  final ContentData data;

  const ContentDetail({Key? key, required this.data}) : super(key: key);

  String thumbnail() {
    if (data.postType == 'vid') {
      return VIDTHUMB368x208;
    } else if (data.postType == 'diary') {
      return DIARYTHUMB300x540;
    } else {
      return PICTHUMB300x300;
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ContentDetail');
    return SafeArea(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                CustomContentModeratedWidget(
                  isSale: (data.saleAmount ?? 0) > 0,
                    isSafe: true,
                    boxFitError: BoxFit.fill,
                    boxFitContent: BoxFit.contain,
                    thumbnail: ImageUrl(data.postID, url: '${data.fullThumbPath}' + thumbnail())),
                CustomIconButtonWidget(
                    onPressed: () => Routing().moveBack(),
                    iconData: '${AssetPath.vectorPath}back-arrow.svg',
                    padding: const EdgeInsets.only(top: 16, left: 16))
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.surface,
            child: CustomTextWidget(
                maxLines: null,
                textAlign: TextAlign.left,
                textToDisplay: data.description ?? '',
                textOverflow: TextOverflow.visible,
                textStyle: Theme.of(context).textTheme.bodyText2),
          )
        ],
      ),
    );
  }
}
