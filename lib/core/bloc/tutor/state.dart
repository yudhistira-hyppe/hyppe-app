enum TutorState {
  init,
  loading,
  getPostSuccess,
  getPostError,
}

class TutorFetch {
  final data;
  final TutorState tutorState;
  final String? version;
  final String? versionIos;

  TutorFetch(this.tutorState, {this.data, this.version, this.versionIos});
}
