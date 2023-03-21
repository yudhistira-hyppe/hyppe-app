import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class HomeAppBar extends StatelessWidget {
  final String? name;
  final double? offset;

  const HomeAppBar({super.key, this.name = '', this.offset = 0});

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HomeAppBar');
    String nameTitle = name ?? '';
    // String nameTitle = "AaaAAAAASKJLKJDiiiiaskdlaksjdlkajsd asdasdas asdasd";
    nameTitle = nameTitle.split(" ").elementAt(0);

    if ((nameTitle.length) >= 15) {
      nameTitle = nameTitle.substring(0, 15);
    }
    String helloName = nameTitle;
    helloName = helloName == '' ? '' : System().capitalizeFirstLetter(helloName);
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
      title: (offset ?? 0) <= 100
          ? Text(
              "Halo, $helloName!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
            )
          : const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}hyppe.svg",
              defaultColor: false,
              color: kHyppeTextLightPrimary,
            ),
    );
  }
}
