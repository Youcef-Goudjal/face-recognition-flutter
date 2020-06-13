import 'dart:io';

import 'package:app/util/utilitis.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // making it a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static final _dbName = 'Data.db';
  static final _dbVersion = 1;
  static final _tableName = 'Lists';
  static final _tablePerson = 'Person';
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnlandmark = 'landmark';
  static final columnfaceimge = 'face_img';
  static final columnemail = 'email';
  static final columnlistid = 'list_ID';
  static final columnface = 'face';
  static final columnleftEye = 'leftEye';
  static final columnleftEyebrowBottom = 'leftEyebrowBottom';
  static final columnleftEyebrowTop = 'leftEyebrowTop';
  static final columnlowerLipBottom = 'lowerLipBottom';
  static final columnlowerLipTop = 'lowerLipTop';
  static final columnnoseBottom = 'noseBottom';
  static final columnnoseBridge = 'noseBridge';
  static final columnrightEye = 'rightEye';
  static final columnrightEyebrowBottom = 'rightEyebrowBottom';
  static final columnrightEyebrowTop = 'rightEyebrowTop';
  static final columnupperLipBottom = 'upperLipBottom';
  static final columnupperLipTop = 'upperLipTop';

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE $_tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnName TEXT NOT NULL )
      ''');

    db.execute('''
    CREATE TABLE $_tablePerson (
    $columnId INTEGER PRIMARY KEY,
    $columnName TEXT NOT NULL,
    $columnfaceimge TEXT,
    $columnface TEXT,
    $columnleftEye TEXT,
    $columnleftEyebrowBottom TEXT,
    $columnleftEyebrowTop TEXT,
    $columnlowerLipBottom TEXT,
    $columnlowerLipTop TEXT,
    $columnnoseBottom TEXT,
    $columnnoseBridge TEXT,
    $columnrightEye TEXT,
    $columnrightEyebrowBottom TEXT,
    $columnrightEyebrowTop TEXT,
    $columnupperLipBottom TEXT,
    $columnupperLipTop TEXT,
    
    $columnlistid  INTEGER,
    FOREIGN KEY ($columnlistid) REFERENCES $_tableName($columnId)
    )
    '''); //TEXT to BLOB
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tableName, row);
  }

  /*
    db.execute('''
    CREATE TABLE $group (
    $columnId INTEGER PRIMARY KEY,
    $columnName TEXT NOT NULL,
    $columnface Text,
    $columnlandmark
    )
    ''');//TODO: landmark type ???
    //array [1..132] {dx : float , dy: float}
    * */
// Lists table function
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(_tableName);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return db.update(_tableName, row, where: '$columnId = ? ', whereArgs: [id]);
  }

  Future<int> findlistbyname(String group) async {
    Database db = await instance.database;
    List list = await db
        .query(_tableName, where: '$columnName = ?', whereArgs: [group]);
    return list[0][columnId];
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return db.delete(_tableName, where: '$columnId = ? ', whereArgs: [id]);
  }

  // Person table function
  Future<List<Map<String, dynamic>>> PqueryAll() async {
    Database db = await instance.database;
    return await db.query(_tablePerson);
  }

  Future<List<Map<String, dynamic>>> PGqueryAll(int list_id) async {
    Database db = await instance.database;

    return await db
        .query(_tablePerson, where: '$columnlistid = ?', whereArgs: [list_id]);
  }

  Future<int> Pinsert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tablePerson, row);
  }

  Future<int> Pinsert2(Face face, int id, String name) async {
    Map<String, dynamic> map = {
      columnName: name,
      columnlistid: id,
      columnface:
          list_string(face.getContour(FaceContourType.values[1]).positionsList),
      columnleftEye:
          list_string(face.getContour(FaceContourType.values[2]).positionsList),
      columnleftEyebrowBottom:
          list_string(face.getContour(FaceContourType.values[3]).positionsList),
      columnleftEyebrowTop:
          list_string(face.getContour(FaceContourType.values[4]).positionsList),
      columnlowerLipBottom:
          list_string(face.getContour(FaceContourType.values[5]).positionsList),
      columnlowerLipTop:
          list_string(face.getContour(FaceContourType.values[6]).positionsList),
      columnnoseBottom:
          list_string(face.getContour(FaceContourType.values[7]).positionsList),
      columnnoseBridge:
          list_string(face.getContour(FaceContourType.values[8]).positionsList),
      columnrightEye:
          list_string(face.getContour(FaceContourType.values[9]).positionsList),
      columnrightEyebrowBottom: list_string(
          face.getContour(FaceContourType.values[10]).positionsList),
      columnrightEyebrowTop: list_string(
          face.getContour(FaceContourType.values[11]).positionsList),
      columnupperLipBottom: list_string(
          face.getContour(FaceContourType.values[12]).positionsList),
      columnupperLipTop: list_string(
          face.getContour(FaceContourType.values[13]).positionsList),
    };
    Pinsert(map);
  }

  String list_string(List<Offset> list) {
    String s = '';
    for (int i = 0; i < list.length; i++) {
      s +=
          '(${list[i].dx.toStringAsFixed(5)},${list[i].dy.toStringAsFixed(5)})';
    }
    return s;
  }

  Future<List<Offset>> readData(Map<String, dynamic> map) async {
    List l = [
      columnface,
      columnleftEye,
      columnleftEyebrowBottom,
      columnleftEyebrowTop,
      columnlowerLipBottom,
      columnlowerLipTop,
      columnnoseBottom,
      columnnoseBridge,
      columnrightEye,
      columnrightEyebrowBottom,
      columnrightEyebrowTop,
      columnupperLipBottom,
      columnupperLipTop
    ];
    List<Offset> list = List();
    for (int i = 0; i < l.length; i++) {
      String column = map[l[i]];
      List temp = Stringtoarray(column);
      for (int j = 0; j < temp.length; j++) {
        list.add(temp[j]);
      }
    }
    //print("landmark(${list.length}) :$list");
  }

  Future<int> Pupdate(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return db
        .update(_tablePerson, row, where: '$columnId = ? ', whereArgs: [id]);
  }

  Future<int> Pdelete(int id) async {
    Database db = await instance.database;
    return db.delete(_tablePerson, where: '$columnId = ? ', whereArgs: [id]);
  }
}
