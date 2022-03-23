enum MessageState {
  init,
  loading,
  getDiscussionBlocSuccess,
  getDiscussionBlocError,
  createDiscussionBlocSuccess,
  createDiscussionBlocError,
}

class MessageFetch {
  final data;
  final MessageState chatState;
  MessageFetch(this.chatState, {this.data});
}
