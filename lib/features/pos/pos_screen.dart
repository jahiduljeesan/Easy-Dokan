import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'cart_provider.dart';
import '../products/products_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/repositories_impl/sale_repository_impl.dart';
import '../../core/services/pdf_service.dart';
import '../../core/widgets/calculator_dialog.dart';
import '../products/barcode_scanner_screen.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  String _searchQuery = '';

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
    final products = ref.watch(productsProvider).where((p) {
      final query = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(query) || (p.barcodeId != null && p.barcodeId!.contains(query));
    }).toList();

    final isWideScreen = MediaQuery.of(context).size.width > 600;

    Widget productsGrid = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Products',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWideScreen ? 3 : 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    ref.read(cartProvider.notifier).addProduct(p);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.inventory, size: 40, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('৳${p.sellingPrice} | Stock: ${p.quantity}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                          ],
                        ),
                      )
                    ],
                  ),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Discount'), Text('৳${cartState.discount.toStringAsFixed(2)}')]),
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
                  onPressed: cartState.items.isEmpty ? null : () => _showCheckoutDialog(context, cartState, isWideScreen),
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
                builder: (context) => const Dialog(
                  insetPadding: EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: SizedBox(
                      width: 400,
                      height: 500,
                      child: BarcodeScannerScreen(isPopup: true),
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

  void _showCheckoutDialog(BuildContext context, CartState cartState, bool isWideScreen) {
    double paidAmount = cartState.total;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Checkout'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Amount: ৳${cartState.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Paid Amount', border: OutlineInputBorder()),
                    onChanged: (val) {
                      setState(() {
                        paidAmount = double.tryParse(val) ?? 0.0;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Due: ৳${(cartState.total - paidAmount).clamp(0.0, double.infinity).toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                  Text('Return: ৳${(paidAmount - cartState.total).clamp(0.0, double.infinity).toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final saleItems = cartState.items.map((i) => SaleItemModel(
                      productId: i.product.uid,
                      productName: i.product.name,
                      quantity: i.quantity,
                      unitPrice: i.product.sellingPrice,
                      total: i.totalPrice,
                      buyingPrice: i.product.buyingPrice,
                    )).toList();

                    final sale = SaleModel(
                      id: now.millisecondsSinceEpoch.toString(),
                      items: saleItems,
                      subtotal: cartState.subtotal,
                      discount: cartState.discount,
                      vat: cartState.vat,
                      total: cartState.total,
                      paidAmount: paidAmount,
                      dueAmount: (cartState.total - paidAmount).clamp(0.0, double.infinity),
                      profit: cartState.totalProfit,
                      paymentMethod: 'CASH',
                      date: now,
                    );

                    await ref.read(saleRepositoryProvider).addSale(sale);
                    
                    // Deduct stock
                    for (var item in cartState.items) {
                      final updatedProduct = ProductModel(
                        uid: item.product.uid,
                        barcodeId: item.product.barcodeId,
                        name: item.product.name,
                        buyingPrice: item.product.buyingPrice,
                        sellingPrice: item.product.sellingPrice,
                        quantity: item.product.quantity - item.quantity,
                        createdDate: item.product.createdDate,
                        updatedDate: now,
                      );
                      ref.read(productsProvider.notifier).updateProduct(updatedProduct);
                    }

                    ref.read(cartProvider.notifier).clearCart();
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      if (!isWideScreen) Navigator.pop(context); // Close bottom sheet if open
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale Completed Successfully!')));
                    }
                    
                    // Print Invoice
                    await PdfService.generateAndPrintInvoice(sale);
                  },
                  child: const Text('Confirm Sale'),
                )
              ],
            );
          }
        );
      }
    );
  }
}
