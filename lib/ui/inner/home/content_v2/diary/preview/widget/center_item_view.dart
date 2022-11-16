import 'dart:ui';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/bottom_item_view.dart';
// import 'package:hyppe/ui/inner/home/content/diary/preview/widget/top_item_view.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/bottom_user_tag.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/top_item_view.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../../core/services/shared_preference.dart';

class CenterItemView extends StatelessWidget {
  final Function? onTap;
  final ContentData? data;
  const CenterItemView({this.onTap, this.data});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _scaling = (MediaQuery.of(context).size.width - 16.0 - 16.0 - 8) / 3;
    // double _result = context.read<PreviewDiaryNotifier>().scaleDiary(context) < 100
    //     ? SizeWidget.barShortVideoHomeLarge
    //     : context.read<PreviewDiaryNotifier>().scaleDiary(context);

    return GestureDetector(
      onTap: onTap as void Function()?,
      child: CustomBaseCacheImage(
        widthPlaceHolder: 112,
        heightPlaceHolder: 40,
        imageUrl: (data?.isApsara ?? false) ? "${data?.mediaThumbEndPoint}" : "${data?.fullThumbPath}",
        imageBuilder: (context, imageProvider) => Container(
          clipBehavior: Clip.hardEdge,
          width: _scaling,
          height: 181,
          child: _buildBody(context),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: _scaling,
          height: 181,
          child: _buildBody(context),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('${AssetPath.pngPath}content-error.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(context) {
    final email = SharedPreference().readStorage(SpKeys.email);
    final isSale = data?.email != email;
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false);
    return Stack(
      children: [
        if (isSale) Positioned(top: 0, right: 0, child: TopItemView(data: data)),
        Positioned(
          bottom: 0,
          left: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BottomItemView(data: data),
              data?.tagPeople?.isNotEmpty ?? false ? BottomUserView(data: data) : const SizedBox(),
            ],
          ),
        ),
        data?.isReport ?? false
            ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 30.0,
                    sigmaY: 30.0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${translate.translate.see} HyppeDiary",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        sixPx,
                        sixPx,
                        sixPx,
                        sixPx,
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
