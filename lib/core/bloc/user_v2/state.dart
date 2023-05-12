enum UserState {
  init,
  loading,
  changePasswordSuccess,
  changePasswordError,
  completeProfileSuccess,
  completeProfileError,
  getBioSuccess,
  getBioError,
  getUserDetailsSuccess,
  getUserDetailsFailed,
  getProfileOverviewSuccess,
  getProfileOverviewError,
  LoginSuccess,
  LoginError,
  postBioSuccess,
  postBioError,
  RecoverSuccess,
  RecoverError,
  updateInterestSuccess,
  updateInterestError,
  signUpSuccess,
  signUpError,
  uploadIdProofSuccess,
  uploadIdProofError,
  uploadProfilePictureSuccess,
  uploadProfilePictureError,
  uploadProfilePictureCanceled,
  logOutFromOtherDevicesSuccess,
  logOutFromOtherDevicesError,
  verifyAccountSuccess,
  verifyAccountError,
  resendOTPSuccess,
  resendOTPError,
  getProfilePictureSuccess,
  getProfilePictureError,
  getIdProofSuccess,
  getIdProofError,
  LoginGoogleSuccess,
  LoginGoogleError,
  getUserProfilesSuccess,
  getUserProfilesError,
  logoutSuccess,
  logoutError,
  deleteAccountError,
  deleteAccountSuccess,
}

class UserFetch {
  final data;
  final UserState userState;
  final String? version;
  final String? versionIos;

  UserFetch(this.userState, {this.data, this.version, this.versionIos});
}
