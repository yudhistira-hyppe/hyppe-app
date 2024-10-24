class UrlConstants {
  UrlConstants._private();

  static final UrlConstants _instance = UrlConstants._private();

  factory UrlConstants() {
    return _instance;
  }

  // ====Agora
  static const String agoraId = '7c3726a8377c4662be2e5b555aa35dbf';

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

  static const String userShare = "/api/streamsharelist";

  static const String monetization = "/api/monetization";
  // Monetization
  static const String monetizationRoute = "/api/monetization";
  
  static const String guidlineRoute = "/api/guidelines";

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
  static const String signUp = "$userRoute/signup/v2";

  /// post sign_in
  static const String login = "$userRoute/login/v2";

  /// guest mode
  static const String guest = "$userRoute/guest";

  /// post login with google
  static const String loginGoogle = "$userRoute/signup/socmed/v2";

  /// post change_password => To change password.
  static const String changePassword = "$userRoute/changepassword/v2";

  /// post update_profile
  static const String updateProfile = "$userRoute/updateprofile/v2";

  /// post recover_password => To recover password with either username or email.
  static const String recoverPassword = "$userRoute/recoverpassword/v2";

  /// post register interest => To register interests of user.
  static const String updateInterest = "$userRoute/profileinterest/v2";

  /// post => Upload Profile picture V2.
  static const String uploadProfilePictureV2 = "$postsRoute/profilepicture/v2";

  /// post => Verify Account
  static const String verifyAccount = "$userRoute/verifyaccount/v2";

  /// post => Resend OTP
  static const String resendOTP = "$userRoute/resendotp";

  /// user => Referral
  static const String referral = "$userRoute/referral/v2";

  /// user => Referral Count
  static const String referralCount = "$userRoute/referral-count/v2";

  /// user => Change Language
  static const String updateLanguage = "$userRoute/updatelang";

  /// user => Change Language
  static const String userPin = "$userRoute/pin";

  static const String userBearer = "$userRoute/bearer";

  ///---------------------------------------------------------------------------------------------------------///
  /* APIs Posts */

  /// get => Get User Post.
  static const String getUserPostsLandingPage = "$postsRoute/getuserposts/landing-page";

  static const String getStoriesLandingPage = "$postsRoute/landing-page/recentStory";

  /// post => View Like and View.
  static const String viewLike = "$postRoute/viewlike/v2";

  static const String getListMyBoost = "$postsRoute/getboost/v2";

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
  static const String getuserposts = "$postRouteV2/getuserposts/v2";

  /// get => Get My Contents.
  static const String getMyUserPosts = "$postRouteV2/getuserposts/my/v2";

  /// get => Get My Contents.
  static const String getOtherUserPosts = "$postRouteV2/getuserposts/byprofile/v2";

  static const String getUserPostsIndex = "$postRouteV2/getuserposts/byprofile/index";

  /// post => Get Apsara Video.
  static const String getVideoApsara = "$postRouteV2/getvideo";

  /// post => Post Contents
  static const String createuserposts = "$postRouteV2/createpost/v2";

  /// post => Update Contents
  static const String updatepost = "$postRouteV2/updatepost/v2";

  /// post => post to change value key isViewed
  static const String postViewer = "$postRouteV2/postviewer";

  /// post lineID to delete comment
  static const String removeComment = "$postRouteV2/removecomment";

  /// post => Post Device Activity
  static const String deviceactivity = "$userRoute/deviceactivity/v2";

  /// post => Get User Profiles
  static const String getuserprofile = "$userRoute/getuserprofile/v2";

  /// post => Get User Profiles by username
  static const String getProfileByUser = "$userRoute/getuserprofile/byusername/v2";

  /// post => Log out
  static const String logout = "$userRoute/logout/v2";

  /// post => Interactives
  static const String interactive = "$postRouteV2/interactive/v2";

  /// post => Get Interactives
  static const String getInnteractives = "$postRouteV2/getinteractives/v2";

  /// post => Get/Create Discussion
  static const String discuss = "$postRouteV2/disqus/v2";

  /// post => Delete Discuss
  static const String deleteDiscuss = "$postRouteV2/disqus/deletedicuss";

  /// post => Delete Chat
  static const String deleteChat = "$postRouteV2/disqus/deletedicusslog";

  /// post => Get Notification
  static const String getNotification = "$postRouteV2/getnotification2/v2";

  /// post => Get auth apsara
  static const String apsaraauth = "$postRouteV2/apsaraauth?apsaraId=";

  /// post => Get Notification
  static const String getBoostMaster = "$postRoute/boostmaster";

  //apis goole plcae
  static const String getGoogleMapApis = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  static const String getGoogleGeocodingApis = "https://maps.googleapis.com/maps/api/geocode/json";

  //get search people
  static const String getSearchPeople = "$profileRoute/search/v2";

  ///---------------------------------------------------------------------------------------------------------///
  /* v3 search data content dan user */
  static const String getSearchContentV3 = "$contentRouteV3/searchdata/v2";
  static const String getSearchContentV4 = "$contentRouteV3/searchdatanew";
  static const String landingPageSearch = "$interestCount/default-page";
  static const String getDetailHashtag = "$contentRouteV3/searchdatanew/newdetailtag";
  static const String getDetailInterest = "$contentRouteV3/searchdatanew/newdetailinterest";
  static const String getSearchContentV5 = "$contentRouteV3/searchdatanew/v2";
  static const String getDetailHashtagV2 = "$contentRouteV3/searchdatanew/newdetailtag/v2";
  static const String getDetailInterestV2 = "$contentRouteV3/searchdatanew/newdetailinterest/v2";
  // v3 delete tag
  static const String deletTagUser = "$postRouteV2/deletetag";

  // verification ID
  static const String verificationID = "$postsRoute/verificationid/v2";

  //delete Account
  static const String deleteAccount = "$userRoute/noneactive/v2";

  /// post => Get Buy Content
  static const String getBuyContent = "$userContentRoute/buy/details/v2";

  /// post => Get Buy Content
  static const String postBuyContent = "$transactionRoute/v2";

  /// post => Get History Transaction
  static const String transactionHistorys = "$transactionRoute/historys";

  /// post => Get History Transaction
  static const String detailTransactionHistorys = "$transactionRoute/historys/details";

  /// post => Get Withdraw Detail
  static const String detailWithdrawal = "$transactionRoute/withdraw/listdetail/v2";

  /// post => Get Withdraw Detail
  static const String withdraw = "$transactionRoute/withdraw/v2";

  /// post => Get Withdraw Detail
  static const String boostContent = "$transactionRoute/boostcontent";

  /// post => Check Panding
  static const String pandingTransaction = "$transactionRoute/pending/";

  /// get => Get All Bank
  static const String getAllBank = "$bankRoute/all";

  /// get => Get All Bank
  static const String getBankByCode = "$bankRoute/search";

  /// post => Create account Bank
  static const String userBankAccounts = "$userbankaccountsRoute/v2";

  /// post => Get List bank account
  static const String myUserBankAccounts = "$userbankaccountsRoute/byuser/v2";

  /// post => Get List bank account
  static const String deleteUserBankAccounts = "$userbankaccountsRoute/delete";

  /// post => Get Account Balance
  static const String accountBalances = "$accountBalancesRoutes/v2";

  /// post => Get Account Balance
  static const String detailRewards = "$accountBalancesRoutes/detailrewards";

  //old upload support file
  static const String verificationIDSupportingDocs = "$postsRoute/supportfile";

  // new verification ID Upload
  static const String verificationIDWithSupportDocs = "$postsRoute/upload/v2";

  // get tag people in content
  static const String tagPeople = "$postsRoute/tagpeople/v2";

  /// get => Get Ads User
  static const String getAdsVideo = "$adsRoute/getAds/user?type=Content%20Ads";

  /// get => Get Sponsored Ads
  static const String getSponsoredAds = "$adsRoute/getAds/user?type=Sponsor%20Ads";

  /// get => Get In App Ads
  static const String getInAppAds = "$adsRoute/getAds/user?type=In%20App%20Ads";

  /// get => Get Ads In Between
  static const String getAdsInBetween = "$adsRouteV2/get/v2/62e238a4f63d0000510026b3";

  /// get => Get Ads In Content
  static const String getAdsInContent = "$adsRouteV2/get/v2/62f0b435118731ecc0f45772";

  /// get => Get Pop Up Ads
  static const String getPopUpAds = "$adsRouteV2/get/v2/632a806ad2770000fd007a62";

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
  static const String insertReport = "/api/reportuser/create/v2";
  static const String detailTypeAppeal = "/api/reportuser/detailreason";

  static const String appealPost = "/api/reportuser/appeal/v2";
  static const String createTicket = "/api/usertickets/createticket/v2";

  /// ===music===
  static const String getMusicGenre = "/api/genre/";
  static const String getMusicTheme = "/api/theme/";
  static const String getMusicMood = "/api/mood/";
  static const String getMusics = "/api/music";
  static const String getMusicsPath = "/api/posts/music?musicId=";

  /// FAQ
  static const String faqList = "/api/faqs/allfaqs";

  /// Tiket Histories
  static const String ticketHistories = "/api/usertickets/filter/v2";
  static const String ticketComments = "/api/usertickets/comment/v2";
  static const String replyComment = "/api/usertickets/reply/v2";
  static const String reportHistories = "/api/reportuser/listreport/v2";

  // Get Old Video
  static const String oldVideo = "/stream/v2?postid=";
  static const String getNewLandingPage = "$userContentRoute/landingpage";

  static const String getKtpText = "$postsRoute/gettext";

  // Get Chalange
  static const String getBannerChalange = "$challange/listing/bannerlandingpage";
  static const String getLeaderBoard = "$challange/listleaderboard";
  static const String getLeaderBoardSession = "$challange/listleaderboard2";
  static const String getOtherChallange = "$challange/allchallenge/v2";
  static const String joinChallange = "$challange/join/v2";
  static const String listAchievement = "$challange/listbadgebyuser/v2";
  static const String collectionBadge = "$challange/listbadgeuserdetail/v2";
  static const String selectBadge = "$challange/badgechoice/v2";
  static const String checkChallengeStatus = "$challange/join/currentstatus";
  static const String getDataMyChallenge = "/score/api/challenge/byuser";

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
  static const String listGift = "$liveStramRoute/gift"; //list hadiah yg diterima streamer
  static const String checkStream = "$liveStramRoute/ceck"; //list hadiah yg diterima streamer
  static const String appealStream = "$liveStramRoute/appeal"; //submit appeal

  //List Gift
  // static const String listGift = "$monetization/list";

  //Appeal Bank
  static const String appealBank = "$userbankaccountsRoute/v3";

  //Monetization
  static const String listmonetization = "$monetizationRoute/listActive";
  static const String discmonetization = "$monetizationRoute/list/discount";
  static const String coinpurchasedetail = "$transactionRoute/coinpurchasedetail";
  static const String transactioncoin = "$transactionRoute/new";
  static const String checkposting = "$postsRoute/check-post";
  static const String activationgift = "$userRoute/updatestatusgift";
  static const String historyordercoin = "$transactionRoute/coinorderhistory";
  static const String historytransactioncoin = "$transactionRoute/cointransactionhistory";
  static const String historytransaction = "$transactionRoute/usercoinorderhistory";
  static const String saldocoin = "$postBuyContent/balanceds/preview";
  static const String transactionboostpost = "/api/transactionsv2/createboostpost";
  static const String boostContentNew = "/api/transactionsv2/boostpostdetail";
  static const String createboostContent = "/api/transactionsv2/createboostpost";
  static const String transactioncoindetail = "$transactionRoute/detail/coin/v2";
  static const String withdrawtransactiondetail = "$transactionRoute/withdrawtransactiondetail";
  static const String withdrawaldetail = "$transactionRoute/consolewithdrawdetail";
  static const String withdrawcoin = "$transactionRoute/withdrawcoin";
  static const String maxmincoin = "$transactionRoute/checkcoinmaxmin";

  //communityGuidlenList for detail
  static const String guidlineList = "$guidlineRoute/list";

  
}

