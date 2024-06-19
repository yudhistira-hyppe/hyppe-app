import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../../widget/custom_text_widget.dart';
import 'on_live_stream_status.dart';

class OnWatcherStatus extends StatefulWidget {
  final BuildContext? contextAsal;
  final String? email;
  final String? idMediaStreaming;
  final bool isViewer;
  const OnWatcherStatus({super.key, this.email, this.idMediaStreaming, this.isViewer = true, this.contextAsal});

  @override
  State<OnWatcherStatus> createState() => _OnWatcherStatusState();
}

class _OnWatcherStatusState extends State<OnWatcherStatus> {
  StreamerNotifier? streampro;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewStreamingNotifier>().buttonSheetProfil = true;
      streampro = Provider.of<StreamerNotifier>(context, listen: false);
      streampro?.getProfileNCheck(context, widget.email ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Consumer2<StreamerNotifier, ViewStreamingNotifier>(
      builder: (_, notifier, viewNotifier, __) => Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
        decoration: BoxDecoration(
          color: context.getColorScheme().background,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            // Text("${widget.contextAsal}"),
            notifier.isloadingProfile
                ? const Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: CustomLoading(
                        size: 10,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      sixteenPx,
                      // SelectableText("${System().showUserPicture(notifier.audienceProfile.avatar?.mediaEndpoint)}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: ItemAccount(
                              urlImage: notifier.audienceProfile.avatar?.mediaEndpoint ?? '',
                              name: notifier.audienceProfile.fullName ?? '',
                              username: notifier.audienceProfile.username ?? '',
                              email: notifier.audienceProfile.email ?? '',
                              sId: notifier.dataStream.sId ?? '',
                              isHost: false,
                              isViewer: widget.isViewer,
                              notifier: notifier,
                              canTap: false,
                              userId: notifier.audienceProfile.idUser ?? '',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.pop(context);

                              if (widget.isViewer) {
                                if (notifier.audienceProfile.username == viewNotifier.dataStreaming.user?.username) {
                                  Navigator.pop(context);
                                  viewNotifier.reportLive(context);
                                }
                              } else {
                                Navigator.pop(context);
                                ShowGeneralDialog.generalDialog(
                                  widget.contextAsal,
                                  titleText: "${language.delete} ${notifier.audienceProfile.username}? ",
                                  bodyText: "${language.messageRemoveUser1} ${notifier.audienceProfile.username}${language.messageRemoveUser2}",
                                  titleButtonPrimary: "${language.removeUser}",
                                  titleButtonSecondary: "${language.cancel}",
                                  isHorizontal: false,
                                  barrierDismissible: true,
                                  functionPrimary: () {
                                    notifier.kickUser(
                                      widget.contextAsal ?? context,
                                      widget.contextAsal?.mounted ?? context.mounted,
                                      notifier.audienceProfile.idUser ?? '',
                                      notifier.audienceProfile.username ?? '',
                                    );
                                  },
                                  functionSecondary: () => Routing().moveBack(),
                                );
                              }
                            },
                            child: Align(
                                alignment: Alignment.center,
                                child: widget.isViewer
                                    ? (notifier.audienceProfile.username == viewNotifier.dataStreaming.user?.username)
                                        ? CircleAvatar(
                                            radius: 18,
                                            backgroundColor: kHyppeBurem.withOpacity(.2),
                                            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}flag.svg"),
                                          )
                                        : const SizedBox.shrink()
                                    : Container()

                                //  Container(
                                //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(12),
                                //       border: Border.all(color: Colors.black.withOpacity(0.4)),
                                //     ),
                                //     child: Text(
                                //       notifier.tn?.removeListLive ?? 'Keluarkan',
                                //       style: const TextStyle(fontWeight: FontWeight.bold),
                                //     ),
                                //   ),
                                ),
                          )
                        ],
                      ),
                      twentyPx,
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: WatcherStatusItem(
                                value: System().formatterNumber((notifier.audienceProfile.insight?.posts ?? 0).toInt()),
                                title: language.posts ?? '',
                              ),
                            ),
                            Flexible(
                              child: WatcherStatusItem(
                                value: System().formatterNumber((notifier.audienceProfile.insight?.followers ?? 0).toInt()),
                                title: notifier.audienceProfile.insight?.followers == 1 ? (language.follower ?? '') : (language.followers ?? ''),
                              ),
                            ),
                            Flexible(
                              child: WatcherStatusItem(
                                value: System().formatterNumber((notifier.audienceProfile.insight?.followings ?? 0).toInt()),
                                title: language.following ?? '',
                              ),
                            ),
                          ],
                        ),
                      ),
                      sixteenPx,
                      CustomElevatedButton(
                        width: SizeConfig.screenWidth,
                        height: 42 * SizeConfig.scaleDiagonal,
                        buttonStyle: ButtonStyle(
                          backgroundColor: (notifier.statusFollowing == StatusFollowing.requested || notifier.statusFollowing == StatusFollowing.following)
                              ? null
                              : MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                        ),
                        function: notifier.isCheckLoading
                            ? null
                            // : (notifier.userName == notifier.audienceProfile.username)
                            //     ? null
                            : () {
                                if (notifier.statusFollowing == StatusFollowing.none || notifier.statusFollowing == StatusFollowing.rejected) {
                                  notifier.followUser(context, widget.email, idMediaStreaming: widget.idMediaStreaming).then((value) {
                                    notifier.audienceProfile.insight?.followers = notifier.audienceProfile.insight!.followers! + 1;
                                  });
                                } else if (notifier.statusFollowing == StatusFollowing.following) {
                                  notifier.followUser(context, widget.email, isUnFollow: true, idMediaStreaming: widget.idMediaStreaming).then((value) {
                                    notifier.audienceProfile.insight?.followers = notifier.audienceProfile.insight!.followers! - 1;
                                  });
                                }
                              },
                        child: notifier.isCheckLoading
                            ? const CustomLoading()
                            : CustomTextWidget(
                                textToDisplay: notifier.statusFollowing == StatusFollowing.following
                                    ? language.following ?? 'following '
                                    : notifier.statusFollowing == StatusFollowing.requested
                                        ? language.requested ?? 'requested'
                                        : language.follow ?? 'follow',
                                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: (notifier.statusFollowing == StatusFollowing.requested || notifier.statusFollowing == StatusFollowing.following) ? kHyppeGrey : kHyppeLightButtonText,
                                    ),
                              ),
                      ),
                      // CustomGesture(
                      //   margin: EdgeInsets.zero,
                      //   onTap: () {},
                      //   child: Container(
                      //     width: double.infinity,
                      //     height: 44,
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(8),
                      //         // color: context.getColorScheme().primary.withOpacity(0.9),
                      //         color: Colors.red),
                      //     alignment: Alignment.center,
                      //     child: CustomTextWidget(
                      //       textToDisplay: language.follow ?? '',
                      //       textAlign: TextAlign.center,
                      //       textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      //     ),
                      //   ),
                      // ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}

class WatcherStatusItem extends StatelessWidget {
  final String value;
  final String title;
  const WatcherStatusItem({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomTextWidget(
          textToDisplay: value,
          textStyle: context.getTextTheme().bodyText1?.copyWith(fontWeight: FontWeight.w700),
        ),
        fourPx,
        CustomTextWidget(
          textToDisplay: title,
          textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, color: kHyppeBurem),
        ),
      ],
    );
  }
}
