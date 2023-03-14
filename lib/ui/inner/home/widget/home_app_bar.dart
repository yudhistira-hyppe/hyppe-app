import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/widget/profile.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      actions: const [
        // Doku(),
        CustomIconWidget(defaultColor: false, color: kHyppeTextLightPrimary, iconData: '${AssetPath.vectorPath}message.svg'),
        // Profile(),
        // AliPlayer(),
        sixteenPx,
      ],
      title: Text(
        "Halo, Ilham!",
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
      ),
      // const CustomIconWidget(iconData: "${AssetPath.vectorPath}hyppe.svg"),
    );
  }
}
