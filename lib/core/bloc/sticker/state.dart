enum StickerState {
  init,
  loading,
  getStickerSuccess,
  getStickerError,
}

class StickerFetch {
  final data;
  final StickerState state;
  StickerFetch(this.state, {this.data});
}