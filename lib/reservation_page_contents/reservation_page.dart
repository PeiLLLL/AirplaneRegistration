import 'package:flutter/material.dart';
import 'reservation.dart';
import 'reservation_dao.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'reservation_detail_page.dart';
import '../app_localizations.dart';

class ReservationPage extends StatefulWidget {
  final ReservationDao reservationDao;
  final void Function(Locale) onChangeLanguage;

  const ReservationPage(
      {super.key, required this.reservationDao, required this.onChangeLanguage});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _departureCityController =
      TextEditingController();
  final TextEditingController _destinationCityController =
      TextEditingController();
  final TextEditingController _departureTimeController =
      TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  List<Reservation> _reservations = [];
  Reservation? _selectedReservation;
  final EncryptedSharedPreferences _encryptedSharedPreferences =
      EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _loadReservations();
    _loadSharedPreferences();
  }

  Future<void> _loadReservations() async {
    final reservations = await widget.reservationDao.findAllReservations();
    setState(() {
      _reservations = reservations;
    });
  }

  void _addReservation() async {
    final localizations = AppLocalizations.of(context);

    if (_nameController.text.isNotEmpty &&
        _customerNameController.text.isNotEmpty &&
        _departureCityController.text.isNotEmpty &&
        _destinationCityController.text.isNotEmpty &&
        _departureTimeController.text.isNotEmpty &&
        _arrivalTimeController.text.isNotEmpty) {
      final reservation = Reservation(
        id: null,
        name: _nameController.text,
        customerName: _customerNameController.text,
        departureCity: _departureCityController.text,
        destinationCity: _destinationCityController.text,
        departureTime: _departureTimeController.text,
        arrivalTime: _arrivalTimeController.text,
      );
      await widget.reservationDao.insertReservation(reservation);
      _clearControllers();
      _saveToSharedPreferences();
      _loadReservations();
      _showSnackbar(context,
          localizations?.translate('reservationAdded') ?? "Reservation Added");
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _customerNameController.clear();
    _departureCityController.clear();
    _destinationCityController.clear();
    _departureTimeController.clear();
    _arrivalTimeController.clear();
  }

  void _deleteReservation(Reservation reservation) async {
    final localizations = AppLocalizations.of(context);
    await widget.reservationDao.deleteReservation(reservation);
    _loadReservations();
    _showSnackbar(
        context,
        localizations?.translate('reservationDeleted') ??
            "Reservation Deleted");
  }

  void _saveToSharedPreferences() {
    _encryptedSharedPreferences.setString('name', _nameController.text);
    _encryptedSharedPreferences.setString(
        'customerName', _customerNameController.text);
    _encryptedSharedPreferences.setString(
        'departureCity', _departureCityController.text);
    _encryptedSharedPreferences.setString(
        'destinationCity', _destinationCityController.text);
    _encryptedSharedPreferences.setString(
        'departureTime', _departureTimeController.text);
    _encryptedSharedPreferences.setString(
        'arrivalTime', _arrivalTimeController.text);
  }

  void _loadSharedPreferences() async {
    _nameController.text =
        await _encryptedSharedPreferences.getString('name') ?? '';
    _customerNameController.text =
        await _encryptedSharedPreferences.getString('customerName') ?? '';
    _departureCityController.text =
        await _encryptedSharedPreferences.getString('departureCity') ?? '';
    _destinationCityController.text =
        await _encryptedSharedPreferences.getString('destinationCity') ?? '';
    _departureTimeController.text =
        await _encryptedSharedPreferences.getString('departureTime') ?? '';
    _arrivalTimeController.text =
        await _encryptedSharedPreferences.getString('arrivalTime') ?? '';
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDeleteDialog(Reservation reservation) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations?.translate('deleteReservation') ??
              "Delete Reservation"),
          content: Text(localizations?.translate('deleteConfirmation') ??
              "Are you sure you want to delete this reservation?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations?.translate('cancel') ?? "Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteReservation(reservation);
                Navigator.of(context).pop();
              },
              child: Text(localizations?.translate('delete') ?? "Delete"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetailPage(BuildContext context, Reservation reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReservationDetailPage(
              reservation: reservation, reservationDao: widget.reservationDao)),
    );
  }

  void _showPopupMenu(
      BuildContext context, Offset offset, Reservation reservation) async {
    final screenSize = MediaQuery.of(context).size;
    final left = offset.dx;
    final top = offset.dy;
    final right = screenSize.width - left;
    final bottom = screenSize.height - top;

    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, right, bottom),
      items: [
        PopupMenuItem(
          value: 'details',
          child: Text(AppLocalizations.of(context)?.translate('viewDetails') ??
              "View Details"),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
              AppLocalizations.of(context)?.translate('delete') ?? "Delete"),
        ),
      ],
    );

    if (selected == 'details') {
      _navigateToDetailPage(context, reservation);
    } else if (selected == 'delete') {
      _showDeleteDialog(reservation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localizations?.translate('reservationPage') ?? "Reservation Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(localizations?.translate('instructions') ??
                        "Instructions"),
                    content: Text(localizations
                            ?.translate('instructionDetails') ??
                        "Manage your reservations by adding, viewing, and deleting."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(localizations?.translate('ok') ?? "OK"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(localizations?.translate('changeLanguage') ??
                        "Change Language"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('English'),
                          onTap: () {
                            widget.onChangeLanguage(const Locale('en', 'US'));
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: const Text('Türkçe'),
                          onTap: () {
                            widget.onChangeLanguage(const Locale('tr', 'TR'));
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('reservationName')),
                      ),
                      TextField(
                        controller: _customerNameController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('customerName')),
                      ),
                      TextField(
                        controller: _departureCityController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('departureCity')),
                      ),
                      TextField(
                        controller: _destinationCityController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('destinationCity')),
                      ),
                      TextField(
                        controller: _departureTimeController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('departureTime')),
                      ),
                      TextField(
                        controller: _arrivalTimeController,
                        decoration: InputDecoration(
                            labelText: localizations?.translate('arrivalTime')),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _addReservation,
                        child: Text(
                            localizations?.translate('addReservation') ??
                                "Add Reservation"),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        localizations?.translate('reservationDetails') ??
                            "Manage your reservations by:\n\n1. Adding new reservations using the text fields and Add Reservation button.\n2. Viewing details of a reservation by tapping on it in the list.\n3. Deleting a reservation by either long-pressing on it or using the delete button in the details page.\n\nLong press on a reservation for quick actions like view details and delete.",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _reservations.isEmpty
                      ? Center(
                          child: Text(
                              localizations?.translate('noReservations') ??
                                  "No Reservations."))
                      : ListView.builder(
                          itemCount: _reservations.length,
                          itemBuilder: (context, index) {
                            final reservation = _reservations[index];
                            return Card(
                              child: ListTile(
                                title: Text(reservation.name),
                                subtitle: Text(
                                    'Customer: ${reservation.customerName}, From: ${reservation.departureCity} To: ${reservation.destinationCity}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteDialog(reservation);
                                  },
                                ),
                                onLongPress: () {
                                  _showPopupMenu(
                                      context, Offset.zero, reservation);
                                },
                                onTap: () {
                                  _navigateToDetailPage(context, reservation);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                  labelText: localizations
                                      ?.translate('reservationName')),
                            ),
                            TextField(
                              controller: _customerNameController,
                              decoration: InputDecoration(
                                  labelText:
                                      localizations?.translate('customerName')),
                            ),
                            TextField(
                              controller: _departureCityController,
                              decoration: InputDecoration(
                                  labelText: localizations
                                      ?.translate('departureCity')),
                            ),
                            TextField(
                              controller: _destinationCityController,
                              decoration: InputDecoration(
                                  labelText: localizations
                                      ?.translate('destinationCity')),
                            ),
                            TextField(
                              controller: _departureTimeController,
                              decoration: InputDecoration(
                                  labelText: localizations
                                      ?.translate('departureTime')),
                            ),
                            TextField(
                              controller: _arrivalTimeController,
                              decoration: InputDecoration(
                                  labelText:
                                      localizations?.translate('arrivalTime')),
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: _addReservation,
                              child: Text(
                                  localizations?.translate('addReservation') ??
                                      "Add Reservation"),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              localizations?.translate('reservationDetails') ??
                                  "Manage your reservations by:\n\n1. Adding new reservations using the text fields and Add Reservation button.\n2. Viewing details of a reservation by tapping on it in the list.\n3. Deleting a reservation by either long-pressing on it or using the delete button in the details page.\n\nLong press on a reservation for quick actions like view details and delete.",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _reservations.isEmpty
                            ? Center(
                                child: Text(localizations
                                        ?.translate('noReservations') ??
                                    "No Reservations"))
                            : ListView.builder(
                                itemCount: _reservations.length,
                                itemBuilder: (context, index) {
                                  final reservation = _reservations[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(reservation.name),
                                      subtitle: Text(
                                          'Customer: ${reservation.customerName}, From: ${reservation.departureCity} To: ${reservation.destinationCity}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _showDeleteDialog(reservation);
                                        },
                                      ),
                                      onLongPress: () {
                                        _showPopupMenu(
                                            context, Offset.zero, reservation);
                                      },
                                      onTap: () {
                                        setState(() {
                                          _selectedReservation = reservation;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _selectedReservation == null
                      ? Center(
                          child: Text(localizations
                                  ?.translate('noReservationSelected') ??
                              "No reservation selected."))
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${localizations?.translate('reservationName')}: ${_selectedReservation!.name}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    '${localizations?.translate('customerName')}: ${_selectedReservation!.customerName}'),
                                const SizedBox(height: 8),
                                Text(
                                    '${localizations?.translate('departureCity')}: ${_selectedReservation!.departureCity}'),
                                const SizedBox(height: 8),
                                Text(
                                    '${localizations?.translate('destinationCity')}: ${_selectedReservation!.destinationCity}'),
                                const SizedBox(height: 8),
                                Text(
                                    '${localizations?.translate('departureTime')}: ${_selectedReservation!.departureTime}'),
                                const SizedBox(height: 8),
                                Text(
                                    '${localizations?.translate('arrivalTime')}: ${_selectedReservation!.arrivalTime}'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _showDeleteDialog(_selectedReservation!);
                                  },
                                  child: Text(localizations
                                          ?.translate("deleteReservation") ??
                                      "Delete Reservation"),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
