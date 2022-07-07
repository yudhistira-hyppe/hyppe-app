import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
// import 'package:hyppe/ui/inner/home/widget/aliplayer.dart';
// import 'package:hyppe/ui/inner/home/widget/doku.dart';
import 'package:hyppe/ui/inner/home/widget/profile.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: const [
        // Doku(),
        Profile(),
        // AliPlayer(),
        sixteenPx,
      ],
      title:
          const CustomIconWidget(iconData: "${AssetPath.vectorPath}hyppe.svg"),
    );
  }
}
