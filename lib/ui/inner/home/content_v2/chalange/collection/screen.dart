import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
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
        title: Text(
          lang?.myBadgeCollections ?? '',
          style: const TextStyle(
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
                      Image.asset("${AssetPath.pngPath}badge_banner_background.png"),
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
                              allwaysUseBadgePadding: true,
                            ),
                            sixteenPx,
                            Text(
                              lang?.yourBadgeCollections ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                  (cn.collectionBadgeData?[0].badgeAktif?.length == 1) && (cn.collectionBadgeData?[0].badgeNonAktif?.isEmpty ?? [].isEmpty)
                      ? empty()
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang?.activeBadgeChallenge ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF3E3E3E),
                                      fontSize: 14,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  twentyFourPx,
                                  // Text("${cn.badgeUser?.badgeProfile}"),
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
                                    lang?.badgeCollection ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF3E3E3E),
                                      fontSize: 14,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  twentyFourPx,
                                  BadgeWidget(badgeData: cn.collectionBadgeData?[0].badgeNonAktif, isActive: false),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
      bottomNavigationBar: cn.badgeUser?.idUserBadge == cn.iduserbadge
          ? const SizedBox(
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
                      text: lang?.applyBadge ?? '',
                      bgColor: kHyppePrimary,
                      function: () async {
                        if (!isLoadingButton) {
                          setState(() {
                            isLoadingButton = true;
                          });
                          await cn.postSelectBadge(context, mounted, cn.badgeUser?.id ?? '').then((value) {
                            setState(() {
                              isLoadingButton = false;
                            });
                          });
                        }
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(),
    );
  }

  Widget empty() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      height: SizeConfig.screenWidth! * 1.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("${lang?.youDontHaveaBadge}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              )),
          twelvePx,
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Text(
              "${lang?.winachallengetoreceiveabadge}",
              style: const TextStyle(color: kHyppeBurem),
              textAlign: TextAlign.center,
            ),
          ),
          twentyFourPx,
          ButtonChallangeWidget(
            bgColor: kHyppePrimary,
            text: "${lang?.joinTheChallengeNow}",
            function: () {
              Routing().moveBack();
              Routing().moveBack();
            },
          ),
        ],
      ),
    );
  }
}
