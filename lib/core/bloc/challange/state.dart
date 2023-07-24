enum ChallengeState {
  init,
  loading,
  getPostSuccess,
  getPostError,
}

class ChallangeFetch {
  final data;
  final ChallengeState challengeState;
  final String? version;
  final String? versionIos;

  ChallangeFetch(this.challengeState, {this.data, this.version, this.versionIos});
}
