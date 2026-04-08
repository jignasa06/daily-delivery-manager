enum Environment { dev, prod }

class AppConfig {
  final Environment environment;
  final String appName;
  final String apiBaseUrl;

  AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
  });

  static late AppConfig _instance;

  static void initialize(AppConfig config) {
    _instance = config;
  }

  static AppConfig get instance => _instance;

  bool get isProduction => environment == Environment.prod;
}
