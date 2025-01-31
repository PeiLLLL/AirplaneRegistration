import 'package:flutter/material.dart';
import 'reservation.dart';
import 'reservation_dao.dart';

class ReservationDetailPage extends StatelessWidget {
  final Reservation reservation;
  final ReservationDao reservationDao;

  const ReservationDetailPage({super.key, required this.reservation, required this.reservationDao});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Reservation'),
          content: const Text('Are you sure you want to delete this reservation?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await reservationDao.deleteReservation(reservation);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reservation Name: ${reservation.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Customer Name: ${reservation.customerName}'),
            const SizedBox(height: 8),
            Text('Departure City: ${reservation.departureCity}'),
            const SizedBox(height: 8),
            Text('Destination City: ${reservation.destinationCity}'),
            const SizedBox(height: 8),
            Text('Departure Time: ${reservation.departureTime}'),
            const SizedBox(height: 8),
            Text('Arrival Time: ${reservation.arrivalTime}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showDeleteDialog(context);
              },
              child: const Text('Delete Reservation'),
            ),
          ],
        ),
      ),
    );
  }
}
