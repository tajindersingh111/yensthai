
/// Central configuration for API and app branding.
class AppConfig {
  AppConfig._();

  static const String apiBase = 'https://application.yensthai.com';
  static const String appDisplayName = 'Yens';

  static Duration get requestTimeout => const Duration(seconds: 20);
  static int get maxRetries => 2;
  static Duration get retryDelay => const Duration(milliseconds: 400);

  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    String normalizedPath = path;
    if (normalizedPath.contains('data/uploads/')) {
      normalizedPath = normalizedPath.replaceFirst(RegExp(r'/?data/uploads/'), '/uploads/');
    }
    if (normalizedPath.startsWith('http')) return Uri.encodeFull(normalizedPath);
    return Uri.encodeFull('$apiBase$normalizedPath');
  }
}
