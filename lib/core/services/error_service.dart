import 'package:hyppe/core/extension/log_extension.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:hyppe/core/constants/enum.dart' show ErrorType;

abstract class ErrorInterface {
  void clearErrorData();
  void removeErrorObject(ErrorType k);
  void setRefreshing(Object? k, bool v);
  void addErrorObject(ErrorType k, dynamic v);
  dynamic getError(ErrorType k);
  dynamic refresh(Object? k, Function? function);
  bool isInitialError(dynamic error, dynamic data);
  bool refreshing(Object? k);
}

class ErrorService with ChangeNotifier implements ErrorInterface {
  final Map<ErrorType, dynamic> _errorObj = <ErrorType, dynamic>{};
  final Map<int, bool> _functionState = <int, bool>{};

  @override
  getError(ErrorType k) => _errorObj[k];

  @override
  void addErrorObject(ErrorType k, v) {
    "Error object => $v".logger();
    if (!_errorObj.containsKey(k)) {
      _errorObj[k] = v;

      _setState();
    }
  }

  @override
  bool isInitialError(error, data) => error != null && data == null;

  @override
  void removeErrorObject(ErrorType k) {
    "Remove error object => ${_errorObj[k]}".logger();
    _errorObj.remove(k);
    _setState();
  }

  @override
  bool refreshing(Object? k) => _functionState[k.hashCode] ?? false;

  @override
  void setRefreshing(Object? k, bool v) {
    _functionState[k.hashCode] = v;
    _setState();
  }

  @override
  refresh(Object? k, Function? fn) async {
    try {
      if (fn != null) {
        setRefreshing(k, true);
        await fn();
        setRefreshing(k, false);
      }
    } catch (e) {
      e.toString().logger();
      setRefreshing(k, false);
    }
  }

  @override
  void clearErrorData() {
    _errorObj.clear();
    _functionState.clear();
  }

  _setState() => notifyListeners();
}
