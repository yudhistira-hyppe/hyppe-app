import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/view_streaming_argument.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_gesture.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../ux/path.dart';
import '../../../../../../../ux/routing.dart';
import '../../../../../../constant/widget/icon_button_widget.dart';
import '../notifier.dart';

class ListStreamersScreen extends StatefulWidget {
  const ListStreamersScreen({super.key});

  @override
  State<ListStreamersScreen> createState() => _ListStreamersScreenState();
}

class _ListStreamersScreenState extends State<ListStreamersScreen> with TickerProviderStateMixin, AfterFirstLayoutMixin, WidgetsBindingObserver, RouteAware {
  late AnimationController _controller;

  final scrollController = ScrollController();

  @override
  void initState() {
    final notifier = Routing.navigatorKey.currentContext?.read<ViewStreamingNotifier>();
    notifier?.initListStreamers();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      (Routing.navigatorKey.currentContext ?? context).read<ViewStreamingNotifier>().getListStreamers(Routing.navigatorKey.currentContext ?? context, mounted);
    });
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.reset();
      }
    });
    scrollController.addListener(() {
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
        if (notifier != null) {
          if (notifier.listStreamers.length % 20 == 0) {
            notifier.getListStreamers(context, mounted, isReload: false);
          }
        }
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  String? displayPhotoProfileOriginal(String url) {
    try {
      var orginial = url.split('/');
      var endpoint = "/profilepict/orignal/${orginial.last}";
      return System().showUserPicture(endpoint);
    } catch (e) {
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    print("ini didpooooop next ======");
    Routing.navigatorKey.currentContext?.read<ViewStreamingNotifier>().initListStreamers();
    (Routing.navigatorKey.currentContext ?? context).read<ViewStreamingNotifier>().getListStreamers(Routing.navigatorKey.currentContext ?? context, mounted);
    super.didPopNext();
  }

  @override
  void didPop() {
    print("ini didpooooop ======");
    super.didPop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewStreamingNotifier>(builder: (context, notifier, _) {
      final sizeTile = (context.getWidth() - 12) / 2;
      return Scaffold(
        appBar: AppBar(
          leading: CustomIconButtonWidget(
            onPressed: () {
              Routing().moveBack();
            },
            color: Colors.black,
            iconData: '${AssetPath.vectorPath}back-arrow.svg',
            padding: const EdgeInsets.only(right: 16, left: 16),
          ),
          title: Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: const CustomTextWidget(textToDisplay: 'HyppeLive', textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _controller
                    ..duration = const Duration(seconds: 2)
                    ..forward();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.exploreLiveToLivenUpYourDay ?? 'Serunya LIVE untuk ramaikan harimu!',
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  strokeWidth: 2.0,
                  color: Colors.purple,
                  onRefresh: () async {
                    await notifier.getListStreamers(context, mounted);
                  },
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: notifier.listStreamers.isEmpty && !notifier.loading
                        ? Container(
                            width: double.infinity,
                            height: context.getHeight() * 0.85,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 187,
                                  width: 187,
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage('${AssetPath.pngPath}empty_data.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                CustomTextWidget(
                                  textToDisplay: notifier.language.emptyStreamers ?? '',
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                CustomTextWidget(
                                  textToDisplay: notifier.language.messageEmptyStreamers ?? '',
                                  textStyle: const TextStyle(fontSize: 12, color: kHyppeBurem),
                                ),
                                const SizedBox(
                                  height: 120,
                                )
                              ],
                            ))
                        : SizedBox(
                            height: (notifier.listStreamers.length <= 6 && !notifier.loading) ? (context.getHeight() * 0.85) : null,
                            child: Wrap(
                              children: [
                                ...List.generate(notifier.loading ? 10 : notifier.listStreamers.length, (index) {
                                  if (notifier.loading) {
                                    if (index % 2 == 0) {
                                      return Container(
                                        width: sizeTile,
                                        height: sizeTile,
                                        margin: const EdgeInsets.only(left: 4, right: 2, bottom: 4, top: 4),
                                        child: CustomShimmer(
                                          width: sizeTile,
                                          height: sizeTile,
                                          radius: 8,
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width: sizeTile,
                                        height: sizeTile,
                                        margin: const EdgeInsets.only(left: 2, right: 4, bottom: 4, top: 4),
                                        child: CustomShimmer(
                                          width: sizeTile,
                                          height: sizeTile,
                                          radius: 8,
                                        ),
                                      );
                                    }
                                  } else {
                                    final streamer = notifier.listStreamers[index];
                                    // return Lottie.asset(
                                    //   "${AssetPath.jsonPath}loveicon.json",
                                    //   width: sizeTile,
                                    //   height: sizeTile + 150,
                                    //   repeat: false,
                                    //   controller: _controller
                                    // );
                                    if (notifier.listStreamers.length == 1) {
                                      return Container(
                                        width: double.infinity,
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          width: sizeTile,
                                          height: sizeTile,
                                          margin: const EdgeInsets.only(left: 4, right: 2, bottom: 4, top: 4),
                                          child: CustomGesture(
                                            onTap: () {
                                              Routing().move(Routes.viewStreaming, argument: ViewStreamingArgument(data: streamer));
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(child: streamerImage(displayPhotoProfileOriginal(streamer.avatar?.mediaEndpoint ?? '') ?? '')),
                                                  Positioned(
                                                    top: 8,
                                                    right: 14,
                                                    child: Container(
                                                      padding: const EdgeInsets.only(left: 4, right: 8, top: 2, bottom: 2),
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.black.withOpacity(0.5)),
                                                      child: Row(
                                                        children: [
                                                          const CustomIconWidget(
                                                            iconData: '${AssetPath.vectorPath}eye.svg',
                                                            width: 16,
                                                            height: 16,
                                                            defaultColor: false,
                                                          ),
                                                          fourPx,
                                                          CustomTextWidget(
                                                            textToDisplay: streamer.totalView?.getCountShort() ?? '0',
                                                            textStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 10,
                                                    bottom: 14,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (streamer.title != null)
                                                          CustomTextWidget(
                                                            textToDisplay: streamer.title ?? '',
                                                            textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                                          ),
                                                        twoPx,
                                                        CustomTextWidget(
                                                          textToDisplay: streamer.username ?? '',
                                                          textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    if (index % 2 == 0) {
                                      return Container(
                                        width: sizeTile,
                                        height: sizeTile,
                                        margin: const EdgeInsets.only(left: 4, right: 2, bottom: 4, top: 4),
                                        child: CustomGesture(
                                          onTap: () async {
                                            await Routing().move(Routes.viewStreaming, argument: ViewStreamingArgument(data: streamer));
                                            // notifier.getListStreamers(Routing.navigatorKey.currentContext ?? context, mounted);
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(child: streamerImage(displayPhotoProfileOriginal(streamer.avatar?.mediaEndpoint ?? '') ?? '')),
                                                Positioned(
                                                  top: 8,
                                                  right: 14,
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 4, right: 8, top: 2, bottom: 2),
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.black.withOpacity(0.5)),
                                                    child: Row(
                                                      children: [
                                                        const CustomIconWidget(
                                                          iconData: '${AssetPath.vectorPath}eye.svg',
                                                          width: 16,
                                                          height: 16,
                                                          defaultColor: false,
                                                        ),
                                                        fourPx,
                                                        CustomTextWidget(
                                                          textToDisplay: streamer.totalView?.getCountShort() ?? '0',
                                                          textStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 10,
                                                  bottom: 14,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if (streamer.title != null)
                                                        CustomTextWidget(
                                                          textToDisplay: streamer.title ?? '',
                                                          textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                                        ),
                                                      twoPx,
                                                      CustomTextWidget(
                                                        textToDisplay: streamer.username ?? '',
                                                        textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width: sizeTile,
                                        height: sizeTile,
                                        margin: const EdgeInsets.only(left: 2, right: 4, bottom: 4, top: 4),
                                        child: CustomGesture(
                                          onTap: () {
                                            Routing().move(Routes.viewStreaming, argument: ViewStreamingArgument(data: streamer));
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(child: streamerImage(displayPhotoProfileOriginal(streamer.avatar?.mediaEndpoint ?? '') ?? '')),
                                                Positioned(
                                                  top: 8,
                                                  right: 14,
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 4, right: 8, top: 2, bottom: 2),
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.black.withOpacity(0.5)),
                                                    child: Row(
                                                      children: [
                                                        const CustomIconWidget(
                                                          iconData: '${AssetPath.vectorPath}eye.svg',
                                                          width: 16,
                                                          height: 16,
                                                          defaultColor: false,
                                                        ),
                                                        fourPx,
                                                        CustomTextWidget(
                                                          textToDisplay: streamer.totalView?.getCountShort() ?? '0',
                                                          textStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 10,
                                                  bottom: 14,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if (streamer.title != null)
                                                        CustomTextWidget(
                                                          textToDisplay: streamer.title ?? '',
                                                          textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                                        ),
                                                      twoPx,
                                                      CustomTextWidget(
                                                        textToDisplay: streamer.username ?? '',
                                                        textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }),
                                ...[
                                  if (notifier.loadMore && !notifier.stopLoad)
                                    Container(
                                      width: double.infinity,
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: const CustomLoading(),
                                    )
                                ]
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget streamerImage(String image) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.center,
          child: CustomLoading(),
        ),
        Positioned.fill(
            child: Image.network(
          image,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth);
          },
        )),
      ],
    );
  }
}

class Streamer {
  final String? image;
  final String? username;
  final String? name;
  final bool isFollowing;
  final String? streamDesc;
  final int watchersCount;
  const Streamer({this.image, this.username, this.name, this.isFollowing = true, this.streamDesc, this.watchersCount = 0});
}
