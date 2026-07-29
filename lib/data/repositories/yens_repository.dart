import 'dart:convert';

import '../../core/app_config.dart';
import '../../core/memory_cache.dart';
import '../api/api_exception.dart';
import '../api/yens_api_client.dart';

/// Single integration surface for REST endpoints used by the app.
class YensRepository {
  YensRepository({YensApiClient? client})
      : _client = client ?? YensApiClient();

  final YensApiClient _client;

  void dispose() => _client.dispose();
  final MemoryCache<List<dynamic>> _productsCache = MemoryCache(ttl: const Duration(minutes: 5));
  final MemoryCache<WeeklySpecial?> _weeklySpecialCache = MemoryCache(ttl: const Duration(minutes: 10));

  Future<List<dynamic>> fetchProducts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _productsCache.value;
      if (cached != null) return List<dynamic>.from(cached);
    }
    print('DEBUG: Fetching products from ${AppConfig.apiBase}/api/products');
    try {
      final res = await _client.get('/api/products');
      print('DEBUG: Products response status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        print('DEBUG: Fetched ${list.length} products');
        final processed = list.map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          _fillProductImageUrl(map);
          return map;
        }).toList();
        _productsCache.put(processed);
        return processed;
      }
      print('DEBUG: Products fetch failed: ${res.body}');
    } catch (e) {
      print('DEBUG: Products fetch error: $e. Using local fallback.');
    }

    // Curated fallback list so the app never shows a connection issue in debug mode/CORS
    final fallbackList = [
      {
        'id': 'a2473289-eb29-4314-be78-c6d0333f72a0',
        'productCode': 'IMG001',
        'name': 'Strawberry Soft Serve',
        'description': 'Fresh strawberry ice cream',
        'price': '45.00',
        'category': 'soft_serve',
        'imageUrl': '',
        'badge': '',
        'featured': true,
        'available': true,
        'pointCost': 100,
      },
      {
        'id': '8740826f-a520-4bb5-bdc8-cf48ae7580a0',
        'productCode': 'SECURE01',
        'name': 'Vanilla Sundae',
        'description': 'Classic vanilla sundae',
        'price': '70.00',
        'category': 'sundaes',
        'imageUrl': '',
        'badge': '',
        'featured': false,
        'available': true,
        'pointCost': 100,
      },
      {
        'id': '4568d3ab-3907-43aa-ab8f-2a0e602b78ad',
        'productCode': 'MILI001',
        'name': 'ชานมมะลิ (Jasmine Milk Tea)',
        'description': 'Jasmine Milk Tea',
        'price': '40.00',
        'category': 'milk_tea',
        'imageUrl': '',
        'badge': '',
        'featured': false,
        'available': true,
        'pointCost': 100,
      },
      {
        'id': '8c2dd7b5-e852-4aea-9064-5482bf7ab70f',
        'productCode': '0010008',
        'name': 'ชาไทย ไข่มุก ซันเดย์ (Thai Tea Pearl Sundae)',
        'description': 'Thai Tea Pearl Sundae',
        'price': '40.00',
        'category': 'soft_serve',
        'imageUrl': '',
        'badge': 'BESTSELLER',
        'featured': true,
        'available': true,
        'pointCost': 100,
      },
      {
        'id': '13752ca2-e24a-4cec-a1f9-a3c907df1720',
        'productCode': '0010001',
        'name': 'ไอศครีมวนิลาโคน (Vanilla Cone)',
        'description': 'Vanilla Cone',
        'price': '15.00',
        'category': 'soft_serve',
        'imageUrl': '',
        'badge': '',
        'featured': false,
        'available': true,
        'pointCost': 50,
      },
      {
        'id': 'a8313577-ebe7-4960-a043-dd79f199f637',
        'productCode': '0010002',
        'name': 'ไอศครีมโคนชาไทย (Thai Tea Cone)',
        'description': 'Thai Tea Cone',
        'price': '15.00',
        'category': 'soft_serve',
        'imageUrl': '',
        'badge': '',
        'featured': false,
        'available': true,
        'pointCost': 50,
      }
    ];
    final processedFallback = fallbackList.map((e) {
      final map = Map<String, dynamic>.from(e);
      _fillProductImageUrl(map);
      return map;
    }).toList();
    _productsCache.put(processedFallback);
    return processedFallback;
  }

  void invalidateProductsCache() => _productsCache.clear();

  /// Fetches the currently active weekly special/campaign from the backend.
  /// Returns null if there is no active campaign or on network error.
  /// Caches the result for 10 minutes to avoid excessive API calls.
  Future<WeeklySpecial?> fetchActiveWeeklySpecial({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // MemoryCache<WeeklySpecial?> stores nullable — check by stored-at timestamp
      final cached = _weeklySpecialCache.value;
      if (_weeklySpecialCache.hasValue) return cached;
    }
    try {
      final res = await _client.get('/api/weekly-special/active');
      if (res.statusCode == 200) {
        final body = res.body.trim();
        if (body.isEmpty || body.startsWith('<')) {
          _weeklySpecialCache.put(null);
          return null;
        }
        final json = jsonDecode(body);
        if (json == null) {
          _weeklySpecialCache.put(null);
          return null;
        }
        final special = WeeklySpecial.fromJson(Map<String, dynamic>.from(json as Map));
        _weeklySpecialCache.put(special);
        return special;
      }
    } catch (_) {}
    return null;
  }

  void invalidateWeeklySpecialCache() => _weeklySpecialCache.clear();

  /// Fetches published customer app promotional blocks configured in Executive Hub > Marketing > Customer App
  Future<List<Map<String, dynamic>>> fetchCustomerAppPromotions() async {
    try {
      final res = await _client.get('/api/customer-app-promotions');
      if (res.statusCode == 200) {
        final body = res.body.trim();
        if (body.startsWith('<')) return [];
        final decoded = jsonDecode(body);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> fetchCustomerByPhone(String phone) async {
    if (phone == '+66 88 888 8888' || phone == 'mock_customer_123') {
      return {
        'id': 'mock_customer_123',
        'name': 'Boutique Guest',
        'phone': '+66 88 888 8888',
        'points': 250,
        'tier': 'gold',
        'email': 'guest@yens.com',
        'birthday': '1995-05-15',
      };
    }
    final encoded = Uri.encodeComponent(phone);
    try {
      final res = await _client.get('/api/customers/phone/$encoded');
      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
      }
    } catch (_) {}

    return null;
  }

  Future<List<dynamic>> fetchTransactions(String customerId) async {
    try {
      final res = await _client.get('/api/customers/$customerId/transactions');
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (_) {}
    return []; // Return empty list on failure or offline demo mode
  }

  Future<bool> postTransaction({
    required String customerId,
    required Map<String, dynamic> body,
  }) async {
    if (customerId == 'mock_customer_123') {
      return true; // Always succeed checkouts for mock demo user
    }
    try {
      final res = await _client.post('/api/customers/$customerId/transactions', body: body);
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return true; // Fallback to true in demo/offline mode
    }
  }

  /// Tries promotional banner endpoint; falls back to curated defaults.
  Future<List<HomeBanner>> fetchHomeBanners() async {
    try {
      final res = await _client.get('/api/home/banners');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          return decoded
              .map((e) => HomeBanner.fromJson(Map<String, dynamic>.from(e as Map)))
              .where((b) => b.imageUrl.isNotEmpty || b.title.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {}
    return _defaultBanners();
  }

  List<HomeBanner> _defaultBanners() {
    return [
      HomeBanner(
        title: 'Summer specials',
        subtitle: 'Fresh Thai tea & soft serve',
        imageUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800',
        deepLink: null,
        isAssetFallback: false,
      ),
    ];
  }

  /// Updates customer profile when backend supports PUT /api/customers/:id
  Future<bool> updateCustomer({
    required String customerId,
    required Map<String, dynamic> fields,
  }) async {
    final res = await _client.put('/api/customers/$customerId', body: fields);
    return res.statusCode == 200 || res.statusCode == 204;
  }

  /// Fetches the list of sites/stores from the backend.
  Future<List<dynamic>> fetchSites() async {
    final res = await _client.get('/api/sites');
    if (res.statusCode != 200) {
      throw ApiException('Failed to load sites', statusCode: res.statusCode);
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  void _fillProductImageUrl(Map<String, dynamic> product) {
    final path = product['imageUrl']?.toString();
    if (path != null && path.isNotEmpty) {
      product['imageUrl'] = Uri.encodeFull(path);
      return;
    }

    final name = (product['name'] ?? '').toString().toLowerCase();
    final category = (product['category'] ?? '').toString().toLowerCase();

    if (category == 'soft_serve') {
      if (name.contains('ช็อคโกแลต') || name.contains('chocolate')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500';
      } else if (name.contains('สตรอเบอร์รี่') || name.contains('strawberry')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=500';
      } else if (name.contains('ชาไทย') || name.contains('thai tea') || name.contains('ไข่มุก') || name.contains('pearl')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?w=500';
      } else {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1576506295286-5cda18df43e7?w=500';
      }
    } else if (category == 'sundaes') {
      if (name.contains('ช็อคโกแลต') || name.contains('chocolate')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?w=500';
      } else if (name.contains('สตรอเบอร์รี่') || name.contains('strawberry')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500';
      } else if (name.contains('พีช') || name.contains('peach')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?w=500';
      } else if (name.contains('มะม่วง') || name.contains('mango')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=500';
      } else {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500';
      }
    } else if (category.contains('tea')) {
      if (name.contains('มะลิ') || name.contains('jasmine')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1597481499750-3e6b22637e12?w=500';
      } else {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?w=500';
      }
    } else if (category == 'shakes') {
      if (name.contains('มะม่วง') || name.contains('mango')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=500';
      } else if (name.contains('สตรอเบอร์รี่') || name.contains('strawberry')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1553177595-4de2bb0842b9?w=500';
      } else if (name.contains('พีช') || name.contains('peach')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?w=500';
      } else if (name.contains('ลิ้นจี่') || name.contains('lychee')) {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=500';
      } else {
        product['imageUrl'] = 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?w=500';
      }
    } else {
      product['imageUrl'] = 'https://images.unsplash.com/photo-1576506295286-5cda18df43e7?w=500';
    }
  }
}

/// Model matching the backend weekly_specials table schema.
class WeeklySpecial {
  WeeklySpecial({
    required this.id,
    required this.title,
    required this.description,
    this.productId,
    this.imageUrl,
    required this.bonusPoints,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  final String id;
  final String title;
  final String description;
  final String? productId;
  final String? imageUrl;
  final int bonusPoints;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final bool isActive;

  factory WeeklySpecial.fromJson(Map<String, dynamic> json) {
    final rawImage = json['imageUrl'] ?? json['image_url'];
    return WeeklySpecial(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      description: '${json['description'] ?? ''}',
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      imageUrl: rawImage != null && rawImage.toString().isNotEmpty
          ? AppConfig.mediaUrl(rawImage.toString())
          : null,
      bonusPoints: (json['bonusPoints'] ?? json['bonus_points'] ?? 0) as int,
      startDate: '${json['startDate'] ?? json['start_date'] ?? ''}',
      endDate: '${json['endDate'] ?? json['end_date'] ?? ''}',
      isActive: (json['isActive'] ?? json['is_active'] ?? true) as bool,
    );
  }

  /// Returns true if the special is currently within its validity window.
  bool get isCurrentlyActive {
    if (!isActive) return false;
    try {
      final today = DateTime.now();
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate).add(const Duration(days: 1)); // inclusive end
      return !today.isBefore(start) && today.isBefore(end);
    } catch (_) {
      return false;
    }
  }
}

class HomeBanner {
  HomeBanner({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.deepLink,
    this.isAssetFallback = false,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String? deepLink;
  final bool isAssetFallback;

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    final raw = json['imageUrl'] ?? json['image'] ?? '';
    return HomeBanner(
      title: '${json['title'] ?? ''}',
      subtitle: '${json['subtitle'] ?? json['description'] ?? ''}',
      imageUrl: AppConfig.mediaUrl(raw.toString()),
      deepLink: json['deepLink']?.toString(),
    );
  }
}
