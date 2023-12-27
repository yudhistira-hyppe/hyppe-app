import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../../widget/custom_text_widget.dart';
import 'on_live_stream_status.dart';

class OnWatcherStatus extends StatefulWidget {
  final String? email;
  final String? idMediaStreaming;
  const OnWatcherStatus({super.key, this.email, this.idMediaStreaming});

  @override
  State<OnWatcherStatus> createState() => _OnWatcherStatusState();
}

class _OnWatcherStatusState extends State<OnWatcherStatus> {
  StreamerNotifier? streampro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      streampro = Provider.of<StreamerNotifier>(context, listen: false);
      streampro?.getProfileNCheck(context, widget.email ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    final isIndo = SharedPreference().readStorage(SpKeys.isoCode) == 'id';
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Container(
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
                      ItemAccount(
                        urlImage: notifier.audienceProfile.avatar?.mediaEndpoint ?? '',
                        name: notifier.audienceProfile.fullName ?? '',
                        username: notifier.audienceProfile.username ?? '',
                        isHost: false,
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
                              : (notifier.userName == notifier.audienceProfile.username) ? null : MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                        ),
                        function: notifier.isCheckLoading
                            ? null
                            : (notifier.userName == notifier.audienceProfile.username) ? null :() {
                                if (notifier.statusFollowing == StatusFollowing.none || notifier.statusFollowing == StatusFollowing.rejected) {
                                  notifier.followUser(context, widget.email, idMediaStreaming: widget.idMediaStreaming);
                                } else if (notifier.statusFollowing == StatusFollowing.following) {
                                  notifier.followUser(context, widget.email, isUnFollow: true, idMediaStreaming: widget.idMediaStreaming);
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
