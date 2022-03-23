enum FollowState {
  init, loading,
  checkFollowingToUserSuccess, checkFollowingToUserError,
  followUserSuccess, followUserError,
  getFollowCountSuccess, getFollowCountError,
  getFollowersUsersSuccess, getFollowersUsersError,
}
class FollowFetch {
  final data;
  final FollowState followState;
  FollowFetch(this.followState, {this.data});
}