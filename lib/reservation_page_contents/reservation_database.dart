import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'reservation_dao.dart';
import 'reservation.dart';

part 'reservation_database.g.dart';

@Database(version: 1, entities: [Reservation])
abstract class ReservationDatabase extends FloorDatabase {
  ReservationDao get reservationDao;
}
