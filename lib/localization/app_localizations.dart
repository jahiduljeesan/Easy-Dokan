import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Easy Dokan',
      'dashboard': 'Dashboard',
      'products': 'Products',
      'pos': 'POS',
      'inventory': 'Inventory',
      'customers': 'Customers',
      'suppliers': 'Suppliers',
      'expenses': 'Expenses',
      'settings': 'Settings',
      'today_sales': 'Today Sales',
      'total_profit': 'Total Profit',
      'total_debt': 'Total Debt',
      'low_stock': 'Low Stock',
      'expired': 'Expired',
      'recent_sales': 'Recent Sales',
      'add_product': 'Add Product',
      'add_customer': 'Add Customer',
      'barcode': 'Barcode',
      'scan': 'Scan',
      'search': 'Search',
      'checkout': 'Checkout',
      'cart': 'Cart',
      'total': 'Total',
      'discount': 'Discount',
      'due': 'Due',
      'paid': 'Paid',
      'language': 'Language',
      'setup_shop': 'Setup Shop',
      'shop_name': 'Shop Name',
      'address': 'Address',
      'phone': 'Phone',
      'currency': 'Currency',
      'continue_btn': 'Continue',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
    },
    'bn': {
      'app_name': 'ইজি দোকান',
      'dashboard': 'ড্যাশবোর্ড',
      'products': 'পণ্যসমূহ',
      'pos': 'বিক্রয় (POS)',
      'inventory': 'মজুদ',
      'customers': 'গ্রাহক',
      'suppliers': 'সরবরাহকারী',
      'expenses': 'খরচ',
      'settings': 'সেটিংস',
      'today_sales': 'আজকের বিক্রয়',
      'total_profit': 'মোট লাভ',
      'total_debt': 'মোট বকেয়া',
      'low_stock': 'মজুদ কম',
      'expired': 'মেয়াদোত্তীর্ণ',
      'recent_sales': 'সাম্প্রতিক বিক্রয়',
      'add_product': 'পণ্য যোগ করুন',
      'add_customer': 'গ্রাহক যোগ করুন',
      'barcode': 'বারকোড',
      'scan': 'স্ক্যান',
      'search': 'অনুসন্ধান',
      'checkout': 'চেকআউট',
      'cart': 'কার্ট',
      'total': 'মোট',
      'discount': 'ছাড়',
      'due': 'বকেয়া',
      'paid': 'পরিশোধিত',
      'language': 'ভাষা',
      'setup_shop': 'দোকান সেটআপ',
      'shop_name': 'দোকানের নাম',
      'address': 'ঠিকানা',
      'phone': 'ফোন',
      'currency': 'মুদ্রা',
      'continue_btn': 'চালিয়ে যান',
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল',
      'delete': 'মুছে ফেলুন',
      'edit': 'সম্পাদনা করুন',
    },
  };
}

extension AppLocalizationsExtension on String {
  String tr(BuildContext context) {
    final locale = AppLocalizations.of(context)?.locale.languageCode ?? 'en';
    return AppLocalizations._localizedValues[locale]?[this] ?? this;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
