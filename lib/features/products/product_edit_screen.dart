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
  late TextEditingController _unitController;
  bool _isMeasurable = false;
  Map<String, List<String>> _attributes = {};

  @override
  void initState() {
    super.initState();
    _attributes = Map<String, List<String>>.from(widget.product?.attributes ?? {});
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
    _unitController = TextEditingController(text: widget.product?.unit ?? '');
    _isMeasurable = widget.product?.isMeasurable ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _showAddAttributeDialog() {
    String key = '';
    String valuesStr = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Option Name (e.g. Size)'),
              onChanged: (v) => key = v,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Values (comma separated)',
                hintText: 'M, L, XL',
              ),
              onChanged: (v) => valuesStr = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (key.isNotEmpty && valuesStr.isNotEmpty) {
                final values = valuesStr
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                if (values.isNotEmpty) {
                  setState(() {
                    _attributes[key] = values;
                  });
                  context.pop();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
        quantity: double.tryParse(_quantityController.text) ?? 0.0,
        category: _categoryController.text.isEmpty
            ? null
            : _categoryController.text,
        createdDate: widget.product?.createdDate ?? now,
        updatedDate: now,
        attributes: _attributes.isEmpty ? null : _attributes,
        isMeasurable: _isMeasurable,
        unit: _isMeasurable ? _unitController.text : null,
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Sold by Measurement'),
                subtitle: const Text('e.g. Weight (kg), Volume (liter), Length (meter)'),
                value: _isMeasurable,
                onChanged: (val) => setState(() => _isMeasurable = val),
                secondary: const Icon(Icons.scale),
              ),
              if (_isMeasurable) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit (e.g. kg, gram, liter, meter)',
                    prefixIcon: Icon(Icons.straighten),
                    hintText: 'kg',
                  ),
                  validator: (value) => _isMeasurable && (value == null || value.isEmpty)
                      ? 'Required for measurable products'
                      : null,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Additional Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showAddAttributeDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Field'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_attributes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No additional details added yet.',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _attributes.length,
                  itemBuilder: (context, index) {
                    final key = _attributes.keys.elementAt(index);
                    final values = _attributes[key] ?? [];
                    return Card(
                      child: ListTile(
                        title: Text(key),
                        subtitle: Text(values.join(', ')),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _attributes.remove(key);
                            });
                          },
                        ),
                      ),
                    );
                  },
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
