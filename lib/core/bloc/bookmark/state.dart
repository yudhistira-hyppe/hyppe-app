enum BookmarkState {
  init, loading,
  addBookmarkBlocSuccess, addBookmarkBlocError,
  getBookmarkBlocSuccess, getBookmarkBlocError,
}
class BookmarkFetch {
  final data;
  final BookmarkState bookmarkState;
  BookmarkFetch(this.bookmarkState, {this.data});
}