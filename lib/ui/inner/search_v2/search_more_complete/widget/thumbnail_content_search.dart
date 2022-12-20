import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hyppe/core/config/env.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_bottom_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';

// import 'package:hyppe/ui/inner/home/content/pic/widget/pic_top_item.dart';

class ThumbnailContentSearch extends StatelessWidget {
  final Function? onTap;
  final ContentData? data;
  final EdgeInsets? margin;

  const ThumbnailContentSearch({Key? key, this.onTap, this.data, this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _scaling = (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2;
    String gambar;
    if (data?.postType == 'pict') {
      if (data?.apsara ?? false) {
        gambar = data?.media?.imageInfo?[0].url ?? '';
      } else {
        gambar = System().showUserPicture(data?.mediaEndpoint ?? '') ?? '';
      }
    } else {
      if (data?.apsara ?? false) {
        gambar = data?.media?.videoList?[0].coverURL ?? '';
      } else {
        gambar = System().showUserPicture(data?.mediaThumbEndPoint ?? '') ?? '';
      }
    }

    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomBaseCacheImage(
            widthPlaceHolder: 80,
            heightPlaceHolder: 80,
            imageUrl: gambar,
            imageBuilder: (context, imageProvider) => Container(
              margin: margin,
              // const EdgeInsets.symmetric(horizontal: 4.5),
              width: _scaling,
              height: 168,
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _buildBody(context),
            ),
            errorWidget: (context, url, error) => Container(
              margin: margin,
              // const EdgeInsets.symmetric(horizontal: 4.5),
              width: _scaling,
              height: 186,
              child: _buildBody(context),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            emptyWidget: Container(
              margin: margin,
              // const EdgeInsets.symmetric(horizontal: 4.5),
              width: _scaling,
              height: 186,
              child: _buildBody(context),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          data?.reportedStatus != 'BLURRED' && data?.postType != 'pict'
              ? Center(
                  child: CustomIconWidget(
                    width: 30,
                    iconData: '${AssetPath.vectorPath}vid.svg',
                    defaultColor: false,
                    color: kHyppeLightButtonText.withOpacity(0.7),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildBody(context) {
    return Stack(
      children: [
        PicTopItem(data: data),
        Positioned(bottom: 0, left: 0, child: PicBottomItem(data: data)),
        data?.reportedStatus == 'BLURRED'
            ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 30.0,
                    sigmaY: 30.0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                    height: 167,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}eye-off.svg",
                          defaultColor: false,
                          height: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
