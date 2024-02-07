import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../main/notifier.dart';

class HomeAppBar extends StatelessWidget {
  final String? name;
  final double? offset;
  final ScrollController? scrollController;

  const HomeAppBar({
    super.key,
    this.name = '',
    this.offset,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HomeAppBar');
    String nameTitle = (isGuest ?? false) ? 'Hyppers' : (name ?? 'Hyppers');
    // String nameTitle = "AaaAAAAASKJLKJDiiiiaskdlaksjdlkajsd asdasdas asdasd";
    nameTitle = nameTitle.split(" ").elementAt(0);

    if ((nameTitle.length) >= 15) {
      nameTitle = nameTitle.substring(0, 15);
    }
    String helloName = nameTitle;
    helloName =
        helloName == '' ? '' : System().capitalizeFirstLetter(helloName);
    SizeConfig().init(context);
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      actions: [
        // Doku(),
        GestureDetector(
            onTap: () {
              context.handleActionIsGuest((){
                Routing().move(Routes.listStreamers);
              });
            },
            child: CustomIconWidget(
              width: 30,
                height: 30,
                defaultColor: false,
                iconData: '${AssetPath.vectorPath}ic_live_streaming.svg')),
        // CustomIconButtonWidget(iconData: '${AssetPath.vectorPath}ic_live_streaming.svg', onPressed: (){
        //   Routing().move(Routes.listStreamers);
        // }),
        sixteenPx,
        Consumer<MainNotifier>(builder: (context, notifier, _) {
          final isReceived = notifier.receivedMsg;
          return GestureDetector(
            onTap: () {
              context.handleActionIsGuest((){
                Routing().move(Routes.message);
                notifier.receivedMsg = false;
              });

            },
            child: isReceived
                ? CustomIconWidget(
                    defaultColor: false,
                    iconData: '${AssetPath.vectorPath}message_with_dot.svg')
                : CustomIconWidget(
                    defaultColor: false,
                    color: kHyppeTextLightPrimary,
                    iconData: '${AssetPath.vectorPath}message.svg'),
          );
        }),
        // Profile(),
        // AliPlayer(),
        sixteenPx,
      ],
      title: (offset ?? 0) <= 150
          ? Text(
              // "$offset",
              "Halo, $helloName ",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: kHyppeTextLightPrimary),
            )
          : const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}hyppe.svg",
              defaultColor: false,
              color: kHyppeTextLightPrimary,
            ),
    );
  }
}
