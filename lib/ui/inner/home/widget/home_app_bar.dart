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
import 'package:provider/provider.dart';

import '../../main/notifier.dart';

class HomeAppBar extends StatefulWidget {
  final String? name;
  final double? offset;
  final ScrollController? scrollController;

  const HomeAppBar({
    super.key,
    this.name = '',
    this.offset = 0,
    this.scrollController,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  double offset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var notifierMain = Routing.navigatorKey.currentState?.overlay?.context.read<MainNotifier>();
      context.read<MainNotifier>().globalKey?.currentState?.innerController.addListener(() {
        print("---------scrol------");
        offset = context.read<MainNotifier>().globalKey?.currentState?.innerController.position.pixels ?? 0;
      });
      // notifierMain?.globalKey.currentState?.innerController.addListener(() async {});
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HomeAppBar');
    String nameTitle = widget.name == null || widget.name == 'null' ? '' : (widget.name ?? '');
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
        Consumer<MainNotifier>(builder: (context, notifier, _) {
          final isReceived = notifier.receivedMsg;
          return GestureDetector(
            onTap: () {
              Routing().move(Routes.message);
              notifier.receivedMsg = false;
            },
            child: isReceived
                ? CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}message_with_dot.svg')
                : CustomIconWidget(defaultColor: false, color: kHyppeTextLightPrimary, iconData: '${AssetPath.vectorPath}message.svg'),
          );
        }),
        // Profile(),
        // AliPlayer(),
        sixteenPx,
      ],
      title: (widget.offset ?? 0) <= 150
          ? Text(
              "Halo, $helloName! ",
              // "  $offset",
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
