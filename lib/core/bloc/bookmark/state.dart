enum BookmarkState {
  init,
  loading,
  addBookmarkBlocSuccess,
  addBookmarkBlocError,
  getBookmarkBlocSuccess,
  getBookmarkBlocError,
}

class BookmarkFetch {
  // ignore: prefer_typing_uninitialized_variables
  final data;
  final BookmarkState bookmarkState;
  BookmarkFetch(this.bookmarkState, {this.data});
}
