import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// This service handles all data encryption and decryption logic.
class EncryptionService {
  final _secureStorage = const FlutterSecureStorage();
  static const _secretKeyStorageIdentifier = 'app_secret_key';

  // FIX: Renamed from 'encrypt' to 'encryptData' to avoid name collision.
  Future<String?> encryptData(String plainText) async {
    final key = await _getSecretKeyForEncryption();
    if (key == null) return null;

    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  // FIX: Renamed from 'decrypt' to 'decryptData' for consistency.
  Future<String?> decryptData(String encryptedText) async {
    final key = await _getSecretKeyForEncryption();
    if (key == null) return null;

    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2) return null; // Basic validation

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      return encrypter.decrypt(encryptedData, iv: iv);
    } catch (e) {
      print("Decryption failed: $e");
      return null;
    }
  }

  Future<encrypt.Key?> _getSecretKeyForEncryption() async {
    final secretKeyString = await getSecretKey();
    if (secretKeyString == null) return null;
    return encrypt.Key.fromUtf8(secretKeyString);
  }

  Future<String?> getSecretKey() async {
    return await _secureStorage.read(key: _secretKeyStorageIdentifier);
  }

  Future<bool> setSecretKey(String key) async {
    if (key.length != 32) {
      return false;
    }
    await _secureStorage.write(key: _secretKeyStorageIdentifier, value: key);
    return true;
  }
}

