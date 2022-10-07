import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_bottom_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';

import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/services/shared_preference.dart';

// import 'package:hyppe/ui/inner/home/content/pic/widget/pic_top_item.dart';

class PicCenterItem extends StatelessWidget {
  final Function? onTap;
  final ContentData? data;
  final EdgeInsets? margin;

  const PicCenterItem({Key? key, this.onTap, this.data, this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _scaling = (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2;

    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Stack(
        children: [
          CustomBaseCacheImage(
            widthPlaceHolder: 80,
            heightPlaceHolder: 80,
            imageUrl: data!.isApsara! ? data!.mediaThumbEndPoint : "${data?.fullThumbPath}",
            imageBuilder: (context, imageProvider) => Container(
              margin: margin,
              // const EdgeInsets.symmetric(horizontal: 4.5),
              width: _scaling,
              height: 168,
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _buildBody(),
            ),
            errorWidget: (context, url, error) => Container(
              margin: margin,
              // const EdgeInsets.symmetric(horizontal: 4.5),
              width: _scaling,
              height: 186,
              child: _buildBody(),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final email = SharedPreference().readStorage(SpKeys.email);
    final isSale = data?.email != email;
    return Stack(
      children: [
        if (isSale) PicTopItem(data: data),
        Positioned(bottom: 0, left: 0, child: PicBottomItem(data: data)),
      ],
    );
  }
}
