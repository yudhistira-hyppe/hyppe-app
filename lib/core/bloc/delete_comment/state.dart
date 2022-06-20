enum DeleteCommentState {
  init,
  loading,
  deleteCommentSuccess,
  deleteCommentError
}

class DeleteCommentPost {
  final data;
  final DeleteCommentState deleteCommentState;
  DeleteCommentPost(this.deleteCommentState, {this.data});
}
