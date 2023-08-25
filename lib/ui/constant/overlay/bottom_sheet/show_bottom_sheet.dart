import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart' as messageData;
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/on_show_comment_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_boost_interval.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_boost_time.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_buy_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_cancel_post.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_category_support_ticket.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/on_choose_music.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_datepicker_month.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_delete_message.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_interest_list.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_internal_server_error.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_location_search.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_no_internet_connection.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_option_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_ownership_EULA.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_people_search.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_privacy_post.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_qrcode.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_report_account.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_report_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_report_content_form.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_report_spam_form.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_ID_verification.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_all_bank.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_complete_profile_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_filters.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_help_bank_account.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_help_support_docs.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_id_verification_failed.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_idcard_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_license_agreement.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_user_tag.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_show_user_view_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_statement_ownership.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_statement_pin.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_upload_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_warning.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/content/reportProfile.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/content/report_content.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_challange_periode.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_overview_gender_content.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/filter/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';

import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';
import 'bottom_sheet_content/on_show_success_ownership_content.dart';
import 'bottom_sheet_content/on_sign_out.dart';
import 'bottom_sheet_content/on_something_when_wrong.dart';
import 'bottom_sheet_content/on_coloured_sheet.dart';

class ShowBottomSheet {
  ShowBottomSheet._private();

  static final ShowBottomSheet _instance = ShowBottomSheet._private();

  factory ShowBottomSheet() {
    return _instance;
  }

  static onChooseMusic(context, {isPic = false, isInit = true}) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
              height: context.getHeight() * 0.92,
              child: OnChooseMusicBottomSheet(
                isPic: isPic,
                isInit: isInit,
              ),
            ),
          );
        });
  }

  static onUploadContent(
    context, {
    bool isStory = true,
    bool isPict = true,
    bool isDiary = true,
    bool isVid = true,
  }) async {
    await showModalBottomSheet(
      context: context,
      // isScrollControlled: false,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            // height: SizeConfig.screenHeight! / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnUploadContentBottomSheet(
              isDiary: isDiary,
              isPict: isPict,
              isStory: isStory,
              isVid: isVid,
            ),
          ),
        );
      },
    );
  }

  static onLongPressDeleteMessage(BuildContext _, {messageData.MessageDataV2? data, required Function() function}) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: false,

      // isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Wrap(
          children: [
            Container(
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

  static onNoInternetConnection(_, {Function? tryAgainButton, Function? onBackButton}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: _,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
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
            child: OnNoInternetConnectionBottomSheet(tryAgainButton: tryAgainButton ?? () {}, onBackButton: onBackButton),
          ),
        );
      },
    );
  }

  static onInternalServerError(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnInternalServerErrorBottomSheet(),
          ),
        );
      },
    );
  }

  static onShowReport(BuildContext context, {ContentData? data, ReportType? reportType, double? height, bool fromLandscapeMode = false}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: height ?? SizeConfig.screenHeight! / 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(0),
          child: ReportContent(userID: data?.email, postID: data?.postID, reportType: reportType, fromLandscapeMode: fromLandscapeMode),
        );
      },
    ).whenComplete(() {
      // if (_.read<PreviewVidNotifier>().forcePause) _.read<PreviewVidNotifier>().forcePause = false;
      // if (_.read<DiariesPlaylistNotifier>().forcePause) _.read<DiariesPlaylistNotifier>().forcePause = false;
    });
  }

  static onShowReportStory(context, {ContentData? data, int? index, bool? forceStop}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight! / 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: ReportContent(userID: data?.email, storyID: data?.postID, reportType: ReportType.story),
          ),
        );
      },
    ).whenComplete(() => forceStop = false);
  }

  static void onShowCommentV2(
    BuildContext _, {
    required String? postID,
    DisqusLogs? parentComment,
  }) {
    // System().actionReqiredIdCard(
    //   _,
    //   uploadContentAction: false,
    //   action: () {

    // final _routing = Routing();

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
                return true;
              },
              child: SafeArea(
                child: Container(
                  height: !notifier.isLoading ? SizeConfig.screenHeight! : SizeConfig.screenHeight! - (28 + (SizeConfig.screenWidth! / 1.78)),
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
              notifier.retryTakeIdCard(fromBottomSheet: true);
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
                child: OnShowIDVerificationFailedBottomSheet()),
          ),
        );
      },
    );
  }

  static onShowInfoIDCard(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: false,
      context: ctx,
      enableDrag: false,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(0),
          child: const OnShowInfoIdCardBottomSheet(),
        );
      },
    );
  }

  static onShowHelpSupportDocs(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: false,
      context: ctx,
      enableDrag: false,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(0),
          child: const OnShowHelpSupportDocsBottomSheet(),
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
    String? caption, {
    int? maxLines,
    TextOverflow? textOverflow,
    Color color = kHyppeTextSuccess,
    Color textColor = kHyppeLightButtonText,
    Color textButtonColor = kHyppeLightButtonText,
    String? subCaption,
    String? iconSvg,
    double? sizeIcon,
    Color? iconColor,
    Function? function,
    bool enableDrag = true,
    bool dismissible = true,
    bool isArrow = false,
    String textButton = 'Ok',
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10),
    EdgeInsets? margin,
    double? borderRadius,
    final Function()? functionSubCaption,
    final String? subCaptionButton,
    final int? milisecond,
    Function()? onClose,
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
              margin: margin,
              padding: padding,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0))),
              child: OnColouredSheet(
                isArrow: isArrow,
                isMargin: margin != null,
                caption: caption,
                maxLines: maxLines,
                subCaption: subCaption,
                iconSvg: iconSvg,
                sizeIcon: sizeIcon,
                iconColor: iconColor,
                function: function,
                textOverflow: textOverflow,
                subCaptionButton: subCaptionButton,
                functionSubCaption: functionSubCaption,
                milisecond: milisecond,
                textButton: textButton,
                textButtonColor: textButtonColor,
                textColor: textColor,
              )),
        );
      },
    ).whenComplete(onClose ?? () {});
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

  PersistentBottomSheetController<T>? onShowFilters<T>(BuildContext context, GlobalKey<ScaffoldState> scaffoldState, String file, GlobalKey? globalKey) {
    return scaffoldState.currentState?.showBottomSheet<T>(
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

  Future onShowOptionContent(
    BuildContext _, {
    required ContentData contentData,
    required String captionTitle,
    bool onDetail = true,
    StoryController? storyController,
    Function? onUpdate,
    bool? isShare,
    FlutterAliplayer? fAliplayer,
  }) async {
    await showModalBottomSheet(
      context: _,
      enableDrag: true,
      isDismissible: true,
      // isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          // height: MediaQuery.of(_).size.height * 0.4,
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
            isShare: isShare ?? true,
            fAliplayer: fAliplayer,
          ),
        );
      },
    ).whenComplete(() {
      if (storyController != null) storyController.play();
      if (fAliplayer != null) {
        fAliplayer.play();
        fAliplayer.setMuted(false);
      }

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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

  Future onReportContent(
    _, {
    ContentData? postData,
    AdsData? adsData,
    String? type,
    StoryController? storyController,
    Function? onUpdate,
    bool? inDetail,
    FlutterAliplayer? fAliplayer,
    String? key,
  }) async {
    await showModalBottomSheet(
      context: _,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            // height: SizeConfig.screenHeight / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnReportContentBottomSheet(
              postData: postData,
              type: type,
              onUpdate: onUpdate,
              adsData: adsData,
              inDetail: inDetail,
              keyInt: key,
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (fAliplayer != null) {
        fAliplayer.pause();
      }
    });
  }

  static onReportFormContent(_, {StoryController? storyController}) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            // height: SizeConfig.screenHeight / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: const OnReportContentFormBottomSheet(),
          ),
        );
      },
    ).whenComplete(() {
      Routing().moveBack();
    });
  }

  static onReportSpamContent(_, {StoryController? storyController, ContentData? postData, AdsData? adsData, String? type, Function? onUpdate, bool? inDetail, String? key}) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      builder: (builder) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
            child: Container(
              height: SizeConfig.screenHeight ?? 0 / 1.09,
              decoration: BoxDecoration(
                color: Theme.of(_).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.all(0),
              child: OnReportSpamFormBottomSheet(
                postData: postData,
                type: type,
                inDetail: inDetail ?? true,
                keyInt: key,
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      // if (onUpdate != null) onUpdate();
    });
  }

  static onReportAccountContent(
    _, {
    StoryController? storyController,
    ContentData? postData,
    AdsData? adsData,
    String? type,
    Function? onUpdate,
    bool? inDetail,
  }) {
    showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      builder: (builder) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
            child: Container(
              height: SizeConfig.screenHeight ?? 0 / 1.09,
              decoration: BoxDecoration(
                color: Theme.of(_).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.all(0),
              child: OnReportAccountBottomSheet(
                postData: postData,
                type: type,
                inDetail: inDetail ?? true,
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
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
    FlutterAliplayer? fAliplayer,
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
        }).whenComplete(() {
      if (fAliplayer != null) fAliplayer.play();
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
          return Container(
            constraints: BoxConstraints(
              maxHeight: SizeConfig.screenHeight! / 2,
              minHeight: 20,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: OnShowUserViewContentBottomSheet(
              postId: postId,
              eventType: eventType,
              title: title,
            ),
          );
        });
  }

  static onShowReportProfile(BuildContext _, {userID}) {
    showModalBottomSheet(
        isScrollControlled: false,
        context: _,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
            // height: height ?? SizeConfig.screenHeight / 4,
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
        });
  }

  static onBuyContent(context, {ContentData? data, FlutterAliplayer? fAliplayer}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
            height: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnBuyContentBottomSheet(
              data: data,
            ));
      },
    ).whenComplete(() {
      if (fAliplayer != null) {
        fAliplayer.play();
      }
    });
  }

  onShowHelpBankAccount(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
            margin: EdgeInsets.only(top: 50),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnHelpBankAccountBottomSheet());
      },
    );
  }

  onShowAllBank(BuildContext _) {
    showModalBottomSheet(
        isScrollControlled: false,
        context: _,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
            // height: height ?? SizeConfig.screenHeight / 4,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: onShowAllBankBottomSheet(),
          );
        });
  }

  onShowFilterAllTransaction(BuildContext _) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: _,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.only(top: 30),
            // height: height ?? SizeConfig.screenHeight / 4,
            decoration: BoxDecoration(
              color: Theme.of(_).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: AllTransactionFilter(),
          );
        });
  }

  static onShowOwnerEULA(
    BuildContext context, {
    required Function() onSave,
    required Function() onCancel,
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
          child: OnOwnershipEULABottomSheet(
            onSave: onSave,
            onCancel: onCancel,
          ),
        );
      },
    );
  }

  static onShowStatementOwnership(
    BuildContext context, {
    required Function() onSave,
    required Function() onCancel,
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
          child: OnStatementOwnershipBottomSheet(
            onSave: onSave,
            onCancel: onCancel,
          ),
        );
      },
    );
  }

  static onShowStatementPin(
    BuildContext context, {
    Function()? onSave,
    Function()? onCancel,
    title = '',
    bodyText = '',
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
          child: OnStatementPinBottomSheet(
            onSave: onSave,
            onCancel: onCancel,
            title: title,
            bodyText: bodyText,
          ),
        );
      },
    );
  }

  static onShowCategorySupportTicket(
    BuildContext context, {
    Function()? onSave,
    Function()? onCancel,
    title = '',
    bodyText = '',
  }) {
    showModalBottomSheet(
      context: context,
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
          child: const OnCategorySupportTicket(),
        );
      },
    );
  }

  static onWarningBottom(
    BuildContext context, {
    Function()? onSave,
    Function()? onCancel,
    title = '',
    bodyText = '',
    buttonText = '',
    icon = '',
  }) {
    showModalBottomSheet(
      context: context,
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
          child: OnWarningBottomSheet(
            onSave: onSave,
            onCancel: onCancel,
            title: title,
            bodyText: bodyText,
            buttonText: buttonText,
            icon: icon,
          ),
        );
      },
    );
  }

  static onShowBoostTime(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
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
          child: const OnBoostTimeContent(),
        );
      },
    );
  }

  static onShowBoostInterval(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
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
          child: const OnBoostIntervalContent(),
        );
      },
    );
  }

  static onPeriodChallange(context, String idchallenge, bool isDetail, int session) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight! / 1.5,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnChallangePeriodeBottomSheet(
              session: session,
              idchallenge: idchallenge,
              isDetail: isDetail,
            ),
          ),
        );
      },
    );
  }

  static onDatePickerMonth(context, bool isDetail) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            height: SizeConfig.screenHeight! / 2.2,
            // height: SizeConfig.screenHeight!,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnDatepickerMonth(isDetail: isDetail),
          ),
        );
      },
    );
  }

  static onQRCodeChallange(context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(builder).viewInsets.bottom),
          child: Container(
            // height: SizeConfig.screenHeight! / 1.78,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: OnQRCode(),
          ),
        );
      },
    );
  }
}
