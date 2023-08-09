import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/slided_pic_detail_screen_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class ShimmerSlider extends StatefulWidget {
  final SlidedPicDetailScreenArgument? arguments;
  const ShimmerSlider({super.key, this.arguments});

  @override
  State<ShimmerSlider> createState() => _ShimmerSliderState();
}

class _ShimmerSliderState extends State<ShimmerSlider> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Align(
                  alignment: const Alignment(-1.2, 0),
                  child: Container(margin: const EdgeInsets.symmetric(horizontal: 10), child: widget.arguments?.titleAppbar ?? Container()),
                ),
                leading: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: kHyppeTextLightPrimary,
                    ),
                    onPressed: () {
                      Future.delayed(Duration.zero, () {
                        // Navigator.pop(context, '$_curIdx');
                        Navigator.pop(context);
                      });
                    }),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                margin: const EdgeInsets.only(
                  top: 18,
                  left: 6,
                  right: 6,
                ),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 11,
                    itemBuilder: (context, index) => Column(
                          children: [
                            CustomShimmer(width: SizeConfig.screenWidth, height: 350, radius: 12),
                            twelvePx,
                            CustomShimmer(width: SizeConfig.screenWidth, height: 18, radius: 8),
                            twelvePx,
                            CustomShimmer(width: SizeConfig.screenWidth, height: 18, radius: 8),
                            twelvePx,
                            twelvePx,
                            twelvePx,
                          ],
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
