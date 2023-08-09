import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/collection/badge.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/collection/widget/shimmer_badge.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/home/widget/profile.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class CollectionBadgeScreen extends StatefulWidget {
  const CollectionBadgeScreen({Key? key}) : super(key: key);

  @override
  State<CollectionBadgeScreen> createState() => _CollectionBadgeScreenState();
}

class _CollectionBadgeScreenState extends State<CollectionBadgeScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  LocalizationModelV2? lang;
  bool isLoadingButton = false;
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Chalange Screen');

    lang = context.read<TranslateNotifierV2>().translate;

    Future.delayed(Duration.zero, () {
      var cn = context.read<ChallangeNotifier>();
      cn.collectionBadgeInit(context);
    });

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
    final hn = Provider.of<HomeNotifier>(context);
    isFromSplash = false;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: kHyppeTextLightPrimary,
            size: 16,
          ),
          onPressed: () {
            Routing().moveBack();
          },
        ),
        title: const Text(
          'Koleksi Badge Saya',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
          ),
        ),
        titleSpacing: 0,
      ),
      body: cn.isLoadingCollection
          ? const ShimmerBadge()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.asset("${AssetPath.pngPath}bg_collection.jpg"),
                      Positioned.fill(
                          child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomProfileImage(
                              following: true,
                              forStory: false,
                              width: 80,
                              height: 80,
                              badge: cn.badgeUser,
                              imageUrl: System().showUserPicture(hn.profileImage) ?? '',
                            ),
                            sixteenPx,
                            Text(
                              'Koleksi Badgemu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.36,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                      ))
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Badge Challenge Aktif',
                          style: TextStyle(
                            color: Color(0xFF3E3E3E),
                            fontSize: 14,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        twentyFourPx,
                        BadgeWidget(
                          badgeData: cn.collectionBadgeData?[0].badgeAktif,
                          avatar: hn.profileImage,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 24,
                    color: kHyppeLightSurface,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Koleksi Badge',
                          style: TextStyle(
                            color: Color(0xFF3E3E3E),
                            fontSize: 14,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        twentyFourPx,
                        // BadgeWidget(badgeData: cn.collectionBadgeData?[0].badgeNonAktif),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: cn.badgeUser?.idUserBadge == cn.iduserbadge
          ? SizedBox(
              height: 0,
            )
          : cn.badgeUser?.badgeProfile != null
              ? Container(
                  // height: 100,
                  color: kHyppeLightSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ButtonChallangeWidget(
                      isloading: isLoadingButton,
                      text: "Terapkan Badge",
                      bgColor: kHyppePrimary,
                      function: () async {
                        if (!isLoadingButton) {
                          setState(() {
                            isLoadingButton = true;
                          });
                          await cn.postSelectBadge(context, mounted, cn.badgeUser?.idUserBadge ?? '').then((value) {
                            setState(() {
                              isLoadingButton = false;
                            });
                          });
                        }
                      },
                    ),
                  ),
                )
              : SizedBox(
                  height: 0,
                ),
    );
  }
}
