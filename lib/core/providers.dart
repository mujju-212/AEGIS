import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacy_ai/core/services/encryption/encryption_service.dart';
import 'package:privacy_ai/core/services/database/database_service.dart';
import 'package:privacy_ai/core/constants/settings_keys.dart';

/// Global encryption service provider.
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// Global database service provider.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final encryption = ref.watch(encryptionServiceProvider);
  return DatabaseService(encryption);
});

/// Tracks whether the app has completed initial setup.
final isOnboardingCompleteProvider = StateProvider<bool>((ref) {
  final db = ref.watch(databaseServiceProvider);
  if (!db.isInitialized) return false;
  return db.readSetting<bool>(SettingsKeys.onboardingComplete) ?? false;
});

/// Current bottom nav index.
final currentNavIndexProvider = StateProvider<int>((ref) => 0);
