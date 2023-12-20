class UrlConstants {
  UrlConstants._private();

  static final UrlConstants _instance = UrlConstants._private();

  factory UrlConstants() {
    return _instance;
  }

  /// Versioning
  static const String apiV0 = '';

  static const String apiV1 = '/v1/';

  static const String apiV2 = '/v2/';

  static const String apiV3 = '/v3/';

  static const String apiV4 = '/v4/';

  static const String apiV5 = '/v5/';

  static const String apiV6 = '/v6/';

  static const String apiV7 = '/v7/';

  static const String urlPing = "s1.hyppe.cloud";

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

  /* User Content route */
  static const String liveStramRoute = "/api/live";

  /* v3 user ads */
  static const String adsRoute = "/api/ads";

  static const String adsRouteV2 = "/api/adsv2/ads";

  static const String transactionRoute = "/api/transactions";

  static const String userbankaccountsRoute = "/api/userbankaccounts";

  static const String accountBalancesRoutes = "/api/accountbalances";

  /* Post route */
  static const String contentRouteV3 = "/api/getusercontents";

  static const String interestCount = "/api/interest-count";

  static const String challange = "/api/challenge";

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

  static const String userBearer = "$userRoute/bearer";

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

  static const String getStoriesLandingPage = "$postsRoute/landing-page/recentStory";

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
  // static const String getMyUserPostsV2 = "$postRouteV2/getuserposts/my/v2";

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
  static const String getNotification = "$postRouteV2/getnotification2";

  /// post => Get auth apsara
  static const String apsaraauth = "$postRouteV2/apsaraauth?apsaraId=";

  /// post => Get Notification
  static const String getBoostMaster = "$postRoute/boostmaster";

  //apis goole plcae
  static const String getGoogleMapApis = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  static const String getGoogleGeocodingApis = "https://maps.googleapis.com/maps/api/geocode/json";

  //get search people
  static const String getSearchPeople = "$profileRoute/search";

  ///---------------------------------------------------------------------------------------------------------///
  /* v3 search data content dan user */
  static const String getSearchContentV3 = "$contentRouteV3/searchdata";
  static const String getSearchContentV4 = "$contentRouteV3/searchdatanew";
  static const String landingPageSearch = "$interestCount/default-page";
  static const String getDetailHashtag = "$contentRouteV3/searchdatanew/detailtag";
  static const String getDetailInterest = "$contentRouteV3/searchdatanew/detailinterest";
  static const String getSearchContentV5 = "$contentRouteV3/searchdatanew/v2";
  static const String getDetailHashtagV2 = "$contentRouteV3/searchdatanew/detailtag/v2";
  static const String getDetailInterestV2 = "$contentRouteV3/searchdatanew/detailinterest/v2";
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

  // get tag people in content
  static const String tagPeople = "$postsRoute/tagpeople";

  /// get => Get Ads User
  static const String getAdsVideo = "$adsRoute/getAds/user?type=Content%20Ads";

  /// get => Get Sponsored Ads
  static const String getSponsoredAds = "$adsRoute/getAds/user?type=Sponsor%20Ads";

  /// get => Get In App Ads
  static const String getInAppAds = "$adsRoute/getAds/user?type=In%20App%20Ads";

  /// get => Get Ads In Between
  static const String getAdsInBetween = "$adsRouteV2/get/62e238a4f63d0000510026b3";

  /// get => Get Ads In Content
  static const String getAdsInContent = "$adsRouteV2/get/62f0b435118731ecc0f45772";

  /// get => Get Pop Up Ads
  static const String getPopUpAds = "$adsRouteV2/get/632a806ad2770000fd007a62";

  /// post => View Ads User
  /// static const String viewAds = "$adsRoute/viewads";
  static const String viewAds = "$adsRouteV2/viewads";

  //setting
  static const String settingApps = "$utilsRoute/getSetting";

  /// post => Click Learn More Ads
  /// static const String clickAds = "$adsRoute/clickads";
  static const String clickAds = "$adsRouteV2/clicked";

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

  // Get Old Video
  static const String oldVideo = "/stream/v2?postid=";
  static const String getNewLandingPage = "$userContentRoute/landingpage";

  static const String getKtpText = "$postsRoute/gettext";

  // Get Chalange
  static const String getBannerChalange = "$challange/listing/bannerlandingpage";
  static const String getLeaderBoard = "$challange/listleaderboard";
  static const String getLeaderBoardSession = "$challange/listleaderboard2";
  static const String getOtherChallange = "$challange/allchallenge";
  static const String joinChallange = "$challange/join";
  static const String listAchievement = "$challange/listbadgebyuser";
  static const String collectionBadge = "$challange/listbadgeuserdetail";
  static const String selectBadge = "$challange/badgechoice";
  static const String checkChallengeStatus = "$challange/join/currentstatus";

  // Get Effect
  static const String getEffects = "/api/assets/filter/list";
  static const String downloadEffect = "/api/assets/filter/file";

  //Tutor
  static const String tutorPost = "$userRoute/tutor/update";

  //Banner
  static const String getBanners = "/api/banner/listing";

  // Get Sticker
  static const String getStickers = "/api/mediastiker/listingapp";

  //Live Stream
  static const String getLinkStream = "$liveStramRoute/create";
  static const String updateStream = "$liveStramRoute/update";
  static const String viewrStream = "$liveStramRoute/view";
  static const String feedbackStream = "$liveStramRoute/feedback";
  static const String listLiveStreaming = "$liveStramRoute/list";
}
