import 'package:floor/floor.dart';
import 'customer.dart';

/// The DAO (Data Access Object) for the customer table.
@dao
abstract class CustomerDao {
  /// Returns a list of all customers.
  @Query('SELECT * FROM customer')
  Future<List<Customer>> findAllCustomers();

  /// Inserts a customer into the database.
  @insert
  Future<void> insertCustomer(Customer customer);

  /// Updates a customer in the database.
  @update
  Future<void> updateCustomer(Customer customer);

  /// Deletes a customer from the database.
  @delete
  Future<void> deleteCustomer(Customer customer);
}
