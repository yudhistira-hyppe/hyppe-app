import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/content_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/shimmer_list_end.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:provider/provider.dart';

class ListEndDetail extends StatefulWidget {
  final bool? isWinner;
  const ListEndDetail({super.key, this.isWinner});

  @override
  State<ListEndDetail> createState() => _ListEndDetailState();
}

class _ListEndDetailState extends State<ListEndDetail> {
  LocalizationModelV2? lang;

  @override
  void initState() {
    super.initState();
    lang = context.read<TranslateNotifierV2>().translate;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      var participant = 0;
      if (cn.leaderBoardDetaiEndlData?.challengeData?[0].objectChallenge == "KONTEN") {
        cn.leaderBoardDetaiEndlData?.getlastrank?.forEach((element) {
          if (element.postChallengess?.isNotEmpty ?? [].isEmpty) {
            participant++;
          }
        });
      } else {
        cn.leaderBoardDetaiEndlData?.getlastrank?.forEach((element) {
          participant++;
        });
      }

      return cn.isLoading
          ? const ShimmerListLeaderboardEnd()
          : SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ShowBottomSheet.onPeriodChallange(
                              context,
                              cn.leaderBoardDetaiEndlData?.challengeId ?? '',
                              true,
                              cn.selectOptionSession,
                              isWinner: widget.isWinner ?? false,
                            );
                            print(cn.selectOptionSession);
                          },
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${lang?.challengePeriod} ${cn.selectOptionSession}',
                                  style: TextStyle(
                                    color: Color(0xFF9B9B9B),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: kHyppeTextLightPrimary,
                                )
                              ],
                            ),
                          ),
                        ),
                        // Text("${cn.leaderBoardDetaiEndlData?.getlastrank}"),
                        // Text("asdasdasd"),
                        cn.isLoadingLeaderboard
                            ? Container()
                            : (cn.leaderBoardDetaiEndlData?.getlastrank?.isEmpty ?? [].isEmpty) || cn.leaderBoardDetaiEndlData?.status == "BERLANGSUNG"
                                ? Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: CustomEmptyWidget(
                                      title: lang?.theresNoLeaderboardAvailable ?? 'Belum ada Leaderboard Tersedia',
                                      subtitle: lang?.getFirstPlaceByEnteringThisExcitingCompetition ?? "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                    ),
                                  )
                                : cn.leaderBoardDetaiEndlData?.getlastrank?[0].score == 0 || participant == 0
                                    ? Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: CustomEmptyWidget(
                                          title: lang?.theresNoLeaderboardAvailable ?? 'Belum ada Leaderboard Tersedia',
                                          subtitle: lang?.getFirstPlaceByFollowingThisExciting ?? "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                        ),
                                      )
                                    : ScrollConfiguration(
                                        behavior: const ScrollBehavior().copyWith(overscroll: false),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 24),
                                          child: ListView.builder(
                                            itemCount: cn.leaderBoardDetaiEndlData?.getlastrank?.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              if (cn.leaderBoardDetaiEndlData?.getlastrank?[index].score == 0) {
                                                return Container();
                                              } else {
                                                if (cn.leaderBoardDetaiEndlData?.challengeData?[0].objectChallenge == 'KONTEN') {
                                                  return GestureDetector(
                                                      onTap: () {
                                                        var post = cn.leaderBoardDetaiEndlData?.getlastrank?[index].postChallengess?[0];
                                                        var email = cn.leaderBoardDetaiEndlData?.getlastrank?[index].email;
                                                        cn.navigateToScreen(
                                                          context,
                                                          post?.index,
                                                          email,
                                                          post?.postType,
                                                          indexContent: cn.leaderBoardDetaiEndlData?.getlastrank?[index].postChallengess?[0].index,
                                                          postId: post?.postID,
                                                        );
                                                      },
                                                      child: ContentLeaderboard(
                                                        data: cn.leaderBoardDetaiEndlData?.getlastrank?[index],
                                                        statusPengguna: cn.leaderBoardDetaiEndlData?.challengeData?[0].tampilStatusPengguna,
                                                      ));
                                                } else {
                                                  return GestureDetector(
                                                      onTap: () {
                                                        System().navigateToProfile(context, cn.leaderBoardDetaiEndlData?.getlastrank?[index].email ?? '');
                                                        // Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: cn.leaderBoardDetaiEndlData?.getlastrank?[index].email));
                                                      },
                                                      child: ItemLeader(
                                                        data: cn.leaderBoardDetaiEndlData?.getlastrank?[index],
                                                        dataStatusLead: cn.leaderBoardDetaiEndlData?.challengeData?[0].leaderBoard?[0],
                                                        statusPengguna: cn.leaderBoardDetaiEndlData?.challengeData?[0].tampilStatusPengguna,
                                                      ));
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                      ],
                    ),
                  ),
                ],
              ),
            );
    });
  }
}
