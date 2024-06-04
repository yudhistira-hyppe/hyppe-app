import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class ResponsAllreadyReport extends StatelessWidget {
  const ResponsAllreadyReport({super.key});

  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;
    return Consumer<ViewStreamingNotifier>(builder: (context, notifier, _) {
      return DraggableScrollableSheet(
          expand: false,
          maxChildSize: .5,
          initialChildSize: .4,
          builder: (context, controller) {
            return Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.symmetric(),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.15,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                      child: Container(
                        height: 5.0,
                        decoration: const BoxDecoration(
                          color: kHyppeBurem,
                          borderRadius: BorderRadius.all(Radius.circular(2.5)),
                        ),
                      ),
                    ),
                  ),
                  fifteenPx,
                  CustomProfileImage(
                    cacheKey: '',
                    following: true,
                    forStory: false,
                    width: 36 * SizeConfig.scaleDiagonal,
                    height: 36 * SizeConfig.scaleDiagonal,
                    imageUrl: System().showUserPicture(notifier.dataStreaming.user?.avatar?.mediaEndpoint ?? ''),
                    // badge: notifier.user.profile?.urluserBadge,
                    allwaysUseBadgePadding: false,
                  ),
                  Divider(),
                  tenPx,
                  Text(
                    tn.localeDatetime == 'id' ? "Kamu sudah melaporkan LIVE ${notifier.dataStreaming.user?.username}" : "You have already reported  ${notifier.dataStreaming.user?.username} LIVE",
                    style: const TextStyle(color: kHyppeTextLightPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  tenPx,
                  Text(
                    tn.localeDatetime == 'id' ? 'Kami akan segera memberikan pembaruan mengenai status laporanmu.' : "We'll keep you updated on the progress of your report.",
                    style: TextStyle(
                      color: kHyppeTextLightPrimary,
                      // fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  sixteenPx,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: kHyppePrimary),
                      child: SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: Center(
                          child: Text(tn.understand ?? 'Mengerti', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                  fivePx,
                ],
              ),
            );
          });
    });
  }
}
