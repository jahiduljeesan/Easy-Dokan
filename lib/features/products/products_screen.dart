import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'products_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final barcode = await context.push<String>('/scanner');
              if (barcode != null) {
                // handle finding product by barcode (to be implemented)
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Scanned: $barcode')));
              }
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products added yet.'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                  title: Text(product.name),
                  subtitle: Text(
                    'Stock: ${product.quantity} | Price: ৳${product.sellingPrice}',
                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/products/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
