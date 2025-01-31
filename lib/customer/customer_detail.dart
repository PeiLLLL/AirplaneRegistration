import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'customer.dart';
import 'customer_dao.dart';

/// A stateful widget that displays detailed information about a customer.
class CustomerDetailPage extends StatefulWidget {
  /// The customer whose details are to be displayed.
  final Customer customer;

  /// Determines whether to show the back button in the app bar.
  final bool showBackButton;

  /// The data access object for customer operations.
  final CustomerDao customerDao;

  /// Callback to be invoked when the customer is updated.
  final VoidCallback onUpdate;

  /// Callback to be invoked when the customer is deleted.
  final VoidCallback onDelete;

  /// Constructor for CustomerDetailPage.
  const CustomerDetailPage({
    super.key,
    required this.customer,
    this.showBackButton = true,
    required this.customerDao,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late Customer customer;

  @override
  void initState() {
    super.initState();
    customer = widget.customer;
  }

  /// Shows a dialog for updating the customer details.
  void _showUpdateCustomerDialog(BuildContext context) {
    final TextEditingController nameController =
    TextEditingController(text: customer.name);
    final TextEditingController emailController =
    TextEditingController(text: customer.email);
    final TextEditingController phoneController =
    TextEditingController(text: customer.phone);
    final TextEditingController addressController =
    TextEditingController(text: customer.address);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)?.translate('updateCustomer') ??
                  "Update Customer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      ?.translate('enterCustomerName'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      ?.translate('enterCustomerEmail'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      ?.translate('enterCustomerPhone'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
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
              onPressed: () async {
                final updatedCustomer = Customer(
                  customer.id,
                  nameController.text,
                  emailController.text,
                  phoneController.text,
                  addressController.text,
                );
                await widget.customerDao.deleteCustomer(customer);
                await widget.customerDao.insertCustomer(updatedCustomer);
                widget.onUpdate();
                setState(() {
                  customer = updatedCustomer;
                });
                Navigator.of(context).pop();
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('updateButton') ??
                      "Update"),
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog for deleting the customer.
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)?.translate('deleteCustomer') ??
                  "Delete"),
          content: Text(
              AppLocalizations.of(context)?.translate('areYouSureDelete') ??
                  "Are you sure?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('noButton') ?? "No"),
            ),
            TextButton(
              onPressed: () async {
                await widget.customerDao.deleteCustomer(customer);
                widget.onDelete();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('yesButton') ?? "Yes"),
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
        automaticallyImplyLeading: widget.showBackButton,
        title: Text(
            AppLocalizations.of(context)?.translate('customerDetails') ??
                "Customer Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${AppLocalizations.of(context)?.translate('id')}: ${customer.id}',
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16.0)),
            Text(
                '${AppLocalizations.of(context)?.translate('name')}: ${customer.name}',
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16.0)),
            Text(
                '${AppLocalizations.of(context)?.translate('email')}: ${customer.email}',
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16.0)),
            Text(
                '${AppLocalizations.of(context)?.translate('phone')}: ${customer.phone}',
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16.0)),
            Text(
                '${AppLocalizations.of(context)?.translate('address')}: ${customer.address}',
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16.0)),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _showUpdateCustomerDialog(context),
                  child: Text(
                      AppLocalizations.of(context)?.translate('updateButton') ??
                          "Update"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _showDeleteConfirmationDialog(context),
                  style: ElevatedButton.styleFrom(),
                  child: Text(
                      AppLocalizations.of(context)?.translate('deleteButton') ??
                          "Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
