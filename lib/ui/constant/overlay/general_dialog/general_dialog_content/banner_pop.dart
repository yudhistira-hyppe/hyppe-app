import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';

class BannerPop extends StatelessWidget {
  final bool uploadProses;
  const BannerPop({Key? key, this.uploadProses = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.loose,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8.0)),
              height: size.width * 0.92,
              width: size.width * 0.92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // !uploadProses ? const CustomLoading() : const ProcessUploadComponent(showAlert: false),
                  GestureDetector(
                    // onTap: () => Routing().moveBack(),
                    child: CustomTextWidget(
                      textToDisplay: 'Loading',
                      textStyle: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const CustomIconWidget(
                width: 20,
                height: 20,
                iconData: "${AssetPath.vectorPath}close.svg",
                defaultColor: false,
                color: kHyppePrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
