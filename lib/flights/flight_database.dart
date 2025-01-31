import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'flights_dao.dart';
import 'flights_model.dart';

part 'flight_database.g.dart';

@Database(version: 1, entities: [Flight])
abstract class FlightDatabase extends FloorDatabase {
  FlightDao get flightDao;
}
