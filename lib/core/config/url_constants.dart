class UrlConstants {
  UrlConstants._private();

  static final UrlConstants _instance = UrlConstants._private();

  factory UrlConstants() {
    return _instance;
  }

  /// Versioning
  static const String apiV1 = 'v1';

  static const String apiV2 = 'v2';

  static const String apiV3 = 'v3';

  static const String apiV4 = 'v4';

  /// Production Base url
  // static const String productionBaseApi = "https://prod.hyppe.app";
  static const String productionBaseApi = "https://prod.hyppe.app";
  static const String productionUploadBaseApi = "https://upload.hyppe.app/";

  /// Staging v2 Base url
  // static const String stagingBaseApi = "https://prod.hyppe.app";
  static const String stagingBaseApi = "https://staging.hyppe.app";
  static const String stagingUploadBaseApi = "https://stagingupload.hyppe.app/";

  // static const String stagingBaseApi = "http://192.168.43.179/erp/";

  /// Prod Deeplink Base url
  static const String prodDeeplinkUrl = "https://share.hyppe.app";

  /// Staging Deeplink Base url
  static const String devDeeplinkUrl = "https://share.hyppe.app";

  /// APIs end point
  /* User route */
  static const String userRoute = "/api/user";

  /* Utils route */
  static const String utilsRoute = "/api/utils";

  /* Post route */
  static const String postRoute = "/api/post";

  /* Posts route */
  static const String postsRoute = "/api/posts";

  /* Follow route */
  static const String followRoute = "/api/follow";

  /* Stories route */
  static const String storiesRoute = "/api/story";

  /* Search route */
  static const String searchRoute = "/api/search";

  /* Chat route */
  static const String chatRoute = "/api/chat";

  /* Notification route */
  static const String notificationRoute = "/api/inapp";

  /* Wallet route */
  static const String walletRoute = "/bagea-core";

  /* Wallet route */
  static const String bizRoute = "/api/biz";

  /* v3 user profile */
  static const String profileRoute = "/api/getuserprofiles";

  /* User Content route */
  static const String userContentRoute = "/api/getusercontents";

  /* User Content route */
  static const String bankRoute = "/api/banks";

  /* v3 user ads */
  static const String adsRoute = "/api/ads";

  static const String transactionRoute = "/api/transactions";

  static const String userbankaccountsRoute = "/api/userbankaccounts";

  static const String accountBalancesRoutes = "/api/accountbalances";

  /* Post route */
  static const String contentRouteV3 = "/api/getusercontents";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Bookmark */
  /// get => Get bookmark.
  static const String getBookmark = "$postRoute/getBookmark";

  /// post => Add bookmark.
  static const String addBookmark = "$postRoute/addBookmark";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Follow */
  /// post Add Story View.
  static const String followUser = "$followRoute/follow";

  /// get Check Following to user.
  static const String isFollowing = "$followRoute/isFollowing";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Users */
  /// post sign_up => Send data user to server.
  static const String signUp = "$userRoute/signup";

  /// post sign_in
  static const String login = "$userRoute/login";

  /// post login with google
  static const String loginGoogle = "$userRoute/signup/socmed";

  /// post change_password => To change password.
  static const String changePassword = "$userRoute/changepassword";

  /// post update_profile
  static const String updateProfile = "$userRoute/updateprofile";

  /// post recover_password => To recover password with either username or email.
  static const String recoverPassword = "$userRoute/recoverpassword";

  /// post register interest => To register interests of user.
  static const String updateInterest = "$userRoute/profileinterest";

  /// post => Upload Profile picture V2.
  static const String uploadProfilePictureV2 = "$postsRoute/profilepicture";

  /// post => Verify Account
  static const String verifyAccount = "$userRoute/verifyaccount";

  /// post => Resend OTP
  static const String resendOTP = "$userRoute/resendotp";

  /// user => Referral
  static const String referral = "$userRoute/referral";

  /// user => Referral Count
  static const String referralCount = "$userRoute/referral-count";

  /// user => Change Language
  static const String updateLanguage = "$userRoute/updatelang";

  /// user => Change Language
  static const String userPin = "$userRoute/pin";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Playlist */
  /// post => Create new playlist.
  static const String createNewPlaylist = "$postRoute/createPlaylist";

  /// get => Get all playlist.
  static const String getAllPlaylist = "$postRoute/getAllPlaylist";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Posts */

  /// get => Get User Post.
  static const String getUserPostsLandingPage = "$postsRoute/getuserposts/landing-page";

  /// post => View Like and View.
  static const String viewLike = "$postRoute/viewlike";

  static const String getListMyBoost = "$postsRoute/getboost";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Reaction */
  /// post Add Reaction to content.
  static const String addPostReaction = "$postRoute/reactions/reactOnPost";

  /// post Add Reaction to comment.
  static const String addReactOnComment = "$postRoute/reactions/reactOnComment";

  /// post get Comment from Post.
  static const String getCommentReactions = "$postRoute/reactions/getCommentReactions";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Stories */

  /// get => Get viewer story.
  static const String views = "$storiesRoute/views";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Utils */
  /// get list of Area
  static const String area = "$utilsRoute/area";

  /// get the list of languages as a specified in ISO 639.
  static const String languages = "$utilsRoute/language";

  /// get the list of interests during registration process.
  static const String interest = "$utilsRoute/interest";

  /// get Eula.
  static const String eula = "$utilsRoute/eula";

  /// get Welcome notes.
  static const String welcomeNotes = "$utilsRoute/welcomenotes";

  /// get list of Gender
  static const String gender = "$utilsRoute/gender";

  /// get reactions.
  static const String reaction = "$utilsRoute/reaction";

  /// get list of City
  static const String city = "$utilsRoute/city";

  /// get list of Country
  static const String country = "$utilsRoute/country";

  /// get => Get Report Options.
  static const String postLogDevice = "$utilsRoute/logdevice";

  ///---------------------------------------------------------------------------------------------------------///
  // V2

  /// APIs end point
  /* Post route */
  static const String postRouteV2 = "/api/posts";

  ///---------------------------------------------------------------------------------------------------------///
  /// post => Get Contents
  static const String getuserposts = "$postRouteV2/getuserposts";

  /// get => Get My Contents.
  static const String getMyUserPosts = "$postRouteV2/getuserposts/my";

  /// get => Get My Contents.
  static const String getOtherUserPosts = "$postRouteV2/getuserposts/byprofile";

  /// post => Get Apsara Video.
  static const String getVideoApsara = "$postRouteV2/getvideo";

  /// post => Post Contents
  static const String createuserposts = "$postRouteV2/createpost";

  /// post => Update Contents
  static const String updatepost = "$postRouteV2/updatepost";

  /// post => post to change value key isViewed
  static const String postViewer = "$postRouteV2/postviewer";

  /// post lineID to delete comment
  static const String removeComment = "$postRouteV2/removecomment";

  /// post => Post Device Activity
  static const String deviceactivity = "$userRoute/deviceactivity";

  /// post => Get User Profiles
  static const String getuserprofile = "$userRoute/getuserprofile";

  /// post => Get User Profiles by username
  static const String getProfileByUser = "$getuserprofile/byusername";

  /// post => Log out
  static const String logout = "$userRoute/logout";

  /// post => Interactives
  static const String interactive = "$postRouteV2/interactive";

  /// post => Get Interactives
  static const String getInnteractives = "$postRouteV2/getinteractives";

  /// post => Get/Create Discussion
  static const String discuss = "$postRouteV2/disqus";

  /// post => Delete Discuss
  static const String deleteDiscuss = "$postRouteV2/disqus/deletedicuss";

  /// post => Delete Chat
  static const String deleteChat = "$postRouteV2/disqus/deletedicusslog";

  /// post => Get Notification
  static const String getNotification = "$postRouteV2/getnotification";

  /// post => Get Notification
  static const String getBoostMaster = "$postRoute/boostmaster";

  //apis goole plcae
  static const String getGoogleMapApis = "https://maps.googleapis.com/maps/api/place/autocomplete/json";

  //get search people
  static const String getSearchPeople = "$profileRoute/search";

  ///---------------------------------------------------------------------------------------------------------///
  /* v3 search data content dan user */
  static const String getSearchContentV3 = "$contentRouteV3/searchdata";
  // v3 delete tag
  static const String deletTagUser = "$postRouteV2/deletetag";

  // verification ID
  static const String verificationID = "$postsRoute/verificationid";

  //delete Account
  static const String deleteAccount = "$userRoute/noneactive";

  /// post => Get Buy Content
  static const String getBuyContent = "$userContentRoute/buy/details";

  /// post => Get Buy Content
  static const String postBuyContent = "$transactionRoute/";

  /// post => Get History Transaction
  static const String transactionHistorys = "$transactionRoute/historys";

  /// post => Get History Transaction
  static const String detailTransactionHistorys = "$transactionRoute/historys/details";

  /// post => Get Withdraw Detail
  static const String detailWithdrawal = "$transactionRoute/withdraw/listdetail";

  /// post => Get Withdraw Detail
  static const String withdraw = "$transactionRoute/withdraw";

  /// post => Get Withdraw Detail
  static const String boostContent = "$transactionRoute/boostcontent";

  /// post => Check Panding
  static const String pandingTransaction = "$transactionRoute/pending/";

  /// get => Get All Bank
  static const String getAllBank = "$bankRoute/all";

  /// get => Get All Bank
  static const String getBankByCode = "$bankRoute/search";

  /// post => Create account Bank
  static const String userBankAccounts = "$userbankaccountsRoute/";

  /// post => Get List bank account
  static const String myUserBankAccounts = "$userbankaccountsRoute/byuser";

  /// post => Get List bank account
  static const String deleteUserBankAccounts = "$userbankaccountsRoute/delete";

  /// post => Get Account Balance
  static const String accountBalances = "$accountBalancesRoutes/";

  /// post => Get Account Balance
  static const String detailRewards = "$accountBalancesRoutes/detailrewards";

  //old upload support file
  static const String verificationIDSupportingDocs = "$postsRoute/supportfile";

  // new verification ID Upload
  static const String verificationIDWithSupportDocs = "$postsRoute/upload";

  /// get => Get Ads User
  static const String getAdsVideo = "$adsRoute/getAds/user?type=Content%20Ads";

  /// get => Get Sponsored Ads
  static const String getSponsoredAds = "$adsRoute/getAds/user?type=Sponsor%20Ads";

  /// get => Get In App Ads
  static const String getInAppAds = "$adsRoute/getAds/user?type=In%20App%20Ads";

  /// post => View Ads User
  static const String viewAds = "$adsRoute/viewads";

  //setting
  static const String settingApps = "$utilsRoute/getSetting";

  /// post => Click Learn More Ads
  static const String clickAds = "$adsRoute/clickads";

  /// get => categorytickets
  static const String categoryTickets = "/api/categorytickets/all";

  /// get => categorytickets
  static const String levelTickets = "/api/leveltickets/all";

  //==========report============
  static const String getOptionReport = "/api/reportreasons/all";
  static const String insertReport = "/api/reportuser/create";
  static const String detailTypeAppeal = "/api/reportuser/detailreason";

  static const String appealPost = "/api/reportuser/appeal";
  static const String createTicket = "/api/usertickets/createticket";

  /// ===music===
  static const String getMusicGenre = "/api/genre/";
  static const String getMusicTheme = "/api/theme/";
  static const String getMusicMood = "/api/mood/";
  static const String getMusics = "/api/music";

  /// FAQ
  static const String faqList = "/api/faqs/allfaqs";

  /// Tiket Histories
  static const String ticketHistories = "/api/usertickets/filter";
  static const String ticketComments = "/api/usertickets/comment";
  static const String replyComment = "/api/usertickets/reply";
  static const String reportHistories = "/api/reportuser/listreport";
}
