enum ViewState {
  init,
  loading,
  viewUserPostSuccess,
  viewUserPostFailed,
}

class ViewFetch {
  final data;
  final ViewState viewState;
  ViewFetch(this.viewState, {this.data});
}
