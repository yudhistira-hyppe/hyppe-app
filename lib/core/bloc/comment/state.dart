enum CommentState {
  init, loading,
  commentsBlocSuccess, commentsBlocError,
}
class CommentFetch {
  final data;
  final CommentState commentState;
  CommentFetch(this.commentState, {this.data});
}