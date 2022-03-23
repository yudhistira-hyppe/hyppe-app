extension MapExtension on Map {
  // Get next key in the map.
  dynamic nextKey(dynamic currentKey) {
    var keys = this.keys.toList();
    var index = keys.indexOf(currentKey);
    return keys[index + 1];
  }

  // Get previous key in the map.
  dynamic previousKey(dynamic currentKey) {
    var keys = this.keys.toList();
    var index = keys.indexOf(currentKey);
    return keys[index - 1];
  }
}
