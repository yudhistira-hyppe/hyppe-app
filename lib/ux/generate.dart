import 'package:hyppe/core/arguments/account_preference_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/follower_screen_argument.dart';
import 'package:hyppe/core/arguments/image_preview_argument.dart';
import 'package:hyppe/core/arguments/message_detail_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/arguments/referral_list_user.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/arguments/user_otp_screen_argument.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/models/collection/referral/model_referral.dart';
import 'package:hyppe/ui/constant/entities/web_view/screen.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/screen.dart';
import 'package:hyppe/ui/constant/page_no_internet_connection.dart';
import 'package:hyppe/ui/constant/page_not_found.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/see_all/diary_see_all_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/see_all/pic_see_all_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/insert_referral.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/list_referral.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/failed_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_1/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_2/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_3/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_4/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/step_5/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/success_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/see_all/vid_see_all_screen.dart';
import 'package:hyppe/ui/inner/main/screen.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/screen.dart'
    as message_detail_v2;
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/image_preview_view.dart';
import 'package:hyppe/ui/inner/search_v2/search_more/screen.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/screen.dart';
import 'package:hyppe/ui/inner/upload/make_content/screen.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/screen.dart';
import 'package:hyppe/ui/inner/upload/preview_content/screen.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/forgot_password_screen.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_screen.dart';
import 'package:hyppe/ui/outer/login/screen.dart';
import 'package:hyppe/ui/outer/opening_logo/screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/register/register_screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_agreement/user_agreement_screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_screen.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/screen.dart';
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
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/screen.dart';

class Generate {
  static List<Route<dynamic>> initialRoute(_) {
    return [MaterialPageRoute(builder: (_) => OpeningLogo())];
  }

  static Route<dynamic> allRoutes(RouteSettings settings) {
    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(builder: (_) => OpeningLogo());
      case Routes.welcomeLogin:
        return MaterialPageRoute(builder: (_) => WelcomeLoginScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Routes.lobby:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case Routes.selfProfile:
        return MaterialPageRoute(builder: (_) => SelfProfileScreen());
      case Routes.otherProfile:
        return MaterialPageRoute(
            builder: (_) => OtherProfileScreen(
                arguments: settings.arguments as OtherProfileArgument));
      case Routes.homePageSignInSecurity:
        return MaterialPageRoute(builder: (_) => HyppeHomeSignAndSecurity());
      case Routes.makeContent:
        return MaterialPageRoute(builder: (_) => MakeContentScreen());
      case Routes.previewContent:
        return MaterialPageRoute(builder: (_) => const PreviewContentScreen());
      case Routes.preUploadContent:
        return MaterialPageRoute(
            builder: (_) => PreUploadContentScreen(
                arguments: settings.arguments as UpdateContentsArgument));
      case Routes.changePassword:
        return MaterialPageRoute(builder: (_) => HyppeChangePassword());
      case Routes.accountPreferences:
        return MaterialPageRoute(
            builder: (_) => HyppeAccountPreferences(
                argument: settings.arguments == null
                    ? AccountPreferenceScreenArgument(fromSignUpFlow: false)
                    : settings.arguments as AccountPreferenceScreenArgument));
      case Routes.signUpPin:
        return MaterialPageRoute(
            builder: (_) =>
                SignUpPin(arguments: settings.arguments as VerifyPageArgument));
      case Routes.signUpWelcome:
        return MaterialPageRoute(builder: (_) => SignUpWelcome());
      case Routes.messageDetail:
        return MaterialPageRoute(
            builder: (_) => message_detail_v2.MessageDetailScreen(
                argument: settings.arguments as MessageDetailArgument));
      case Routes.report:
        return MaterialPageRoute(builder: (_) => HyppeReport());
      case Routes.noInternetConnection:
        return MaterialPageRoute(
            builder: (_) => const PageNoInternetConnection());
      case Routes.moderatedContent:
        return MaterialPageRoute(
            builder: (_) =>
                ModeratedContent(arguments: settings.arguments as ContentData));
      // case Routes.wallet:
      //   return MaterialPageRoute(builder: (_) => Wallet());
      case Routes.walletWebView:
        return MaterialPageRoute(
            builder: (_) =>
                WalletWebView(arguments: settings.arguments as String));

      // ------------------------------------------------------------ //
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.userInterest:
        return MaterialPageRoute(
            builder: (_) => UserInterestScreen(
                arguments: settings.arguments as UserInterestScreenArgument));
      case Routes.userAgreement:
        return MaterialPageRoute(builder: (_) => const UserAgreementScreen());

      case Routes.picDetail:
        return MaterialPageRoute(
            builder: (_) => PicDetailScreen(
                arguments: settings.arguments as PicDetailScreenArgument));
      case Routes.picDetailPreview:
        return MaterialPageRoute(
            builder: (_) =>
                PicDetail(arguments: settings.arguments as ContentData));

      case Routes.diaryDetail:
        return MaterialPageRoute(
            builder: (_) => HyppePlaylistDiaries(
                argument: settings.arguments as DiaryDetailScreenArgument));

      case Routes.storyDetail:
        return MaterialPageRoute(
            builder: (_) => HyppePlaylistStories(
                argument: settings.arguments as StoryDetailScreenArgument));

      case Routes.appSettings:
        return MaterialPageRoute(builder: (_) => const SettingScreen());

      case Routes.themeScreen:
        return MaterialPageRoute(builder: (_) => const ThemeScreen());

      case Routes.followerScreen:
        return MaterialPageRoute(
            builder: (_) => FollowerScreen(
                argument: settings.arguments as FollowerScreenArgument));

      case Routes.userOtpScreen:
        return MaterialPageRoute(
            builder: (_) => UserOtpScreen(
                argument: settings.arguments as UserOtpScreenArgument));

      case Routes.diarySeeAllScreen:
        return MaterialPageRoute(builder: (_) => const DiarySeeAllScreen());

      case Routes.picSeeAllScreen:
        return MaterialPageRoute(builder: (_) => const PicSeeAllScreen());

      case Routes.vidDetail:
        return MaterialPageRoute(
            builder: (_) => VidDetailScreen(
                arguments: settings.arguments as VidDetailScreenArgument));
      case Routes.vidSeeAllScreen:
        return MaterialPageRoute(builder: (_) => const VidSeeAllScreen());

      case Routes.imagePreviewScreen:
        return MaterialPageRoute(
            builder: (_) => ImagePreviewView(
                argument: settings.arguments as ImagePreviewArgument));

      case Routes.completeProfile:
        return MaterialPageRoute(
            builder: (_) => ProfileCompletion(
                argument:
                    AccountPreferenceScreenArgument(fromSignUpFlow: false)));

      case Routes.referralScreen:
        return MaterialPageRoute(builder: (_) => const Referral());

      case Routes.listReferral:
        return MaterialPageRoute(
            builder: (_) => ListReferralUser(
                arguments: settings.arguments as ReferralListUserArgument));
      case Routes.insertReferral:
        return MaterialPageRoute(builder: (_) => InsertReferral());
      case Routes.searcMore:
        return MaterialPageRoute(builder: (_) => const SearchMoreScreen());
      case Routes.searcMoreComplete:
        return MaterialPageRoute(
            builder: (_) => const SearchMoreCompleteScreen());

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
      case Routes.verificationIDFailed:
        return MaterialPageRoute(builder: (_) => const VerificationIDFailed());
      case Routes.verificationIDSuccess:
        return MaterialPageRoute(builder: (_) => const VerificationIDSuccess());
    }
    return MaterialPageRoute(builder: (_) => PageNotFoundScreen());
  }
}
