enum EffectState {
  init,
  loading,
  getEffectSuccess,
  getEffectError,
}

class EffectFetch {
  final data;
  final EffectState state;
  EffectFetch(this.state, {this.data});
}