import 'dart:convert' show json;
import 'package:tuple/tuple.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/shared_preference.dart';

class CacheService {

  CacheService();

  static final _preferences = SharedPreference();

  _getCache(String k, {bool full = false}) {
    final _cacheData = _preferences.readStorage(k);

    final _finalCacheData = _cacheData != null ? json.decode(_cacheData) as Map<dynamic, dynamic> : null;

    return full ? _finalCacheData : _finalCacheData?.values.single;
  }

  dynamic processingCacheData(String k) {
    final _cacheData = _getCache(k);
    if (_cacheData != null) {
      return _cacheData;
    } else {
      return null;
    }
  }



  static String? cacheObject(Tuple2 data) {
    String? _result;
    final _cacheKey = data.item1;
    final _cacheData = data.item2;
    final _cacheTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

    'Key $_cacheKey'.logger();
    'Value $_cacheData'.logger();

    try {
      if (_cacheData != null) {
        _result = json.encode(_cacheData.toJson());
      }
    } catch (e) {
      "[INFO] => Failed execute computation with error ${e.toString()} for Key $_cacheKey".logger();
    }

    return _cacheData == null ? _result : '{"${_cacheTime.toString()}": $_result}';
  }
}
