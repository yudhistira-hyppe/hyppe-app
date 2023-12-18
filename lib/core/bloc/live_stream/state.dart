enum LiveStreamState { init, loading, getApiSuccess, getApiError }

class LiveStreamFetch {
  final data;
  final message;
  final LiveStreamState postsState;
  LiveStreamFetch(this.postsState, {this.data, this.message});
}
