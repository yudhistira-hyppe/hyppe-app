import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart'
    as messageData;
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/view_content.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';
import 'package:hyppe/ui/constant/entities/playlist/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/on_show_comment_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_cancel_post.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coming_soon_doku.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_delete_message.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_interest_list.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_internal_server_error.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_location_search.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_no_internet_connection.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_option_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_option_story.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_people_search.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_privacy_post.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_report_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_report_content_form.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_report_spam_form.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_ID_verification.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_complete_profile_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_filters.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_id_verification_failed.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_license_agreement.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_user_tag.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_user_view_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_upload_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/playlist/add/screen.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/playlist/list/screen.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/content/reportProfile.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/content/report_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/stories/screen.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_overview_gender_content.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';
import 'bottom_sheet_content/on_show_success_ownership_content.dart';
import 'bottom_sheet_content/on_sign_out.dart';
import 'bottom_sheet_content/on_something_when_wrong.dart';
import 'bottom_sheet_content/on_coloured_sheet.dart';

// import 'package:hyppe/ui/inner/home/content/vid/notifier.dart';
// import 'package:hyppe/ui/constant/entities/report/notifier.dart';
// import 'package:hyppe/ui/inner/home/content/profile/notifier.dart';
// import 'package:hyppe/ui/inner/home/content/diary/playlist/notifier.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/content/report_user_first_layer.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/content/report_user_second_layer.dart';

class ShowBottomSheet {
  ShowBottomSheet._private();

  static final ShowBottomSheet _instance = ShowBottomSheet._private();

  factory ShowBottomSheet() {
    return _instance;
  }

  // static onLongPressTileUserMessage(BuildContext _) {
  //   final notifier = Provider.of<MessageNotifier>(_, listen: false);
  //   showModalBottomSheet(
  //     context: _,
  //     isScrollControlled: true,
  //     enableDrag: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (builder) {
  //       return Padding(
  //         padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
  //         child: Container(
  //           height: SizeConfig.screenHeight! / 3.5,
  //           decoration: BoxDecoration(
  //             color: Theme.of(_).colorScheme.surface,
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(8),
  //               topRight: Radius.circular(8),
  //             ),
  //           ),
  //           padding: const EdgeInsets.all(0),
  //           child: OnLongPressTileUserMessageBottomSheet(),
  //         ),
  //       );
  //     },
  //   ).whenComplete(() => notifier.overview = null);
  // }

  static onUploadContent(_) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight! / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnUploadContentBottomSheet(),
          ),
        );
      },
    );
  }

  static onLongPressDeleteMessage(BuildContext _,
      {messageData.MessageDataV2? data, required Function() function}) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: false,

      // isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Wrap(
          children: [
            Container(
              // height: SizeConfig.screenHeight! / 1.78,
              decoration: BoxDecoration(
                color: Theme.of(_).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.all(0),
              child: OnDeleteMessageBottomSheet(data: data, function: function),
            ),
          ],
        );
      },
    );
  }

  static onNoInternetConnection(_,
      {Function? tryAgainButton, Function? onBackButton}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnNoInternetConnectionBottomSheet(
                tryAgainButton: tryAgainButton ?? () {},
                onBackButton: onBackButton),
          ),
        );
      },
    );
  }

  static onInternalServerError(_,
      {Function? tryAgainButton, Function? backButton}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnInternalServerErrorBottomSheet(
                tryAgainButton: tryAgainButton!, backButton: backButton),
          ),
        );
      },
    );
  }

  static onShowReport(BuildContext _,
      {ContentData? data,
      ReportType? reportType,
      double? height,
      bool fromLandscapeMode = false}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: height ?? SizeConfig.screenHeight! / 4,
          decoration: BoxDecoration(
            color: Theme.of(_).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(0),
          child: ReportContent(
              userID: data!.email,
              postID: data.postID,
              reportType: reportType,
              fromLandscapeMode: fromLandscapeMode),
        );
      },
    ).whenComplete(() {
      // if (_.read<PreviewVidNotifier>().forcePause) _.read<PreviewVidNotifier>().forcePause = false;
      // if (_.read<DiariesPlaylistNotifier>().forcePause) _.read<DiariesPlaylistNotifier>().forcePause = false;
    });
  }

  static onShowReportStory(_,
      {ContentData? data, int? index, bool? forceStop}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight! / 4,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: ReportContent(
                userID: data!.email,
                storyID: data.postID,
                reportType: ReportType.story),
          ),
        );
      },
    ).whenComplete(() => forceStop = false);
  }

  // static onShowReportProfile(_, {String? userID}) {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: _,
  //     enableDrag: true,
  //     isDismissible: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (builder) {
  //       return Selector<ReportNotifier, bool>(
  //         selector: (_, select) => select.screen,
  //         builder: (_, screen, __) => Container(
  //           height: screen
  //               ? (SizeConfig.screenHeight! / 3.5)
  //               : Provider.of<ProfileNotifier>(_, listen: false).statusFollowing != StatusFollowing.following
  //                   ? (SizeConfig.screenHeight! / 6.2)
  //                   : (SizeConfig.screenHeight! / 4),
  //           decoration: BoxDecoration(
  //             color: Theme.of(_).colorScheme.surface,
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(8),
  //               topRight: Radius.circular(8),
  //             ),
  //           ),
  //           padding: const EdgeInsets.all(0),
  //           child: screen ? ReportUserSecondLayer(userID: userID) : ReportUserFirstLayer(userID: userID),
  //         ),
  //       );
  //     },
  //   ).whenComplete(() => Provider.of<ReportNotifier>(_, listen: false).screen = false);
  // }

  static void onShowCommentV2(
    BuildContext _, {
    required String? postID,
    DisqusLogs? parentComment,
  }) {
    // System().actionReqiredIdCard(
    //   _,
    //   uploadContentAction: false,
    //   action: () {
    final _routing = Routing();

    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return ChangeNotifierProvider(
          create: (context) => CommentNotifierV2(),
          child: Consumer<CommentNotifierV2>(
            builder: (context, notifier, child) => WillPopScope(
              onWillPop: () async {
                notifier.initState(context, postID, true, parentComment);
                return false;
              },
              child: SafeArea(
                child: Container(
                  height: !notifier.isLoading
                      ? SizeConfig.screenHeight!
                      : SizeConfig.screenHeight! -
                          (28 + (SizeConfig.screenWidth! / 1.78)),
                  decoration: BoxDecoration(
                    color: Theme.of(_).colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  margin: const EdgeInsets.only(top: 200),
                  child: OnShowCommentBottomSheetV2(
                    postID: postID,
                    fromFront: false,
                    parentComment: parentComment,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    //    ;
    //   },
    // );
  }

  static onShowPlaylist(BuildContext _,
      {String? feature, ContentData? data, int? index}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Selector<PlaylistNotifier, bool>(
          selector: (_, select) => select.screen,
          builder: (_, screen, __) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(builder).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(_).size.height / 2,
              decoration: BoxDecoration(
                color: Theme.of(_).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.all(0),
              child: screen
                  ? AddPlaylist()
                  : ListMyPlaylist(
                      featureType: feature,
                      postID: data!.postID,
                      contentID: data.postID),
            ),
          ),
        );
      },
    ).whenComplete(() {
      // if (_.read<DiariesPlaylistNotifier>().forcePause) _.read<DiariesPlaylistNotifier>().forcePause = false;
      // Provider.of<PlaylistNotifier>(_, listen: false).onExit();
    });
  }

  static onShowCompleteProfile(_) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
            height: MediaQuery.of(_).size.height / 3,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnShowCompleteProfileBottomSheet());
      },
    );
  }

  static onShowIDVerification(_) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
            height: 450,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: const OnShowIDVerificationBottomSheet());
      },
    );
  }

  static onShowIDVerificationFailed(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: false,
      context: ctx,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Consumer<VerificationIDNotifier>(
          builder: (_, notifier, __) => WillPopScope(
            onWillPop: () async {
              notifier.retryTakeIdCard();
              return false;
            },
            child: Container(
                height: 330,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.all(0),
                child: const OnShowIDVerificationFailedBottomSheet()),
          ),
        );
      },
    );
  }

  static onShowSuccessPostContentOwnership(_) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: const OnShowSuccessPostContentOwnershipBottomSheet());
      },
    );
  }

  static onShowSomethingWhenWrong(_, {Function()? onClose}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
            height: MediaQuery.of(_).size.height / 2,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: const OnSomethingWhenWrong());
      },
    ).whenComplete(onClose ?? () {});
  }

  Future<bool> onShowColouredSheet(
    _,
    String caption, {
    int? maxLines,
    TextOverflow? textOverflow,
    Color color = kHyppeTextSuccess,
    String? subCaption,
    String? iconSvg,
    double? sizeIcon,
    Color? iconColor,
    Function? function,
    bool enableDrag = true,
    bool dismissible = true,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10),
  }) async {
    final _result = await showModalBottomSheet<bool>(
      isScrollControlled: enableDrag,
      context: _,
      enableDrag: enableDrag,
      isDismissible: dismissible,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return SafeArea(
          child: Container(
              padding: padding,
              decoration: BoxDecoration(color: color),
              child: OnColouredSheet(
                caption: caption,
                maxLines: maxLines,
                subCaption: subCaption,
                iconSvg: iconSvg,
                sizeIcon: sizeIcon,
                iconColor: iconColor,
                function: function,
                textOverflow: textOverflow,
              )),
        );
      },
    );
    return _result ?? false;
  }

  static onShowCancelPost(_, {required Function onCancel}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
            height: MediaQuery.of(_).size.height / 3,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnCancelPostBottomSheet(onCancel: onCancel));
      },
    );
  }

  static onShowSignOut(
    BuildContext context, {
    required Function() onSignOut,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 3.5,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(0),
          child: OnSignOutSheet(onSignOut: onSignOut),
        );
      },
    );
  }

  PersistentBottomSheetController<T> onShowFilters<T>(
      BuildContext context,
      GlobalKey<ScaffoldState> scaffoldState,
      String file,
      GlobalKey? globalKey) {
    return scaffoldState.currentState!.showBottomSheet<T>(
      (context) => GestureDetector(
        onVerticalDragStart: (_) {},
        child: OnShowFilters(
          file: file,
          globalKey: globalKey,
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  static onShowViewers(BuildContext _, {required String? storyID}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: MediaQuery.of(_).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(_).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: ViewedStoriesScreen(storyID: storyID!),
        );
      },
    );
  }

  static onShowOptionStory(BuildContext _, Map<String, dynamic>? arguments) {
    showModalBottomSheet(
      context: _,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: MediaQuery.of(_).size.height * 0.4,
          decoration: BoxDecoration(
            color: Theme.of(_).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: OnShowOptionStory(arguments: arguments),
        );
      },
    );
  }

  static onShowOptionContent(
    BuildContext _, {
    required ContentData contentData,
    required String captionTitle,
    bool onDetail = true,
    StoryController? storyController,
    Function? onUpdate,
  }) {
    showModalBottomSheet(
      context: _,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: MediaQuery.of(_).size.height * 0.4,
          decoration: BoxDecoration(
            color: Theme.of(_).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: OnShowOptionContent(
            captionTitle: captionTitle,
            contentData: contentData,
            onDetail: onDetail,
          ),
        );
      },
    ).whenComplete(() {
      if (storyController != null) storyController.play();
      if (onUpdate != null) onUpdate();
    });
  }

  static onShowOptionGender(
    BuildContext context, {
    required String value,
    required Function() onSave,
    required Function() onCancel,
    required Future<dynamic> initFuture,
    required Function(String value) onChange,
  }) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: false,
      isScrollControlled: true,
      builder: (builder) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          constraints: const BoxConstraints(maxHeight: 270),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: UserOverviewGenderContent(
            value: value,
            onSave: onSave,
            onChange: onChange,
            onCancel: onCancel,
            initFuture: initFuture,
          ),
        );
      },
    );
  }

  Future<bool> onShowLicenseAgreementSheet(
    BuildContext context, {
    Function? function,
    bool enableDrag = true,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10),
  }) async {
    final _result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: enableDrag,
      isScrollControlled: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.28,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: const SafeArea(
              child: OnShowLicenseAgreement(),
            ),
          ),
        );
      },
    );
    return _result ?? false;
  }

  static onComingSoonDoku(_) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight! / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: const OnComingSoonDoku(),
          ),
        );
      },
    );
  }

  static onReportContent(_, {StoryController? storyController}) {
    showModalBottomSheet(
      context: _,
      builder: (builder) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            // height: SizeConfig.screenHeight! / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnReportContentBottomSheet(),
          ),
        );
      },
    ).whenComplete(() {
      if (storyController != null) storyController.play();
      // if (onUpdate != null) onUpdate();
    });
    ;
  }

  static onReportFormContent(_, {StoryController? storyController}) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      builder: (builder) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            // height: SizeConfig.screenHeight! / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnReportContentFormBottomSheet(),
          ),
        );
      },
    ).whenComplete(() {
      if (storyController != null) storyController.play();
      Routing().moveBack();
      // if (onUpdate != null) onUpdate();
    });
  }

  static onReportSpamContent(_, {StoryController? storyController}) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      builder: (builder) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            // height: SizeConfig.screenHeight! / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnReportSpamFormBottomSheet(),
          ),
        );
      },
    ).whenComplete(() {
      if (storyController != null) storyController.play();
      Routing().moveBack();
      // if (onUpdate != null) onUpdate();
    });
  }

  static onShowOptionPrivacyPost(
    BuildContext context, {
    required String value,
    required Function() onSave,
    required Function() onCancel,
    required Function(String value, String code) onChange,
  }) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      builder: (builder) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          // constraints: const BoxConstraints(maxHeight: 280),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: OnPrivacyPostBottomSheet(
            value: value,
            onSave: onSave,
            onChange: onChange,
            onCancel: onCancel,
          ),
        );
      },
    );
  }

  static onShowLocation(
    BuildContext context, {
    required String value,
    required Function() onSave,
    required Function() onCancel,
    required Function(String value) onChange,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (builder) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: OnLocationSearchBottomSheet(
            value: value,
            onSave: onSave,
            onChange: onChange,
            onCancel: onCancel,
          ),
        );
      },
    );
  }

  static onShowInteresList(
    BuildContext context, {
    required String value,
    required Function() onSave,
    required Function() onCancel,
    required Function(String value) onChange,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (builder) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: OnInterestListBottomSheet(
            value: value,
            onSave: onSave,
            onChange: onChange,
            onCancel: onCancel,
          ),
        );
      },
    );
  }

  static onShowSearchPeople(
    BuildContext context, {
    required String value,
    required Function() onSave,
    required Function() onCancel,
    required Function(String value) onChange,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (builder) {
        return Material(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: OnSearchPeopleBottomSheet(
              value: value,
              onSave: onSave,
              onChange: onChange,
              onCancel: onCancel,
            ),
          ),
        );
      },
    );
  }

  static void onShowAutoComplate(
    BuildContext _,
  ) {
    // System().actionReqiredIdCard(
    //   _,
    //   uploadContentAction: false,
    //   action: () {
    String value = '';
    Function() onSave = () {};
    Function() onCancel = () {};
    Function(String value) onChange = (val) {};
    showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (builder) {
        return Material(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: OnSearchPeopleBottomSheet(
              value: value,
              onSave: onSave,
              onChange: onChange,
              onCancel: onCancel,
            ),
          ),
        );
      },
    );
  }

  static onShowUserTag(
    BuildContext _, {
    required List<TagPeople> value,
    required Function() function,
    required postId,
    StoryController? storyController,
  }) {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        context: _,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[
            WillPopScope(
              onWillPop: () async {
                Routing().moveBack();
                if (storyController != null) {
                  storyController.play();
                }
                return false;
              },
              child: Container(
                decoration: const BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: OnShowUserTagBottomSheet(
                  value: value,
                  function: function,
                  postId: postId,
                ),
              ),
            )
          ]);
        });
  }

  static onShowUserViewContent(
    BuildContext _, {
    // required List<ViewContent> value,
    // required Function() function,
    required postId,
    required eventType,
    required title,
    StoryController? storyController,
  }) {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        context: _,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[
            WillPopScope(
              onWillPop: () async {
                Routing().moveBack();
                if (storyController != null) {
                  storyController.play();
                }
                return false;
              },
              child: Container(
                decoration: const BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: OnShowUserViewContentBottomSheet(
                  postId: postId,
                  eventType: eventType,
                  title: title,

                  // value: value,
                  // function: function,
                  // postId: postId,
                ),
              ),
            )
          ]);
        });
  }

  static onShowReportProfile(BuildContext _, {userID}) {
    showModalBottomSheet(
      isScrollControlled: false,
      context: _,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          // height: height ?? SizeConfig.screenHeight! / 4,
          decoration: BoxDecoration(
            color: Theme.of(_).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(0),
          child: ReportProfile(userID: userID),
        );
      },
    );
  }
}
