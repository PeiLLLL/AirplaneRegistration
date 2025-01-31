import 'package:flutter/material.dart';
import 'package:test1/flights/flights_dao.dart';
import 'package:test1/main.dart';
import '../app_localizations.dart';
import 'flights_model.dart';

class FlightsPage extends StatefulWidget {
  const FlightsPage(this.dao, {super.key});

  /// Define flight dao
  final FlightDao dao;

  /// Create page state
  @override
  State<StatefulWidget> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightsPage> {
  /// Text controllers for input
  final TextEditingController _controllerFlightName = TextEditingController();
  final TextEditingController _controllerDepartureCity =
      TextEditingController();
  final TextEditingController _controllerDestinationCity =
      TextEditingController();
  final TextEditingController _controllerDepartureTime =
      TextEditingController();
  final TextEditingController _controllerArrivalTime = TextEditingController();
  final TextEditingController _controllerCreatedAt = TextEditingController();

  /// Flight list and variable for currently selected flight
  List<Flight> _flights = [];
  Flight? _selectedFlight;

  /// Main build widget containing the page content
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      /// AppBar section containing title, language options, instructions and button for getting input
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(localizations?.translate('flight_list') ?? 'Flight List'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: _alertInstructions, icon: const Icon(Icons.info)),
          Row(
            children: [
              Text(localizations?.translate('add_flight') ?? "Add Flight"),
              IconButton(
                icon: const Icon(Icons.add),

                /// OnPressed we use the [_showInputForm] function
                onPressed: _showInputForm,
              ),
            ],
          ),
          Padding(
            /// Section for the PopupButton which gives a selection option for [locale], allowing for DE and EN language options.
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: PopupMenuButton<Locale>(
              icon: const Icon(Icons.language, color: Colors.black87),
              onSelected: (Locale selectedLocale) {
                MyApp.setLocale(context, selectedLocale);
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<Locale>(
                  value: Locale('en'),
                  child: Text('EN'),
                ),
                const PopupMenuItem<Locale>(
                  value: Locale('de'),
                  child: Text('DE'),
                ),
              ],
            ),
          ),
        ],
      ),

      /// For our main page we check the max-width of screen and build based on if we are landscape or portrait view
      body: LayoutBuilder(
        builder: (context, constraints) {
          /// If we are below 720 we only use [_buildFlightList]
          if (constraints.maxWidth < 720) {
            return _buildFlightList();
          } else {
            return Row(
              children: [
                /// IF we are not, then we [_buildFlightList] as well as [_buildFlightDetailsPanel]
                Expanded(child: _buildFlightList()),
                const VerticalDivider(width: 1, color: Colors.grey),
                Expanded(child: _buildFlightDetailsPanel()),
              ],
            );
          }
        },
      ),
    );
  }

  /// Below we start our helper functions, first our initState will refresh flight list with [_refreshFlights]
  @override
  void initState() {
    super.initState();
    _refreshFlights();
  }

  /// find all flights with our widget.dao and setState of our [_flights] to our flights found in the database.
  Future<void> _refreshFlights() async {
    final flights = await widget.dao.findAllFlights();
    setState(() {
      _flights = flights;
    });
  }

  /// Addflight will get the information from the [_controllers]. Assuming everything is populated, we make a flight object and insert into the database and [_refreshFlights]
  void _addFlight() async {
    final localizations = AppLocalizations.of(context);

    final flightName = _controllerFlightName.text;
    final departureCity = _controllerDepartureCity.text;
    final destinationCity = _controllerDestinationCity.text;
    final departureTime = _controllerDepartureTime.text;
    final arrivalTime = _controllerArrivalTime.text;
    final createdAt = _controllerCreatedAt.text;

    if (departureCity.isNotEmpty &&
        destinationCity.isNotEmpty &&
        departureTime.isNotEmpty &&
        arrivalTime.isNotEmpty &&
        createdAt.isNotEmpty) {
      final flight = Flight(
          id: null,
          flightName: flightName,
          departureCity: departureCity,
          destinationCity: destinationCity,
          departureTime: departureTime,
          arrivalTime: arrivalTime,
          createdAt: createdAt);
      await widget.dao.insertFlight(flight);
      _controllerFlightName.clear();
      _controllerDepartureCity.clear();
      _controllerDestinationCity.clear();
      _controllerDepartureTime.clear();
      _controllerArrivalTime.clear();
      _controllerCreatedAt.clear();
      _refreshFlights();
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          localizations?.translate('data_saved') ?? "Data saved successfully!"),
    ));
  }

  /// Simple delete of our flight object using the current [_selectedFlight]
  void _deleteFlight(Flight flight) async {
    await widget.dao.deleteFlight(flight);
    setState(() {
      if (_selectedFlight == flight) {
        _selectedFlight = null;
      }
    });
    _refreshFlights();
  }

  /// Helper for updating our flight object.
  void _updateFlight(Flight flight) async {
    _controllerFlightName.clear();
    _controllerDepartureCity.clear();
    _controllerDestinationCity.clear();
    _controllerDepartureTime.clear();
    _controllerArrivalTime.clear();
    _controllerCreatedAt.clear();

    await widget.dao.updateFlight(flight);
  }

  /// Showdetails will run when our media width is below 720 it builds our [_flightDetailsPage]
  void _showDetails(Flight flight) {
    setState(() {
      _selectedFlight = flight;
    });

    if (MediaQuery.of(context).size.width < 720) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightDetailsPage(
              flight: flight,
              onDelete: _deleteFlight,
              onUpdate: _showUpdateForm,
            ),
          )).then((_) {
        _refreshFlights();
      });
    }
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  /// This is the main helper for updating our flight.
  void _showUpdateForm(Flight flight) {
    final localizations = AppLocalizations.of(context);

    _controllerFlightName.text = flight.flightName;
    _controllerDepartureCity.text = flight.departureCity;
    _controllerDestinationCity.text = flight.destinationCity;
    _controllerDepartureTime.text = flight.departureTime;
    _controllerArrivalTime.text = flight.arrivalTime;
    _controllerCreatedAt.text = flight.createdAt;

    String flightName =
        localizations?.translate('flight_name') ?? 'Flight Name';
    String departureCity =
        localizations?.translate('departure_city') ?? 'Departure City';
    String destinationCity =
        localizations?.translate('destination_city') ?? 'Destination City';
    String departureTime =
        localizations?.translate('departure_time') ?? 'Departure Time';
    String arrivalTime =
        localizations?.translate('arrival_time') ?? 'Arrival Time';
    String createdAt = localizations?.translate('created_at') ?? 'Created At';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              localizations?.translate("update_flight") ?? 'Update Flight',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _controllerFlightName,
                  decoration: InputDecoration(
                    labelText: flightName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerDepartureCity,
                  decoration: InputDecoration(
                    labelText: departureCity,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerDestinationCity,
                  decoration: InputDecoration(
                    labelText: destinationCity,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerDepartureTime,
                  decoration: InputDecoration(
                    labelText: departureTime,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerArrivalTime,
                  decoration: InputDecoration(
                    labelText: arrivalTime,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerCreatedAt,
                  decoration: InputDecoration(
                    labelText: createdAt,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                /// Clear our controllers
                if (Navigator.of(context).canPop()) {
                  _controllerFlightName.clear();
                  _controllerDepartureCity.clear();
                  _controllerDestinationCity.clear();
                  _controllerDepartureTime.clear();
                  _controllerArrivalTime.clear();
                  _controllerCreatedAt.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text(localizations?.translate('cancel') ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                /// Make a new flight with our updated info and the original flight.id
                Flight updatedFlight = Flight(
                  id: flight.id,
                  flightName: _controllerFlightName.text,
                  departureCity: _controllerDepartureCity.text,
                  destinationCity: _controllerDestinationCity.text,
                  departureTime: _controllerDepartureTime.text,
                  arrivalTime: _controllerArrivalTime.text,
                  createdAt: _controllerCreatedAt.text,
                );

                /// Run our [_updateFlight] helper
                _updateFlight(updatedFlight);

                /// If we can pop, pop and clear controllers
                if (Navigator.of(context).canPop()) {
                  _controllerFlightName.clear();
                  _controllerDepartureCity.clear();
                  _controllerDestinationCity.clear();
                  _controllerDepartureTime.clear();
                  _controllerArrivalTime.clear();
                  _controllerCreatedAt.clear();
                  Navigator.of(context).pop();
                }

                _refreshFlights();
              },
              child: Text(localizations?.translate('update') ?? 'Update'),
            ),
          ],
        );
      },
    );
  }

  /// This will give us our input form
  void _showInputForm() {
    DateTime now = DateTime.now();
    final localizations = AppLocalizations.of(context);

    String formattedDateTime =
        "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";
    _controllerCreatedAt.text = formattedDateTime;

    String flightName =
        localizations?.translate('flight_name') ?? 'Flight Name';
    String departureCity =
        localizations?.translate('departure_city') ?? 'Departure City';
    String destinationCity =
        localizations?.translate('destination_city') ?? 'Destination City';
    String departureTime =
        localizations?.translate('departure_time') ?? 'Departure Time';
    String arrivalTime =
        localizations?.translate('arrival_time') ?? 'Arrival Time';
    String createdAt = localizations?.translate('created_at') ?? 'Created At';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations?.translate("add_flight") ?? 'Add Flight',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _controllerFlightName,
                  decoration: InputDecoration(
                    labelText: flightName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerDepartureCity,
                  decoration: InputDecoration(
                    labelText: departureCity,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerDestinationCity,
                  decoration: InputDecoration(
                    labelText: destinationCity,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerDepartureTime,
                  decoration: InputDecoration(
                    labelText: departureTime,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerArrivalTime,
                  decoration: InputDecoration(
                    labelText: arrivalTime,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllerCreatedAt,
                  decoration: InputDecoration(
                    labelText: createdAt,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(localizations?.translate('cancel') ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: _addFlight,
              child: Text(localizations?.translate('add') ?? 'Add'),
            ),
          ],
        );
      },
    );
  }

  /// Main builder for our flight list. If there are none, display some text for that.
  Widget _buildFlightList() {
    final localizations = AppLocalizations.of(context);

    if (_flights.isEmpty) {
      return Center(
        child: Text(localizations?.translate('no_flights') ??
            'There are no flights at this time.'),
      );
    }

    return ListView.builder(
        itemCount: _flights.length,
        itemBuilder: (context, index) {
          final flight = _flights[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.pinkAccent),
            ),
            child: ListTile(
              title: Text(
                "${localizations?.translate('flight')} ${flight.flightName}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => _showDetails(flight),
            ),
          );
        });
  }

  /// Main build for the detailsPanel
  Widget _buildFlightDetailsPanel() {
    final localizations = AppLocalizations.of(context);

    if (_selectedFlight == null) {
      return Center(
          child: Text(localizations?.translate('no_flight_selected') ??
              'No flight selected.'));
    }

    /// Flight details Panel object is sent our current [_selectedFlight], what we do on delete [_deleteFlight] and what we do onUpdate [_showUpdateForm].
    return FlightDetailsPanel(
      flight: _selectedFlight!,
      onDelete: _deleteFlight,
      onUpdate: _showUpdateForm,
    );
  }

  /// This is our altern for our instructions.
  void _alertInstructions() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final localizations = AppLocalizations.of(context);
          return AlertDialog(
            title: Center(
                child: Text(localizations?.translate('instructions_title') ??
                    "Instructions")),
            content: Text(localizations?.translate('instructions_content') ??
                'The main page will give you details on existing entries of flights. If you want to add a new flight, click the + icon in the top right and fill in the details. All flight information will be saved, you don'
                    't need to worry about potential data loss.'),
            actions: [
              Center(
                  child: TextButton(
                child: Text(localizations?.translate('ok') ?? 'OK'),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ))
            ],
          );
        });
  }
}

/// Our flightDetailsPanel class for building our entire details Panel on landscape mode.
class FlightDetailsPanel extends StatelessWidget {
  final Flight flight;
  final Function(Flight) onDelete;
  final Function(Flight) onUpdate;

  const FlightDetailsPanel(
      {super.key,
      required this.flight,
      required this.onDelete,
      required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.pinkAccent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                    localizations?.translate('flight_name_label') ??
                        'Flight Name: ',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(flight.flightName, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                    localizations?.translate('departure_city_label') ??
                        'Departure City: ',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(flight.departureCity,
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                    localizations?.translate('destination_city_label') ??
                        'Destination City: ',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(flight.destinationCity,
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                    localizations?.translate('departure_time_label') ??
                        'Departure Time: ',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(flight.departureTime,
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                    localizations?.translate('arrival_time_label') ??
                        'Arrival Time: ',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(flight.arrivalTime, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                    localizations?.translate('created_at_label') ??
                        'Created At: ',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(flight.createdAt, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onDelete(flight);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(localizations?.translate('delete') ?? 'Delete'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                onUpdate(flight);
              },
              child: Text(localizations?.translate('update') ?? 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flight Details Page for building the page when we are in portrait view
class FlightDetailsPage extends StatelessWidget {
  final Flight flight;
  final Function(Flight) onDelete;
  final Function(Flight) onUpdate;

  const FlightDetailsPage(
      {super.key,
      required this.flight,
      required this.onDelete,
      required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localizations?.translate('flight_details') ?? 'Flight Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.pinkAccent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                                localizations?.translate('flight_name_label') ??
                                    'Flight Name: ',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(flight.flightName,
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                localizations
                                        ?.translate('departure_city_label') ??
                                    'Departure City: ',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(flight.departureCity,
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                localizations
                                        ?.translate('destination_city_label') ??
                                    'Destination City: ',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(flight.destinationCity,
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                localizations
                                        ?.translate('departure_time_label') ??
                                    'Departure Time: ',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(flight.departureTime,
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                localizations
                                        ?.translate('arrival_time_label') ??
                                    'Arrival Time: ',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(flight.arrivalTime,
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                localizations?.translate('created_at_label') ??
                                    'Created At: ',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(flight.createdAt,
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            onDelete(flight);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                              localizations?.translate('delete') ?? 'Delete'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            onUpdate(flight);
                          },
                          child: Text(
                              localizations?.translate('update') ?? 'Update'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
