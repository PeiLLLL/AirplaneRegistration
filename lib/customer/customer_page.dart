import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../app_localizations.dart';
import 'customer_list_view.dart';
import 'customer.dart';
import 'customer_dao.dart';
import 'customer_detail.dart';

/// The CustomerPage class is a stateful widget that displays a list of customers
/// and allows adding, updating, and deleting customers.
class CustomerPage extends StatefulWidget {
  /// The data access object for customer operations.
  final CustomerDao customerDao;

  /// Callback to change the app's language.
  final void Function(Locale) onChangeLanguage;

  /// Constructor for CustomerPage.
  const CustomerPage(
      {super.key, required this.customerDao, required this.onChangeLanguage});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final EncryptedSharedPreferences _encryptedSharedPreferences =
  EncryptedSharedPreferences();
  int _idCounter = 1;
  Customer? selectedCustomer;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadSavedCustomerData();
  }

  /// Loads all customers from the database.
  Future<void> _loadCustomers() async {
    final result = await widget.customerDao.findAllCustomers();
    setState(() {
      var customers = result;
      if (customers.isNotEmpty) {
        _idCounter =
            customers.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    });
  }

  /// Loads saved customer data from encrypted shared preferences.
  Future<void> _loadSavedCustomerData() async {
    _nameController.text =
        await _encryptedSharedPreferences.getString('customerName') ?? '';
    _emailController.text =
        await _encryptedSharedPreferences.getString('customerEmail') ?? '';
    _phoneController.text =
        await _encryptedSharedPreferences.getString('customerPhone') ?? '';
    _addressController.text =
        await _encryptedSharedPreferences.getString('customerAddress') ?? '';
  }

  /// Validates if the provided email is in correct format.
  bool _validateEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  /// Saves customer data to encrypted shared preferences.
  void _saveCustomerData() async {
    await _encryptedSharedPreferences.setString(
        'customerName', _nameController.text);
    await _encryptedSharedPreferences.setString(
        'customerEmail', _emailController.text);
    await _encryptedSharedPreferences.setString(
        'customerPhone', _phoneController.text);
    await _encryptedSharedPreferences.setString(
        'customerAddress', _addressController.text);
  }

  /// Adds a new customer to the database.
  void _addCustomer() async {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty) {
      if (!_validateEmail(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)?.translate('invalidEmail') ??
                    "Invalid Email")));
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    AppLocalizations.of(context)?.translate('invalidEmail') ??
                        "Invalid Email"),
                content: Text(AppLocalizations.of(context)
                    ?.translate('pleaseEnterValidEmail') ??
                    "Please Enter Valid Email"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
              );
            });
        return;
      }

      final newCustomer = Customer(
          _idCounter++,
          _nameController.text,
          _emailController.text,
          _phoneController.text,
          _addressController.text);
      await widget.customerDao.insertCustomer(newCustomer);
      _saveCustomerData(); // Save customer data
      _loadCustomers();
      Navigator.of(context).pop();

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Record saved in the database | Enregistrement sauvegardé dans la base de données'),
      ));
    }
  }

  /// Updates an existing customer in the database.
  void _updateCustomer(Customer updatedCustomer) async {
    await widget.customerDao.updateCustomer(updatedCustomer);
    _loadCustomers();
  }

  /// Deletes a customer from the database.
  void _deleteCustomer(Customer customer) async {
    await widget.customerDao.deleteCustomer(customer);
    _loadCustomers();
  }

  /// Shows the dialog to add a new customer.
  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('addCustomer') ??
              "Add Customer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      ?.translate('enterCustomerName'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      ?.translate('enterCustomerEmail'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      ?.translate('enterCustomerPhone'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      ?.translate('enterCustomerAddress'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('cancelButton') ??
                      "Cancel"),
            ),
            TextButton(
              onPressed: _addCustomer,
              child: Text(
                  AppLocalizations.of(context)?.translate('addButton') ??
                      "Add"),
            ),
          ],
        );
      },
    );
  }

  /// Shows the dialog to confirm deletion of a customer.
  void _showDeleteDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)?.translate('deleteCustomer') ??
                  "Delete"),
          content: Text(
              AppLocalizations.of(context)?.translate('areYouSureDelete') ??
                  "Are you sure you want to delete?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('noButton') ?? "No"),
            ),
            TextButton(
              onPressed: () {
                _deleteCustomer(customer);
                Navigator.of(context).pop();
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('yesButton') ??
                      "Yes"),
            ),
          ],
        );
      },
    );
  }

  /// Shows the welcome dialog with instructions.
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('Instruction') ??
              "Instructions"),
          content: Text(AppLocalizations.of(context)
              ?.translate('CustomerInstruction') ??
              "The main page will give you details on existing entries of customers. If you want to add a new customer, click the + icon in the top right and fill in the details. All customer information will be saved, you don't need to worry about potential data loss."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var isWideScreen = size.width > 720;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('customers') ??
            "Customers"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCustomerDialog,
          ),
          IconButton(
            icon: const Icon(Icons.warning),
            onPressed: _showWelcomeDialog,
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              widget.onChangeLanguage(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('en', 'US'),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('fr', 'FR'),
                child: Text('Français'),
              ),
            ],
          ),
        ],
      ),
      body: isWideScreen
          ? Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomerListView(
              customerDao: widget.customerDao,
              onCustomerSelected: (customer) {
                setState(() {
                  selectedCustomer = customer;
                });
              },
              onDeleteCustomer: _showDeleteDialog,
            ),
          ),
          if (selectedCustomer != null)
            Expanded(
              flex: 3,
              child: CustomerDetailPage(
                customer: selectedCustomer!,
                showBackButton: false,
                customerDao: widget.customerDao,
                onUpdate: () {
                  setState(() {
                    _updateCustomer(selectedCustomer!);
                  });
                },
                onDelete: () {
                  setState(() {
                    _deleteCustomer(selectedCustomer!);
                    selectedCustomer = null;
                  });
                },
              ),
            ),
        ],
      )
          : CustomerListView(
        customerDao: widget.customerDao,
        onCustomerSelected: (customer) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailPage(
                customer: customer,
                showBackButton: true,
                customerDao: widget.customerDao,
                onUpdate: () {
                  setState(() {
                    _updateCustomer(customer);
                  });
                },
                onDelete: () {
                  setState(() {
                    _deleteCustomer(customer);
                    Navigator.of(context).pop();
                  });
                },
              ),
            ),
          );
        },
        onDeleteCustomer: _showDeleteDialog,
      ),
    );
  }
}
