import 'package:floor/floor.dart';

@Entity(tableName: 'reservation')
class Reservation {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final String customerName;
  final String departureCity;
  final String destinationCity;
  final String departureTime;
  final String arrivalTime;

  Reservation({
    this.id,
    required this.name,
    required this.customerName,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });
}
