import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/bottom_detail.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../../../core/arguments/hashtag_argument.dart';
import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/services/route_observer_service.dart';
import '../../../constant/widget/custom_base_cache_image.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/icon_button_widget.dart';

class DetailHashtagScreen extends StatefulWidget {
  HashtagArgument argument;
  DetailHashtagScreen({Key? key, required this.argument})
      : super(key: key);

  @override
  State<DetailHashtagScreen> createState() => _DetailHashtagScreenState();
}

class _DetailHashtagScreenState extends State<DetailHashtagScreen>
    with RouteAware, AfterFirstLayoutMixin {
  final ScrollController _scrollController = ScrollController();
  // final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  int heightTab = 0;

  @override
  void didPop() {
    'DetailHashtagScreen didPop'.logger();
    super.didPop();
  }


  @override
  void didPush() {
    'DetailHashtagScreen didPush'.logger();
    super.didPush();
  }


  @override
  void didPushNext() {
    'DetailHashtagScreen didPushNext'.logger();
    super.didPushNext();
  }


  @override
  void didPopNext() {
    'DetailHashtagScreen didPopNext'.logger();
    final notifier = context.read<SearchNotifier>();
    notifier.getDetailHashtag(
        context, widget.argument.hashtag.tag?.replaceAll(' ', '') ?? ' ').whenComplete((){
      Future.delayed(Duration(milliseconds: 500), () {
        var jumpTo = heightTab + notifier.heightIndex - 10;
        print("jumpt ====== ${jumpTo}");
        print("jumpt ====== ${heightTab}");
        print("jumpt ====== ${notifier.heightIndex}");
        _scrollController.jumpTo(jumpTo.toDouble());
      });
    });

    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    final tag = widget.argument.hashtag.tag;
    if(tag != null){
      context.read<SearchNotifier>().deleteMapHashtag(tag);
    }

    print('Deactivate Hashtag Detail');
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    CustomRouteObserver.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'DetailHashtagScreen');
    final notifier = context.read<SearchNotifier>();
    notifier.initDetailHashtag();

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SearchNotifier>();
    var tag = widget.argument.hashtag.tag;
    if(widget.argument.fromRoute){
      tag = tag?.replaceAll(' ', '');
    }
    notifier.getDetailHashtag(
        context, tag?.replaceAll(' ', '') ?? ' ');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: CustomIconButtonWidget(
          onPressed: (){
            if(widget.argument.fromRoute){
              Routing().moveBack();
            }else{
              context.read<SearchNotifier>().backFromSearchMore();
            }
          },
          defaultColor: false,
          iconData: "${AssetPath.vectorPath}back-arrow.svg",
          color: Theme.of(context).colorScheme.onSurface,
        ),
        title: CustomTextWidget(
          textToDisplay: widget.argument.isTitle
              ? (context.read<SearchNotifier>().language.popularHashtag ?? 'Popular Hashtag')
              : ('#${widget.argument.hashtag.tag}' ),
          textStyle: context
              .getTextTheme()
              .bodyText1
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<SearchNotifier>(builder: (context, notifier, _){
              return MeasuredSize(
                onChange: (Size size) {
                  heightTab = size.height.toInt();
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 16, top: 16, right: 16, bottom: 12),
                  child: Column(
                    children: [
                      !notifier.loadTagDetail ? Row(
                        children: [Builder(builder: (context) {

                          return CustomBaseCacheImage(
                            imageUrl: notifier.tagImageMain,
                            memCacheWidth: 70,
                            memCacheHeight: 70,
                            imageBuilder: (_, imageProvider) {
                              return Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: imageProvider,
                                  ),
                                ),
                              );
                            },
                            errorWidget: (_, __, ___) {
                              return Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: const AssetImage('${AssetPath.pngPath}default_hashtag.png'),
                                  ),
                                ),
                              );
                            },
                            emptyWidget: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: const AssetImage('${AssetPath.pngPath}default_hashtag.png'),
                                ),
                              ),
                            ),
                          );
                        }),
                          twelvePx,
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextWidget(
                                  textToDisplay: '#${widget.argument.hashtag.tag}',
                                  textStyle: context
                                      .getTextTheme()
                                      .bodyText1
                                      ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context
                                          .getColorScheme()
                                          .onBackground),
                                  textAlign: TextAlign.start,
                                ),
                                fourPx,
                                Text(
                                  "${notifier.countTag} ${notifier.language.posts}",
                                  style: const TextStyle(
                                      fontSize: 12, color: kHyppeGrey),
                                )
                              ],
                            ),
                          )
                        ],
                      ): Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomShimmer(height: 50, width: 50, radius: 25,),
                            tenPx,
                            Expanded(child: Column(
                              children: [
                                CustomShimmer(height: 20, width: double.infinity, radius: 5,),
                                sixteenPx,
                                CustomShimmer(height: 20, width: double.infinity, radius: 5,)
                              ],
                            ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
            Container(
              height: 2,
              width: double.infinity,
              color: context.getColorScheme().surface,
            ),
            Expanded(
                child: BottomDetail(
                  hashtag: widget.argument.hashtag,
                  fromRoute: widget.argument.fromRoute,
                  scrollController: _scrollController,
                ))
          ],
        ),
      ),
    );
  }
}
