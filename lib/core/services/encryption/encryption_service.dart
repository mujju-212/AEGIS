import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256 encryption service.
/// Keys stored in Android Keystore (hardware-backed) via flutter_secure_storage.
/// Nothing ever leaves the device.
class EncryptionService {
  static const _keyStorageKey = 'privacy_ai_encryption_key';
  static const _ivStorageKey = 'privacy_ai_encryption_iv';

  final FlutterSecureStorage _secureStorage;
  Encrypter? _encrypter;
  IV? _iv;
  bool _initialized = false;

  EncryptionService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  bool get isInitialized => _initialized;

  /// Initialize or load existing encryption keys.
  Future<void> initialize() async {
    if (_initialized) return;

    String? storedKey = await _secureStorage.read(key: _keyStorageKey);
    String? storedIv = await _secureStorage.read(key: _ivStorageKey);

    if (storedKey == null || storedIv == null) {
      // First run — generate new keys
      final key = Key.fromSecureRandom(32); // AES-256
      final iv = IV.fromSecureRandom(16);

      await _secureStorage.write(
        key: _keyStorageKey,
        value: base64Encode(key.bytes),
      );
      await _secureStorage.write(
        key: _ivStorageKey,
        value: base64Encode(iv.bytes),
      );

      _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      _iv = iv;
    } else {
      // Load existing keys
      final keyBytes = base64Decode(storedKey);
      final ivBytes = base64Decode(storedIv);

      _encrypter = Encrypter(AES(Key(Uint8List.fromList(keyBytes)), mode: AESMode.cbc));
      _iv = IV(Uint8List.fromList(ivBytes));
    }

    _initialized = true;
  }

  /// Encrypt a plain text string.
  String encrypt(String plainText) {
    _ensureInitialized();
    final encrypted = _encrypter!.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt an encrypted base64 string.
  String decrypt(String encryptedBase64) {
    _ensureInitialized();
    final encrypted = Encrypted.from64(encryptedBase64);
    return _encrypter!.decrypt(encrypted, iv: _iv);
  }

  /// Encrypt raw bytes.
  Uint8List encryptBytes(Uint8List data) {
    _ensureInitialized();
    final encrypted = _encrypter!.encryptBytes(data.toList(), iv: _iv);
    return encrypted.bytes;
  }

  /// Decrypt raw bytes.
  Uint8List decryptBytes(Uint8List encryptedData) {
    _ensureInitialized();
    final encrypted = Encrypted(encryptedData);
    final decrypted = _encrypter!.decrypt(encrypted, iv: _iv);
    return Uint8List.fromList(utf8.encode(decrypted));
  }

  /// Wipe all encryption keys — triggers full data loss (by design).
  Future<void> wipeKeys() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
    _encrypter = null;
    _iv = null;
    _initialized = false;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('EncryptionService not initialized. Call initialize() first.');
    }
  }
}
