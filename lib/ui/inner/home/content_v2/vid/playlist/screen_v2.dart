import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/user_template.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../app.dart';
import '../../../../../../core/arguments/contents/vid_detail_screen_argument.dart';
import '../../../../../../core/config/ali_config.dart';
import '../../../../../../core/constants/enum.dart';
import '../../../../../../core/constants/kyc_status.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../core/constants/utils.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../../core/services/system.dart';
import '../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../constant/widget/button_boost.dart';
import '../../../../../constant/widget/custom_follow_button.dart';
import '../../../../../constant/widget/custom_profile_image.dart';
import '../../../../../constant/widget/custom_text_button.dart';
import '../../pic/playlist/notifier.dart';
import '../player/player_page.dart';
import '../widget/tag_label.dart';
import 'notifier.dart';
// import 'package:flutter/services.dart';

class NewVideoDetailScreen extends StatefulWidget {
  final VidDetailScreenArgument arguments;
  const NewVideoDetailScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<NewVideoDetailScreen> createState() => _NewVideoDetailScreenState();
}

class _NewVideoDetailScreenState extends State<NewVideoDetailScreen> with AfterFirstLayoutMixin {
  bool isPlay = false;
  String email = '';

  @override
  void initState() {
    email = SharedPreference().readStorage(SpKeys.email);
    FirebaseCrashlytics.instance.setCustomKey('layout', 'NewVideoDetailScreen');
    context.read<VidDetailNotifier>().initialize();
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // context.read<VidDetailNotifier>().getDetail(context, 'c3690a7d-d6a4-47fc-c068-71a1ae4225c4');
    context.read<VidDetailNotifier>().initState(context, widget.arguments);
    if (widget.arguments.vidData?.certified ?? false) {
      System().block(context);
    } else {
      System().disposeBlock();
    }
  }

  bool isFullPotrait = false;
  void fullscreen() {
    setState(() {
      isFullPotrait = !isFullPotrait;
    });
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    var width = MediaQuery.of(context).size.width;
    var height;
    if (orientation == Orientation.portrait) {
      if (isFullPotrait) {
        if (Platform.isIOS) {
          height = MediaQuery.of(context).size.height * 0.9;
        } else {
          height = MediaQuery.of(context).size.height * 0.95;
        }
      } else {
        height = width * 9.0 / 16.0;
      }
    } else {
      if (Platform.isIOS) {
        height = MediaQuery.of(context).size.height * 0.95;
      } else {
        height = MediaQuery.of(context).size.height * 0.95;
      }
    }
    return Consumer2<VidDetailNotifier, LikeNotifier>(builder: (context, notifier, like, _) {
      final data = notifier.data;
      print("======data ${data?.postID}");
      var map = {
        DataSourceRelated.vidKey: widget.arguments.vidData?.apsaraId,
        DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
      };

      return WillPopScope(
        onWillPop: notifier.onPop,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: orientation == Orientation.landscape || isFullPotrait ? Colors.transparent : Colors.white,
          // backgroundColor: context.getColorScheme().surface,
          body: data != null
              ? notifier.loadDetail
                  ? SafeArea(child: _contentDetailShimmer(context))
                  : SafeArea(
                      child: RefreshIndicator(
                        strokeWidth: 2.0,
                        color: context.getColorScheme().primary,
                        onRefresh: () => notifier.initState(context, widget.arguments),
                        notificationPredicate: orientation == Orientation.landscape || isFullPotrait ? (_) => false : (_) => true,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // margin: const EdgeInsets.only(left: 16, top: 12, right: 16),
                                decoration: BoxDecoration(
                                    boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                                    color: context.getColorScheme().background),
                                child: Column(
                                  children: [
                                    Offstage(
                                      offstage: orientation == Orientation.landscape || isFullPotrait,
                                      child: _topDetail(context, notifier, data),
                                    ),
                                    Container(
                                      color: Colors.black,
                                      child: PlayerPage(
                                        playMode: (widget.arguments.vidData?.isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
                                        dataSourceMap: map,
                                        data: data,
                                        height: height,
                                        width: width,
                                        inLanding: widget.arguments.fromLAnding,
                                        fromDeeplink: widget.arguments.fromDeepLink,
                                        functionFullTriger: () {
                                          print('===========hahhahahahaa===========');
                                          fullscreen();
                                        },
                                        listenerPlay: (state, isInit) {
                                          if (isInit) {
                                            isPlay = state;
                                          } else {
                                            setState(() {
                                              isPlay = state;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Offstage(
                                      offstage: orientation == Orientation.landscape || isFullPotrait,
                                      child: _middleDetail(context, notifier, like, data),
                                    ),
                                  ],
                                ),
                              ),
                              //  if (orientation == Orientation.portrait) twelvePx,
                              (data.allowComments ?? false)
                                  ? Offstage(
                                      offstage: orientation == Orientation.landscape || isFullPotrait,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: _bottomDetail(context, notifier, data),
                                      ))
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    )
              : SafeArea(child: _contentDetailShimmer(context)),
        ),
      );
    });
  }

  Widget _topDetail(BuildContext context, VidDetailNotifier notifier, ContentData data) {
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 23),
      child: Row(
        children: [
          CustomIconButtonWidget(
            iconData: '${AssetPath.vectorPath}back-arrow.svg',
            color: kHyppeTextLightPrimary,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // GestureDetector(
          //     onTap: () {
          //       Navigator.pop(context);
          //     },
          //     child: const CustomIconWidget(width: 20, height: 25, iconData: '${AssetPath.vectorPath}back-arrow.svg')),
          sixteenPx,
          // CustomProfileImage(
          //   width: 36,
          //   height: 36,
          //   onTap: () {},
          //   imageUrl: System().showUserPicture(data.avatar?.mediaEndpoint?.split('_')[0]),
          //   following: true,
          //   onFollow: () {},
          // ),
          // twelvePx,
          Expanded(
              child: Row(
            children: [
              Expanded(
                child: ProfileLandingPage(
                  show: true,
                  // cacheKey: vidData?.email == email ? homeNotifier.profileImageKey : null,
                  onFollow: () {},
                  following: true,
                  haveStory: false,
                  textColor: kHyppeTextLightPrimary,
                  username: data.username,
                  featureType: FeatureType.other,
                  // isCelebrity: viddata.privacy?.isCelebrity,
                  isCelebrity: false,
                  imageUrl: '${System().showUserPicture(data.avatar?.mediaEndpoint)}',
                  onTapOnProfileImage: () {
                    System().navigateToProfile(context, data.email ?? '');
                  },
                  createdAt: '2022-02-02',
                  musicName: data.music?.musicTitle ?? '',
                  location: data.location ?? '',
                  isIdVerified: data.isIdVerified ?? false,
                  badge: data.urluserBadge,
                ),
              ),
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       UserTemplate(
              //         username: data.username ?? 'No Username',
              //         isVerified: data.isIdVerified ?? false,
              //       ),
              //       twoPx,
              //       // CustomTextWidget(
              //       //   textToDisplay: 'France, Paris',
              //       //   textStyle: context.getTextTheme().overline,
              //       // ),
              //       if (data.location?.isNotEmpty ?? false)
              //         CustomTextWidget(
              //           textToDisplay: data.location ?? '',
              //           textStyle: context.getTextTheme().caption,
              //         ),
              //       if (data.location?.isNotEmpty ?? false) twoPx,
              //       if (data.music?.artistName != null)
              //         Row(
              //           children: [
              //             CustomIconWidget(
              //               iconData: '${AssetPath.vectorPath}music_stroke_black.svg',
              //               color: context.getColorScheme().onBackground,
              //               defaultColor: false,
              //             ),
              //             fourPx,
              //             Expanded(child: CustomTextWidget(textToDisplay: '${data.music?.musicTitle} - ${data.music?.artistName}'))
              //           ],
              //         )
              //     ],
              //   ),
              // ),
              eightPx,
              if (data.email != SharedPreference().readStorage(SpKeys.email))
                notifier.checkIsLoading
                    ? const Center(child: SizedBox(height: 40, width: 40, child: CustomLoading()))
                    : notifier.statusFollowing == StatusFollowing.following
                        ? const SizedBox.shrink()
                        : CustomFollowButton(
                            checkIsLoading: notifier.checkIsLoading,
                            onPressed: () async {
                              try {
                                await notifier.followUser(context, isUnFollow: notifier.statusFollowing == StatusFollowing.following);
                              } catch (e) {
                                e.logger();
                              }
                            },
                            isFollowing: notifier.statusFollowing,
                          ),
              // Builder(
              //     builder: (context) {
              //       return (data.following ?? false) ? const SizedBox.shrink() : GestureDetector(
              //         onTap: () {
              //           if (data.insight?.isloadingFollow != true) {
              //             notifier.newFollowUser(context, data, isUnFollow: data.following, isloading: data.insight!.isloadingFollow ?? false);
              //           }
              //         },
              //         child: data.insight?.isloadingFollow ?? false
              //             ? const SizedBox(
              //           height: 40,
              //           width: 30,
              //           child: Align(
              //             alignment: Alignment.center,
              //             child: CustomLoading(),
              //           ),
              //         )
              //             : Text(
              //            (notifier.language.follow ?? ''),
              //           style: const TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
              //         ),
              //       );
              //     }
              // ),
              data.email != SharedPreference().readStorage(SpKeys.email)
                  ? SizedBox(
                      width: 50,
                      child: CustomTextButton(
                        onPressed: () async {
                          context.handleActionIsGuest(() async {
                            globalAliPlayer?.pause();
                            await ShowBottomSheet().onReportContent(
                              context,
                              postData: data,
                              type: hyppePic,
                              adsData: null,
                              onUpdate: () => context.read<PicDetailNotifier>().onUpdate(),
                            );
                            if (isPlay) {
                              globalAliPlayer?.play();
                            }
                          });
                        },
                        child: const CustomIconWidget(
                          defaultColor: false,
                          iconData: '${AssetPath.vectorPath}more.svg',
                          color: kHyppeTextLightPrimary,
                        ),
                      ),
                    )
                  : const SizedBox(),
              data.email == SharedPreference().readStorage(SpKeys.email)
                  ? SizedBox(
                      width: 50,
                      child: CustomTextButton(
                        onPressed: () async {
                          context.handleActionIsGuest(() async {
                            if (globalAudioPlayer != null) {
                              globalAudioPlayer!.pause();
                            }
                            if (globalAliPlayer != null) {
                              globalAliPlayer?.pause();
                            }
                            await ShowBottomSheet().onShowOptionContent(
                              context,
                              onDetail: true,
                              contentData: data,
                              captionTitle: hyppeVid,
                              onUpdate: () => context.read<VidDetailNotifier>().onUpdate(),
                              isShare: data.isShared,
                            );
                            if (globalAudioPlayer != null) {
                              globalAudioPlayer!.seek(Duration.zero);
                              globalAudioPlayer!.resume();
                            }
                            if (globalAliPlayer != null) {
                              if (isPlay) {
                                globalAliPlayer?.play();
                              }
                            }
                          });
                        },
                        child: const CustomIconWidget(
                          defaultColor: false,
                          iconData: '${AssetPath.vectorPath}more.svg',
                          color: kHyppeTextLightPrimary,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ))
        ],
      ),
    );
  }

  Widget _middleDetail(BuildContext context, VidDetailNotifier notifier, LikeNotifier like, ContentData data) {
    return Column(
      children: [
        data.email == SharedPreference().readStorage(SpKeys.email) && (data.reportedStatus == 'OWNED')
            ? ContentViolationWidget(
                data: data,
                text: notifier.language.thisHyppeVidisSubjectToModeration ?? '',
              )
            : Container(),
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              twelvePx,
              GestureDetector(
                onTap: () {
                  Provider.of<LikeNotifier>(context, listen: false).viewLikeContent(context, data.postID, 'VIEW', 'Viewer', data.email);
                },
                child: Row(
                  children: [
                    CustomTextWidget(
                      textToDisplay: System().formatterNumber(data.insight?.views),
                      textStyle: context.getTextTheme().overline?.copyWith(fontWeight: FontWeight.w700, color: context.getColorScheme().onBackground),
                    ),
                    twoPx,
                    CustomTextWidget(textToDisplay: '${notifier.language.views}', textStyle: context.getTextTheme().overline?.copyWith(color: context.getColorScheme().secondary)),
                  ],
                ),
              ),
              sixteenPx,
              SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                      (data.boosted.isEmpty) &&
                      (data.reportedStatus != 'OWNED' && data.reportedStatus != 'BLURRED' && data.reportedStatus2 != 'BLURRED') &&
                      data.email == email
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ButtonBoost(
                        onDetail: false,
                        marginBool: true,
                        contentData: data,
                        startState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                        },
                        afterState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            like.likePost(context, data);
                          },
                          child: CustomIconWidget(
                            width: 20,
                            height: 20,
                            color: (data.insight?.isPostLiked ?? false) ? null : Colors.black,
                            defaultColor: false,
                            iconData: '${AssetPath.vectorPath}${(data.insight?.isPostLiked ?? false) ? 'ic_like_red.svg' : 'ic_like_stroke.svg'}',
                          ),
                        ),
                        if (data.allowComments ?? false) twentyPx,
                        if (data.allowComments ?? false)
                          InkWell(
                            onTap: () {
                              context.handleActionIsGuest(() {
                                notifier.goToComments(CommentsArgument(postID: data.postID ?? '', fromFront: true, data: data, giftActication: data.giftActivation));
                              });
                            },
                            child: const CustomIconWidget(
                              width: 20,
                              height: 20,
                              color: Colors.black,
                              defaultColor: false,
                              iconData: '${AssetPath.vectorPath}comment2.svg',
                            ),
                          ),
                        if (data.isShared ?? false) twentyPx,
                        if (data.isShared ?? false)
                          InkWell(
                            onTap: () {
                              notifier.createdDynamicLink(context, data: data);
                            },
                            child: const CustomIconWidget(
                              width: 20,
                              height: 20,
                              color: Colors.black,
                              defaultColor: false,
                              iconData: '${AssetPath.vectorPath}share2.svg',
                            ),
                          ),
                      ],
                    ),
                  ),
                  if ((data.saleAmount ?? 0) > 0 && data.email != SharedPreference().readStorage(SpKeys.email))
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: InkWell(
                        onTap: () async {
                          await context.handleActionIsGuest(() async {
                            await ShowBottomSheet.onBuyContent(context, data: data);
                          });
                        },
                        child: const CustomIconWidget(
                          width: 25,
                          height: 25,
                          color: Colors.black,
                          defaultColor: false,
                          iconData: '${AssetPath.vectorPath}cart.svg',
                        ),
                      ),
                    ),
                ],
              ),
              sixteenPx,
              CustomTextWidget(
                textToDisplay: '${data.insight?.likes ?? 0} ${notifier.language.like}',
                textStyle: const TextStyle(color: kHyppeTextLightPrimary),
              ),
              fourPx,
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDescContent(
                      desc: "${data.description}",
                      trimLines: 3,
                      textAlign: TextAlign.start,
                      seeLess: ' ${notifier.language.seeLess}',
                      seeMore: ' ${notifier.language.seeMoreContent}',
                      normStyle: Theme.of(context).textTheme.subtitle2,
                      hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                      expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      isPlay: isPlay,
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
                                    throw  Fluttertoast.showToast(msg: 'Could not launch $uri');
                                  }
                            },
                        )
                      ]),
                    )
                    : const SizedBox.shrink(),
                  ],
                ),
              ),
              eightPx,
              if (data.tagPeople != null)
                Builder(builder: (context) {
                  final tags = data.tagPeople ?? [];
                  if (tags.isNotEmpty) {
                    return TagLabel(
                      icon: 'tag_people',
                      label: tags.length > 1 ? '${tags.length} ${notifier.language.people}' : '${data.tagPeople?.first.username}',
                      function: () {
                        notifier.showUserTag(context, data.tagPeople, data.postID);
                        // vidNotifier.showUserTag(context, index, data.postID);
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              if (data.tagPeople != null) twelvePx,
              // CustomTextWidget(
              //   textToDisplay: '${System().readTimestamp(
              //     DateTime.parse(System().dateTimeRemoveT(data.createdAt ?? '')).millisecondsSinceEpoch,
              //     context,
              //     fullCaption: true,
              //   )}',
              //   textStyle: context.getTextTheme().overline?.copyWith(color: context.getColorScheme().secondary),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomDetail(BuildContext context, VidDetailNotifier notifier, ContentData data) {
    final comment = notifier.firstComment;
    if ((comment?.disqusLogs ?? []).isEmpty) {
      return _noComment(context, notifier, data);
    }
    final commentor = comment?.disqusLogs?[0].comment?.senderInfo;
    return !notifier.loadComment
        ? notifier.firstComment != null
            ? InkWell(
                onTap: () {
                  context.handleActionIsGuest(() {
                    notifier.goToComments(CommentsArgument(postID: data.postID ?? '', fromFront: true, data: data, giftActication: data.giftActivation));
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                      boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      color: context.getColorScheme().background),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.language.comment ?? '',
                            textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w700, color: context.getColorScheme().onBackground),
                          ),
                          fourPx,
                          CustomTextWidget(
                            textToDisplay: System().formatterNumber(comment?.comment ?? (data.insight?.comments ?? 0)),
                            textStyle: context.getTextTheme().overline?.copyWith(color: context.getColorScheme().secondary),
                          )
                        ],
                      ),
                      twelvePx,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomProfileImage(
                            width: 36,
                            height: 36,
                            onTap: () => System().navigateToProfile(context, comment?.disqusLogs?[0].comment?.sender ?? ''),
                            imageUrl: System().showUserPicture(commentor?.avatar?.mediaEndpoint),
                            badge: commentor?.urluserBadge,
                            following: true,
                            onFollow: () {},
                          ),
                          twelvePx,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserTemplate(
                                    username: '${commentor?.username}', isVerified: commentor?.isIdVerified ?? false, date: comment?.disqusLogs?[0].comment?.createdAt ?? DateTime.now().toString()),
                                twoPx,
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextWidget(
                                        textAlign: TextAlign.start,
                                        textToDisplay: '${comment?.disqusLogs?[0].comment?.txtMessages}',
                                        maxLines: 2,
                                        textStyle: context.getTextTheme().caption?.copyWith(color: context.getColorScheme().onBackground),
                                      ),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(right: 5),
                                        child: const CustomIconWidget(
                                          iconData: '${AssetPath.vectorPath}arrow_down.svg',
                                        ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : _noComment(context, notifier, data)
        : _shimmerComment(context);
  }

  Widget _noComment(BuildContext context, VidDetailNotifier notifier, ContentData data) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(16)), color: context.getColorScheme().background),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextWidget(
              textToDisplay: '${notifier.language.noCommentYet}',
              textStyle: context.getTextTheme().bodyText2?.copyWith(color: context.getColorScheme().secondary),
            ),
            eightPx,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  textToDisplay: '${notifier.language.beTheFirstToComment}',
                  textStyle: context.getTextTheme().bodyText2?.copyWith(color: context.getColorScheme().secondary),
                ),
                fourPx,
                InkWell(
                  onTap: () {
                    notifier.goToComments(CommentsArgument(postID: data.postID ?? '', fromFront: true, data: data, giftActication: data.giftActivation));
                  },
                  child: CustomTextWidget(
                    textToDisplay: '${notifier.language.tapHere2}',
                    textStyle: context.getTextTheme().bodyText2?.copyWith(color: context.getColorScheme().primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget _shimmerComment(BuildContext context, {double? padding}) {
    final width = context.getWidth();
    return Container(
      padding: EdgeInsets.all(padding ?? 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CustomShimmer(
            height: 36,
            width: 36,
            radius: 18,
          ),
          sixteenPx,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomShimmer(
                      width: width * 0.2,
                      height: 16,
                      radius: 8,
                    ),
                    fourPx,
                    CustomShimmer(
                      width: width * 0.1,
                      height: 16,
                      radius: 8,
                    ),
                  ],
                ),
                eightPx,
                const CustomShimmer(
                  width: double.infinity,
                  height: 16,
                  radius: 8,
                ),
                fourPx,
                const CustomShimmer(
                  width: double.infinity,
                  height: 16,
                  radius: 8,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _contentDetailShimmer(BuildContext context) {
    final width = context.getWidth();
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
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
                    width: width * 0.3,
                    height: 16,
                    radius: 8,
                  ),
                  fourPx,
                  CustomShimmer(
                    width: width * 0.35,
                    height: 16,
                    radius: 8,
                  )
                ],
              ),
            ],
          ),
          sixteenPx,
          const CustomShimmer(
            width: double.infinity,
            height: 200,
            radius: 16,
          ),
          twelvePx,
          Row(
            children: [
              CustomShimmer(
                width: width * 0.1,
                height: 16,
                radius: 8,
              ),
              fourPx,
              CustomShimmer(
                width: width * 0.1,
                height: 16,
                radius: 8,
              ),
            ],
          ),
          sixteenPx,
          Row(
            children: const [
              CustomShimmer(
                width: 20,
                height: 20,
                radius: 5,
              ),
              twentyPx,
              CustomShimmer(
                width: 20,
                height: 20,
                radius: 5,
              ),
              twentyPx,
              CustomShimmer(
                width: 20,
                height: 20,
                radius: 5,
              ),
            ],
          ),
          sixteenPx,
          CustomShimmer(
            width: width * 0.2,
            height: 16,
            radius: 8,
          ),
          fourPx,
          CustomShimmer(
            width: width * 0.75,
            height: 16,
            radius: 8,
          ),
          fourPx,
          CustomShimmer(
            width: width * 0.8,
            height: 16,
            radius: 8,
          ),
          eightPx,
          CustomShimmer(
            width: width * 0.3,
            height: 24,
            radius: 8,
          ),
          twelvePx,
          CustomShimmer(
            width: width * 0.2,
            height: 16,
            radius: 8,
          ),
          twentyPx,
          _shimmerComment(context, padding: 0)
        ],
      ),
    );
  }
}
