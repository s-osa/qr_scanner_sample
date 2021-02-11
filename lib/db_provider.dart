import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scanner_sample/scan_history.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'TestDB.db');

    return await openDatabase(path, version: 1, onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute(_createTableDDL());
    });
  }

  newScanHistory(ScanHistory newScanHistory) async {
    final db = await database;
    var rel = await db.rawQuery("select coalesce(max(id), 0) + 1 as id from scan_histories");
    final newId = rel.first["id"] + 1;
    var res = await db.rawInsert(
      "insert into scan_histories (id, payload) values (?, ?)",
      [newId, newScanHistory.payload],
    );
    return res;
  }

  getScanHistory(int id) async {
    final db = await database;
    var res = await db.query("scan_results", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? ScanHistory.fromMap(res.first) : Null;
  }

  getScanHistories() async {
    final db = await database;
    var res = await db.query("scan_results");
    List<ScanHistory> list = res.isNotEmpty ? res.map((sh) => ScanHistory.fromMap(sh)).toList() : [];
    return list;
  }

  String _createTableDDL() {
    return '''
      create table scan_histories (
        id integer primary key,
        payload text
      );
    ''';
  }
}
