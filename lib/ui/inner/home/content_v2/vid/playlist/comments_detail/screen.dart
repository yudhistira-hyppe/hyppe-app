import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/gift_live_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/widget/comment_tile.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/user_template.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/build_auto_complete_user_tag_comment.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/models/collection/comment_v2/comment_data_v2.dart';
import '../../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../constant/entities/comment_v2/notifier.dart';
import '../../../../../../constant/widget/custom_desc_content_widget.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../../constant/widget/custom_loading.dart';
import '../../../../../../constant/widget/custom_profile_image.dart';
import '../../../../../../constant/widget/custom_shimmer.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../constant/widget/custom_text_button.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';

class CommentsDetailScreen extends StatefulWidget {
  final CommentsArgument argument;
  const CommentsDetailScreen({Key? key, required this.argument}) : super(key: key);

  @override
  State<CommentsDetailScreen> createState() => _CommentsDetailScreenState();
}

class _CommentsDetailScreenState extends State<CommentsDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isLoad = true;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CommentsDetailScreen');
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final notifier = context.read<CommentNotifierV2>();
      final postID = widget.argument.postID;
      final fromFront = widget.argument.fromFront;
      final parentComment = widget.argument.parentComment;
      notifier.initState(context, postID, fromFront, parentComment);

      _scrollController.addListener(() => notifier.scrollListener(context, _scrollController));
    });
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

  List<String> emoji = [
    '❤',
    '🙌',
    '🔥',
    '😢',
    '😍',
    '😯',
    '😂',
  ];

  @override
  Widget build(BuildContext context) {
    final postID = widget.argument.postID;
    final fromFront = widget.argument.fromFront;
    final parentComment = widget.argument.parentComment;
    final data = widget.argument.data;
    return Consumer<CommentNotifierV2>(builder: (context, notifier, _) {
      if (notifier.commentData == null) {
        return _commentsShimmer(context);
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
                        notifier.parentID = null;
                        notifier.commentController.clear();
                        Routing().moveBack();
                      },
                      child: const CustomIconWidget(width: 20, height: 25, iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                    ),
                    fourteenPx,
                    Expanded(
                        child: CustomTextWidget(
                      textAlign: TextAlign.start,
                      textToDisplay: notifier.language.comment ?? 'Comment',
                      textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
                    ))
                  ],
                ),
              ),
              sixteenPx,
              Flexible(
                child: RefreshIndicator(
                  strokeWidth: 2.0,
                  color: Colors.purple,
                  onRefresh: () async {
                    notifier.commentData = null;
                    notifier.initState(context, postID, fromFront, parentComment);
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
                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                  itemBuilder: (context, index) {
                                    if (index == notifier.commentData?.length && notifier.hasNext) {
                                      return const CustomLoading();
                                    }
                                    final comments = notifier.commentData?[index];
                                    print('all comments: ${comments?.comment?.txtMessages}');
                                    return CommentTile(logs: comments, fromFront: fromFront, notifier: notifier, index: index);
                                  },
                                ),
                              ),
                            )
                          : Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 100.0),
                                child: CustomTextWidget(textToDisplay: context.read<TranslateNotifierV2>().translate.beTheFirstToComment ?? ''),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              Builder(builder: (context) {
                final parentID = notifier.parentID;
                List<CommentsLogs>? comments;
                try {
                  if (parentID != null) {
                    comments = notifier.commentData?.where((element) => element.comment?.lineID == parentID).toList();
                  } else {
                    comments = null;
                  }
                } catch (e) {
                  comments = null;
                }
                return Column(
                  children: [
                    if (comments?.isNotEmpty ?? false)
                      Container(
                        color: kHyppeBgNotSolve,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: CustomTextWidget(textAlign: TextAlign.start, textToDisplay: '${notifier.language.replyTo} ${comments?.first.comment?.senderInfo?.username ?? '-'}')),
                            InkWell(
                              onTap: () {
                                notifier.parentID = null;
                                notifier.commentController.clear();
                                notifier.onUpdate();
                              },
                              child: CustomIconWidget(
                                width: 20,
                                height: 20,
                                iconData: '${AssetPath.vectorPath}close.svg',
                                defaultColor: false,
                                color: context.getColorScheme().onBackground,
                              ),
                            )
                          ],
                        ),
                      ),
                    Container(
                      color: context.getColorScheme().surface,
                      padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16, top: 10),
                      child: Column(
                        children: [
                          notifier.isShowAutoComplete
                              ? const AutoCompleteUserTagComment()
                              : Row(
                                  children: List.generate(emoji.length, (index) {
                                    return Expanded(
                                        child: InkWell(
                                            onTap: () {
                                              context.handleActionIsGuest(() async {
                                                final currentText = notifier.commentController.text;
                                                notifier.commentController.text = "$currentText${emoji[index]}";
                                                notifier.commentController.selection = TextSelection.fromPosition(TextPosition(offset: notifier.commentController.text.length));
                                                notifier.onUpdate();
                                              });
                                            },
                                            child: CustomTextWidget(
                                              textToDisplay: emoji[index],
                                              textStyle: const TextStyle(fontSize: 24),
                                            )));
                                  }),
                                ),
                          tenPx,
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onTap: () {
                                    context.handleActionIsGuest(() async {}, addAction: () {
                                      notifier.inputNode.unfocus();
                                    });
                                  },
                                  controller: notifier.commentController,
                                  focusNode: notifier.inputNode,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  decoration: InputDecoration(
                                    filled: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: context.getColorScheme().surface)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: context.getColorScheme().surface)),
                                    fillColor: Theme.of(context).colorScheme.background,
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: context.getColorScheme().surface)),
                                    hintText: "${notifier.language.typeAMessage}...",
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.only(right: 5, left: 5),
                                      child: Builder(builder: (context) {
                                        final urlImage = context.read<SelfProfileNotifier>().user.profile?.avatar?.mediaEndpoint;
                                        return CustomProfileImage(
                                          width: 26,
                                          height: 26,
                                          imageUrl: System().showUserPicture(comments?.first.comment?.senderInfo?.avatar?.mediaEndpoint ?? (urlImage ?? '')),
                                          badge: comments?.first.comment?.senderInfo?.urluserBadge,
                                          following: true,
                                        );
                                      }),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                    suffixIcon: notifier.commentController.text.isNotEmpty
                                        ? notifier.loading
                                            ? const CustomLoading(size: 4)
                                            : CustomTextButton(
                                                child: CustomTextWidget(
                                                  textToDisplay: notifier.language.send ?? '',
                                                  textStyle: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  await notifier.addComment(context, pageDetail: widget.argument.pageDetail);
                                                  if (context.mounted) {
                                                    notifier.initState(
                                                      context,
                                                      widget.argument.postID,
                                                      widget.argument.fromFront,
                                                      widget.argument.parentComment,
                                                    );
                                                  }
                                                },
                                              )
                                        : const SizedBox.shrink(),
                                  ),
                                  onChanged: (value) => notifier.onChangeHandler(value, context),
                                ),
                              ),
                              if (data.email != SharedPreference().readStorage(SpKeys.email))
                                if (!notifier.inputNode.hasFocus && (comments?.isEmpty ?? true) && (widget.argument.giftActication??false))
                                  Container(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Material(
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        splashColor: Colors.black,
                                        onTap: () {
                                          // notifier.isShowGift = true;
                                          // dsfsdfsdf

                                          // context.handleActionIsGuest(() {
                                          //   ShowBottomSheet()
                                          //     .onShowGiftComment(context, argument: widget.argument, comments: comments);
                                          // });
                                          context.handleActionIsGuest(() async {
                                            notifier.giftSelect = null;
                                            notifier.validateUserGif(context, widget, comments, notifier.language);
                                          });
                                        },
                                        onTapUp: (val) {},
                                        customBorder: const CircleBorder(),
                                        child: Ink(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [Color(0xff7552C0), Color(0xffAB22AF)],
                                              stops: [0.25, 0.75],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                          ),
                                          height: 38,
                                          width: 38,
                                          child: Image.asset("${AssetPath.pngPath}gift.png"),
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              })
            ],
          ),
        ),
      );
    });
  }

  List<Widget> generateComment(BuildContext context, ContentData data, CommentNotifierV2 notifier, int index, bool fromFront) {
    List<Widget> widget = [];
    if (index == 0) {
      widget.add(_bottomDetail(context, data, notifier));
    }

    if (notifier.isCommentEmpty) {
      widget.add(Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 100.0),
            child: CustomTextWidget(textToDisplay: context.read<TranslateNotifierV2>().translate.beTheFirstToComment ?? ''),
          ),
        ),
      ));
    }
    // final comments = notifier.commentData?[index].comment;
    if (index > 0) {
      Widget item = Container(color: context.getColorScheme().background, child: CommentTile(logs: notifier.commentData?[index - 1], fromFront: fromFront, notifier: notifier, index: index - 1));
      widget.add(item);
    }

    return widget;
  }

  Widget _bottomDetail(BuildContext context, ContentData data, CommentNotifierV2 notifier) {
    return Container(
      color: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
            boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)], borderRadius: const BorderRadius.all(Radius.circular(16)), color: context.getColorScheme().background),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomProfileImage(
              width: 36,
              height: 36,
              onTap: () => System().navigateToProfile(context, data.email ?? ''),
              imageUrl: System().showUserPicture(data.avatar?.mediaEndpoint),
              badge: data.urluserBadge,
              following: true,
              onFollow: () {},
            ),
            twelvePx,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UserTemplate(username: '${data.username}', isVerified: data.isIdVerified ?? (data.privacy?.isIdVerified ?? false), date: data.createdAt ?? DateTime.now().toString()),
                  UserTemplate(username: '${data.username}', isVerified: data.isIdVerified ?? (data.privacy?.isIdVerified ?? false)),
                  twoPx,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: SizeConfig.screenWidth! * .7,
                              maxHeight: data.description!.length > 24
                                  ? isLoad
                                      ? 84
                                      : 150
                                  : 54),
                          child: SingleChildScrollView(
                            child: CustomDescContent(
                              desc: data.description ?? '',
                              trimLines: 5,
                              textAlign: TextAlign.start,
                              seeLess: ' ${notifier.language.less}',
                              seeMore: ' ${notifier.language.more}',
                              textOverflow: TextOverflow.visible,
                              normStyle: Theme.of(context).textTheme.bodyText2,
                              hrefStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary),
                              expandStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary),
                              callbackIsMore: (val) {
                                setState(() {
                                  isLoad = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  data.urlLink != '' || data.judulLink != ''
                  ? RichText(
                    text: TextSpan(
                      children: [
                      TextSpan(
                        text: (data.judulLink != null)
                            ? data.judulLink
                            : data.urlLink,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            var uri = data.urlLink??'';
                              if (!uri.withHttp()){
                                uri='https://$uri';
                              }
                              if (await canLaunchUrl(Uri.parse(uri))) {
                                  await launchUrl(Uri.parse(uri));
                                } else {
                                  throw Fluttertoast.showToast(msg: 'Could not launch $uri');
                                }
                              },
                          )
                        ]),
                      )
                    : const SizedBox.shrink(),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentItemShimmer(BuildContext context) {
    final width = context.getWidth();
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      child: Column(
        children: [
          Row(
            children: [
              const CustomShimmer(
                height: 36,
                width: 36,
                radius: 18,
              ),
              twelvePx,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomShimmer(
                    width: width * 0.7,
                    height: 16,
                    radius: 8,
                    margin: EdgeInsets.only(right: 20),
                  ),
                  fourPx,
                  CustomShimmer(
                    width: width * 0.6,
                    height: 16,
                    radius: 8,
                    margin: EdgeInsets.only(right: 30),
                  )
                ],
              ),
            ],
          ),
          tenPx,
          Container(
            margin: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CustomShimmer(
                      height: 36,
                      width: 36,
                      radius: 18,
                    ),
                    twelvePx,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomShimmer(
                          width: width * 0.4,
                          height: 16,
                          radius: 8,
                          margin: EdgeInsets.only(right: 20),
                        ),
                        fourPx,
                        CustomShimmer(
                          width: width * 0.3,
                          height: 16,
                          radius: 8,
                          margin: EdgeInsets.only(right: 30),
                        )
                      ],
                    ),
                  ],
                ),
                tenPx,
                Row(
                  children: [
                    const CustomShimmer(
                      height: 36,
                      width: 36,
                      radius: 18,
                    ),
                    twelvePx,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomShimmer(
                          width: width * 0.4,
                          height: 16,
                          radius: 8,
                          margin: EdgeInsets.only(right: 20),
                        ),
                        fourPx,
                        CustomShimmer(
                          width: width * 0.3,
                          height: 16,
                          radius: 8,
                          margin: EdgeInsets.only(right: 30),
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          tenPx,
        ],
      ),
    );
  }

  Widget _commentsShimmer(BuildContext context) {
    final width = context.getWidth();
    return Scaffold(
      backgroundColor: context.getColorScheme().surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20, right: 16, left: 16, bottom: 16),
              child: Row(
                children: [
                  const CustomShimmer(
                    height: 36,
                    width: 36,
                    radius: 18,
                  ),
                  twelvePx,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer(
                        width: width * 0.7,
                        height: 16,
                        radius: 8,
                        margin: EdgeInsets.only(right: 20),
                      ),
                      fourPx,
                      CustomShimmer(
                        width: width * 0.6,
                        height: 16,
                        radius: 8,
                        margin: EdgeInsets.only(right: 30),
                      )
                    ],
                  ),
                ],
              ),
            ),
            sixteenPx,
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                color: context.getColorScheme().background,
                child: Column(
                  children: List.generate(5, (index) => _commentItemShimmer(context)),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class CommentsArgument {
  String postID;
  final bool fromFront;
  final DisqusLogs? parentComment;
  final ContentData data;
  final bool? pageDetail;
  final bool? giftActication;

  CommentsArgument({this.parentComment, this.giftActication, required this.postID, required this.fromFront, required this.data, this.pageDetail});
}
