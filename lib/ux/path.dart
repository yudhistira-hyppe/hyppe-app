class Routes {
  Routes._();

  static const String root = '/';
  static const String login = '/login';
  static const String welcomeLogin = '/welcome-login';
  static const String lobby = '/lobby';
  static const String selfProfile = '/self-profile';
  static const String otherProfile = '/other-profile';
  static const String makeContent = '/make-content';
  static const String previewContent = '/preview-content';
  static const String preUploadContent = '/pre-upload-content';
  static const String ownershipSelling = '/ownership-selling';
  static const String homePageSignInSecurity = '/home-page-sign-in-security';
  static const String accountPreferences = '/account-preferences';
  static const String changePassword = '/change-password';
  static const String messageDetail = '/message-detail';
  static const String report = '/report';
  static const String noInternetConnection = '/no-internet-connection';
  static const String moderatedContent = '/moderated-content';
  static const String wallet = '/wallet';
  static const String walletWebView = 'wallet-web-view';
  static const String completeProfile = '/required-complete-profile';
  static const String referralScreen = '/referral-screen';
  static const String listReferral = '/list-referral';
  static const String insertReferral = '/insert-referral';
  static const String showAds = '/show-ads';

// Sign up
  static const String signUpPin = '/sign-up-pin';
  static const String signUpWelcome = '/sign-up-welcome';
  static const String signUpVerified = '/sign-up-verified';

// ------------------------------------------------------------- //

  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String userInterest = '/user-interest';
  static const String userAgreement = '/user-agreement';

// content
  static const String vidDetail = '/vid-detail';
  static const String vidSeeAllScreen = '/vid-see-all-screen';

  static const String picDetail = '/pic-detail';
  static const String picSeeAllScreen = '/pic-see-all-screen';
  static const String picDetailPreview = '/pic-detail-preview';
  static const String picSlideDetailPreview = '/pic-slide-detail-preview';

  static const String diaryDetail = '/diary-detail';
  static const String diarySeeAllScreen = '/diary-see-all-screen';

  static const String storyDetail = '/story-detail';
  static const String showStories = '/show-stories';

  static const String appSettings = '/app-settings';
  static const String themeScreen = '/theme-screen';
  static const String followerScreen = '/follower-screen';
  static const String userOtpScreen = '/user-otp-screen';

  static const String imagePreviewScreen = '/image-preview-screen';

  static const String testAliPlayer = '/test-ali-player';

  //search
  static const String searcMore = '/search-more';
  static const String searcMoreComplete = '/search-more-complete';

  static const String verificationIDStep1 = '/verification-id-step-1';
  static const String verificationIDStep2 = '/verification-id-step-2';
  static const String verificationIDStep3 = '/verification-id-step-3';
  static const String verificationIDStep4 = '/verification-id-step-4';
  static const String verificationIDStep5 = '/verification-id-step-5';
  static const String verificationIDStep6 = '/verification-id-step-6';
  static const String verificationIDStep7 = '/verification-id-step-7';
  static const String verificationIDFailed = '/verification-id-failed';
  static const String verificationIDSuccess = '/verification-id-success';
  static const String verificationIDLoading = '/verification-id-loading';

  //delete account
  static const String deleteAccount = '/delete-account';
  static const String confirmDeleteAccount = '/confirm-delete-account';

  static const String reviewBuyContent = '/review-buy-content';
  static const String paymentScreen = '/payment-screen';
  static const String paymentMethodScreen = '/payment-method-screen';
  static const String paymentSummaryScreen = '/payment-summary-screen';

  //transaction
  static const String transaction = '/transaction';
  static const String allTransaction = '/all-transaction';
  static const String detailTransaction = '/detail-transaction';
  static const String transactionInProgress = '/transaction-inprogress';
  static const String bankAccount = '/bank-account';
  static const String addBankAccount = '/add-bank-account';
  static const String withdrawal = '/withdrawal';
  static const String withdrawalSummary = '/withdrawal-summary';
  static const String pinWithdrawal = '/pin-withdrawal';
  static const String successWithdrawal = '/success-withdrawal';

  //create pin
  static const String pinScreen = '/pin-screen';
  static const String confirmPinScreen = '/confirm-pin-screen';
  static const String verificationPinScreen = '/verification-pin-screen';
  static const String forgotPinScreen = '/forgot-pin-screen';

  static const String verificationIDStepSupportingDocs = '/verification-id-docs';
  static const String verificationIDStepSupportingDocsPreview = '/verification-id-docs-preview';
  static const String verificationIDStepSupportDocsEula = '/verification-id-docs-eula';

  static const String reportContent = '/report-content';

  // help support ticket
  static const String help = '/help';
  static const String faqDetail = '/faq-detail';
  static const String supportTicket = '/support-ticket';
  static const String appeal = '/appeal';
  static const String appealSuccess = '/appeal-success';
  static const String ticketHistory = '/ticket-history';
  static const String detailTAHistory = '/detail-ticket-appeal-history';

  //boost
  static const String boostUpload = '/boost-upload';
  static const String boostPaymentSummary = '/boost-payment-summary';
  static const String boostList = '/boost-list';
}
