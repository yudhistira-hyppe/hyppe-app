import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class ContentLeaderboard extends StatelessWidget {
  final Getlastrank? data;
  const ContentLeaderboard({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    Color colorRank;
    Color colorRankFont;
    switch (data?.ranking) {
      case 1:
        colorRank = kHyppeRank1;
        break;
      case 2:
        colorRank = kHyppeRank2;
        break;
      case 3:
        colorRank = kHyppeRank3;
        break;
      default:
        colorRank = kHyppeRank4;
    }
    if (data?.ranking == 1 || data?.ranking == 2 || data?.ranking == 3) {
      colorRankFont = kHyppeLightButtonText;
    } else {
      colorRankFont = kHyppeBurem;
    }
    if ((data?.isUserLogin ?? false)) {
      colorRank = kHyppePrimary;
      colorRankFont = kHyppeLightButtonText;
    }
    return data?.postChallengess?.isEmpty ?? [].isEmpty
        ? Container()
        : data?.ranking == 11 && data?.isUserLogin == false
            ? Container()
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: (data?.isUserLogin ?? false) ? kHyppePrimaryTransparent : kHyppeLightButtonText,
                  border: Border.all(color: (data?.isUserLogin ?? false) ? kHyppePrimary : kHyppeLightButtonText),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: colorRank, borderRadius: BorderRadius.circular(100)),
                      child: Center(
                        child: Text(
                          "${data?.ranking}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorRankFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    twelvePx,
                    CustomContentModeratedWidget(
                      width: 80,
                      height: 80,
                      isSale: false,
                      featureType: data?.postChallengess?[0].postType == 'pict' ? FeatureType.pic : FeatureType.vid,
                      isSafe: true, //notifier.postData.data.listPic[index].isSafe,
                      thumbnail: ImageUrl('${data?.postChallengess?[0].postID}', url: System().showUserPicture(data?.postChallengess?[0].mediaThumbEndpoint) ?? ''),
                    ),
                    twelvePx,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data?.postChallengess?[0].description}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF3E3E3E),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: Text(
                              '${data?.score} poin',
                              style: const TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 12,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 0.0, left: 2, right: 2, bottom: 0),
                                    margin: const EdgeInsets.only(top: 2.0, left: 0, right: 0, bottom: 2),
                                    child: ClipOval(
                                      child: CustomProfileImage(
                                        following: true,
                                        forStory: false,
                                        width: 16,
                                        height: 16,
                                        // imageUrl: notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}"),
                                        imageUrl: data?.avatar?.mediaEndpoint != null ? System().showUserPicture("${data?.avatar?.mediaEndpoint}") : '',
                                      ),
                                    ),
                                  ),
                                  data?.ranking == 1 || data?.ranking == 2 || data?.ranking == 3
                                      ? Positioned.fill(
                                          child: Center(
                                            child: data?.winnerBadgeOther != null
                                                ? Image.network(
                                                    "${data?.winnerBadgeOther}",
                                                    width: 50 * SizeConfig.scaleDiagonal,
                                                    height: 50 * SizeConfig.scaleDiagonal,
                                                  )
                                                : Container(),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                              Text(
                                '${data?.username}',
                                style: const TextStyle(
                                  color: Color(0xFF3E3E3E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    twelvePx,
                    data?.currentstatistik == "NETRAL"
                        ? Container()
                        : Align(
                            alignment: Alignment.centerRight,
                            child: CustomIconWidget(
                              iconData: data?.currentstatistik == 'UP' ? "${AssetPath.vectorPath}arrow_drop_up.svg" : "${AssetPath.vectorPath}arrow_drop_down.svg",
                              defaultColor: false,
                            ),
                          )
                  ],
                ),
              );
  }
}
