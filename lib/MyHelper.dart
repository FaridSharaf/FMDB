import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'FilmResponse.dart';

class MyHelper {
//1- create object from MyHelper
  static MyHelper helper;

  MyHelper._getInstance();

  factory MyHelper() {
    if (helper == null) {
      return MyHelper._getInstance();
    } else {
      return helper;
    }
  }

  static Database _database;

  //2- define constants
  static String db_name = 'films.db';
  static String table_name = 'Film';

  static String col_id = 'id';
  static String col_title = 'title';
  static String col_voteCount = 'voteCount';
  static String col_isStored = 'isStored';
  static String col_overview = 'overview';
  static String col_popularity = 'popularity';
  static String col_posterPath = 'posterPath';
  static String col_releaseDate = 'releaseDate';
  static String col_voteAverage = 'voteAverage';
  static String col_backdropPath = 'backdropPath';

  //3- create object from datbase
  Future<Database> get database async {
    if (_database != null)
      return _database;
    else
      return intializeDb();
  }

  Future<Database> intializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    var path = join(dir.path, db_name);
    return openDatabase(path, version: 1, onCreate: createTable);
  }

//create table
  static void createTable(Database db, int version) {
    //create table mytable (id integer primary key autoincrement, text text)
    String sql = '''
    create table $table_name (
    $col_id integer primary key, 
    $col_title text,
    $col_overview text,
    $col_popularity real,
    $col_voteAverage real,
    $col_releaseDate text,
    $col_voteCount integer,
    $col_posterPath text,
    $col_backdropPath text
    )
    ''';
    db.execute(sql);
  }

//insert operation
  insertIntoTable(Results f) async {
    //values => Map<String,dynamic>
    var db = await this.database;
    db.insert(table_name, f.ConvertToMap());
  }

//  void insertFilm(BuildContext context, Film film) {
//    var f = Film.withInfo(film.id, film.title, film.overview, film.popularity,
//        film.voteAverage, film.releaseDate);
//    helper.insertIntoTable(f);
//    Toast.show("Saved", context);
//  }

//select operation
  Future<List<Map<String, dynamic>>> selectFromTable() async {
    var db = await database;
    return db.rawQuery("select * from $table_name");
  }

  Future<List<Results>> getFilms() async {
    var listOfMap = await selectFromTable();
    List<Results> films = List();
    for (int i = 0; i < listOfMap.length; i++) {
      films.add(Results.ConvertFromMap(listOfMap[i]));
    }
    return films;
  }

  Future<List<Map<String, dynamic>>> selectWithId(int Id) async {
    var db = await database;
    return db.rawQuery("select * from $table_name where $col_id = $Id");
  }

  //Delete operations
  deleteFilm(int id) async {
    var db = await database;
    db.delete(table_name, where: "$col_id = ?", whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    var db = await database;
    return await db.rawDelete('DELETE FROM $table_name');
  }
}
