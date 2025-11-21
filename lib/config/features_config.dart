/// Feature flags untuk enable/disable fitur tertentu
/// Berguna untuk development dan troubleshooting
class FeaturesConfig {
  /// Enable Google Drive auto-backup feature
  /// 
  /// Set ke `false` jika:
  /// - Belum setup OAuth Client ID
  /// - Masih dalam development/testing
  /// - Ingin fokus testing fitur lain dulu
  /// 
  /// Set ke `true` untuk production setelah OAuth setup selesai
  static const bool enableGoogleDriveBackup = true;
  
  /// Enable Excel export/import feature
  static const bool enableExcelFeatures = true;
  
  /// Enable local JSON backup/restore
  static const bool enableLocalBackup = true;
  
  /// Show debug info in UI
  static const bool showDebugInfo = false;
}









