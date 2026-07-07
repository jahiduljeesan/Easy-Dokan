# <img src="https://i.ibb.co.com/R4hWm5ts/easy-dokan-logo.png" width="48" height="48" align="center" alt="Easy Dokan Logo"/> Easy Dokan

[![Flutter Version](https://img.shields.io/badge/Flutter-^3.11.5-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-^3.0-blue.svg?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

**Easy Dokan** (ইজি দোকান) is a modern, light-weight, and highly efficient Point of Sale (POS) and inventory management mobile application built with **Flutter**. Designed specifically for small to medium-sized retail shops, grocery stores, and local businesses, it simplifies daily transactions, inventory tracking, supplier/customer ledgers, and financial reports.

---

## 📸 App Showcase

### Banner
![Easy Dokan Banner](https://i.ibb.co.com/CsBZ51hZ/easy-dokan-banner.png)

### App Screenshots

<table width="100%">
  <tr>
    <td width="33.3%" align="center"><b>Dashboard (English)</b></td>
    <td width="33.3%" align="center"><b>Dashboard (Bengali)</b></td>
    <td width="33.3%" align="center"><b>Product List</b></td>
  </tr>
  <tr>
    <td align="center"><img src="https://i.ibb.co.com/r2RXsWcz/Screenshot-20260708-003835.png" width="90%" alt="Dashboard English"/></td>
    <td align="center"><img src="https://i.ibb.co.com/5g7ftMnt/Screenshot-20260708-003926.png" width="90%" alt="Dashboard Bengali"/></td>
    <td align="center"><img src="https://i.ibb.co.com/YTXjFgZB/Screenshot-20260708-004121.png" width="90%" alt="Product List"/></td>
  </tr>
  <tr>
    <td width="33.3%" align="center"><b>Point of Sale (POS) Cart</b></td>
    <td width="33.3%" align="center"><b>Checkout / Billing</b></td>
    <td width="33.3%" align="center"><b>Add/Edit Product</b></td>
  </tr>
  <tr>
    <td align="center"><img src="https://i.ibb.co.com/pBmBjw7B/Screenshot-20260708-004031.png" width="90%" alt="POS Cart"/></td>
    <td align="center"><img src="https://i.ibb.co.com/hJWPM2VR/Screenshot-20260708-004109.png" width="90%" alt="Checkout Dialog"/></td>
    <td align="center"><img src="https://i.ibb.co.com/XkShswsw/Screenshot-20260708-004130.png" width="90%" alt="Add Product"/></td>
  </tr>
  <tr>
    <td width="33.3%" align="center"><b>Stock / Inventory Logs</b></td>
    <td width="33.3%" align="center"><b>Customer / Supplier Directory</b></td>
    <td width="33.3%" align="center"><b>Customer Debt Details</b></td>
  </tr>
  <tr>
    <td align="center"><img src="https://i.ibb.co.com/qMxcYqKq/Screenshot-20260708-004140.png" width="90%" alt="Inventory Logs"/></td>
    <td align="center"><img src="https://i.ibb.co.com/Ngmys1gq/Screenshot-20260708-004209.png" width="90%" alt="Contacts List"/></td>
    <td align="center"><img src="https://i.ibb.co.com/LDWxxTtj/Screenshot-20260708-004357.png" width="90%" alt="Customer Debt"/></td>
  </tr>
  <tr>
    <td width="33.3%" align="center"><b>Transaction History Ledger</b></td>
    <td width="33.3%" align="center"><b>App Settings</b></td>
    <td width="33.3%" align="center">-</td>
  </tr>
  <tr>
    <td align="center"><img src="https://i.ibb.co.com/RWnpHyM/Screenshot-20260708-004344.png" width="90%" alt="Ledger History"/></td>
    <td align="center"><img src="https://i.ibb.co.com/0RqDnvkX/Screenshot-20260708-004006.png" width="90%" alt="App Settings"/></td>
    <td align="center">-</td>
  </tr>
</table>

---

## ✨ Features

- 📊 **Smart Dashboard**: Keep track of today's sales, net profits, inventory valuation, and receive low stock alerts. Includes weekly/monthly trends via interactive graphs.
- 🛒 **Intuitive POS (Point of Sale)**:
  - Quick product search and selection.
  - Barcode scanning via camera.
  - Cart item management, discount application, and customer linkage.
  - Multi-payment support (Cash, Digital/MFS, Cards).
- 📦 **Inventory & Stock Management**:
  - Add products with SKU, categories, wholesale/retail prices, barcodes, and minimum stock alerts.
  - Stock logs showing check-ins, check-outs, and stock adjustments.
- 👥 **Customer & Supplier Ledger (Dena-Paona)**:
  - Dedicated customer and supplier directories.
  - Keep track of debts (credit sales) and payments.
  - Single-tap payment collection/payout entries.
- 💸 **Expense Tracker**: Categorize and track shop expenses (rent, utility bills, salaries) to calculate true net profit.
- 📄 **Digital Receipt & Invoice PDF**: Generate print-ready PDF invoices, and share them directly via WhatsApp, Email, or printing devices.
- 🌐 **Multilingual & Localized**: Complete support for both **English** and **Bengali (বাংলা)** languages.
- 🌓 **Themes**: Toggle seamlessly between Light Mode and Dark Mode.
- 🔒 **Data Privacy & Backup**: Fully offline local database storage with backup (export/import) options.

---

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev/) (Android, iOS)
- **State Management**: [Riverpod](https://riverpod.dev/) (using `flutter_riverpod`)
- **Database**: [Hive](https://pub.dev/packages/hive) & `hive_flutter` for ultra-fast, local NoSQL key-value storage.
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart) for beautiful data visualization.
- **Scanner**: [Mobile Scanner](https://pub.dev/packages/mobile_scanner) for camera-based barcode and QR scanning.
- **PDF & Printing**: [pdf](https://pub.dev/packages/pdf) and [printing](https://pub.dev/packages/printing) for receipt generation.
- **Dependency Injection & Code Generation**: [Freezed](https://pub.dev/packages/freezed) and [json_serializable](https://pub.dev/packages/json_serializable).

---

## 🚀 Setup and Installation

### Prerequisites
Make sure you have [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your system.

### Steps to Run Locally

1. **Clone the repository**:
   ```bash
   git clone https://github.com/jahiduljeesan/Easy-Dokan.git
   cd Easy-Dokan
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code files** (models, adapters, serialization):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Generate App Launcher Icons** (Optional):
   ```bash
   flutter pub run flutter_launcher_icons
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
