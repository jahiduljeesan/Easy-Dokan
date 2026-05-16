import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/customer_model.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../data/repositories_impl/customer_repository_impl.dart';

final customersProvider =
    StateNotifierProvider<CustomersNotifier, List<CustomerModel>>((ref) {
      final repository = ref.watch(customerRepositoryProvider);
      return CustomersNotifier(repository);
    });

class CustomersNotifier extends StateNotifier<List<CustomerModel>> {
  final CustomerRepository repository;

  CustomersNotifier(this.repository) : super(repository.getAllCustomers());

  void loadCustomers() {
    state = repository.getAllCustomers();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await repository.addCustomer(customer);
    loadCustomers();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await repository.updateCustomer(customer);
    loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await repository.deleteCustomer(id);
    loadCustomers();
  }
}
