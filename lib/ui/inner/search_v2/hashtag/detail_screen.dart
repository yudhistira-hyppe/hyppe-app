import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_image_assets.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/bottom_detail.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../core/arguments/hashtag_argument.dart';
import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/services/system.dart';
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
    with AfterFirstLayoutMixin {
  final _scrollController = ScrollController();

  @override
  void initState() {
    final notifier = context.read<SearchNotifier>();
    notifier.initDetailHashtag();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        notifier.getDetail(context, widget.argument.hashtag.tag ?? 'tag', TypeApiSearch.detailHashTag, reload: false);
      }
    });
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SearchNotifier>();
    var tag = widget.argument.hashtag.tag;
    if(widget.argument.fromRoute){
      tag = tag?.replaceAll(' ', '');
    }
    notifier.getDetail(
        context, tag ?? ' ', TypeApiSearch.detailHashTag);
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      final extraTag = notifier.detailHashTag?.tags;
      final count = (widget.argument.hashtag.total ?? (extraTag.isNotNullAndEmpty() ? (extraTag?[0].total ?? 0) : 0));
      return Scaffold(
        appBar: AppBar(
          leading: CustomIconButtonWidget(
            onPressed: (){
              if(widget.argument.fromRoute){
                Routing().moveBack();
              }else{
                notifier.backFromSearchMore();
              }
            },
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: CustomTextWidget(
            textToDisplay: widget.argument.isTitle
                ? (notifier.language.popularHashtag ?? 'Popular Hashtag')
                : ('#${widget.argument.hashtag.tag}' ),
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
                              notifier.detailHashTag?.pict?.isNotNullAndEmpty() ?? false
                                  ? Builder(builder: (context) {
                                      final data =
                                          notifier.detailHashTag?.pict?[0];
                                      final url = data != null ? ((data.isApsara ?? false)
                                          ? ( data.media?.imageInfo?[0].url ?? (data.mediaThumbEndPoint ?? ''))
                                          : System().showUserPicture(data.mediaThumbEndPoint) ?? '') : '';
                                      return CustomBaseCacheImage(
                                        imageUrl: url,
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
                                          '${AssetPath.pngPath}content-error.png'),
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
                                      count > 500
                                          ? "500+ ${notifier.language.posts}"
                                          : "$count ${notifier.language.posts}",
                                      style: const TextStyle(
                                          fontSize: 12, color: kHyppeGrey),
                                    )
                                  ],
                                ),
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
                      hashtag: widget.argument.hashtag,
                      scrollController: _scrollController,
                    ))
                  ],
                ),
        ),
      );
    });
  }
}
