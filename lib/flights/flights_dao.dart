import 'package:floor/floor.dart';
import 'flights_model.dart';

@dao
abstract class FlightDao {
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> findAllFlights();

  @Query('SELECT * FROM Flight WHERE id = :id')
  Stream<Flight?> findFlightById(int id);

  @Query('SELECT * FROM Flight WHERE departure_city = :departure')
  Stream<Flight?> findByDeparture(String departure);

  @Query('SELECT * FROM Flight WHERE destination_city = :destination')
  Stream<Flight?> findByDestination(String destination);

  @insert
  Future<void> insertFlight(Flight flight);

  @update
  Future<void> updateFlight(Flight flight);

  @delete
  Future<void> deleteFlight(Flight flight);
}
