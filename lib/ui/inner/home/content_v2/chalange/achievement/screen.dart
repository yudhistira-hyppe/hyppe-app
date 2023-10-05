import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/achievement_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/achievement/widget/shimmer_list.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  LocalizationModelV2? lang;
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Chalange Screen');

    lang = context.read<TranslateNotifierV2>().translate;

    Future.delayed(Duration.zero, () {
      var cn = context.read<ChallangeNotifier>();
      cn.achievementInit(context);
    });

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
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
            lang?.achievementsPage ?? '',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
          ),
          titleSpacing: 0,
        ),
        body: cn.isLoadingAchivement
            ? const ShimmerListAchievement()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Routing().move(Routes.chalengeCollectionBadge);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        color: kHyppeLightSurface,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(1.00, 0.00),
                              end: Alignment(-1, 0),
                              colors: [Color(0xFF7551C0), Color(0xFFAB22AF)],
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "${AssetPath.pngPath}avatarbadge.png",
                                height: 37,
                              ),
                              twelvePx,
                              Text(
                                "${lang?.seeMyBadgeCollection}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: cn.achievementData?.isEmpty ?? [].isEmpty
                          ? empty()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${lang?.myListOfAchievements}',
                                  style: const TextStyle(
                                    color: Color(0xFF3E3E3E),
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                twentyFourPx,
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: cn.achievementData?.length,
                                  itemBuilder: (context, index) {
                                    return item(cn.achievementData?[index] ?? AcievementModel());
                                  },
                                )
                              ],
                            ),
                    ),
                  ],
                ),
              ));
  }

  Widget empty() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      height: SizeConfig.screenWidth! * 1.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("${lang?.youHaveNotAchievedAnythingYet}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              )),
          twelvePx,
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Text(
              "${lang?.joinTheChallengeAndGetOther}",
              style: const TextStyle(color: kHyppeBurem),
              textAlign: TextAlign.center,
            ),
          ),
          twentyFourPx,
          ButtonChallangeWidget(
            bgColor: kHyppePrimary,
            text: "${lang?.joinTheChallenge}",
            function: () {
              Routing().moveBack();
            },
          ),
        ],
      ),
    );
  }

  Widget item(AcievementModel data) {
    return GestureDetector(
      onTap: () {
        Routing().move(
          Routes.chalengeDetail,
          argument: GeneralArgument(
            id: data.subChallengeData?[0].challengeId,
            session: data.subChallengeData?[0].session,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            twelvePx,
            Stack(
              fit: StackFit.passthrough,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 3.0, left: 3, right: 3, bottom: 3),
                  child: ClipOval(
                    child: CustomProfileImage(
                      following: true,
                      forStory: false,
                      width: 43,
                      height: 43,
                      // imageUrl: "https://hips.hearstapps.com/hmg-prod/images/sam-worthington-avatar-the-way-of-the-water-1670323169.jpg?crop=0.528xw:1.00xh;0.134xw,0&resize=1200:*",
                      imageUrl: data.avatar?.mediaEndpoint != null ? System().showUserPicture("${data.avatar?.mediaEndpoint}") : '',
                    ),
                  ),
                ),
                data.badgeData?.isNotEmpty ?? [].isEmpty
                    ? Positioned.fill(
                        child: Center(
                          child: data.badgeData != null
                              ? Image.network(
                                  "${data.badgeData?[0].badgeOther}",
                                  width: 50 * SizeConfig.scaleDiagonal,
                                  height: 50 * SizeConfig.scaleDiagonal,
                                )
                              : Container(),
                        ),
                      )
                    : Container()
              ],
            ),
            twelvePx,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.subChallengeData?[0].nameChallenge ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF3E3E3E),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  fourPx,
                  Text(
                    'Period ${data.session}',
                    style: const TextStyle(
                      color: Color(0xFF3E3E3E),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  fourPx,
                  Text(
                    '${System().dateFormatter(data.startDatetime ?? '2023-01-01', 5)} - ${System().dateFormatter(data.startDatetime ?? '2023-01-01', 5)}',
                    style: const TextStyle(
                      color: Color(0xFF9B9B9B),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            twelvePx,
            const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}arrow_right.svg",
              defaultColor: false,
            )
          ],
        ),
      ),
    );
  }
}
