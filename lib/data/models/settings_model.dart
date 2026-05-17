import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 7)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String shopName;

  @HiveField(1)
  String currency;

  @HiveField(2)
  String language;

  @HiveField(3)
  bool isDarkTheme;

  @HiveField(4)
  String? pinCode;

  @HiveField(5)
  String? address;

  @HiveField(6)
  String? phone;

  @HiveField(7)
  bool isSetupComplete;

  @HiveField(8)
  String? ownerName;

  @HiveField(9)
  String? businessEmail;

  @HiveField(10)
  String? tradeLicense;

  SettingsModel({
    this.shopName = 'Easy Dokan',
    this.currency = '৳',
    this.language = 'en',
    this.isDarkTheme = true,
    this.pinCode,
    this.address,
    this.phone,
    this.isSetupComplete = false,
    this.ownerName,
    this.businessEmail,
    this.tradeLicense,
  });
}
