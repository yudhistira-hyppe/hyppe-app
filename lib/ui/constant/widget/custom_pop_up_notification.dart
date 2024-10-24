// import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class CustomPopUpNotification extends StatelessWidget {
  const CustomPopUpNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final isHaveSomethingNew = context.select((HomeNotifier value) => value.isHaveSomethingNew);

    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: (child, animation) {
          final _slideAnim = Tween<Offset>(
                  begin: const Offset(0.0, -1.0), end: const Offset(0.0, 0.0))
              .animate(animation);
          return SlideTransition(position: _slideAnim, child: child);
        },
        child:
            // isHaveSomethingNew
            //     ? Align(
            //         alignment: const Alignment(0.0, -0.96),
            //         child: Container(
            //             height: 46,
            //             width: MediaQuery.of(context).size.width,
            //             margin: const EdgeInsets.symmetric(horizontal: 16),
            //             decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.all(Radius.circular(10.0))),
            //             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            //               CustomTextWidget(
            //                   textToDisplay: "${context.read<HomeNotifier>().language.hiYouHaveNewContentPleasePullDownToRefresh}",
            //                   textStyle: Theme.of(context).textTheme.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            //               eightPx,
            //               CustomIconWidget(iconData: "${AssetPath.vectorPath}palm.svg", defaultColor: false, width: 26, height: 26)
            //             ])))
            //     :
            const SizedBox.shrink());
  }
}
