class LoadingNotifier {
  final Map<int, bool> _loadingState = <int, bool>{};

  bool get isLoading => _loadingState[hashCode] ?? false;

  bool loadingForObject(Object? object) => _loadingState[object.hashCode] ?? false;

  bool get anyObjectsIsLoading => _loadingState.values.any((loading) => loading);

  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    if (loadingObject != null) {
      _loadingState[loadingObject.hashCode] = val;
    } else {
      _loadingState[hashCode] = val;
    }
  }
}
