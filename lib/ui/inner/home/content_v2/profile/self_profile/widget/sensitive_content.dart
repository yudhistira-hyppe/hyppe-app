import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class SensitiveContentProfile extends StatelessWidget {
  final ContentData? data;
  const SensitiveContentProfile({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CustomBackgroundLayer(
              sigmaX: 30,
              sigmaY: 30,
              // thumbnail: picData!.content[arguments].contentUrl,
              thumbnail: data?.isApsara ?? false ? (data?.mediaThumbEndPoint ?? '') : System().showUserPicture(data?.mediaEndpoint) ?? '',
            ),
          ),
        ),
        const Center(
          child: CustomIconWidget(
            iconData: "${AssetPath.vectorPath}eye-off.svg",
            defaultColor: false,
            height: 30,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
