import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_gesture.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/enum.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../widget/custom_elevated_button.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_profile_image.dart';
import '../../../../widget/custom_spacer.dart';

class OnLiveStreamStatus extends StatefulWidget {
  final String? idStream;
  final bool isViewer;
  final StreamerNotifier? notifier;
  const OnLiveStreamStatus({super.key, this.idStream, this.notifier, required this.isViewer});

  @override
  State<OnLiveStreamStatus> createState() => _OnLiveStreamStatusState();
}

class _OnLiveStreamStatusState extends State<OnLiveStreamStatus> {
  StreamerNotifier? streampro;
  ScrollController? controller;
  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      streampro = Provider.of<StreamerNotifier>(context, listen: false);
      streampro?.getViewer(context, mounted, idStream: widget.idStream);

      controller?.addListener(() {
        streampro?.getMoreViewer(context, mounted, widget.idStream, controller!);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    var profileImage = context.read<HomeNotifier>().profileImage;
    var profileImageKey = context.read<HomeNotifier>().profileImageKey;
    final isIndo = SharedPreference().readStorage(SpKeys.isoCode) == 'id';

    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: context.getColorScheme().background,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
              sixteenPx,
              Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: CustomTextWidget(
                  textAlign: TextAlign.center,
                  textToDisplay: (notifier.titleLive.isNotEmpty) ? (notifier.titleLive ?? '') : "${isIndo ? language.liveVideo : ''} ${notifier.userName} ${!isIndo ? language.liveVideo : ''}",
                  textStyle: context.getTextTheme().bodyText1?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              tenPx,
              const Divider(
                color: kHyppeSecondary,
              ),
              tenPx,
              Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: language.liveHost ?? '',
                  textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w700, color: kHyppeBurem),
                ),
              ),
              sixteenPx,
              Builder(builder: (context) {
                return Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: ItemAccount(
                    urlImage: widget.isViewer ? (notifier.dataStream.avatar?.mediaEndpoint ?? '') : (context.read<SelfProfileNotifier>().user.profile?.avatar?.mediaEndpoint) ?? '',
                    username: widget.isViewer ? (notifier.dataStream.username ?? '') : (context.read<SelfProfileNotifier>().user.profile?.username ?? ''),
                    name: widget.isViewer ? (notifier.dataStream.fullName ?? '') : (context.read<SelfProfileNotifier>().user.profile?.fullName ?? ''),
                    email: widget.isViewer ? (notifier.dataStream.email ?? '') : (context.read<SelfProfileNotifier>().user.profile?.email ?? ''),
                    sId: notifier.dataStream.sId ?? '',
                    isViewer: widget.isViewer,
                    notifier: notifier,
                  ),
                );
              }),
              eightPx,
              Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: language.whosWatching ?? '',
                  textStyle: context.getTextTheme().bodyText2?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (widget.isViewer)
                Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: CustomTextWidget(
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    textToDisplay: language.whosWatchingDetail ?? '',
                    textStyle: context.getTextTheme().bodyText2?.copyWith(color: kHyppeBurem),
                  ),
                ),
              eightPx,
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: notifier.isloadingViewers
                            ? const SizedBox(height: 10, child: Align(alignment: Alignment.topCenter, child: Padding(padding: EdgeInsets.only(top: 60), child: const CustomLoading())))
                            : ListView.builder(
                                controller: controller,
                                itemCount: notifier.dataViewers.length,
                                itemBuilder: (context, index) {
                                  final watcher = notifier.dataViewers[index];
                                  return ItemAccount(
                                    urlImage: watcher.avatar?.mediaEndpoint ?? '',
                                    name: watcher.fullName ?? '',
                                    username: watcher.username ?? '',
                                    isHost: false,
                                    index: index,
                                    sId: widget.idStream ?? '',
                                    length: notifier.dataViewers.length,
                                    isloading: notifier.isloadingViewersMore,
                                    email: watcher.email ?? '',
                                    idStream: widget.idStream,
                                    showThreeDot: true,
                                    isViewer: widget.isViewer,
                                    notifier: notifier,
                                  );
                                },
                              ),
                      ),
                      Visibility(
                        visible: notifier.dataViewers.length > 99,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                          child: CustomTextWidget(
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            textToDisplay: language.noteShowView99 ?? 'Menampilkan 99 penonton teratas yang peringkatnya diaktifkan',
                            textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, color: kHyppeBurem),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ItemAccount extends StatefulWidget {
  final String urlImage;
  final String username;
  final String email;
  final String name;
  final String sId;
  final bool isHost;
  final int? length;
  final int? index;
  final bool? isloading;
  final bool showThreeDot;
  final bool isViewer;
  final StreamerNotifier notifier;

  final String? idStream;
  const ItemAccount({
    super.key,
    required this.urlImage,
    required this.name,
    required this.username,
    required this.email,
    required this.sId,
    required this.isViewer,
    required this.notifier,
    this.isHost = true,
    this.isloading,
    this.index,
    this.length,
    this.idStream,
    this.showThreeDot = false,
  });

  @override
  State<ItemAccount> createState() => _ItemAccountState();
}

class _ItemAccountState extends State<ItemAccount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final streampro = Provider.of<StreamerNotifier>(context, listen: false);
      streampro.getProfileNCheckViewer(context, widget.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomProfileImage(
                  onTap: () async {
                    if (context.read<SelfProfileNotifier>().user.profile?.username != widget.username) {
                      Routing().moveBack();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        ShowBottomSheet.onWatcherStatus(Routing.navigatorKey.currentContext ?? context, widget.email, widget.sId);
                      });
                    }
                  },
                  width: 36,
                  height: 36,
                  following: true,
                  imageUrl: System().showUserPicture(widget.urlImage),
                  forStory: false,
                ),
                twelvePx,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        textAlign: TextAlign.left,
                        textToDisplay: widget.username,
                        textStyle: context.getTextTheme().bodyText2?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      fourPx,
                      CustomTextWidget(
                        textAlign: TextAlign.left,
                        textToDisplay: "${widget.name}${widget.isHost ? " • Host" : ''}",
                        textStyle: context.getTextTheme().caption?.copyWith(fontWeight: FontWeight.w400, color: kHyppeBurem),
                      ),
                    ],
                  ),
                ),
                if (!widget.isHost) tenPx,
                if (!widget.isHost && widget.showThreeDot && SharedPreference().readStorage(SpKeys.email) != widget.email)
                  CustomGesture(
                    margin: EdgeInsets.zero,
                    onTap: () async {
                      Routing().moveBack();
                      ShowBottomSheet.onWatcherStatus(context, widget.email ?? '', widget.idStream ?? '');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: const RotationTransition(
                        turns: AlwaysStoppedAnimation(90 / 360),
                        child: Align(alignment: Alignment.center, child: CustomIconWidget(width: 24, iconData: "${AssetPath.vectorPath}more.svg", color: Colors.black, defaultColor: false)),
                      ),
                    ),
                  ),
                // Text("${widget.notifier.statusFollowingViewer}"),
                if (widget.isHost && widget.isViewer)
                  CustomElevatedButton(
                    width: 100,
                    height: 24,
                    buttonStyle: ButtonStyle(
                      backgroundColor: (widget.notifier.statusFollowingViewer == StatusFollowing.requested || widget.notifier.statusFollowingViewer == StatusFollowing.following)
                          ? null
                          // : (widget.notifier.userName == widget.notifier.audienceProfile.username)
                          //     ? null
                          : MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                    ),
                    function: widget.notifier.isCheckLoading
                        ? null
                        : () {
                            if (widget.notifier.statusFollowingViewer == StatusFollowing.none || widget.notifier.statusFollowingViewer == StatusFollowing.rejected) {
                              widget.notifier.followUserViewer(context, widget.email, idMediaStreaming: widget.sId).then((value) {
                                widget.notifier.audienceProfileViewer.insight?.followers = widget.notifier.audienceProfileViewer.insight!.followers! + 1;
                              });
                            } else if (widget.notifier.statusFollowingViewer == StatusFollowing.following) {
                              widget.notifier.followUserViewer(context, widget.email, isUnFollow: true, idMediaStreaming: widget.sId).then((value) {
                                widget.notifier.audienceProfileViewer.insight?.followers = widget.notifier.audienceProfileViewer.insight!.followers! - 1;
                              });
                            }
                          },
                    child: widget.notifier.isCheckLoading
                        ? const CustomLoading()
                        : CustomTextWidget(
                            textToDisplay: widget.notifier.statusFollowingViewer == StatusFollowing.following
                                ? language.following ?? 'following '
                                : widget.notifier.statusFollowingViewer == StatusFollowing.requested
                                    ? language.requested ?? 'requested'
                                    : language.follow ?? 'follow',
                            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: (widget.notifier.statusFollowingViewer == StatusFollowing.requested || widget.notifier.statusFollowingViewer == StatusFollowing.following)
                                      ? kHyppeGrey
                                      : kHyppeLightButtonText,
                                ),
                          ),
                  ),
                // if (!isHost)
                //   CustomGesture(
                //     margin: EdgeInsets.zero,
                //     onTap: () async {
                //       await ShowGeneralDialog.generalDialog(context,
                //           titleText: "${language.remove} $username?",
                //           bodyText: "${language.messageRemoveUser1} $username ${language.messageRemoveUser2}",
                //           maxLineTitle: 1,
                //           maxLineBody: 4, functionPrimary: () async {
                //         Routing().moveBack();
                //       }, functionSecondary: () {
                //         Routing().moveBack();
                //       }, titleButtonPrimary: "${language.remove}", titleButtonSecondary: "${language.cancel}", barrierDismissible: true, isHorizontal: false);
                //     },
                //     child: Container(
                //       width: 86,
                //       height: 24,
                //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.transparent, border: Border.all(color: kHyppeBurem, width: 1)),
                //       alignment: Alignment.center,
                //       child: CustomTextWidget(
                //         textToDisplay: language.removeUser ?? '',
                //         textAlign: TextAlign.center,
                //         textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                //       ),
                //     ),
                //   ),
              ],
            ),
            if (widget.length == ((widget.index ?? 0) + 1) && (widget.isloading ?? false)) const CustomLoading(size: 4),
          ],
        ),
      ),
    );
  }
}
