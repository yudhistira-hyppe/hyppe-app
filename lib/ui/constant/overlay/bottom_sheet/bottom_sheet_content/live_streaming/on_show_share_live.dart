import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class OnShowShareLiveBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final bool isViewer;
  const OnShowShareLiveBottomSheet({Key? key, required this.scrollController, this.isViewer = false}) : super(key: key);

  @override
  State<OnShowShareLiveBottomSheet> createState() => _OnShowShareLiveBottomSheetState();
}

class _OnShowShareLiveBottomSheetState extends State<OnShowShareLiveBottomSheet> {
  final FocusNode _focus = FocusNode();
  final _debouncer = Debouncer(milliseconds: 600);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreamerNotifier>().searchUserCtrl.clear();
      context.read<StreamerNotifier>().getUserShare(context, mounted);
    });
    super.initState();
    _focus.addListener(_onFocusChange);
    widget.scrollController.addListener(() {
      context.read<StreamerNotifier>().loadMore(context, widget.scrollController);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    debugPrint("Focus: -- kaka ${_focus.hasFocus.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    var trans = context.read<TranslateNotifierV2>().translate;

    return Consumer2<StreamerNotifier, ViewStreamingNotifier>(builder: (_, notifier, viewNotifier, __) {
      if (widget.isViewer && viewNotifier.isOver) {
        Navigator.pop(Routing.navigatorKey.currentContext ?? context);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: Row(
              children: [
                _search(notifier.searchUserCtrl),
                if (!_focus.hasFocus) sixPx,
                if (!_focus.hasFocus)
                  GestureDetector(
                    onTap: () async {
                      if (widget.isViewer) {
                        await context.read<ViewStreamingNotifier>().createLinkStream(context, copiedToClipboard: true, description: 'Link Streamer');
                      } else {
                        await notifier.createLinkStream(context, copiedToClipboard: true, description: 'Link Streamer');
                      }
                      Routing().moveBack();
                    },
                    child: _iconButton(
                      child: const CustomIconWidget(height: 23, iconData: "${AssetPath.vectorPath}link.svg", color: kHyppeTextLightPrimary, defaultColor: false),
                    ),
                  ),
                if (!_focus.hasFocus) sixPx,
                if (!_focus.hasFocus)
                  GestureDetector(
                    onTap: () async {
                      if (widget.isViewer) {
                        await context.read<ViewStreamingNotifier>().createLinkStream(context, copiedToClipboard: false, description: 'Link Streamer');
                      } else {
                        await notifier.createLinkStream(context, copiedToClipboard: false, description: 'Link Streame');
                      }
                      Routing().moveBack();
                    },
                    child: _iconButton(
                      child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}share2.svg", color: kHyppeTextLightPrimary, defaultColor: false),
                    ),
                  ),
              ],
            ),
          ),
          _listUser(),
          // Text("${notifier.shareUsers.length}"),
          if (notifier.shareUsers.isNotEmpty)
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
              child: Column(
                children: [
                  TextFormField(
                    controller: notifier.messageShareCtrl,
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
                    decoration: InputDecoration(
                        hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: kHyppeBurem),
                        hintText: trans.pleaseEnterMessage,
                        contentPadding: const EdgeInsets.only(left: 16),
                        border: InputBorder.none,
                        // focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: ''),
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
                    child: ButtonChallangeWidget(
                      function: () {
                        notifier.sendShareMassage(context, isViewer: widget.isViewer);
                      },
                      text: 'Kirim Secara Terpisah',
                      bgColor: kHyppePrimary,
                    ),
                  ),
                ],
              ),
            )
        ],
      );
    });
  }

  Widget _iconButton({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kHyppeBorderTab),
      ),
      child: Material(
        color: kHyppeLightSurface,
        shape: const CircleBorder(),
        child: InkWell(
          splashColor: Colors.black,
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            height: 50,
            width: 50,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _search(TextEditingController searchUserCtrl) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kHyppeLightSurface,
          border: Border.all(color: kHyppeBorderTab),
          borderRadius: const BorderRadius.all(
            Radius.circular(32),
          ),
        ),
        child: TextFormField(
          controller: searchUserCtrl,
          focusNode: _focus,
          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
          decoration: InputDecoration(
              prefixIcon: CustomIconButtonWidget(
                height: 24,
                defaultColor: false,
                onPressed: () {},
                iconData: "${AssetPath.vectorPath}search.svg",
                color: kHyppeTextLightPrimary,
              ),
              // suffix: Positioned(top: 0, child: CustomIconWidget(iconData: "${AssetPath.vectorPath}close-solid.svg")),
              // suffix:
              suffixIcon: _focus.hasFocus
                  ? CustomIconButtonWidget(
                      height: 24,
                      defaultColor: false,
                      onPressed: () {
                        searchUserCtrl.text = '';
                        context.read<StreamerNotifier>().getUserShare(context, mounted);
                      },
                      iconData: "${AssetPath.vectorPath}close-solid.svg",
                    )
                  : Container(
                      height: 24,
                      width: 10,
                    ),
              hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: kHyppeBurem),
              hintText: 'Cari',
              contentPadding: EdgeInsets.only(top: 12),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              counterText: ''),
          textInputAction: TextInputAction.search,
          maxLines: 1,
          onChanged: (value) {
            _debouncer.run(() {
              context.read<StreamerNotifier>().getUserShare(context, mounted);
            });
          },
        ),
      ),
    );
  }

  Widget _listUser() {
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) {
        return Expanded(
          child: notifier.isloadingUserShare
              ? Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
                  child: const CustomLoading(
                    size: 6,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  // margin: EdgeInsets.only(bottom: 100),
                  child: ListView.builder(
                    controller: widget.scrollController,
                    itemCount: notifier.listShareUser.length,
                    itemBuilder: (context, index) {
                      var data = notifier.listShareUser[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: CustomProfileImage(
                                  cacheKey: '',
                                  following: true,
                                  forStory: false,
                                  width: 36 * SizeConfig.scaleDiagonal,
                                  height: 36 * SizeConfig.scaleDiagonal,
                                  imageUrl: System().showUserPicture(data.avatar?.mediaEndpoint),
                                  // badge: notifier.user.profile?.urluserBadge,
                                  allwaysUseBadgePadding: false,
                                ),
                              ),
                              twelvePx,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(data.username ?? '', style: const TextStyle(fontSize: 16, color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700)),
                                        if (data.isVerified ?? false)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 3.0),
                                            child: CustomIconWidget(
                                              iconData: "${AssetPath.vectorPath}ic_verified.svg",
                                              defaultColor: false,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      data.fullName ?? '',
                                      style: const TextStyle(color: Color(0xff9b9b9b)),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                    value: data.isSelected ?? false,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (value) {
                                      setState(() {
                                        data.isSelected = value;
                                      });
                                      print("hhahaha $value");
                                      if (value == true) {
                                        notifier.insertListShare(data);
                                      } else {
                                        notifier.removeListShare(data);
                                      }
                                    },
                                    checkColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                      if (states.contains(MaterialState.disabled)) {
                                        return Colors.orange.withOpacity(.32);
                                      }
                                      if (!(data.isSelected ?? false)) {
                                        return Colors.white;
                                      }
                                      return kHyppePrimary;
                                    })),
                              ),
                              // const Icon(
                              //   Icons.check_box,
                              //   color: kHyppePrimary,
                              // )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
