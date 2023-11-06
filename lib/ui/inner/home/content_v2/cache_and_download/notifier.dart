import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CacheAndDownloadNotifier extends ChangeNotifier {
  String _cacheSize = '';
  String get cacheSize => _cacheSize;
  set cacheSize(String val) {
    _cacheSize = val;
    notifyListeners();
  }

  String _storageSize = '';
  String get storageSize => _storageSize;
  set storageSize(String val) {
    _storageSize = val;
    notifyListeners();
  }

  deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
      getCacheDirSize();
    }
  }

  deleteStorageDir() async {
    final appDir = await getApplicationSupportDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
      getStorageDirSize();
    }
  }

  Future getCacheDirSize() async {
    Directory tempDir = await getTemporaryDirectory();
    int tempDirSize = _getSize(tempDir);
    cacheSize = getFileSizeString(bytes: tempDirSize);
  }

  Future getStorageDirSize() async {
    Directory tempDir = await getApplicationSupportDirectory();
    int tempDirSize = _getSize(tempDir);
    storageSize = getFileSizeString(bytes: tempDirSize);
  }

  int _getSize(FileSystemEntity file) {
    if (file is File) {
      return file.lengthSync();
    } else if (file is Directory) {
      int sum = 0;
      List<FileSystemEntity> children = file.listSync();
      for (FileSystemEntity child in children) {
        sum += _getSize(child);
      }
      return sum;
    }
    return 0;
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["Bytes", "Kb", "Mb", "Gb", "Tb"];
    if (bytes == 0) return '0 Kb';
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
