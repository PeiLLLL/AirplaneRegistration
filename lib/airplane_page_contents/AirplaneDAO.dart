import 'package:floor/floor.dart';
import 'AirplaneItem.dart';

@dao
abstract class AirplaneDAO {
  @Query('SELECT * FROM AirplaneItem')
  Future<List<AirplaneItem>> findAllAirplaneItems();

  @insert
  Future<void> insertAirplaneItem(AirplaneItem airplaneItem);

  @delete
  Future<void> deleteAirplaneItem(AirplaneItem airplaneItem);

  @update
  Future<void> updateAirplaneItem(AirplaneItem airplaneItem);
}
