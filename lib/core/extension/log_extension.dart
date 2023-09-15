import 'dart:developer';
import 'package:flutter/foundation.dart';

extension LoggerExtension<T> on T {
  void logger() {
    if (kDebugMode) {
      print('HYPPE-LOGGER-EXTENSION => $this');
    }
  }

  void loggerV2({String group = 'log'}) {
    if (kDebugMode) {
      try {
        log('hyppe-$group => $this');
      } catch (e) {
        print('hyppe-$group => $this');
      }
    }
  }
}
