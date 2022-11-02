import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction_interactive.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class ShowReactionsIcon extends StatelessWidget {
  final double widthP;
  final int crossAxisCount;
  final double sizeCloseIcon;
  final double sizeSubtitleText;
  final List<ReactionInteractive>? data;
  final Function onTap;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const ShowReactionsIcon(
      {Key? key,
        required this.data,
        required this.itemBuilder,
        required this.crossAxisCount,
        required this.onTap,
        this.widthP = 0.8,
        this.sizeCloseIcon = 44,
        this.sizeSubtitleText = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return UnconstrainedBox(
      child: Container(
        width: SizeConfig.screenWidth ?? context.getWidth() * widthP,
        height: 550 * SizeConfig.scaleDiagonal,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap as void Function()?,
              child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg", defaultColor: false),
            ),
            SizedBox(height: 43 * SizeConfig.scaleDiagonal),
            Material(
              color: Colors.transparent,
              child: Text(
                "Quick Reactions",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w400,
                  fontSize: sizeSubtitleText * SizeConfig.scaleDiagonal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10 * SizeConfig.scaleDiagonal),
            Expanded(
              child: GridView.builder(
                itemCount: data?.length,
                itemBuilder: itemBuilder,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 30,
                  childAspectRatio: 3 / 2,
                  crossAxisCount: crossAxisCount,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
