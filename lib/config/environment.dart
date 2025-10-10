class Environment {
  // Get the environment from compile-time constants
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'emulator');
  
  // Available environments
  static const String localhost = 'localhost';
  static const String emulator = 'emulator';
  static const String production = 'production';
  
  // Base URLs for each environment
  static const Map<String, String> _baseUrls = {
    'localhost': 'http://localhost:3100/api',
    'emulator': 'http://10.0.2.2:3100/api',
    'production': 'https://your-production-url.com/api',
  };
  
  // Get current environment
  static String get currentEnvironment => _env;
  
  // Get base URL for current environment
  static String get baseUrl => _baseUrls[_env] ?? _baseUrls['emulator']!;
  
  // Check if running in specific environment
  static bool get isLocalhost => _env == localhost;
  static bool get isEmulator => _env == emulator;
  static bool get isProduction => _env == production;
}

