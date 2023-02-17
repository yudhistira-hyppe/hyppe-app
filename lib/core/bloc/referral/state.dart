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
  final message;
  final ReferralState referralState;
  ReferralFetch(this.referralState, {this.data, this.message});
}
