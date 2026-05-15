import '../../data/models/customer_model.dart';

abstract class CustomerRepository {
  List<CustomerModel> getAllCustomers();
  Future<void> addCustomer(CustomerModel customer);
}
