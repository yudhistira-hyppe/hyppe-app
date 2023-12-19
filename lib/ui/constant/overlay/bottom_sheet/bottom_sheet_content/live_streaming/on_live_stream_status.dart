import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_profile_image.dart';
import '../../../../widget/custom_spacer.dart';

class OnLiveStreamStatus extends StatefulWidget {
  final String? idStream;
  final StreamerNotifier? notifier;
  const OnLiveStreamStatus({super.key, this.idStream, this.notifier});

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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            sixteenPx,
            CustomTextWidget(
              textToDisplay: "${isIndo ? language.liveVideo : ''}natalia.jessica${!isIndo ? language.liveVideo : ''}",
              textStyle: context.getTextTheme().bodyText1?.copyWith(fontWeight: FontWeight.w700),
            ),
            sixteenPx,
            CustomTextWidget(
              textAlign: TextAlign.left,
              textToDisplay: language.liveHost ?? '',
              textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w700, color: kHyppeBurem),
            ),
            sixteenPx,
            ItemAccount(urlImage: profileImage, username: widget.notifier?.titleLive ?? '', name: widget.notifier?.userName ?? ''),
            eightPx,
            CustomTextWidget(
              textAlign: TextAlign.left,
              textToDisplay: language.whosWatching ?? '',
              textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w700, color: kHyppeBurem),
            ),
            eightPx,
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
                          length: notifier.dataViewers.length,
                          isloading: notifier.isloadingViewersMore,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class Watcher {
  final String? image;
  final String? username;
  final String? name;
  final bool isFollowing;
  const Watcher({this.image, this.username, this.name, this.isFollowing = true});
}

class ItemAccount extends StatelessWidget {
  final String urlImage;
  final String username;
  final String name;
  final bool isHost;
  final int? length;
  final int? index;
  final bool? isloading;
  const ItemAccount({
    super.key,
    required this.urlImage,
    required this.name,
    required this.username,
    this.isHost = true,
    this.isloading,
    this.index,
    this.length,
  });

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomProfileImage(
                width: 36,
                height: 36,
                following: true,
                imageUrl: System().showUserPicture(urlImage),
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
                      textToDisplay: username,
                      textStyle: context.getTextTheme().bodyText2?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    fourPx,
                    CustomTextWidget(
                      textAlign: TextAlign.left,
                      textToDisplay: "$name${isHost ? " • Host" : ''}",
                      textStyle: context.getTextTheme().caption?.copyWith(fontWeight: FontWeight.w400, color: kHyppeBurem),
                    ),
                  ],
                ),
              ),
              if (!isHost) tenPx,
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
          if (length == ((index ?? 0) + 1) && (isloading ?? false)) const CustomLoading(size: 4),
        ],
      ),
    );
  }
}
