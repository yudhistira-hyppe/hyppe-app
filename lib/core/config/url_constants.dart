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

  /// Production Base url
  static const String productionBaseApi = "https://prod.hyppe.app";
  // static const String productionBaseApi = "https://staging.hyppe.app";

  /// Staging v2 Base url
  // static const String stagingBaseApi = "https://prod.hyppe.app";
  static const String stagingBaseApi = "https://staging.hyppe.app";
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

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Wallet */
  /// event.
  static const String eventBus = "$walletRoute/eventbus";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs In App Notification */
  /// get => Get Users notification.
  static const String getUsersNotification =
      "$notificationRoute/getAllUsersnotification";

  /// post => Read notification.
  static const String readNotification = "$notificationRoute/readNotification";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Bookmark */
  /// get => Get bookmark.
  static const String getBookmark = "$postRoute/getBookmark";

  /// post => Add bookmark.
  static const String addBookmark = "$postRoute/addBookmark";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Chat */
  /// all user chat
  static const String allUserChat = "$chatRoute/getAllUserChats";

  /// history chat
  static const String historyChat = "$chatRoute/getChatHistoryByrecipientId";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Comment */
  /// post => Add Post Comment.
  static const String addPostComment = "$postRoute/comments/commentOnPost";

  /// post => Add Post Comment On Comment.
  static const String addPostCommentOnComment =
      "$postRoute/comments/commentOnComment";

  /// get => Get More Comments.
  static const String getMoreComments = "$postRoute/comments/viewMoreComments";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Follow */
  /// post Add Story View.
  static const String followUser = "$followRoute/follow";

  /// get => Get Follow Count.
  static const String followCounts = "$followRoute/counts";

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

  /// get => Get User Profile Overview.
  static const String userOverview = "$userRoute/overview";

  /// get => Get User Profile Details.
  static const String details = "$userRoute/userProfile";

  /// post complete_profile
  static const String completeProfile = "$userRoute/userProfile";

  /// post update_profile
  static const String updateProfile = "$userRoute/updateprofile";

  /// post recover_password => To recover password with either username or email.
  static const String recoverPassword = "$userRoute/recoverpassword";

  /// post register interest => To register interests of user.
  static const String registerInterest = "$userRoute/userInterest";

  /// post register interest => To register interests of user.
  static const String updateInterest = "$userRoute/profileinterest";

  /// post and get => Id proof.
  static const String idProof = "$userRoute/idProof";

  /// post => Upload Profile picture.
  static const String uploadProfilePicture = "$userRoute/uploadProfilePicture";

  /// post => Upload Profile picture V2.
  static const String uploadProfilePictureV2 = "$postsRoute/profilepicture";

  /// User Bio.
  static const String bio = "$userRoute/bio";

  /// get => Add Profile Report.
  static const String addProfileReport = "$userRoute/report/addProfileReport";

  /// get => Log Out From Other Devices.
  static const String logOutFromOtherDevices = "$userRoute/logout/otherDevices";

  /// post => Verify Account
  static const String verifyAccount = "$userRoute/verifyaccount";

  /// post => Resend OTP
  static const String resendOTP = "$userRoute/resendotp";

  /// get => Get user profile picture
  static const String profilePic = "$userRoute/profilePic";

  /// user => Referral
  static const String referral = "$userRoute/referral";

  /// user => Referral Count
  static const String referralCount = "$userRoute/referral-count";

  /// user => Change Language
  static const String updateLanguage = "$userRoute/updatelang";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Playlist */
  /// post => Create new playlist.
  static const String createNewPlaylist = "$postRoute/createPlaylist";

  /// get => Get all playlist.
  static const String getAllPlaylist = "$postRoute/getAllPlaylist";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Posts */
  /// post Content.
  static const String createPost = "$postRoute/createPost";

  /// get one post.
  static const String getPost = "$postRoute/getPost";

  /// get => Get Post Count.
  static const String postCounts = "$postRoute/counts";

  /// get list_pic.
  static const String getPicPostsFeeds = "$postRoute/getPicPostsFeeds";

  /// get list_diary.
  static const String getDiaryPostsFeeds = "$postRoute/getDiaryPostsFeeds";

  /// get list_vid.
  static const String getVidPostsFeeds = "$postRoute/getVidPostsFeeds";

  /// get => Get User Post.
  static const String getUserPosts = "$postRoute/getUserPosts";

  /// get => Add Post Report.
  static const String reportOnPost = "$postRoute/report/reportOnPost";

  /// get => Add Comment Report.
  static const String reportOnComment = "$postRoute/report/reportOnComment";

  /// post => Add View Post.
  static const String addPostView = "$postRoute/view";

  /// delete => Delete Post.
  static const String deletePostByID = "$postRoute/deletePostByID";

  /// post => View Like and View.
  static const String viewLike = "$postRoute/viewlike";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Reaction */
  /// post Add Reaction to content.
  static const String addPostReaction = "$postRoute/reactions/reactOnPost";

  /// get => Get Post Reactions Count.
  static const String getPostReactionsCount =
      "$postRoute/reactions/getPostReactionsCounts";

  /// post Add Reaction to comment.
  static const String addReactOnComment = "$postRoute/reactions/reactOnComment";

  /// post get Comment from Post.
  static const String getCommentReactions =
      "$postRoute/reactions/getCommentReactions";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Search */
  /// post => Search.
  static const String searchMedia = "$searchRoute/media/search";

  /// post => Search General.
  static const String searchGeneral = "$searchRoute/search";

  /// post => Add to trending.
  static const String addToTrending = "$searchRoute/search/trending";

  ///---------------------------------------------------------------------------------------------------------///

  /* APIs Stories */
  /// get list_story.
  static const String myUserStories = "$storiesRoute/myUserStories";

  /// post Add Story View.
  static const String addStoryView = "$storiesRoute/viewStory";

  /// post Add Reaction to story.
  static const String addStoryReaction = "$storiesRoute/reaction";

  /// get => Get My Stories.
  static const String myStories = "$storiesRoute/myStories";

  /// get Stories by user.
  static const String stories = "$storiesRoute/stories";

  /// post Story.
  static const String createStory = "$storiesRoute/createStory";

  /// get => Add Story Report.
  static const String reportOnStory = "$storiesRoute/report/reportOnStory";

  /// get => Get viewer story.
  static const String views = "$storiesRoute/views";

  /// delete => Delete Story.
  static const String deleteStoryByID = "$storiesRoute/deleteStoryByID";

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

  /// get list of Document
  static const String document = "$utilsRoute/document";

  /// get list of Gender
  static const String gender = "$utilsRoute/gender";

  /// get list of Martial Status
  static const String martialstatus = "$utilsRoute/martialstatus";

  /// get reactions.
  static const String reaction = "$utilsRoute/reaction";

  /// get list of City
  static const String city = "$utilsRoute/city";

  /// get list of Country
  static const String country = "$utilsRoute/country";

  /// get => Get Report Options.
  static const String getReportOptions = "$utilsRoute/getReportOption";

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

  /// post => Get Contents Qmatic
  static const String qmatic = "$postRouteV2/qmatic";

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

  /// post => Get Ads Roster
  static const String getAdsRoster = "$bizRoute/adsroster";

  //apis goole plcae
  static const String getGoogleMapApis =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json";

  //get search people
  static const String getSearchPeople = "$profileRoute/search";

  static const String getSearch = "$profileRoute/search";

  ///---------------------------------------------------------------------------------------------------------///
  // V3

  /// APIs end point
  /* Post route */
  static const String contentRouteV3 = "/api/getusercontents";

  ///---------------------------------------------------------------------------------------------------------///
  /* v3 search data content dan user */
  static const String getSearchContentV3 = "$contentRouteV3/searchdata";
  // v3 delete tag
  static const String deletTagUser = "$postRouteV2/deletetag";

  // verification ID
  static const String verificationID = "$postsRoute/verificationid";

  //delete Account
  static const String deleteAccount = "$userRoute/noneactive";
}
