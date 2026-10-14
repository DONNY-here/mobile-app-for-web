import 'package:flutter/foundation.dart';

// ======================================================
// TMC EVENTEASE - API CONFIGURATION
// ======================================================

class ApiConfig {
  // Release builds must never use demo authentication.
  static const bool useRealApi =
      kReleaseMode ||
      bool.fromEnvironment('EVENTEASE_USE_REAL_API', defaultValue: false);

  // Actual server address will be supplied at launch.
  static const String baseUrl = String.fromEnvironment(
    'EVENTEASE_API_BASE_URL',
    defaultValue: '',
  );

  // Confirm endpoint with backend developer.
  static const String loginPath = String.fromEnvironment(
    'EVENTEASE_LOGIN_PATH',
    defaultValue: '/api/auth/login',
  );

  static Uri? get loginUri {
    if (baseUrl.trim().isEmpty) {
      return null;
    }

    final base = Uri.tryParse(baseUrl.trim());

    if (base == null ||
        base.scheme != 'https' ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        (base.path.isNotEmpty && base.path != '/')) {
      throw const FormatException('API base URL must be a valid HTTPS origin.');
    }

    if (!loginPath.startsWith('/') ||
        loginPath.startsWith('//') ||
        loginPath.contains('?') ||
        loginPath.contains('#')) {
      throw const FormatException('Invalid login API path.');
    }

    return base.replace(path: loginPath);
  }
}
