import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/customer_model.dart';
import 'customers_provider.dart';
import '../../localization/app_localizations.dart';

class CustomerEditScreen extends ConsumerStatefulWidget {
  final CustomerModel? customer;
  const CustomerEditScreen({super.key, this.customer});

  @override
  ConsumerState<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends ConsumerState<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dueAmountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.customer?.address ?? '',
    );
    _dueAmountController = TextEditingController(
      text: widget.customer?.dueAmount.toString() ?? '0.0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dueAmountController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final customer = CustomerModel(
        id: widget.customer?.id ?? now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text,
        dueAmount: double.tryParse(_dueAmountController.text) ?? 0.0,
        createdDate: widget.customer?.createdDate ?? now,
      );

      if (widget.customer == null) {
        ref.read(customersProvider.notifier).addCustomer(customer);
      } else {
        ref.read(customersProvider.notifier).updateCustomer(customer);
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'edit'.tr(context) : 'add_customer'.tr(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveCustomer),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dueAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Initial Due Amount',
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveCustomer,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'save'.tr(context) : 'add_customer'.tr(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
