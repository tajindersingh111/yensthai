import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists customer identity and access tokens securely for API authorization.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const String keyLoggedIn = 'is_logged_in';
  static const String keyCustomerId = 'customer_id';
  static const String keyCustomerName = 'customer_name';
  static const String keyCustomerPhone = 'customer_phone';
  static const String keyIdToken = 'auth_id_token';
  static const String keyCustomerToken = 'customer_jwt_token'; // customer app Bearer token

  final _secureStorage = const FlutterSecureStorage();

  Future<void> persistCustomerSession({
    required Map<String, dynamic> customerData,
    String? customToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoggedIn, true);
    await prefs.setString(keyCustomerId, '${customerData['id'] ?? ''}');
    await prefs.setString(keyCustomerName, '${customerData['name'] ?? ''}');
    await prefs.setString(keyCustomerPhone, '${customerData['phone'] ?? ''}');

    // Store customer JWT for Bearer-token auth on subsequent API calls
    final token = customToken ?? customerData['customerToken']?.toString();
    if (token != null && token.isNotEmpty) {
      await _secureStorage.write(key: keyCustomerToken, value: token);
    }

    if (customToken != null && customToken.isNotEmpty) {
      await _secureStorage.write(key: keyIdToken, value: customToken);
    }
  }

  /// Returns the saved customer JWT token for Bearer-auth on API requests.
  Future<String?> bearerToken() async {
    // Prefer the customer JWT (set during OTP login)
    final customerJwt = await _secureStorage.read(key: keyCustomerToken);
    if (customerJwt != null && customerJwt.isNotEmpty) return customerJwt;
    // Fall back to any legacy idToken (staff login path)
    return await _secureStorage.read(key: keyIdToken);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLoggedIn) ?? false;
  }

  /// Clears auth session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyLoggedIn);
    await prefs.remove(keyCustomerId);
    await prefs.remove(keyCustomerName);
    await prefs.remove(keyCustomerPhone);
    await _secureStorage.delete(key: keyIdToken);
    await _secureStorage.delete(key: keyCustomerToken);
  }
}
