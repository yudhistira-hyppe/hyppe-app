enum ReactionState {
  init, loading,
  addPostReactionBlocSuccess, addPostReactionBlocError,
  addPostReactionBlocSuccessV2, addPostReactionBlocErrorV2,
  addReactOnCommentBlocSuccess, addReactOnCommentBlocError,
  getCommentReactionsBlocSuccess, getCommentReactionsBlocError,
}
class ReactionFetch {
  final data;
  final ReactionState reactionState;
  ReactionFetch(this.reactionState, {this.data});
}
