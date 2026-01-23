enum Environment { testing, production }

class AppConfig {
  static const String _testingBaseUrl =
      'https://wheelboardapi.addonshareware.com/';
  static const String _productionBaseUrl = 'http://api.wheelboard.in/';

  /// Change this to switch environments
  static Environment currentEnvironment = Environment.production;

  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.testing:
        return _testingBaseUrl;
      case Environment.production:
        return _productionBaseUrl;
    }
  }
}
