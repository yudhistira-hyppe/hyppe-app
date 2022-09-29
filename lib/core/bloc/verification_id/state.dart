enum VerificationIDState {
  init,
  loading,
  postVerificationIDSuccess,
  postVerificationIDError,
}

class VerificationIDFetch {
  final data;
  final VerificationIDState verificationIDState;
  VerificationIDFetch(this.verificationIDState, {this.data});
}
