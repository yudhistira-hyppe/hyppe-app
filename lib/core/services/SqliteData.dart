
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/database/efect_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/collection/database/search_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  final String SEARCH_TABLE = 'search';

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

  Future initDb() async {
    // Directory documentDir = await getApplicationDocumentsDirectory();
    String path = join(await getDatabasesPath(), databaseName);
    // String path2 = join(await getDatabasesPath(), databaseName);

    _db = await openDatabase(path, version: databaseVersion, onCreate: _createDB);

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
      CREATE TABLE IF NOT EXISTS $SEARCH_TABLE (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        keyword TEXT,
        datetime TEXT
      );
        ''').then((value) => print('sukses database '));
    } catch (e) {
      print('gagal database $e');
    }
  }

  Future<List<SearchHistory>> getHistories() async{
    List<SearchHistory> data = [];
    final initDb = await db;
    try{
      List<Map>? _res = await initDb?.query(DatabaseHelper._instance.SEARCH_TABLE);
      for(final row in _res ?? []){
        data.add(SearchHistory.fromJson(row));
      }
      return data;
    }catch(e){
      'Error getHistories'.logger();
    }
    return data;
  }

  Future<SearchHistory?> getHistoryByKeyword(String keyword) async{
    List<SearchHistory> data = [];
    final initDb = await db;
    try{
      List<Map>? _res = await initDb?.query(DatabaseHelper._instance.SEARCH_TABLE, where: "keyword = ?", whereArgs: [keyword]);
      for(final row in _res ?? []){
        data.add(SearchHistory.fromJson(row));
      }
      return data[0];
    }catch(e){
      'Error getHistories'.logger();
    }
    return null;
  }

  Future<int> insertHistory(SearchHistory data) async{
    if(_db != null){
      final query = await _db?.insert(SEARCH_TABLE, data.toJson());
      return query ?? 0;
    }else{
      return 0;
    }
  }
  
  Future<int> updateHistory(SearchHistory data) async{
    if(_db != null){
      final query = await _db?.update(SEARCH_TABLE, data.toJson(), where: "keyword = ?", whereArgs: [data.keyword]);
      return query ?? 0;
    }else{
      return 0;
    }
  }

  Future<int> deleteHistory(SearchHistory data) async{
    if(_db != null){
      final query = await _db?.delete(SEARCH_TABLE, where: "id = ?", whereArgs: [data.id]);
      return query ?? 0;
    }else{
      return 0;
    }
  }
}
