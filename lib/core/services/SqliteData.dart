import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/models/collection/database/efect_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  final String FILTER_CAMERA_TABLE = 'tblfilter';

  static Database? _db;

  final String PID = 'PID';
  final String VID = 'VID';
  final String QTY = 'QTY';

  Future<Database?> get db async {
    print('ini database sekarang banger $_db');
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
    }
  }

  Future<Database> initDb() async {
    // Directory documentDir = await getApplicationDocumentsDirectory();
    String path = join(await getDatabasesPath(), databaseName);
    // String path2 = join(await getDatabasesPath(), databaseName);

    return openDatabase(path, version: databaseVersion, onCreate: _createDB);

    // var databasePath = await getDatabasesPath();
    // var path = join(databasePath, "hyppe.db");

    // var exist = await databaseExists(path);
    // if (!exist) {
    //   try {
    //     await Directory(dirname(path)).create(recursive: true);
    //   } catch (_) {
    //     print('gagal membuat database : $_');
    //   }

    //   ByteData data = await rootBundle.load(join("assets", "hyppe.db"));
    //   List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    //   await File(path).writeAsBytes(bytes, flush: true);
    // } else {}

    // var db = await openDatabase(path, readOnly: false);
    // return db;
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREAMENT';
    const textType = 'TEXT NOT NULL';
    print('ini test database');

    try {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS efect (
        effectId TEXT PRIMARY KEY,
        dirName TEXT,
        fileName TEXT,
        preview TEXT
      );
        ''').then((value) => print('sukses datase '));
    } catch (e) {
      print('gagal database $e');
    }
  }

  Future<List<String>> getFilterCamera() async {
    List<String> data = [];
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.FILTER_CAMERA_TABLE);

    for (var row in result) {
      print(row);
      data.add(row[VID]);
    }
    print("ini data camera Filter $data");
    return data;
  }

  Future<List?> checkFilterItemExists() async {
    // final db1 = await db;
    var result = await _db!.rawQuery("SELECT * FROM $tableEfect");
    print("ini hasil db $result");
    return result;
    // if (result.isNotEmpty) {
    //   return result[0][QTY].toString();
    // } else {
    //   return "0";
    // }
  }

  //insert cart data in table
  Future<int> insertFilterCamera(String effectId, String dirName, String fileName, String preview, BuildContext context) async {
    var dbClient = await db;
    String? check;

    // check = await checkFilterItemExists(pid, vid);
    // print("check database $check");

    // if (check != "0") {
    //   updateFilterCamera(pid, vid, qty);
    // } else {
    //   String query = "INSERT INTO $tableEfect ($PID,$VID,$QTY) SELECT '$pid','$vid','$qty' WHERE NOT EXISTS(SELECT $PID,$VID FROM $FILTER_CAMERA_TABLE WHERE $PID = '$pid' AND $VID='$VID')";
    //   dbClient!.execute(query);
    //   await getTotalFilterCameraCount(context);
    // }
    print('ini database $_db');
    final query = await _db!.insert(tableEfect, {
      EfectFields.effectId: effectId,
      EfectFields.dirName: dirName,
      EfectFields.fileName: fileName,
      EfectFields.preview: preview,
    });
    return query;
  }

  updateFilterCamera(String pid, String vid, String qty) async {
    final db1 = await db;
    Map<String, dynamic> row = {
      DatabaseHelper._instance.QTY: qty,
    };

    db1!.update(FILTER_CAMERA_TABLE, row, where: "$VID = ? AND $PID = ?", whereArgs: [vid, pid]);
  }

  Future<int> getTotalFilterCameraCount(BuildContext context) async {
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.FILTER_CAMERA_TABLE);

    // context.read<UserProvider>().setCartCount(result.length.toString());
    return result.length;
  }
}
