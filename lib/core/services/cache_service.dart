import 'dart:convert' show json;
// import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:tuple/tuple.dart';
import 'package:hyppe/core/extension/log_extension.dart';
// import 'package:hyppe/core/services/isolate_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
// import 'package:hyppe/core/constants/shared_preference_keys.dart';
// import 'package:hyppe/core/models/collection/posts/content/content.dart';

class CacheService {
  // CacheService({/**required vidContent, required diaryContent, required picContent, required userProfiles*/})
  //     : // _vidContent = vidContent,
  //       // _diaryContent = diaryContent,
  //       // _picContent = picContent,
  //       // _userProfiles = userProfiles;

  CacheService();

  // List<String> _isolateResults = [];
  // UserInfoModel? _userProfiles;
  // Content? _vidContent, _diaryContent, _picContent;

  static final _preferences = SharedPreference();
  // static final _isolateService = IsolateService();

  // bool _validation() {
  //   final _oldUserId = _preferences.readStorage(SpKeys.oldUserID);
  //   final _currentUserId = _preferences.readStorage(SpKeys.userID);
  //   final _cacheTimeStamp = _preferences.readStorage(SpKeys.cacheTimeStamp);

  //   return _oldUserId == _currentUserId && _cacheTimeStamp != null ? DateTime.now().isBefore(DateTime.parse(_cacheTimeStamp)) : false;
  // }

  _getCache(String k, {bool full = false}) {
    final _cacheData = _preferences.readStorage(k);

    final _finalCacheData = _cacheData != null ? json.decode(_cacheData) as Map<dynamic, dynamic> : null;

    return full ? _finalCacheData : _finalCacheData?.values.single;
  }

  // bool _validateCache(String k) {
  //   final _cacheData = _getCache(k, full: true);
  //   final _validate = _validation();

  //   if (_cacheData != null) {
  //     if (!_validate) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     return true;
  //   }
  // }

  // void _handleResult(Tuple3<String, dynamic, String?> data) async {
  //   "[INFO] => Handling result with key ${data.item1} and data ${data.item2}".logger();
  //   try {
  //     if (data.item2 != null) {
  //       if (_validateCache(data.item1)) {
  //         "[INFO] => Write cache data to memory for key ${data.item1}".logger();
  //         _preferences.writeStorage(SpKeys.cacheTimeStamp, DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1).toString());
  //         _preferences.writeStorage(data.item1, data.item3);
  //       } else {
  //         "[INFO] => Cache in this key ${data.item1} is already exist and not expired or same user".logger();
  //       }
  //     }
  //   } catch (e) {
  //     "[INFO] => Failed handling result with error ${e.toString()} with key ${data.item1}".logger();
  //   }

  //   _isolateResults.add(data.item3 ?? 'x');
  //   // check if all computation is done and then turn off isolate
  //   if (_isolateResults.length == List<int>.generate(4, (index) => index).length) {
  //     "[INFO] => Write current userID".logger();
  //     var _userID = _preferences.readStorage(SpKeys.userID);
  //     _preferences.writeStorage(SpKeys.oldUserID, _userID);
  //     _isolateResults.clear();
  //     await _isolateService.turnOffWorkers().then((_) {
  //       "[INFO] => Success turn off isolate".logger();
  //     }).catchError((e) {
  //       "[INFO] => Failed turn off isolate with error ${e.toString()}".logger();
  //     });
  //   }
  // }

  dynamic processingCacheData(String k) {
    final _cacheData = _getCache(k);
    if (_cacheData != null) {
      return _cacheData;
    } else {
      return null;
    }
  }

  Future saveCache() async {
    // if (!_validation()) {
    //   // enable worker if not enabling
    //   if (!_isolateService.workerActive()) await _isolateService.turnOnWorkers();

    //   if (_isolateService.workerActive()) {
    //     // Start caching object
    //     _isolateService
    //         .computeFunction<Tuple2, String?>(
    //           fn: cacheObject,
    //           param: Tuple2(SpKeys.profileCacheData, _userProfiles),
    //         )
    //         .then((value) => _handleResult(Tuple3(SpKeys.profileCacheData, _userProfiles, value)));

    //     _isolateService
    //         .computeFunction<Tuple2, String?>(
    //           fn: cacheObject,
    //           param: Tuple2(SpKeys.vidCacheData, _vidContent),
    //         )
    //         .then((value) => _handleResult(Tuple3(SpKeys.vidCacheData, _vidContent, value)));

    //     _isolateService
    //         .computeFunction<Tuple2, String?>(
    //           fn: cacheObject,
    //           param: Tuple2(SpKeys.diaryCacheData, _diaryContent),
    //         )
    //         .then((value) => _handleResult(Tuple3(SpKeys.diaryCacheData, _diaryContent, value)));

    //     _isolateService
    //         .computeFunction<Tuple2, String?>(
    //           fn: cacheObject,
    //           param: Tuple2(SpKeys.picCacheData, _picContent),
    //         )
    //         .then((value) => _handleResult(Tuple3(SpKeys.picCacheData, _picContent, value)));
    //   } else {
    //     '''[INFO] => Isolate Service is not active!
    //   Activate Isolate Service first, before use Computation Function.
    //   '''
    //         .logger();
    //   }
    // } else {
    //   if (_isolateService.workerActive()) await _isolateService.turnOffWorkers();
    // }
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
