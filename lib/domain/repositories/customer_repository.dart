import '../../data/models/customer_model.dart';

abstract class CustomerRepository {
  List<CustomerModel> getAllCustomers();
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}
