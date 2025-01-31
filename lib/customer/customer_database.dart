import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'customer_dao.dart';
import 'customer.dart';

part 'customer_database.g.dart';

/// The database class for the application.
///
/// This class defines the database schema and provides access to the DAOs.
@Database(version: 1, entities: [Customer])
abstract class AppDatabase extends FloorDatabase {
  /// The DAO for the customer table.
  CustomerDao get customerDao;
}
