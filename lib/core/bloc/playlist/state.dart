enum PlaylistState {
  init, loading,
  createNewPlaylistBlocSuccess, createNewPlaylistBlocError,
  getAllPlaylistBlocSuccess, getAllPlaylistBlocBlocError,
}
class PlaylistFetch {
  final data;
  final PlaylistState playlistState;
  PlaylistFetch(this.playlistState, {this.data});
}