import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product_model.dart';
import 'products_provider.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  final ProductModel? product;
  const ProductEditScreen({super.key, this.product});

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _buyingPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _quantityController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController = TextEditingController(
      text: widget.product?.barcodeId ?? '',
    );
    _buyingPriceController = TextEditingController(
      text: widget.product?.buyingPrice.toString() ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: widget.product?.sellingPrice.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.product?.category ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final product = ProductModel(
        uid: widget.product?.uid ?? now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        barcodeId: _barcodeController.text.isEmpty
            ? null
            : _barcodeController.text,
        buyingPrice: double.tryParse(_buyingPriceController.text) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        category: _categoryController.text.isEmpty
            ? null
            : _categoryController.text,
        createdDate: widget.product?.createdDate ?? now,
        updatedDate: now,
      );

      if (widget.product == null) {
        ref.read(productsProvider.notifier).addProduct(product);
      } else {
        ref.read(productsProvider.notifier).updateProduct(product);
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveProduct),
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
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      final barcode = await context.push<String>('/scanner');
                      if (barcode != null) {
                        setState(() {
                          _barcodeController.text = barcode;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buyingPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Buying Price',
                        prefixIcon: Icon(Icons.money),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  child: const Text('Save Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
