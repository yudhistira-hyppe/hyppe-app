enum SearchContentState {
  init,
  loading,
  getSearchContentBlocSuccess,
  getSearchContentBlocError,
}

class SearchContentFetch {
  final data;
  final SearchContentState searchContentState;
  SearchContentFetch(this.searchContentState, {this.data});
}
