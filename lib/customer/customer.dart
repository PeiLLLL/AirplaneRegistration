import 'package:floor/floor.dart';

/// Represents a customer entity in the database.
@Entity(tableName: 'customer')
class Customer {
  @primaryKey
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;

  Customer(this.id, this.name, this.email, this.phone, this.address);
}
