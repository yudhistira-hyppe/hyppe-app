import 'package:hyppe/initial/hyppe/notifier.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/appeal/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/entities/stories/notifier.dart';
import 'package:hyppe/ui/constant/entities/web_view/notifier.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/support_ticket/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment/payment_summary/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/list_boost/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/setting_notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/review_buy/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/filter/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/see_all/vid_see_all_notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/payment_summary/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_notifier.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/register/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_agreement/user_aggrement_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_complete_profile/user_complete_profile_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/notifier.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/services/cache_service.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart' as homeV2;
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart' as vidV2;
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart' as picV2;
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart' as diaryV2;
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart' as storyV2;
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart' as V2;
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/change_password/notifier.dart' as cpV2;
import 'package:hyppe/ui/inner/search_v2/notifier.dart' as sV2;
import '../../ui/constant/entities/comment_v2/notifier.dart';
import '../../ui/inner/home/content_v2/help/detail_ticket/notifier.dart';
import '../../ui/inner/home/content_v2/vid/playlist/notifier.dart';
import '../../ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';

class AppDependencies {
  static List<SingleChildWidget> inject({required HyppeNotifier rootNotifier}) => [
        /// All Dependency Injection

        // Root Notifier
        // ChangeNotifierProvider(create: (context) => rootNotifier),

        ChangeNotifierProvider.value(value: rootNotifier),

        // Translate
        // ChangeNotifierProvider(create: (context) => TranslateNotifierV2()),
        ChangeNotifierProvider.value(value: TranslateNotifierV2()),

        // Camera
        // ChangeNotifierProvider(create: (context) => CameraNotifier()),
        ChangeNotifierProvider.value(value: CameraNotifier()),
        ChangeNotifierProvider.value(value: CameraDevicesNotifier()),

        // UI && OUTER
        ChangeNotifierProvider(create: (context) => LoginNotifier()),
        ChangeNotifierProvider(create: (context) => WelcomeLoginNotifier()),

        // SIGN UP
        ChangeNotifierProvider(create: (context) => SignUpPinNotifier()),
        ChangeNotifierProvider(create: (context) => SignUpWelcomeNotifier()),

        // UI && INNER
        ChangeNotifierProvider(create: (context) => MainNotifier()),
        ChangeNotifierProvider(create: (context) => homeV2.HomeNotifier()),
        ChangeNotifierProvider(create: (context) => sV2.SearchNotifier()),
        ChangeNotifierProvider(create: (context) => MakeContentNotifier()),
        ChangeNotifierProvider(create: (context) => PreviewContentNotifier()),
        ChangeNotifierProvider(create: (context) => DiariesPlaylistNotifier()),
        ChangeNotifierProvider(create: (context) => PreUploadContentNotifier()),
        ChangeNotifierProvider(create: (context) => VidDetailNotifier()),
        ChangeNotifierProvider(create: (context) => VideoNotifier()),

        ChangeNotifierProvider(create: (context) => cpV2.ChangePasswordNotifier()),

        // Profile
        ChangeNotifierProvider(create: (context) => SelfProfileNotifier()),
        ChangeNotifierProvider(create: (context) => OtherProfileNotifier()),
        ChangeNotifierProvider(create: (context) => V2.AccountPreferencesNotifier()),

        // Vid
        ChangeNotifierProvider(create: (context) => vidV2.PreviewVidNotifier()),
        ChangeNotifierProvider(create: (context) => VidSeeAllNotifier()),

        // Stories
        ChangeNotifierProvider(create: (context) => storyV2.PreviewStoriesNotifier()),

        // Pic
        ChangeNotifierProvider(create: (context) => picV2.PreviewPicNotifier()),
        ChangeNotifierProvider(create: (context) => PicDetailNotifier()),

        // Diary
        ChangeNotifierProvider(create: (context) => diaryV2.PreviewDiaryNotifier()),

        ChangeNotifierProvider(create: (context) => StoriesPlaylistNotifier()),

        // TODO(Hendi Noviansyah): Refactor totalViews variable
        // Viewer Stories
        ChangeNotifierProxyProvider<storyV2.PreviewStoriesNotifier, ViewerStoriesNotifier>(
          create: (context) => ViewerStoriesNotifier(),
          update: (context, value, previous) => previous!..viewers = 0,
          // update: (context, value, previous) => previous..viewers = value.myStoriesData?.totalViews,
        ),

        /// Report
        ChangeNotifierProvider(create: (context) => ReportNotifier()),

        // Playlist
        ChangeNotifierProvider(create: (context) => LikeNotifier()),
        ChangeNotifierProvider(create: (context) => FollowRequestUnfollowNotifier()),

        // Notification
        ChangeNotifierProvider(create: (context) => NotificationNotifier()),

        //Ticket History
        ChangeNotifierProvider(create: (context) => TicketHistoryNotifier()),
        ChangeNotifierProvider(create: (context) => DetailTicketNotifier()),

        // Wallet
        // ChangeNotifierProxyProvider3<HomeNotifier, SelfProfileNotifier, TranslateNotifierV2, WalletNotifier>(
        //   create: (context) => WalletNotifier(),
        //   update: (context, value, value2, value3, previous) => previous
        //     ..sessionID = value.sessionID
        //     ..user = value2.user
        //     ..language = value3.translate,
        // ),

        // WebView
        Provider(create: (context) => WebViewNotifier()),

        // Error Service
        ChangeNotifierProvider(create: (context) => ErrorService()),

        // Overlay Provider
        Provider(create: (context) => OverlayHandlerProvider()),

        // ProxyProvider<ProfileNotifier, CacheService>(
        //   update: (context, value5, previous) => CacheService(
        //     userProfiles: value5.myProfile,
        //   ),
        // ),

        ProxyProvider0<CacheService>(
          update: (context, previous) => CacheService(),
        ),

        // --------------------------------------------------------------------------------------------- //

        ChangeNotifierProvider<ForgotPasswordNotifier>(
          create: (context) => ForgotPasswordNotifier(),
        ),

        ChangeNotifierProvider<RegisterNotifier>(
          create: (context) => RegisterNotifier(),
        ),

        ChangeNotifierProvider<UserOtpNotifier>(
          create: (context) => UserOtpNotifier(),
        ),

        ChangeNotifierProvider<UserInterestNotifier>(
          create: (context) => UserInterestNotifier(),
        ),

        ChangeNotifierProvider<UserCompleteProfileNotifier>(
          create: (context) => UserCompleteProfileNotifier(),
        ),

        ChangeNotifierProvider<UserAgreementNotifier>(
          create: (context) => UserAgreementNotifier(),
        ),

        ChangeNotifierProxyProvider<HyppeNotifier, SettingNotifier>(
          create: (context) => SettingNotifier(),
          update: (context, value, previous) => previous!..appPackage = value.appVersion,
        ),

        ChangeNotifierProvider<UploadNotifier>(
          create: (context) => UploadNotifier(),
        ),
        ChangeNotifierProvider<VerificationIDNotifier>(create: (context) => VerificationIDNotifier()),

        ChangeNotifierProvider<ProfileCompletionNotifier>(create: (context) => ProfileCompletionNotifier()),

        ChangeNotifierProvider<ReferralNotifier>(create: (context) => ReferralNotifier()),

        ChangeNotifierProvider<ReviewBuyNotifier>(create: (context) => ReviewBuyNotifier()),

        ChangeNotifierProvider<PaymentMethodNotifier>(create: (context) => PaymentMethodNotifier()),

        ChangeNotifierProvider<PaymentNotifier>(create: (context) => PaymentNotifier()),

        ChangeNotifierProvider<PaymentSummaryNotifier>(create: (context) => PaymentSummaryNotifier()),

        ChangeNotifierProvider<TransactionNotifier>(create: (context) => TransactionNotifier()),

        ChangeNotifierProvider<PinAccountNotifier>(create: (context) => PinAccountNotifier()),

        ChangeNotifierProvider<FilterTransactionNotifier>(create: (context) => FilterTransactionNotifier()),

        ChangeNotifierProvider<ReferralNotifier>(create: (context) => ReferralNotifier()),

        ChangeNotifierProvider<SupportTicketNotifier>(create: (context) => SupportTicketNotifier()),
        ChangeNotifierProvider<SlidedPicDetailNotifier>(create: (context) => SlidedPicDetailNotifier()),
        ChangeNotifierProvider<AppealNotifier>(create: (context) => AppealNotifier()),
        ChangeNotifierProvider<PaymentBoostSummaryNotifier>(create: (context) => PaymentBoostSummaryNotifier()),
        ChangeNotifierProvider<ListBoostNotifier>(create: (context) => ListBoostNotifier()),
        ChangeNotifierProvider<CommentNotifierV2>(create: (context) => CommentNotifierV2()),
        ChangeNotifierProvider<ScrollPicNotifier>(create: (context) => ScrollPicNotifier()),
        ChangeNotifierProvider<ScrollDiaryNotifier>(create: (context) => ScrollDiaryNotifier()),
        ChangeNotifierProvider<ScrollVidNotifier>(create: (context) => ScrollVidNotifier()),
        ChangeNotifierProvider<ChallangeNotifier>(create: (context) => ChallangeNotifier()),
        ChangeNotifierProvider<TutorNotifier>(create: (context) => TutorNotifier()),
        ChangeNotifierProvider<VideoNotifier>(create: (context) => VideoNotifier()),
      ];
}
