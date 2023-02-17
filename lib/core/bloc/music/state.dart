enum MusicState {
  init,
  loading,
  getMusicsBlocSuccess,
  getMusicBlocError,
}

class MusicDataFetch {
  final data;
  final MusicState musicDataState;
  MusicDataFetch(this.musicDataState, {this.data});
}