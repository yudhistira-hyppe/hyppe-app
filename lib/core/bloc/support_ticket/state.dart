enum SupportTicketState {
  init,
  loading,
  getCategoryIssueSuccess,
  getCategoryIssueError,
  getLevelSuccess,
  getLevelError,
}

class SupportTicketFetch {
  final data;
  final message;
  final SupportTicketState postsState;
  final version;
  SupportTicketFetch(this.postsState, {this.data, this.message, this.version});
}
