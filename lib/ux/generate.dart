import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/arguments/account_preference_screen_argument.dart';
import 'package:hyppe/core/arguments/ads_argument.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/slided_diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/slided_pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/slided_vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/faq_argument.dart';
import 'package:hyppe/core/arguments/follower_screen_argument.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/hashtag_argument.dart';
import 'package:hyppe/core/arguments/image_preview_argument.dart';
import 'package:hyppe/core/arguments/message_detail_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/arguments/pic_fullscreen_argument.dart';
import 'package:hyppe/core/arguments/referral_list_user.dart';
import 'package:hyppe/core/arguments/summary_live_argument.dart';
import 'package:hyppe/core/arguments/ticket_argument.dart';
import 'package:hyppe/core/arguments/transaction_argument.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/arguments/user_otp_screen_argument.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/arguments/view_streaming_argument.dart';
import 'package:hyppe/ui/constant/entities/appeal/screen.dart';
import 'package:hyppe/ui/constant/entities/appeal/success_appeal.dart';
import 'package:hyppe/ui/constant/entities/web_view/screen.dart';
import 'package:hyppe/ui/constant/page_no_internet_connection.dart';
import 'package:hyppe/ui/constant/page_not_found.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/confirm_delete_account/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/delete_account/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/activation_gift/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/cache_and_download/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/achievement/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/collection/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/shimmer_slider.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/coin_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/content_preferences/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/player/diary_player.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/player/landing_diary_full.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/scroll/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/scroll/screen_full.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/see_all/diary_see_all_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/exchangecoins/exchange_coin_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/exchangecoins/pages/finish_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/FAQ/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/support_ticket/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/disccount/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/historyordercoin/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment/payment_summary/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_waiting/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/paymentcoin/payment_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/fullscreen/pic_fullscreen_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/widget/picscroll_fullscreen_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/see_all/pic_see_all_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/test.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/confirm_pin/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/forgot_pin/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/verification/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/list_boost/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/insert_referral.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/list_referral.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/screen.dart';

import 'package:hyppe/ui/inner/home/content_v2/review_buy/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/player/story_player.dart';
import 'package:hyppe/ui/inner/home/content_v2/topupcoin/topupcoin_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/add_bank_account/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/bank_account/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/transaction_inprogress/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/withdrawal/pin_withdrawal/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/withdrawal/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/withdrawal/success_withdraw/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/withdrawal/summary_withdrawal/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/home_tutorial.dart';

import 'package:hyppe/ui/inner/home/content_v2/verification_id/failed_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_1/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_2/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_3/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_4/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_5/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_6/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_7/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/success_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/supporting_document/eula.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/supporting_document/preview.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/supporting_document/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/screen.dart';

import 'package:hyppe/ui/inner/home/content_v2/vid/see_all/vid_see_all_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/feedback/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/screen.dart';
import 'package:hyppe/ui/inner/home/widget/ads_in_between_full.dart';
import 'package:hyppe/ui/inner/home/widget/ads_video_in_between_full.dart';
import 'package:hyppe/ui/inner/home/widget/aliplayer.dart';
import 'package:hyppe/ui/inner/main/screen.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/screen.dart' as message_detail_v2;
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/image_preview_view.dart';
import 'package:hyppe/ui/inner/message_v2/screen.dart';
import 'package:hyppe/ui/inner/search_v2/search_more/screen.dart';
import 'package:hyppe/ui/inner/upload/link/screen.dart';
import 'package:hyppe/ui/inner/upload/make_content/screen.dart';
import 'package:hyppe/ui/inner/upload/payment/screen.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/boost/screen.dart';
import 'package:hyppe/ui/inner/upload/preview_content/editor/photo/screen.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/ownerhip_selling/screen.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/payment_summary/screen.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/screen.dart';
import 'package:hyppe/ui/inner/upload/preview_content/screen.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/forgot_password_screen.dart';
import 'package:hyppe/ui/outer/forgot_password/set_new_password/screen.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_screen.dart';
import 'package:hyppe/ui/outer/login/screen.dart';
import 'package:hyppe/ui/outer/login/test_login.dart';
import 'package:hyppe/ui/outer/opening_logo/screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/register/register_screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_agreement/user_agreement_screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/screen.dart';
import 'package:hyppe/ui/outer/webview/webview_screen.dart';
import 'package:hyppe/ui/outer/welcome_login/screen.dart';
import 'package:hyppe/ui/view/follower/follower_screen.dart';
import 'package:hyppe/ui/view/theme/theme_screen.dart';
import 'package:hyppe/ux/path.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content/moderated/screen.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

/// V2
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/setting_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/sign_in_security/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/change_password/screen.dart';
import '../core/arguments/detail_ticket_argument.dart';
import '../core/arguments/main_argument.dart';
import '../ui/inner/home/content_v2/help/detail_ticket/screen.dart';
import '../ui/inner/home/content_v2/help/ticket_history/screen.dart';
import '../ui/inner/home/content_v2/pic/playlist/slide/slide_screen.dart';
import '../ui/inner/home/content_v2/vid/playlist/screen_v2.dart';
import '../ui/inner/home/content_v2/video_streaming/view_streaming/list_streamers/screen.dart';
import '../ui/inner/home/content_v2/video_streaming/view_streaming/screen.dart';
import '../ui/inner/search_v2/hashtag/detail_screen.dart';

class Generate {
  static List<Route<dynamic>> initialRoute(_) {
    return [MaterialPageRoute(builder: (_) => OpeningLogo())];
  }

  static Route<dynamic> allRoutes(RouteSettings settings) {
    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(builder: (_) => OpeningLogo());
      case Routes.welcomeLogin:
        return MaterialPageRoute(builder: (_) => const WelcomeLoginScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Routes.lobby:
        return MaterialPageRoute(builder: (_) => MainScreen(args: settings.arguments as MainArgument?));
      case Routes.selfProfile:
        return MaterialPageRoute(builder: (_) => SelfProfileScreen(arguments: settings.arguments as GeneralArgument));
      case Routes.otherProfile:
        return MaterialPageRoute(builder: (_) => OtherProfileScreen(arguments: settings.arguments as OtherProfileArgument));

      case Routes.homePageSignInSecurity:
        return MaterialPageRoute(builder: (_) => HyppeHomeSignAndSecurity());
      case Routes.makeContent:
        return MaterialPageRoute(builder: (_) => const MakeContentScreen());
      case Routes.previewContent:
        return MaterialPageRoute(builder: (_) => const PreviewContentScreen());
      case Routes.editPhoto:
        return MaterialPageRoute(builder: (_) => const PhotoEditorScreen());
      case Routes.preUploadContent:
        return MaterialPageRoute(builder: (_) => PreUploadContentScreen(arguments: settings.arguments as UpdateContentsArgument));
      case Routes.ownershipSelling:
        return MaterialPageRoute(builder: (_) => const OwnershipSellingScreen());
      case Routes.changePassword:
        return MaterialPageRoute(builder: (_) => HyppeChangePassword());
      case Routes.accountPreferences:
        return MaterialPageRoute(
            builder: (_) =>
                HyppeAccountPreferences(argument: settings.arguments == null ? AccountPreferenceScreenArgument(fromSignUpFlow: false) : settings.arguments as AccountPreferenceScreenArgument));

      case Routes.adsBetweenFull:
        return MaterialPageRoute(builder: (_) => AdsInBetweenFull(arguments: settings.arguments as AdsArgument));

      case Routes.adsBetweenVidFull:
        return MaterialPageRoute(builder: (_) => AdsVideoInBetweenFull(arguments: settings.arguments as AdsArgument));

      case Routes.signUpPin:
        return MaterialPageRoute(builder: (_) => SignUpPin(arguments: settings.arguments as VerifyPageArgument));
      case Routes.signUpWelcome:
        return MaterialPageRoute(builder: (_) => SignUpWelcome());
      case Routes.message:
        return MaterialPageRoute(builder: (_) => const MessageScreen());
      case Routes.messageDetail:
        return MaterialPageRoute(builder: (_) => message_detail_v2.MessageDetailScreen(argument: settings.arguments as MessageDetailArgument));
      case Routes.report:
      // return MaterialPageRoute(builder: (_) => HyppeReport());
      case Routes.noInternetConnection:
        return MaterialPageRoute(builder: (_) => const PageNoInternetConnection());
      case Routes.moderatedContent:
        return MaterialPageRoute(builder: (_) => ModeratedContent(arguments: settings.arguments as ContentData));
      // case Routes.wallet:
      //   return MaterialPageRoute(builder: (_) => Wallet());
      case Routes.walletWebView:
        return MaterialPageRoute(builder: (_) => WalletWebView(arguments: settings.arguments as String));

      // ------------------------------------------------------------ //
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case Routes.newPassword:
        return MaterialPageRoute(builder: (_) => const SetNewPassword());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.userInterest:
        return MaterialPageRoute(builder: (_) => UserInterestScreen(arguments: settings.arguments as UserInterestScreenArgument));
      case Routes.userAgreement:
        return MaterialPageRoute(builder: (_) => const UserAgreementScreen());

      case Routes.picDetail:
        return MaterialPageRoute(builder: (_) => PicDetailScreen(arguments: settings.arguments as PicDetailScreenArgument, isOnPageTurning: true));
      case Routes.picDetailPreview:
        return MaterialPageRoute(builder: (_) => PicDetail(arguments: settings.arguments as ContentData));
      case Routes.picSlideDetailPreview:
        return MaterialPageRoute(builder: (_) => SlidedPicDetail(arguments: settings.arguments as SlidedPicDetailScreenArgument));

      // case Routes.diaryDetail:
      //   return MaterialPageRoute(builder: (_) => HyppePlaylistDiaries(argument: settings.arguments as DiaryDetailScreenArgument));

      case Routes.diaryDetail:
        return MaterialPageRoute(builder: (_) => DiaryPlayerPage(argument: settings.arguments as DiaryDetailScreenArgument));

      case Routes.diaryFull:
        return CupertinoPageRoute(builder: (_) => LandingDiaryFullPage(argument: settings.arguments as DiaryDetailScreenArgument));

      // case Routes.storyDetail:
      //   return MaterialPageRoute(builder: (_) => HyppePlaylistStories(argument: settings.arguments as StoryDetailScreenArgument));
      // case Routes.showStories:
      //   return MaterialPageRoute(builder: (_) => StoryGroupScreen(argument: settings.arguments as StoryDetailScreenArgument));
      case Routes.showStories:
        return MaterialPageRoute(builder: (_) => StoryPlayerPage(argument: settings.arguments as StoryDetailScreenArgument));
      case Routes.appSettings:
        return MaterialPageRoute(builder: (_) => const SettingScreen());

      case Routes.themeScreen:
        return MaterialPageRoute(builder: (_) => const ThemeScreen());

      case Routes.followerScreen:
        return MaterialPageRoute(builder: (_) => FollowerScreen(argument: settings.arguments as FollowerScreenArgument));

      case Routes.userOtpScreen:
        return MaterialPageRoute(builder: (_) => UserOtpScreen(argument: settings.arguments as UserOtpScreenArgument));

      case Routes.diarySeeAllScreen:
        return MaterialPageRoute(builder: (_) => const DiarySeeAllScreen());

      case Routes.picSeeAllScreen:
        return MaterialPageRoute(builder: (_) => const PicSeeAllScreen());

      case Routes.vidDetail:
        return MaterialPageRoute(builder: (_) => NewVideoDetailScreen(arguments: settings.arguments as VidDetailScreenArgument));
      // case Routes.vidDetail:
      //   return MaterialPageRoute(builder: (_) => VidDetailScreen(arguments: settings.arguments as VidDetailScreenArgument));

      case Routes.vidSeeAllScreen:
        return MaterialPageRoute(builder: (_) => const VidSeeAllScreen());

      case Routes.commentsDetail:
        return MaterialPageRoute(builder: (_) => CommentsDetailScreen(argument: settings.arguments as CommentsArgument));

      case Routes.imagePreviewScreen:
        return MaterialPageRoute(builder: (_) => ImagePreviewView(argument: settings.arguments as ImagePreviewArgument));

      case Routes.completeProfile:
        return MaterialPageRoute(builder: (_) => ProfileCompletion(argument: AccountPreferenceScreenArgument(fromSignUpFlow: false)));

      case Routes.contentPreferences:
        return MaterialPageRoute(builder: (_) => const ContentPreferencesScreen());

      case Routes.referralScreen:
        return MaterialPageRoute(builder: (_) => const Referral());

      case Routes.listReferral:
        return MaterialPageRoute(builder: (_) => ListReferralUser(arguments: settings.arguments as ReferralListUserArgument));
      case Routes.insertReferral:
        return MaterialPageRoute(builder: (_) => InsertReferral());
      // case Routes.showAds:
      //   return MaterialPageRoute(
      //       builder: (_) => AdsScreen(
      //             argument: settings.arguments as AdsArgument,
      //           ));

      case Routes.searcMore:
        return MaterialPageRoute(builder: (_) => const SearchMoreScreen());
      case Routes.hashtagDetail:
        return MaterialPageRoute(
            builder: (_) => DetailHashtagScreen(
                  argument: settings.arguments as HashtagArgument,
                ));
      case Routes.verificationIDStep1:
        return MaterialPageRoute(builder: (_) => const VerificationIDStep1());
      case Routes.verificationIDStep2:
        return MaterialPageRoute(builder: (_) => const VerificationIDStep2());
      case Routes.verificationIDStep3:
        return MaterialPageRoute(builder: (_) => const VerificationIDStep3());
      case Routes.verificationIDStep4:
        return MaterialPageRoute(builder: (_) => const VerificationIDStep4());
      case Routes.verificationIDStep5:
        return MaterialPageRoute(builder: (_) => const VerificationIDStep5());
      case Routes.verificationIDStep6:
        return MaterialPageRoute(builder: (_) => const VerificationIDStep6());
      case Routes.verificationIDStep7:
        return MaterialPageRoute(builder: (_) => VerificationIDStep7(isFromBack: settings.arguments as bool));
      case Routes.verificationIDFailed:
        return MaterialPageRoute(builder: (_) => const VerificationIDFailed());
      case Routes.verificationIDSuccess:
        return MaterialPageRoute(builder: (_) => const VerificationIDSuccess());
      case Routes.deleteAccount:
        return MaterialPageRoute(builder: (_) => const HyppeDeleteAccoount());
      case Routes.confirmDeleteAccount:
        return MaterialPageRoute(builder: (_) => const HyppeConfirmDeleteAccount());

      case Routes.reviewBuyContent:
        return MaterialPageRoute(builder: (_) => ReviewBuyContentScreen(arguments: settings.arguments as ContentData));

      case Routes.paymentScreen:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());

      case Routes.paymentMethodScreen:
        return MaterialPageRoute(builder: (_) => PaymentMethodScreen(argument: settings.arguments as TransactionArgument));

      case Routes.paymentSummaryScreen:
        return MaterialPageRoute(builder: (_) => const PaymentSummaryScreen());

      case Routes.transaction:
        return MaterialPageRoute(builder: (_) => const Transaction());

      case Routes.transactionInProgress:
        return MaterialPageRoute(builder: (_) => const TransactionHistoryInProgress());

      case Routes.allTransaction:
        return MaterialPageRoute(builder: (_) => const AllTransaction());

      case Routes.bankAccount:
        return MaterialPageRoute(builder: (_) => const BankAccount());

      case Routes.addBankAccount:
        return MaterialPageRoute(builder: (_) => const AddBankAccount());

      case Routes.detailTransaction:
        return MaterialPageRoute(builder: (_) => const DetailTransaction());

      case Routes.withdrawal:
        return MaterialPageRoute(builder: (_) => const WithdrawalScreen());

      case Routes.withdrawalSummary:
        return MaterialPageRoute(builder: (_) => const SummaryWithdrawalScreen());

      case Routes.pinWithdrawal:
        return MaterialPageRoute(builder: (_) => const PinWithdrawalScreen());

      case Routes.successWithdrawal:
        return MaterialPageRoute(builder: (_) => const SuccessWithdrawScreen());

      case Routes.pinScreen:
        return MaterialPageRoute(builder: (_) => const PinScreen());

      case Routes.verificationPinScreen:
        return MaterialPageRoute(builder: (_) => const VerificationPin());

      case Routes.confirmPinScreen:
        return MaterialPageRoute(builder: (_) => const ConfirmPin());

      case Routes.forgotPinScreen:
        return MaterialPageRoute(builder: (_) => const ForgotPinScreen());

      case Routes.verificationIDStepSupportingDocs:
        return MaterialPageRoute(builder: (_) => const VerificationIDStepSupportingDocs());
      case Routes.verificationIDStepSupportingDocsPreview:
        return MaterialPageRoute(builder: (_) => const VerificationIDStepSupportingDocsPreview());
      case Routes.verificationIDStepSupportDocsEula:
        return MaterialPageRoute(builder: (_) => const VerificationIDStepSupportDocsEula());
      case Routes.help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case Routes.cacheAndDownload:
        return MaterialPageRoute(builder: (_) => const CacheAndDownloadScreen());
      case Routes.faqDetail:
        return MaterialPageRoute(builder: (_) => FAQDetailScreen(data: settings.arguments as FAQArgument));
      case Routes.supportTicket:
        return MaterialPageRoute(builder: (_) => const SupportTicketScreen());
      case Routes.appeal:
        return MaterialPageRoute(builder: (_) => AppealScreen(data: settings.arguments as ContentData));
      case Routes.appealSuccess:
        return MaterialPageRoute(builder: (_) => SuccessAppeal(data: settings.arguments as ContentData));
      case Routes.ticketHistory:
        return MaterialPageRoute(builder: (_) => TicketHistoryScreen(data: settings.arguments as TicketArgument));
      case Routes.detailTAHistory:
        return MaterialPageRoute(builder: (_) => DetailTicketScreen(data: settings.arguments as DetailTicketArgument));

      //------boost
      case Routes.boostUpload:
        return MaterialPageRoute(builder: (_) => const BoostUploadScreen());
      case Routes.boostPaymentSummary:
        return MaterialPageRoute(builder: (_) => const PaymentBoostSummaryScreen());
      case Routes.boostList:
        return MaterialPageRoute(builder: (_) => const ListBoostScreen());
      case Routes.aliTest:
        return MaterialPageRoute(builder: (_) => const AliPlayer());

      case Routes.webView:
        return MaterialPageRoute(builder: (_) => WebviewScreen(url: settings.arguments as String));
      case Routes.testImage:
        return MaterialPageRoute(builder: (_) => const TestPageImage());
      case Routes.testLogin:
        return MaterialPageRoute(builder: (_) => const TestLogin());
      case Routes.scrollPic:
        return MaterialPageRoute(builder: (_) => ScrollPic(arguments: settings.arguments as SlidedPicDetailScreenArgument));
      case Routes.scrollDiary:
        return MaterialPageRoute(builder: (_) => ScrollDiary(arguments: settings.arguments as SlidedDiaryDetailScreenArgument));
      case Routes.scrollVid:
        return MaterialPageRoute(builder: (_) => ScrollVid(arguments: settings.arguments as SlidedVidDetailScreenArgument));

      case Routes.scrollFullDiary:
        return CupertinoPageRoute(builder: (_) => ScrollFullDiary(arguments: settings.arguments as SlidedDiaryDetailScreenArgument));

      case Routes.chalenge:
        return MaterialPageRoute(builder: (_) => const ChalangeScreen());
      case Routes.chalengeDetail:
        return MaterialPageRoute(builder: (_) => ChalangeDetailScreen(arguments: settings.arguments as GeneralArgument));
      case Routes.chalengeCollectionBadge:
        return MaterialPageRoute(builder: (_) => CollectionBadgeScreen(arguments: settings.arguments as GeneralArgument));
      case Routes.chalengeAchievement:
        return MaterialPageRoute(builder: (_) => const AchievementScreen());
      case Routes.shimmerSlider:
        return MaterialPageRoute(builder: (_) => ShimmerSlider(arguments: settings.arguments as SlidedPicDetailScreenArgument));
      case Routes.homeTutor:
        return MaterialPageRoute(builder: (_) => const HomeTutorScreen());
      case Routes.streamer:
        return MaterialPageRoute(builder: (_) => const StreamerScreen());
      // case Routes.streameriOS:
      //   return MaterialPageRoute(builder: (_) => const StreamerIOSScreen());
      case Routes.streamingFeedback:
        return MaterialPageRoute(builder: (_) => StreamingFeedbackScreen(arguments: settings.arguments as SummaryLiveArgument));
      case Routes.listStreamers:
        return MaterialPageRoute(builder: (_) => const ListStreamersScreen());
      case Routes.viewStreaming:
        return MaterialPageRoute(
            builder: (_) => ViewStreamingScreen(
                  args: settings.arguments as ViewStreamingArgument,
                ));
      case Routes.picFullScreenDetail:
        return CupertinoPageRoute(builder: (_) => PicFullscreenPage(argument: settings.arguments as PicFullscreenArgument));
      case Routes.picScrollFullScreenDetail:
        return CupertinoPageRoute(builder: (_) => PicScrollFullscreenPage(argument: settings.arguments as SlidedPicDetailScreenArgument));

      // Coins
      case Routes.saldoCoins:
        return MaterialPageRoute(builder: (_) => const CoinPage());
      case Routes.topUpCoins:
        return MaterialPageRoute(builder: (_) => const TopUpCoinPage());
      case Routes.paymentCoins:
        return MaterialPageRoute(builder: (_) => const PaymentCoinPage(), settings: settings);
      case Routes.exchangeCoins:
        return MaterialPageRoute(builder: (_) => const ExchangeCoinPage(), settings: settings);

      // case Routes.verificationPinPage:
      // return MaterialPageRoute(builder: (_) => const VerificationPinPage(), settings: settings);
      case Routes.finishTrxPage:
        return MaterialPageRoute(builder: (_) => const FinishTrxPage(), settings: settings);
      
      case Routes.addlink:
        return MaterialPageRoute(builder: (_) => const AddLinkPage(), settings: settings);

      case Routes.mydiscount:
        return MaterialPageRoute(builder: (_) => const MyCouponsPage(), settings: settings);

      case Routes.transactionwaiting:
        return MaterialPageRoute(builder: (_) => const PaymentWaiting(), settings: settings);

      case Routes.contentgift:
        return MaterialPageRoute(builder: (_) => const ActivationGiftScreen(), settings: settings);
      
      case Routes.historyordercoin:
        return MaterialPageRoute(builder: (_) => const HistoryOrderCoinScreen(), settings: settings);
    }
    return MaterialPageRoute(builder: (_) => PageNotFoundScreen());
  }
}
