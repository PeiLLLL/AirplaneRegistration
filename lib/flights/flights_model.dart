import 'package:floor/floor.dart';

@entity
class Flight {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  String flightName;
  String departureCity;
  String destinationCity;
  String departureTime;
  String arrivalTime;
  String createdAt;

  Flight({
    this.id,
    required this.flightName,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flight_name': flightName,
      'departure_city': departureCity,
      'destination_city': destinationCity,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'created_at': createdAt,
    };
  }
}
