class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Privacy AI';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your private AI companion';

  // Database
  static const String mainBoxName = 'privacy_ai_main';
  static const String patternsBoxName = 'privacy_ai_patterns';
  static const String settingsBoxName = 'privacy_ai_settings';
  static const String eventsBoxName = 'privacy_ai_events';

  // Data Limits (from planning doc)
  static const int maxRawEvents = 10000;
  static const int maxDataRetentionDays = 90;
  static const int timestampQuantisationMinutes = 15;

  // ML Thresholds
  static const double suggestionMinConfidence = 0.60;
  static const double gentleHintThreshold = 0.60;
  static const double clearSuggestionThreshold = 0.75;
  static const double proactiveAlertThreshold = 0.90;

  // Addiction Risk Thresholds
  static const int riskNormalMax = 30;
  static const int riskWatchMax = 60;
  static const int riskInterventionMax = 80;
  static const int riskRigorousTrigger = 81;
  static const int llmWakeTrigger = 75;

  // Battery Tiers
  static const Duration tier1Interval = Duration(minutes: 15);
  static const Duration tier2Interval = Duration(hours: 2);
  static const Duration nightProcessingStart = Duration(hours: 0); // midnight

  // Rigorous Mode
  static const Duration maxLockDuration = Duration(hours: 8);

  // Pattern Detection Thresholds
  static const int weakPatternCount = 3;
  static const int mediumPatternCount = 7;
  static const int strongPatternCount = 14;
  static const int confirmedHabitCount = 21;

  // Rapid Reopen Detection
  static const Duration rapidReopenWindow = Duration(minutes: 2);
  static const int rapidReopenCompulsiveCount = 5;

  // LLM
  static const Duration llmIdleTimeout = Duration(minutes: 5);

  // Onboarding
  static const int totalOnboardingSections = 5;
}
