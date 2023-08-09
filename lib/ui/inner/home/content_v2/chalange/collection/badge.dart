import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/badge_collection_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';

class BadgeWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final double? height;
  final List<BadgeAktif>? badgeData;
  final String? avatar;

  const BadgeWidget({
    Key? key,
    this.scrollController,
    this.height,
    this.badgeData,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChallangeNotifier cn = context.watch<ChallangeNotifier>();
    return GridView.builder(
      itemCount: badgeData?.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 109 / 140,
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            cn.selectBadge(badgeData?[index]);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: badgeData?[index].idBadge == cn.badgeUser?.idUserBadge ? kHyppePrimary : Color(0xFFEAEAEA)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Container(
                            // padding: const EdgeInsets.only(top: 5.0, left: 6, right: 6, bottom: 2),
                            margin: const EdgeInsets.only(top: 2.0, left: 6, right: 6, bottom: 2),
                            child: ClipOval(
                              child: CustomProfileImage(
                                following: true,
                                forStory: false,
                                width: 43,
                                height: 43,
                                // imageUrl: notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}"),
                                imageUrl: '',
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: badgeData?[index].badgeData != null
                                  ? Image.network(
                                      "${badgeData?[index].badgeData?[0].badgeOther}",
                                      width: 50 * SizeConfig.scaleDiagonal,
                                      height: 50 * SizeConfig.scaleDiagonal,
                                    )
                                  : Container(),
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(color: Color(0xFFEAEAEA), thickness: 1),
                    sixPx,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        badgeData?[index].subChallengeId == null ? 'Standar' : '${badgeData?[index].subChallengeData?[0].nameChallenge}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF3E3E3E),
                          fontSize: 10,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    sixPx,
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: ShapeDecoration(
                        color: Color(0xFFE8E8E8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            badgeData?[index].subChallengeId == null ? 'Tampilan Avatar Default' : 'Berlaku hingga ${System().dateFormatter(badgeData?[index].endDatetime ?? '', 3)}',
                            style: const TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 6,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned.fill(
                    child: badgeData?[index].idBadge == cn.badgeUser?.idUserBadge
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: EdgeInsets.all(3),
                              child: const CustomIconWidget(
                                iconData: "${AssetPath.vectorPath}celebrity.svg",
                                defaultColor: false,
                              ),
                            ),
                          )
                        : Container()),
              ],
            ),
          ),
        );
      },
    );
  }
}
