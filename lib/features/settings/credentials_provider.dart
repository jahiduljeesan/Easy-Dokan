import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/credential_model.dart';

final credentialsNotifierProvider =
    StateNotifierProvider<CredentialsNotifier, List<CredentialModel>>((ref) {
  final box = Hive.box<CredentialModel>('credentials');
  return CredentialsNotifier(box);
});

class CredentialsNotifier extends StateNotifier<List<CredentialModel>> {
  final Box<CredentialModel> _box;

  CredentialsNotifier(this._box) : super([]) {
    loadCredentials();
  }

  void loadCredentials() {
    state = _box.values.toList();
  }

  Future<void> addCredential({
    required String name,
    String? username,
    String? secret,
    String? description,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final credential = CredentialModel(
      id: id,
      name: name,
      username: username,
      secret: secret,
      description: description,
    );
    await _box.put(id, credential);
    loadCredentials();
  }

  Future<void> updateCredential(CredentialModel credential) async {
    await credential.save();
    loadCredentials();
  }

  Future<void> deleteCredential(String id) async {
    await _box.delete(id);
    loadCredentials();
  }
}
