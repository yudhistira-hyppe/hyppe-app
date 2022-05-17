enum ReferralState {
  init,
  loading,
  referralUserSuccess,
  referralUserError,
}

class ReferralFetch {
  final data;
  final ReferralState referralState;
  ReferralFetch(this.referralState, {this.data});
}
