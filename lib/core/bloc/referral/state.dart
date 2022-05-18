enum ReferralState {
  init,
  loading,
  referralUserSuccess,
  referralUserError,
  getReferralUserSuccess,
  getReferralUserError,
}

class ReferralFetch {
  final data;
  final ReferralState referralState;
  ReferralFetch(this.referralState, {this.data});
}
