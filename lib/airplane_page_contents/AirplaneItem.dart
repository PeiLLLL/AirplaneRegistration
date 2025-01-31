import 'package:floor/floor.dart';

@entity
class AirplaneItem {
  static int ID = 1;
  @primaryKey
  final int id;
  final String airplaneType;
  final String numOfPassengers;
  final String maxSpeed;
  final String distanceCanFly;

  AirplaneItem(this.id, this.airplaneType, this.numOfPassengers, this.maxSpeed,
      this.distanceCanFly);
}
