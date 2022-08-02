enum FollowState {
  init,
  loading,
  checkFollowingToUserSuccess,
  checkFollowingToUserError,
  followUserSuccess,
  followUserError,
  getFollowCountSuccess,
  getFollowCountError,
  getFollowersUsersSuccess,
  getFollowersUsersError,
  deleteUserTagSuccess,
  deleteUserTagError
}

class FollowFetch {
  final data;
  final FollowState followState;
  FollowFetch(this.followState, {this.data});
}
