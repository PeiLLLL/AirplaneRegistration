import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'customer.dart';
import 'customer_dao.dart';

/// A widget that displays a list of customers and handles selection and deletion.
class CustomerListView extends StatelessWidget {
  /// The data access object for customer operations.
  final CustomerDao customerDao;

  /// Callback when a customer is selected.
  final ValueChanged<Customer> onCustomerSelected;

  /// Callback when a customer is to be deleted.
  final ValueChanged<Customer> onDeleteCustomer;

  /// Constructor for CustomerListView.
  const CustomerListView({
    super.key,
    required this.customerDao,
    required this.onCustomerSelected,
    required this.onDeleteCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Customer>>(
      future: customerDao.findAllCustomers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final customers = snapshot.data!;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(AppLocalizations.of(context)?.translate('id') ?? "Id",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 20.0)),
                  Text(
                      AppLocalizations.of(context)?.translate('name') ?? "NOME",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 20.0)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => onCustomerSelected(customer),
                        onLongPress: () => onDeleteCustomer(customer),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(customer.id.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16.0)),
                              Text(customer.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16.0)),
                            ],
                          ),
                        ),
                      ),
                      const Divider(), // Add a line between each row
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
