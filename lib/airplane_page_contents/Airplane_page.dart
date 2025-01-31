import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'AirplaneDAO.dart';
import 'AirplaneItem.dart';
import 'AirplaneDatabase.dart';
import '../app_localizations.dart';
import '../main.dart';

class AirplanePage extends StatefulWidget {
  const AirplanePage({Key? key}) : super(key: key);

  @override
  _AirplanePageState createState() => _AirplanePageState();
}

class _AirplanePageState extends State<AirplanePage> {
  final TextEditingController airplaneTypeController = TextEditingController();
  final TextEditingController numOfPassengersController =
      TextEditingController();
  final TextEditingController maxSpeedController = TextEditingController();
  final TextEditingController distanceCanFlyController =
      TextEditingController();
  late EncryptedSharedPreferences prefs;
  late AirplaneDAO airplaneDAO;
  List<AirplaneItem> _airplaneItems = [];
  int _idCounter = 1;
  AirplaneItem? _selectedItem;
  late Future<void> _databaseInitialization;

  @override
  void initState() {
    super.initState();
    prefs = EncryptedSharedPreferences();
    _databaseInitialization = _initDatabase();
  }

  Future<void> _initDatabase() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    airplaneDAO = database.getDAO;
    _loadAirplanes();
  }

  @override
  void dispose() {
    airplaneTypeController.dispose();
    numOfPassengersController.dispose();
    maxSpeedController.dispose();
    distanceCanFlyController.dispose();
    super.dispose();
  }

  Future<void> clearData() async {
    await prefs.remove("AirplaneType");
    await prefs.remove("NumOfPassengers");
    await prefs.remove("MaxSpeed");
    await prefs.remove("MaxDistance");

    setState(() {
      airplaneTypeController.clear();
      numOfPassengersController.clear();
      maxSpeedController.clear();
      distanceCanFlyController.clear();
    });
  }

  void alert() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:
            Text(AppLocalizations.of(context)!.translate('Submit_info_key')!),
        content: Text(
            AppLocalizations.of(context)!.translate('Submit_Question_key')!),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              saveInfo();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.translate('Submit')!),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.translate("Cancel")!),
          ),
        ],
      ),
    );
  }

  Future<void> saveInfo() async {
    if (airplaneTypeController.text.isNotEmpty &&
        numOfPassengersController.text.isNotEmpty &&
        maxSpeedController.text.isNotEmpty &&
        distanceCanFlyController.text.isNotEmpty) {
      final newAirplane = AirplaneItem(
        _idCounter++,
        airplaneTypeController.text,
        numOfPassengersController.text,
        maxSpeedController.text,
        distanceCanFlyController.text,
      );

      await airplaneDAO.insertAirplaneItem(newAirplane);

      // Save data in encrypted shared preferences
      await prefs.setString("AirplaneType", airplaneTypeController.text);
      await prefs.setString("NumOfPassengers", numOfPassengersController.text);
      await prefs.setString("MaxSpeed", maxSpeedController.text);
      await prefs.setString("MaxDistance", distanceCanFlyController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate("Airplane_added_!")!),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear text fields after submission
      airplaneTypeController.clear();
      numOfPassengersController.clear();
      maxSpeedController.clear();
      distanceCanFlyController.clear();

      // Reload list of airplanes
      _loadAirplanes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate("All_fields_must_be_entered_!")!),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadAirplanes() async {
    final airplanes = await airplaneDAO.findAllAirplaneItems();
    setState(() {
      _airplaneItems = airplanes;
    });
  }

  void showInstructions() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Instructions"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            Text(AppLocalizations.of(context)!
                .translate("1.Fill_in_the_fields_with_airplane_details.")!),
            Text(AppLocalizations.of(context)!.translate(
                "2.Tap_the_'Submit'_button_to_save_the_information.")!),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.translate("Close")!),
          ),
        ],
      ),
    );
  }

  void _removeItem(AirplaneItem item) async {
    await airplaneDAO.deleteAirplaneItem(item);
    _loadAirplanes();
    setState(() {
      if (_selectedItem == item) {
        _selectedItem = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            AppLocalizations.of(context)!.translate("Airplane_removed_!")!),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDetailsPage(
      BuildContext context, AirplaneItem item, bool isTablet) {
    if (isTablet) {
      setState(() {
        _selectedItem = item;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsPage(
            item: item,
            onDelete: () {
              _removeItem(item);
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  Widget _buildDetailsPage() {
    if (_selectedItem == null) {
      return Center(
          child: Text(
              AppLocalizations.of(context)!.translate("Nothing_is_selected")!));
    } else {
      final item = _selectedItem!;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "${AppLocalizations.of(context)!.translate("Airplane_type")!}  ${item.airplaneType}"),
          Text(
              "${AppLocalizations.of(context)!.translate("Number_of_passengers")!}  ${item.numOfPassengers}"),
          Text(
              "${AppLocalizations.of(context)!.translate("Max_Speed")!}  ${item.maxSpeed}"),
          Text(
              "${AppLocalizations.of(context)!.translate("Distance_plane_can_fly")!} ${item.distanceCanFly}"),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                _removeItem(item);
              },
              child: Text(AppLocalizations.of(context)!.translate("Delete")!)),
          SizedBox(height: 20),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.translate("Airplane_list_page")!),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showInstructions();
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _databaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    "${AppLocalizations.of(context)!.translate("Airplane_list_page")!} ${snapshot.error}"));
          } else {
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(AppLocalizations.of(context)!
                                  .translate("Airplane_type")!),
                            ),
                            Expanded(
                              flex: 4,
                              child: TextField(
                                controller: airplaneTypeController,
                                decoration: const InputDecoration(
                                  hintText: "Ex: Airbus A350",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(AppLocalizations.of(context)!
                                  .translate("Number_of_passengers")!),
                            ),
                            Expanded(
                              flex: 4,
                              child: TextField(
                                controller: numOfPassengersController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Ex: 5",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(AppLocalizations.of(context)!
                                  .translate("Max_speed")!),
                            ),
                            Expanded(
                              flex: 4,
                              child: TextField(
                                controller: maxSpeedController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Ex: 120",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(AppLocalizations.of(context)!
                                  .translate("Distance_plane_can_fly")!),
                            ),
                            Expanded(
                              flex: 4,
                              child: TextField(
                                controller: distanceCanFlyController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Ex: 1000",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            alert();
                          },
                          child: Text(AppLocalizations.of(context)!
                              .translate("Submit")!),
                        ),
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _airplaneItems.length,
                            itemBuilder: (context, index) {
                              final airplane = _airplaneItems[index];

                              return ListTile(
                                title: Text(
                                    "${AppLocalizations.of(context)!.translate("Airplane_type")!}" +
                                        airplane.airplaneType),
                                onTap: () {
                                  _showDetailsPage(context, airplane, isTablet);
                                },
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            MyApp.setLocale(context, Locale('fr', 'CA'));
                          },
                          child: Text('Change to French'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isTablet)
                  Expanded(
                    child: _buildDetailsPage(),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final AirplaneItem item;
  final VoidCallback onDelete;

  const DetailsPage({Key? key, required this.item, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("Details")!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "${AppLocalizations.of(context)!.translate("Airplane_type")!}  ${item.airplaneType}"),
            Text(
                "${AppLocalizations.of(context)!.translate("Number_of_passengers")!}  ${item.numOfPassengers}"),
            Text(
                "${AppLocalizations.of(context)!.translate("Max_Speed")!}  ${item.maxSpeed}"),
            Text(
                "${AppLocalizations.of(context)!.translate("Distance_plane_can_fly")!} ${item.distanceCanFly}"),
            SizedBox(height: 20),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onDelete,
              child: Text(AppLocalizations.of(context)!.translate("Delete")!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.translate("Go_Back")!),
            ),
          ],
        ),
      ),
    );
  }
}
