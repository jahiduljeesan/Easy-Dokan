import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'cart_provider.dart';
import '../products/products_provider.dart';
import '../../data/models/product_model.dart';
import '../../core/widgets/calculator_dialog.dart';
import '../products/barcode_scanner_screen.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  void _handleBarcodeScan(String barcode) {
    final match = ref.read(productsProvider).firstWhere(
          (p) => p.barcodeId == barcode,
          orElse: () => ProductModel(uid: '', name: '', buyingPrice: 0, sellingPrice: 0, quantity: 0, createdDate: DateTime.now(), updatedDate: DateTime.now()),
        );
    if (match.uid.isNotEmpty) {
      ref.read(cartProvider.notifier).addProduct(match);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product not found!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final allProducts = ref.watch(productsProvider);
    
    final categories = ['All', ...allProducts.map((p) => p.category ?? 'Uncategorized').toSet().where((c) => c.isNotEmpty)];

    final products = allProducts.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(query) || (p.barcodeId != null && p.barcodeId!.contains(query));
      final matchesCategory = _selectedCategory == 'All' || (p.category ?? 'Uncategorized') == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final isWideScreen = MediaQuery.of(context).size.width > 600;

    Widget productsGrid = Column(
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
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final barcode = await showDialog<String>(
                    context: context,
                    builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: SizedBox(
                          width: 400,
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const BarcodeScannerScreen(isPopup: true),
                        ),
                      ),
                    ),
                  );
                  if (barcode != null) _handleBarcodeScan(barcode);
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Quick Scan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p.category ?? 'Uncategorized'} | Stock: ${p.quantity}'),
                  trailing: Text('৳${p.sellingPrice}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  onTap: () => ref.read(cartProvider.notifier).addProduct(p),
                ),
              );
            },
          ),
        ),
      ],
    );

    Widget cartPanel = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              const Icon(Icons.shopping_cart),
              const SizedBox(width: 8),
              Text('Cart (${cartState.items.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cartState.items.length,
            itemBuilder: (context, index) {
              final item = cartState.items[index];
              return ListTile(
                title: Text(item.product.name),
                subtitle: Text('৳${item.product.sellingPrice} x ${item.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.uid, item.quantity - 1),
                    ),
                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.uid, item.quantity + 1),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), Text('৳${cartState.subtotal.toStringAsFixed(2)}')]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Discount'), Text('৳${cartState.totalDiscount.toStringAsFixed(2)}')]),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('৳${cartState.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: cartState.items.isEmpty ? null : () => context.push('/checkout'),
                  child: const Text('Checkout', style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CalculatorDialog(),
              );
            },
          ),
          InkWell(
            onTap: () async {
              final barcode = await context.push<String>('/scanner');
              if (barcode != null) {
                _handleBarcodeScan(barcode);
              }
            },
            onLongPress: () async {
              final barcode = await showDialog<String>(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: SizedBox(
                      width: 400,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const BarcodeScannerScreen(isPopup: true),
                    ),
                  ),
                ),
              );
              if (barcode != null) {
                _handleBarcodeScan(barcode);
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.qr_code_scanner),
            ),
          )
        ],
      ),
      body: isWideScreen
          ? Row(
              children: [
                Expanded(flex: 3, child: productsGrid),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: cartPanel),
              ],
            )
          : productsGrid,
      floatingActionButton: isWideScreen
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.8,
                    child: cartPanel,
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: Text('${cartState.items.length} items | ৳${cartState.total.toStringAsFixed(2)}'),
            ),
    );
  }
}
