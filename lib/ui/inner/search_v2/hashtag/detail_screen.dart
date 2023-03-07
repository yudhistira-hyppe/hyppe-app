import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_image_assets.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/bottom_detail.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/services/system.dart';
import '../../../constant/widget/custom_base_cache_image.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/icon_button_widget.dart';

class DetailHashtagScreen extends StatefulWidget {
  bool isTitle;
  Tags hashtag;
  DetailHashtagScreen({Key? key, required this.isTitle, required this.hashtag})
      : super(key: key);

  @override
  State<DetailHashtagScreen> createState() => _DetailHashtagScreenState();
}

class _DetailHashtagScreenState extends State<DetailHashtagScreen>
    with AfterFirstLayoutMixin {
  final _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        final notifier = context.read<SearchNotifier>();
        notifier.getDetail(context, widget.hashtag.tag ?? 'tag', TypeApiSearch.detailHashTag, reload: false);
      }
    });
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SearchNotifier>();
    notifier.getDetail(
        context, widget.hashtag.tag ?? '', TypeApiSearch.detailHashTag);
  }

  @override
  Widget build(BuildContext context) {
    final count = (widget.hashtag.total ?? 0);
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      return Scaffold(
        appBar: AppBar(
          leading: CustomIconButtonWidget(
            onPressed: () => notifier.backFromSearchMore(),
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: CustomTextWidget(
            textToDisplay: widget.isTitle
                ? (notifier.language.popularHashtag ?? 'Popular Hashtag')
                : (widget.hashtag.tag ?? ''),
            textStyle: context
                .getTextTheme()
                .bodyText1
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: (notifier.isLoading)
              ? const Center(
                  child: CustomLoading(),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          left: 16, top: 16, right: 16, bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              notifier.detailHashTag?.pict != null
                                  ? Builder(builder: (context) {
                                      final data =
                                          notifier.detailHashTag!.pict![0];
                                      final url = (data.isApsara ?? false)
                                          ? ( data.media?.imageInfo?[0].url ?? (data.mediaThumbEndPoint ?? ''))
                                          : System().showUserPicture(data.mediaThumbEndPoint) ?? '';
                                      return CustomBaseCacheImage(
                                        imageUrl: url,
                                        memCacheWidth: 70,
                                        memCacheHeight: 70,
                                        imageBuilder: (_, imageProvider) {
                                          return Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                                                image: const AssetImage('${AssetPath.pngPath}content-error.png'),
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
                                              image: const AssetImage('${AssetPath.pngPath}content-error.png'),
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                                  : CustomImageAssets(
                                      width: 56,
                                      height: 56,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(28)),
                                      assetPath:
                                          '${AssetPath.pngPath}thumb_hashtag.png'),
                              twelvePx,
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(
                                    textToDisplay: widget.hashtag.tag ?? '',
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
                                    count > 500
                                        ? "500+ ${notifier.language.posts}"
                                        : "$count ${notifier.language.posts}",
                                    style: const TextStyle(
                                        fontSize: 12, color: kHyppeGrey),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 2,
                      width: double.infinity,
                      color: context.getColorScheme().surface,
                    ),
                    Expanded(
                        child: BottomDetail(
                      data: notifier.detailHashTag,
                      scrollController: _scrollController,
                    ))
                  ],
                ),
        ),
      );
    });
  }
}
