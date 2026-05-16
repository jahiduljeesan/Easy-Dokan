import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/customer_model.dart';

class PdfService {
  static Future<void> generateAndPrintInvoice(SaleModel sale) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'EASY DOKAN',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${sale.date.toString().substring(0, 16)}'),
              pw.Text('Invoice No: ${sale.id}'),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text('Item')),
                  pw.Text('Qty'),
                  pw.SizedBox(width: 20),
                  pw.Text('Price'),
                ],
              ),
              pw.Divider(),
              ...sale.items.map(
                (item) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Text(
                          item.quantity % 1 == 0
                              ? item.quantity.toInt().toString()
                              : item.quantity.toStringAsFixed(2),
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.SizedBox(width: 20),
                        pw.Text(
                          item.total.toStringAsFixed(2),
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    if (item.selectedAttributes != null &&
                        item.selectedAttributes!.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Text(
                          '  ${item.selectedAttributes!.values.join(", ")}',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey700,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Subtotal:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(sale.subtotal.toStringAsFixed(2)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Discount:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(sale.discount.toStringAsFixed(2)),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    sale.total.toStringAsFixed(2),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Paid:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(sale.paidAmount.toStringAsFixed(2)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Due:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(sale.dueAmount.toStringAsFixed(2)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Thank you for shopping with us!')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateCustomerStatement(
      CustomerModel customer, List<SaleModel> sales) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('CUSTOMER STATEMENT',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('EASY DOKAN',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('To:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(customer.name),
                      pw.Text(customer.phone),
                      if (customer.address != null) pw.Text(customer.address!),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                    pw.Text(
                        'Balance Due: ৳${customer.dueAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Table.fromTextArray(
              headers: ['Date', 'Invoice ID', 'Total', 'Paid', 'Due'],
              data: sales.map((s) {
                return [
                  s.date.toString().split(' ')[0],
                  s.id,
                  '৳${s.total.toStringAsFixed(0)}',
                  '৳${s.paidAmount.toStringAsFixed(0)}',
                  '৳${s.dueAmount.toStringAsFixed(0)}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Total Outstanding: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('৳${customer.dueAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 50),
            pw.Center(child: pw.Text('This is a computer generated document.')),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateSalesReport(
      DateTime start, DateTime end, List<SaleModel> sales) async {
    final pdf = pw.Document();

    // Summary Metrics
    final totalSales = sales.fold(0.0, (sum, s) => sum + s.total);
    final totalProfit = sales.fold(0.0, (sum, s) => sum + s.profit);
    final totalDue = sales.fold(0.0, (sum, s) => sum + s.dueAmount);
    final avgOrder = sales.isEmpty ? 0.0 : totalSales / sales.length;

    // Top Selling Products
    final productQty = <String, double>{};
    final productRev = <String, double>{};
    for (var sale in sales) {
      for (var item in sale.items) {
        productQty[item.productName] =
            (productQty[item.productName] ?? 0) + item.quantity;
        productRev[item.productName] =
            (productRev[item.productName] ?? 0) + item.total;
      }
    }
    final sortedProducts = productQty.keys.toList()
      ..sort((a, b) => productQty[b]!.compareTo(productQty[a]!));
    final topProducts = sortedProducts.take(5).toList();

    // Category Breakdown
    final categoryRev = <String, double>{};
    for (var sale in sales) {
      for (var item in sale.items) {
        final cat = item.category ?? 'Uncategorized';
        categoryRev[cat] = (categoryRev[cat] ?? 0) + item.total;
      }
    }
    final sortedCategories = categoryRev.keys.toList()
      ..sort((a, b) => categoryRev[b]!.compareTo(categoryRev[a]!));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Professional Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SALES PERFORMANCE REPORT',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('Easy Dokan POS - Smart Business Management',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Period:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${start.toString().split(' ')[0]} to ${end.toString().split(' ')[0]}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 2, color: PdfColors.blue900),
            pw.SizedBox(height: 20),

            // Summary Section
            pw.Text('1. EXECUTIVE SUMMARY',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('TOTAL SALES', '৳${totalSales.toStringAsFixed(0)}', PdfColors.blue800),
                _buildStatCard('TOTAL PROFIT', '৳${totalProfit.toStringAsFixed(0)}', PdfColors.green800),
                _buildStatCard('TOTAL DUE', '৳${totalDue.toStringAsFixed(0)}', PdfColors.red800),
                _buildStatCard('AVG. ORDER', '৳${avgOrder.toStringAsFixed(0)}', PdfColors.orange800),
              ],
            ),
            pw.SizedBox(height: 30),

            // Top Products Section
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('2. TOP SELLING PRODUCTS',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Table.fromTextArray(
                        headers: ['Product Name', 'Qty', 'Revenue'],
                        data: topProducts.map((p) => [
                          p,
                          productQty[p].toString().contains('.') && !productQty[p]!.toString().endsWith('.0')
                              ? productQty[p]!.toStringAsFixed(2)
                              : productQty[p]!.toInt().toString(),
                          '৳${productRev[p]!.toStringAsFixed(0)}'
                        ]).toList(),
                        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                        cellHeight: 25,
                        cellAlignments: {
                          0: pw.Alignment.centerLeft,
                          1: pw.Alignment.center,
                          2: pw.Alignment.centerRight,
                        },
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('3. CATEGORY BREAKDOWN',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Table.fromTextArray(
                        headers: ['Category', 'Sales'],
                        data: sortedCategories.map((c) => [
                          c,
                          '৳${categoryRev[c]!.toStringAsFixed(0)}'
                        ]).toList(),
                        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
                        cellHeight: 25,
                        cellAlignments: {
                          0: pw.Alignment.centerLeft,
                          1: pw.Alignment.centerRight,
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Recent Transactions Section
            pw.Text('4. DETAILED TRANSACTION HISTORY',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Date', 'Invoice ID', 'Items', 'Amount', 'Status'],
              data: sales.take(20).map((s) {
                return [
                  s.date.toString().substring(5, 16),
                  s.id,
                  s.items.length.toString(),
                  '৳${s.total.toStringAsFixed(0)}',
                  s.dueAmount > 0 ? 'DUE' : 'PAID',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              cellHeight: 20,
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.center,
              },
            ),
            if (sales.length > 20)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Text('* Showing first 20 transactions only',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
              ),
            
            pw.Spacer(),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Generated by Easy Dokan POS', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                pw.Text('Page 1 of 1', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    return pw.Container(
      width: 110,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white)),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
        ],
      ),
    );
  }
}
