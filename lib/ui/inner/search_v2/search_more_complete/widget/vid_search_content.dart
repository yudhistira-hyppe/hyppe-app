import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/thumbnail_content_search.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';

import '../../widget/search_no_result.dart';

class VidSearchContent extends StatefulWidget {
  final String? title;
  final List<ContentData>? content;
  final FeatureType? featureType;
  final int? selecIndex;
  const VidSearchContent({Key? key, this.content, this.featureType, this.title, this.selecIndex}) : super(key: key);

  @override
  _VidSearchContentState createState() => _VidSearchContentState();
}

class _VidSearchContentState extends State<VidSearchContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.pic));
    final _themes = Theme.of(context);
    return Consumer<SearchNotifier>(
      builder: (_, notifier, __) => Container(
        width: SizeConfig.screenWidth,
        height: widget.content.isNotNullAndEmpty() ? SizeWidget.barHyppePic : 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomTextWidget(
              maxLines: 1,
              textAlign: TextAlign.left,
              textToDisplay: widget.title ?? '',
              textStyle: _themes.textTheme.bodyText1?.copyWith(
                color: _themes.colorScheme.onBackground,
                fontWeight: FontWeight.w700
              ),
            ),
            sixPx,
            widget.content.isNotNullAndEmpty() ? Expanded(
              child: context.read<ErrorService>().isInitialError(error, widget.content)
                  ? CustomErrorWidget(
                      errorType: ErrorType.pic,
                      // function: () => notifier.initialPic(context, reload: true),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo is ScrollStartNotification) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            // notifier.initialPic(context);
                          });
                        }
                        return true;
                      },
                      child: ListView.builder(
                        // controller: notifier.scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.content?.length,
                        padding: const EdgeInsets.only(right: 11.5),
                        itemBuilder: (context, index) {
                          if (widget.content == null) {
                            return CustomShimmer(
                              width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                              height: 168,
                              radius: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4.5),
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                            );
                            // } else if (index == widget.content?.length && notifier.hasNext) {
                          } else if (index == widget.content?.length) {
                            return UnconstrainedBox(
                              child: Container(
                                child: const CustomLoading(),
                                alignment: Alignment.center,
                                width: 80 * SizeConfig.scaleDiagonal,
                                height: 80 * SizeConfig.scaleDiagonal,
                              ),
                            );
                          }

                          return ThumbnailContentSearch(
                            data: widget.content?[index] ?? ContentData(),
                            onTap: () {
                              context.read<ReportNotifier>().inPosition = contentPosition.search;
                              notifier.navigateToSeeAllScreen2(context, widget.content ?? [], index, widget.selecIndex ?? 0);
                              final _routing = Routing();
                              // switch (widget.featureType) {
                              //   case FeatureType.vid:
                              //     _routing.move(Routes.vidDetail,
                              //         argument: VidDetailScreenArgument(vidData: widget.content?[index])
                              //           ..postID = widget.content?[index].postID
                              //           ..backPage = true);
                              //     break;

                              //   case FeatureType.diary:
                              //     _routing.move(Routes.diaryDetail,
                              //         argument: DiaryDetailScreenArgument(
                              //             diaryData: widget.content, index: index.toDouble(), page: diaryContentsQuery.page, limit: diaryContentsQuery.limit, type: TypePlaylist.search));

                              //     _routing.move(Routes.diaryDetail,
                              //         argument: DiaryDetailScreenArgument(diaryData: widget.content, index: index.toDouble(), type: TypePlaylist.none)
                              //           ..postID = widget.content?[index].postID
                              //           ..backPage = true);
                              //     break;
                              //   case FeatureType.pic:
                              //     _routing.move(Routes.picDetail,
                              //         argument: PicDetailScreenArgument(picData: widget.content?[index])
                              //           ..postID = widget.content?[index].postID
                              //           ..backPage = true);
                              //     break;
                              //   default:
                              // }

                              // print(widget.content[index].username);
                              // context.read<PreviewPicNotifier>().navigateToHyppePicDetail(context, widget.content[index]);
                            },
                            margin: EdgeInsets.only(right: 11),
                          );
                        },
                      ),
                    ),
            ): SearchNoResult(locale: notifier.language, keyword: notifier.searchController.text),
          ],
        ),
      ),
    );
  }
}
