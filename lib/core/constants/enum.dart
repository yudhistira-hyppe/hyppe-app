enum FeatureType { vid, diary, pic, story, txtMsg, other }
enum MusicEnum { genre, theme, mood }
enum ContentType { image, video, text }
enum StatusFollowing { rejected, requested, following, none }
enum ReportType { profile, comment, story, post }
enum ReportAction { report, hide, block }
enum SourceFile { internet, local }
enum SearchCategory { vid, diary, pic, account, htags }
enum PostView { viewed, notViewed }
enum NotificationCategory { all, like, comment, follower, following, mention, general, transactions, verificationid }
enum UserType { verified, notVerified }
enum MethodType { get, post, download, postUploadProfile, postUploadContent, delete }
enum ErrorType {
  myStory,
  peopleStory,
  vid,
  diary,
  pic,
  vidSearch,
  diarySearch,
  picSearch,
  notification,
  message,
  createMessage,
  checkFollow,
  gGetUserDetail,
  getUserOverview,
  getFollowCount,
  getUserPost,
  getPostCount,
  getReactions,
  getPost,
  getInterests,
  getDocuments,
  getGender,
  getMartialStatus,
  getCountry,
  getStates,
  getCities,
  getViewerStories,
  getWelcomeNotes,
  getLanguage,
  unknown,
  register,
  login
}
enum TransactionType { sell, buy, withdrawal, boost, none }
enum VideoOrientation { landscape, portrait }
enum WalletEventEnum { miniDana, acquiring }
enum WalletResourceType { maskDanaId, balance, userKYC, transactionUrl, topUpUrl, oauthUrl }
enum NotificationActionType { read, hidden }
enum VerifyPageRedirection { toLogin, toHome, toSignUpV2, none }
enum InteractiveEventType { unfollow, following, follower, view, reaction, transactions, verificationid, supportfile, none }
enum InteractiveEvent { initial, accept, request, done, revoke, none }
enum DiscussEventType { directMsg, comment }
enum IdProofStatus { initial, inProgress, complete, revoke }
enum EnvType { development, production }
