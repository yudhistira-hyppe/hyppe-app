import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/widget/comment_tile.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/user_template.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/models/collection/comment_v2/comment_data_v2.dart';
import '../../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../constant/entities/comment_v2/notifier.dart';
import '../../../../../../constant/widget/custom_desc_content_widget.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../../constant/widget/custom_loading.dart';
import '../../../../../../constant/widget/custom_profile_image.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../constant/widget/custom_text_button.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';

class CommentsDetailScreen extends StatefulWidget {
  CommentsArgument argument;
  CommentsDetailScreen({Key? key, required this.argument}) : super(key: key);

  @override
  State<CommentsDetailScreen> createState() => _CommentsDetailScreenState();
}

class _CommentsDetailScreenState extends State<CommentsDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final notifier = context.read<CommentNotifierV2>();
    final postID = widget.argument.postID;
    final fromFront = widget.argument.fromFront;
    final parentComment = widget.argument.parentComment;
    notifier.initState(context, postID, fromFront, parentComment);
    _scrollController
        .addListener(() => notifier.scrollListener(context, _scrollController));
    super.initState();
  }

  @override
  void deactivate() {
    final notifier = context.read<CommentNotifierV2>();
    notifier.onDispose();
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> emoji = [
      '❤',
      '🙌',
      '🔥',
      '😢',
      '😍',
      '😯',
      '😂',
    ];
    final postID = widget.argument.postID;
    final fromFront = widget.argument.fromFront;
    final parentComment = widget.argument.parentComment;
    final data = widget.argument.data;
    return Consumer<CommentNotifierV2>(builder: (context, notifier, _) {
      if (notifier.commentData == null) {
        return const Center(child: CustomLoading());
      }
      return Scaffold(
        backgroundColor: context.getColorScheme().surface,
        body: SafeArea(
          child: Column(
            children: [
              sixteenPx,
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CustomIconWidget(
                            width: 20,
                            height: 25,
                            iconData: '${AssetPath.vectorPath}back-arrow.svg')),
                    fourteenPx,
                    Expanded(
                        child: CustomTextWidget(
                      textAlign: TextAlign.start,
                      textToDisplay: notifier.language.comment ?? 'Comment',
                      textStyle: context.getTextTheme().bodyText1?.copyWith(
                          color: context.getColorScheme().onBackground,
                          fontWeight: FontWeight.w700),
                    ))
                  ],
                ),
              ),
              sixteenPx,
              Expanded(
                child: RefreshIndicator(
                  strokeWidth: 2.0,
                  color: Colors.purple,
                  onRefresh: () async {
                    notifier.initState(
                        context, postID, fromFront, parentComment);
                  },
                  child: Column(
                    children: [
                      _bottomDetail(context, data, notifier),
                      !notifier.isCommentEmpty
                          ? Expanded(
                              child: Container(
                              color: context.getColorScheme().background,
                              child: ListView.builder(
                                itemCount: notifier.itemCount,
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                scrollDirection: Axis.vertical,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemBuilder: (context, index) {
                                  if (index == notifier.commentData?.length &&
                                      notifier.hasNext) {
                                    return const CustomLoading();
                                  }
                                  final comments = notifier.commentData?[index];
                                  return CommentTile(
                                      logs: comments,
                                      fromFront: fromFront,
                                      notifier: notifier);
                                },
                              ),
                            ))
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 100.0),
                              child: CustomTextWidget(
                                  textToDisplay: context
                                          .read<TranslateNotifierV2>()
                                          .translate
                                          .beTheFirstToComment ??
                                      ''),
                            )
                    ],
                  ),
                ),
              ),
              Container(
                color: context.getColorScheme().surface,
                padding: const EdgeInsets.only(
                    bottom: 12, left: 16, right: 16, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(emoji.length, (index) {
                        return Expanded(
                            child: InkWell(
                                onTap: () {
                                  final currentText =
                                      notifier.commentController.text;
                                  notifier.commentController.text =
                                      "$currentText${emoji[index]}";
                                  notifier.commentController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                          offset: notifier
                                              .commentController.text.length));
                                  notifier.onUpdate();
                                },
                                child: CustomTextWidget(
                                  textToDisplay: emoji[index],
                                  textStyle: const TextStyle(fontSize: 24),
                                )));
                      }),
                    ),
                    tenPx,
                    TextField(
                      controller: notifier.commentController,
                      focusNode: notifier.inputNode,
                      style: Theme.of(context).textTheme.bodyText2,
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            color: context.getColorScheme().surface)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color: context.getColorScheme().surface)),
                        fillColor: Theme.of(context).colorScheme.background,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                    color: context.getColorScheme().surface)),
                        hintText: "${notifier.language.typeAMessage}...",
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(right: 5, left: 5),
                          child: CustomProfileImage(
                            width: 26,
                            height: 26,
                            imageUrl: System()
                                .showUserPicture(data.avatar?.mediaEndpoint),
                            following: true,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixIcon: notifier.commentController.text.isNotEmpty
                                ? notifier.loading
                                    ? const CustomLoading(size: 4)
                                    : CustomTextButton(
                                        child: CustomTextWidget(
                                          textToDisplay:
                                              notifier.language.send ?? '',
                                          textStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () {
                                          notifier.addComment(context);
                                        },
                                      )
                                : const SizedBox.shrink(),
                      ),
                      onChanged: (value) =>
                          notifier.onChangeHandler(value, context),
                    ),
                    // TextFormField(
                    //   minLines: 1,
                    //   maxLines: 7,
                    //   textAlignVertical: TextAlignVertical.center,
                    //   focusNode: notifier.inputNode,
                    //   keyboardType: TextInputType.text,
                    //   keyboardAppearance: Brightness.dark,
                    //   controller: notifier.commentController,
                    //   textInputAction: TextInputAction.unspecified,
                    //   style: Theme.of(context).textTheme.bodyText2,
                    //   autofocus: true,
                    //   decoration: InputDecoration(
                    //     fillColor: Theme.of(context).colorScheme.background,
                    //     hintText: "${notifier.language.typeAMessage}...",
                    //     hintStyle: const TextStyle(
                    //         color: Color(0xffBABABA), fontSize: 14),
                    //     // border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    //     contentPadding: const EdgeInsets.symmetric(
                    //         horizontal: 10, vertical: 10),
                    //     // enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    //     focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(25),
                    //         borderSide: BorderSide(
                    //             color: context.getColorScheme().surface)),
                    //     prefixIconConstraints:
                    //         BoxConstraints(minWidth: 0, minHeight: 0),
                    //     prefix: CustomProfileImage(
                    //       width: 26,
                    //       height: 26,
                    //       imageUrl: System()
                    //           .showUserPicture(data.avatar?.mediaEndpoint),
                    //       following: true,
                    //     ),
                    //     suffixIcon: notifier.commentController.text.isNotEmpty
                    //         ? notifier.loading
                    //             ? const CustomLoading(size: 4)
                    //             : CustomTextButton(
                    //                 child: CustomTextWidget(
                    //                   textToDisplay:
                    //                       notifier.language.send ?? '',
                    //                   textStyle: TextStyle(
                    //                     color: Theme.of(context)
                    //                         .colorScheme
                    //                         .primary,
                    //                     fontSize: 16,
                    //                     fontWeight: FontWeight.w700,
                    //                   ),
                    //                 ),
                    //                 onPressed: () {
                    //                   notifier.addComment(context);
                    //                 },
                    //               )
                    //         : const SizedBox.shrink(),
                    //   ),
                    //   onChanged: (value) =>
                    //       notifier.onChangeHandler(value, context),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _bottomDetail(
      BuildContext context, ContentData data, CommentNotifierV2 notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)
          ],
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: context.getColorScheme().background),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomProfileImage(
            width: 36,
            height: 36,
            onTap: () {},
            imageUrl: System().showUserPicture(data.avatar?.mediaEndpoint),
            following: true,
            onFollow: () {},
          ),
          twelvePx,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserTemplate(
                    username: '${data.username}',
                    isVerified: data.isIdVerified ?? false,
                    date: data.createdAt ?? DateTime.now().toString()),
                twoPx,
                Row(
                  children: [
                    Expanded(
                      child: CustomDescContent(
                          desc: data.description ?? '',
                          trimLines: 5,
                          textAlign: TextAlign.start,
                          seeLess: ' ${notifier.language.seeLess}',
                          seeMore: ' ${notifier.language.seeMoreContent}',
                          textOverflow: TextOverflow.visible,
                          normStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(
                                  color: context.getColorScheme().onBackground),
                          hrefStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                          expandStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                      // child: CustomTextWidget(
                      //   textAlign: TextAlign.start,
                      //   textToDisplay:
                      //   '${data.description}',
                      //   maxLines: 2,
                      //   textStyle: context
                      //       .getTextTheme()
                      //       .caption

                      // ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsArgument {
  String postID;
  final bool fromFront;
  final DisqusLogs? parentComment;
  final ContentData data;

  CommentsArgument(
      {this.parentComment,
      required this.postID,
      required this.fromFront,
      required this.data});
}
