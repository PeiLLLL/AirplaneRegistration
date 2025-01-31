import 'package:floor/floor.dart';
import 'reservation.dart';

@dao
abstract class ReservationDao {
  @Query('SELECT * FROM reservation')
  Future<List<Reservation>> findAllReservations();

  @insert
  Future<void> insertReservation(Reservation reservation);

  @delete
  Future<void> deleteReservation(Reservation reservation);
}
