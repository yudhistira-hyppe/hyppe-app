import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/playlist/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/on_show_comment_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_cancel_post.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coming_soon_doku.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_internal_server_error.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_no_internet_connection.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_option_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_option_story.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_ID_verification.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_complete_profile_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_filters.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_license_agreement.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_upload_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/playlist/add/screen.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/playlist/list/screen.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/content/report_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/stories/screen.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_overview_gender_content.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';
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
       Scaffold.of(_)
            .showBottomSheet(
              (context) {
                return Container(
                  height: SizeConfig.screenHeight! -
                      (28 + (SizeConfig.screenWidth! / 1.78)),
                  decoration: BoxDecoration(
                    color: Theme.of(_).colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  padding: const EdgeInsets.all(0),
                  child: OnShowCommentBottomSheetV2(
                    postID: postID,
                    fromFront: false,
                    parentComment: parentComment,
                  ),
                );
              },
            )
            .closed
            .whenComplete(() {
              try {
                if (_.read<DiariesPlaylistNotifier>().forcePause) {
                  _.read<DiariesPlaylistNotifier>().forcePause = false;
                }
              } catch (e) {
                e.logger();
              }
              // Provider.of<CommentNotifier>(_, listen: false).onCommentExit();
            });
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
            height: MediaQuery.of(_).size.height / 2,
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
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35),
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
}
