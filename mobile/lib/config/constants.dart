class AppConstants {
  static const String appName = 'AASHA';
  static const String initialRoute = '/';

  // API — override with --dart-define=API_URL=https://api.aasha.com for production
  static const String apiBaseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');
}
