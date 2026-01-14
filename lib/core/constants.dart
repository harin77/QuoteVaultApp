/// App-wide constants
class AppConstants {
  // App Information
  static const String appName = 'QuoteVault';
  static const String appTagline = 'Your daily dose of inspiration';

  // Categories
  static const List<String> categories = [
    'Motivation',
    'Love',
    'Success',
    'Wisdom',
    'Humor',
  ];

  // Default values
  static const String defaultAccentColor = 'purple';
  static const int defaultFontSize = 16;
  static const String defaultNotificationTime = '09:00';

  // Database table names
  static const String profilesTable = 'profiles';
  static const String quotesTable = 'quotes';
  static const String favoritesTable = 'favorites';
  static const String collectionsTable = 'collections';
  static const String collectionQuotesTable = 'collection_quotes';

  // SharedPreferences keys
  static const String darkModeKey = 'dark_mode';
  static const String accentColorKey = 'accent_color';
  static const String fontSizeKey = 'font_size';
  static const String notificationTimeKey = 'notification_time';
  static const String notificationEnabledKey = 'notification_enabled';
}
