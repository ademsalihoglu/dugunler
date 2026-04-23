// =====================================================
// App Constants - Uygulama Sabitleri
// =====================================================

class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'DüğünDefteri';
  static const String appVersion = '1.0.0';
  
  // Supabase Config
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Hive Box Names
  static const String usersBox = 'users';
  static const String weddingsBox = 'weddings';
  static const String giftsBox = 'gifts';
  static const String guestsBox = 'guests';
  static const String syncQueueBox = 'sync_queue';
  static const String settingsBox = 'settings';
  
  // API Endpoints
  static const String apiBaseUrl = '/api/v1';
  
  // Regions (Doğu ve Güneydoğu Anadolu)
  static const List<String> regions = [
    'Adıyaman',
    'Ağrı',
    'Batman',
    'Bingöl',
    'Bitlis',
    'Diyarbakır',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Gaziantep',
    'Hakkari',
    'Hatay',
    'Kilis',
    'Malatya',
    'Mardin',
    'Muş',
    'Siirt',
    'Şanlıurfa',
    'Şırnak',
    'Tunceli',
    'Van',
  ];
  
  // Gift Types
  static const List<String> giftTypeCodes = [
    'QUARTER_GOLD',
    'HALF_GOLD',
    'FULL_GOLD',
    'GRAM_GOLD',
    'REPUBLIC_GOLD',
    'FIVE_GOLD',
    'USD',
    'EUR',
    'TRY',
  ];
  
  // Ad Categories
  static const List<String> adCategories = [
    'kuyumcu',
    'duvar_salonu',
    'gelinlik',
    'damatlik',
    'mobilya',
    'kamera',
    'ikram',
    'müzik',
  ];
  
  // Sync Settings
  static const int maxSyncRetries = 3;
  static const int syncIntervalMinutes = 5;
  static const int offlineQueueLimit = 100;
}