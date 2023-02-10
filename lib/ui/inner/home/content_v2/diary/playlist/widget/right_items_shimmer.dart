import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class RightItemsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 8, bottom: 12),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(1.0, 0.70),
            child: SizedBox(
              height: 400 * SizeConfig.scaleDiagonal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _customIcon2(context, "${AssetPath.vectorPath}bookmark.svg", "Save", onTap: () {}, color: Colors.white),
                  _customIcon2(context, "${AssetPath.vectorPath}unlike.svg", "Like", onTap: () {}, color: Colors.white),
                  _customIcon2(context, "${AssetPath.vectorPath}comment.svg", "Comment", onTap: () {}, color: Colors.white),
                  _customIcon2(context, "${AssetPath.vectorPath}share.svg", "Share", onTap: () {}, color: Colors.white)
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _customIcon("${AssetPath.vectorPath}more.svg"),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: _customIcon("${AssetPath.vectorPath}close.svg"),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _customIcon("${AssetPath.vectorPath}music_stroke_white.svg"),
                twelvePx,
                CustomShimmer(width: (SizeConfig.screenWidth! - 68), height: 16, radius: 4),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _customIcon(String svg) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomIconWidget(iconData: svg, defaultColor: false),
    );
  }

  Widget _customIcon2(BuildContext context, String svgIcon, String caption, {Function? onTap, Key? key, Color? color}) {
    return CustomTextButton(
      onPressed: onTap,
      child: Column(
        children: <Widget>[
          CustomIconWidget(iconData: svgIcon, key: key, color: color, defaultColor: false),
          fourPx,
          CustomTextWidget(textToDisplay: caption, textStyle: Theme.of(context).textTheme.caption)
        ],
      ),
    );
  }
}
