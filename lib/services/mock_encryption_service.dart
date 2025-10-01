// This class simulates the behavior of the real EncryptionService for UI testing.
// It mimics storing a secret key in memory.
class MockEncryptionService {
  // A private variable to hold our fake secret key.
  String? _secretKey;

  // Simulate setting the secret key.
  Future<bool> setSecretKey(String key) async {
    // In a real app, this would save to flutter_secure_storage.
    // Here, we just set the variable.
    _secretKey = key;
    return true;
  }

  // Simulate retrieving the secret key.
  Future<String?> getSecretKey() async {
    // In a real app, this would read from flutter_secure_storage.
    return _secretKey;
  }
}
