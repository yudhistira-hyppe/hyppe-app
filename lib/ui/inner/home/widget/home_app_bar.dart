import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/widget/profile.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget {
  final String? name;
  final double? offset;

  const HomeAppBar({super.key, this.name, this.offset});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      actions: [
        // Doku(),
        GestureDetector(
          onTap: () {
            Routing().move(Routes.message);
          },
          child: CustomIconWidget(defaultColor: false, color: kHyppeTextLightPrimary, iconData: '${AssetPath.vectorPath}message.svg'),
        ),
        // Profile(),
        // AliPlayer(),
        sixteenPx,
      ],
      title: offset! <= 100
          ? Text(
              "Halo, ${name!.split(" ").elementAt(0)}!",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
            )
          : const CustomIconWidget(iconData: "${AssetPath.vectorPath}hyppe.svg"),
    );
  }
}
