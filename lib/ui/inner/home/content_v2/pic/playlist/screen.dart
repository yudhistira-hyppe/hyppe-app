import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/widget/comment_list_tile.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail_top.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail_slider.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail_shimmer.dart';


class PicDetailScreen extends StatefulWidget {
  final PicDetailScreenArgument arguments;
  final bool isOnPageTurning;

  const PicDetailScreen({Key? key, required this.arguments, required this.isOnPageTurning}) : super(key: key);

  @override
  _PicDetailScreenState createState() => _PicDetailScreenState();
}

class _PicDetailScreenState extends State<PicDetailScreen> with AfterFirstLayoutMixin {
  final _notifier = PicDetailNotifier();
  final _notifierComment = CommentNotifierV2();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicDetailScreen');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<PicDetailNotifier>().setLoadPic(true);
      context.read<PicDetailNotifier>().setLoadMusic(true);
      _scrollController.addListener(() => _notifierComment.scrollListener(context, _scrollController));
      
    });

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _notifier.initState(context, widget.arguments);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<PicDetailNotifier>(
      create: (context) => _notifier,
      child: Consumer<PicDetailNotifier>(
        builder: (_, notifier, __) {
          // Future.delayed(const Duration(milliseconds: 2000), () async {
          //   print('isOnPageTurning ImageDetail: ${widget.isOnPageTurning} $tempAllow');
          //   if (!widget.isOnPageTurning && !tempAllow) {
          //     // notifier.urlMusic = '';
          //     // notifier.isLoadMusic = false;
          //     // if(globalAudioPlayer != null){
          //     //   disposeGlobalAudio();
          //     // }
          //     final music = widget.arguments.picData?.music;
          //     if(music != null){
          //       final apsaraMusic = music.apsaraMusic;
          //       if(apsaraMusic != null){
          //         notifier.initMusic(context, apsaraMusic);
          //       }
          //
          //     }
          //
          //   }
          // });
          return WillPopScope(
            onWillPop: notifier.onPop,
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PicDetailTop(data: notifier.data),
                      _notifier.data != null ? PicDetailSlider(picData: notifier.data) : PicDetailShimmer(),
                      PicDetailBottom(data: notifier.data),
                      _notifier.data != null && (_notifier.data?.allowComments ?? false)
                          ? Expanded(
                              child: commentList(notifPic: notifier))
                          : const SizedBox.shrink()
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget commentList({PicDetailNotifier? notifPic}) {
    _notifierComment.initState(context, notifPic?.data?.postID, true, null);
    return ChangeNotifierProvider<CommentNotifierV2>(
      create: (context) => _notifierComment,
      child: Consumer<CommentNotifierV2>(
        builder: (_, notifier, __) {
          print('notifier data ${notifPic?.data?.postID??''} ${notifier.commentData?.length??0}');
          if (notifier.commentData == null) {
            return const Center(child: CustomLoading());
          }

          return RefreshIndicator(
            strokeWidth: 2.0,
            color: Colors.purple,
            onRefresh: () async {
              notifier.initState(context, notifPic?.data?.postID, true, null);
            },
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      eightPx,
                      notifier.commentData?.isNotEmpty??false
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: notifier.commentData?.length??0,
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.only(bottom: 10),
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                itemBuilder: (context, index) {
                                  if (index == notifier.commentData?.length && notifier.hasNext) {
                                    return const CustomLoading();
                                  }

                                  final comments = notifier.commentData?[index];

                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                                    child: CommentListTile(
                                      data: comments,
                                      fromFront: true,
                                    ),
                                  );
                                },
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 100.0),
                                  child: CustomTextWidget(textToDisplay: context.read<TranslateNotifierV2>().translate.beTheFirstToComment ?? ''),
                                );
                              }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
