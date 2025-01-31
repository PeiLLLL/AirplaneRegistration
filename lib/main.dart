import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'reservation_page_contents/reservation_dao.dart';
import 'reservation_page_contents/reservation_database.dart';
import 'reservation_page_contents/reservation_page.dart';
import 'airplane_page_contents/Airplane_page.dart';
import 'app_localizations.dart';
import 'customer/customer_dao.dart';
import 'customer/customer_page.dart';
import 'customer/customer_database.dart';
import 'flights/flights.dart';
import 'flights/flights_dao.dart';
import 'flights/flight_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final customerDatabase =
      await $FloorAppDatabase.databaseBuilder('customer_database.db').build();
  final customerDao = customerDatabase.customerDao;

  final flightDatabase =
      await $FloorFlightDatabase.databaseBuilder('flight_database.db').build();
  final flightDao = flightDatabase.flightDao;

  final reservationDatabase = await $FloorReservationDatabase
      .databaseBuilder('reservation_database.db')
      .build();
  final reservationDao = reservationDatabase.reservationDao;

  runApp(MyApp(
      customerDao: customerDao,
      flightDao: flightDao,
      reservationDao: reservationDao));
}

class MyApp extends StatefulWidget {
  final CustomerDao customerDao;
  final FlightDao flightDao;
  final ReservationDao reservationDao;

  const MyApp(
      {super.key,
      required this.customerDao,
      required this.flightDao,
      required this.reservationDao});

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', 'US');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'), // Added German locale
        Locale('tr', 'TR'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: HomePage(
        customerDao: widget.customerDao,
        flightDao: widget.flightDao,
        reservationDao: widget.reservationDao,
        onChangeLanguage: setLocale,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final CustomerDao customerDao;
  final FlightDao flightDao;
  final ReservationDao reservationDao;
  final void Function(Locale) onChangeLanguage;

  const HomePage({
    super.key,
    required this.customerDao,
    required this.flightDao,
    required this.reservationDao,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('home') ?? "Home"),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: onChangeLanguage,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('en', 'US'),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('fr', 'FR'),
                child: Text('Français'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('de', 'DE'), // Added German option
                child: Text('Deutsch'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('tr', 'TR'), // Added German option
                child: Text('Türkçe'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerPage(
                        customerDao: customerDao,
                        onChangeLanguage: onChangeLanguage),
                  ),
                );
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('customerPage') ??
                      "Cusomter Page"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlightsPage(flightDao),
                  ),
                );
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('flightPage') ??
                      "FLight Page"),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Airplane page (implement this page separately)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AirplanePage(), // Implement AirplanePage
                  ),
                );
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('airplanePage') ??
                      "Airplane Page"),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Reservation page (implement this page separately)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationPage(
                      reservationDao: reservationDao,
                      onChangeLanguage: onChangeLanguage,
                    ), // Implement ReservationPage
                  ),
                );
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('reservationPage') ??
                      "Reservation Page"),
            ),
          ],
        ),
      ),
    );
  }
}
