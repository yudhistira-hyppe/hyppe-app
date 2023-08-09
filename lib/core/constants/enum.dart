enum FeatureType { vid, diary, pic, story, txtMsg, other }

enum MusicEnum { genre, theme, mood }

enum ContentType { image, video, text }

enum StatusFollowing { rejected, requested, following, none }

enum ReportType { profile, comment, story, post }

enum ReportAction { report, hide, block }

enum SourceFile { internet, local }

enum SearchCategory { vid, diary, pic, account, htags }

enum NotificationCategory { all, like, comment, follower, following, mention, general, transactions, verificationid, adsClick, adsView, challange }

enum UserType { verified, notVerified }

enum MethodType { get, post, download, postUploadProfile, postUploadContent, delete }

enum TypePlaylist { landingpage, mine, other, search, none }

enum TicketType { accountVerification, content, transaction, owner, problemBugs, ads }

enum TicketStatus { newest, inProgress, solved, notSolved }

enum AppealStatus { newest, flaging, notSuspended, suspend, removed }

enum SearchLayout { first, search, searchMore, mainHashtagDetail, hashtagDetail, interestDetail }

enum HyppeType { HyppeVid, HyppeDiary, HyppePic }

enum SearchLoadData { all, content, user, hashtag }

enum TypeApiSearch { normal, detailHashTag, detailInterest }

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
  getEffect,
  downloadEffect,
  unknown,
  register,
  login,
  otpVerifyAccount,
  updateProfile,
}

enum TransactionType { sell, buy, withdrawal, boost, reward, voucher, none }

enum VerifyPageRedirection { toLogin, toHome, toSignUpV2, none }

enum InteractiveEventType { unfollow, following, follower, view, reaction, transactions, verificationid, supportfile, none }

enum InteractiveEvent { initial, accept, request, done, revoke, none }

enum DiscussEventType { directMsg, comment }

enum IdProofStatus { initial, inProgress, complete, revoke }

enum EnvType { development, production }

enum contentPosition { home, myprofile, otherprofile, search, searchFirst, seeAllVid, seeAllDiary, seeAllPict }

enum CaptionType { normal, mention, hashtag, seeMore, seeLess }

enum SpeedInternet { fast, medium, slow }

enum ModeTypeAliPLayer { url, sts, auth, mps }

enum VideoShowMode { grid, screen }

enum PageSrc { selfProfile, otherProfile, interest, hashtag, searchData }
