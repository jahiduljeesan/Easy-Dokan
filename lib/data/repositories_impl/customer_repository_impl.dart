import 'package:hive/hive.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(Hive.box<CustomerModel>('customers'));
});

class CustomerRepositoryImpl implements CustomerRepository {
  final Box<CustomerModel> _box;

  CustomerRepositoryImpl(this._box);

  @override
  List<CustomerModel> getAllCustomers() {
    return _box.values.toList();
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    await _box.put(customer.id, customer);
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await _box.put(customer.id, customer);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
  }
}
