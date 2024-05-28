enum LiveStreamState { init, loading, getApiSuccess, getApiError }

class LiveStreamFetch {
  final data;
  final message;
  final statusStream;
  final LiveStreamState postsState;
  LiveStreamFetch(this.postsState, {this.data, this.statusStream, this.message});
}
