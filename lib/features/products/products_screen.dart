import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'products_provider.dart';
import '../../core/utils/sound_service.dart';
import '../../data/models/product_model.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

    final categories = [
      'All',
      ...products
          .map((p) => p.category ?? 'Uncategorized')
          .toSet()
          .where((c) => c.isNotEmpty),
    ];

    final filteredProducts = products.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          p.name.toLowerCase().contains(query) ||
          (p.barcodeId != null && p.barcodeId!.contains(query)) ||
          (p.category != null && p.category!.toLowerCase().contains(query));
      final matchesCategory =
          _selectedCategory == 'All' ||
          (p.category ?? 'Uncategorized') == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final barcode = await context.push<String>('/scanner');
              if (barcode != null) {
                final match = products.cast<ProductModel?>().firstWhere(
                      (p) => p?.barcodeId == barcode,
                      orElse: () => null,
                    );
                if (match != null) {
                  ref.read(soundProvider).playSuccess();
                  if (context.mounted) {
                    context.push('/products/edit', extra: match);
                  }
                } else {
                  ref.read(soundProvider).playError();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product not found!')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Products',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final barcode = await context.push<String>('/scanner');
                    if (barcode != null) {
                      ref.read(soundProvider).playSuccess();
                      setState(() {
                        _searchQuery = barcode;
                      });
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Quick Scan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final cat = categories.elementAt(index);
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      products.isEmpty
                          ? 'No products added yet.'
                          : 'No matching products found.',
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                        title: Text(product.name),
                        subtitle: Text(
                          'Stock: ${product.quantity % 1 == 0 ? product.quantity.toInt() : product.quantity} | Price: ৳${product.sellingPrice} | Category: ${product.category ?? "Uncategorized"}',
                        ),
                        onLongPress: () {
                          context.push('/products/edit', extra: product);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                context.push('/products/edit', extra: product);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                ref
                                    .read(productsProvider.notifier)
                                    .deleteProduct(product.uid);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/products/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
