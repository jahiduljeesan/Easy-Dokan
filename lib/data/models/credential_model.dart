import 'package:hive/hive.dart';

part 'credential_model.g.dart';

@HiveType(typeId: 9)
class CredentialModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // e.g. "bKash Merchant API", "SMS Gateway Token"

  @HiveField(2)
  String? username; // e.g. Client ID / Username

  @HiveField(3)
  String? secret; // e.g. Password / API Key / Secret

  @HiveField(4)
  String? description; // e.g. Extra notes

  CredentialModel({
    required this.id,
    required this.name,
    this.username,
    this.secret,
    this.description,
  });
}
