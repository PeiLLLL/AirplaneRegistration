import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'AirplaneItem.dart';
import 'AirplaneDAO.dart';

part 'AirplaneDatabase.g.dart'; // the generated code will be there

@Database(version: 1, entities: [AirplaneItem])
abstract class AppDatabase extends FloorDatabase {
  AirplaneDAO get getDAO;
}
