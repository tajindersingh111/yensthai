import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import '../controllers/main_nav_controller.dart';
import '../core/app_config.dart';
import '../core/time_offers.dart';
import '../data/local/rewards_local_store.dart';
import '../data/repositories/yens_repository.dart';
import '../presentation/widgets/error_retry_view.dart';
import 'cart_page.dart';
import 'cart_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _translator = GoogleTranslator();
  List<dynamic> _products = [];
  List<HomeBanner> _banners = [];
  Map<String, dynamic> _customer = {};
  String _loggedInPhone = '';
  bool _loading = true;
  String? _error;
  bool _english = false;
  int _bannerIndex = 0;
  int _streakDays = 0;

  final _categories = const [
    {'id': 'all', 'label': 'All', 'icon': Icons.grid_view_rounded},
    {'id': 'fruit_tea', 'label': 'Fruit tea', 'icon': Icons.local_bar},
    {'id': 'milk_tea', 'label': 'Milk tea', 'icon': Icons.coffee},
    {'id': 'shakes', 'label': 'Shakes', 'icon': Icons.blender},
    {'id': 'soft_serve', 'label': 'Soft serve', 'icon': Icons.icecream},
    {'id': 'sundaes', 'label': 'Sundaes', 'icon': Icons.icecream_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<String> _tr(String text) async {
    if (!_english) return text;
    try {
      final t = await _translator.translate(text, from: 'th', to: 'en');
      return t.text;
    } catch (_) {
      return text;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = context.read<YensRepository>();
    final prefs = await SharedPreferences.getInstance();
    _loggedInPhone = prefs.getString('customer_phone') ?? '';

    try {
      final streak = await RewardsLocalStore.recordDailyVisit();
      final banners = await repo.fetchHomeBanners();
      final products = await repo.fetchProducts();
      Map<String, dynamic> customer = {};
      if (_loggedInPhone.isNotEmpty) {
        final c = await repo.fetchCustomerByPhone(_loggedInPhone);
        if (c != null) customer = c;
      }
      if (!mounted) return;
      setState(() {
        _streakDays = streak;
        _banners = banners;
        _products = products;
        _customer = customer;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String get _qrPayload {
    final id = _customer['id'];
    if (id != null && '$id'.isNotEmpty) return '$id';
    if (_loggedInPhone.isNotEmpty) return _loggedInPhone;
    return 'yens_guest';
  }

  int get _points => (_customer['points'] as num?)?.toInt() ?? 0;

  int get _pointsUntilNext {
    final next = ((_points ~/ 100) + 1) * 100;
    return next - _points;
  }

  List<dynamic> get _previewProducts => _products.take(8).toList();

  void _openMenuWithCategory(String categoryId) {
    context.read<MainNavController>().goToTab(1, menuCategoryId: categoryId == 'all' ? null : categoryId);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xffF5C021))));
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xffF5F1EA),
        body: ErrorRetryView(message: 'We could not load your home feed.', onRetry: _load),
      );
    }

    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F1EA),
          body: SafeArea(
            child: RefreshIndicator(
              color: const Color(0xffF5C021),
              onRefresh: () => _load(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _header(cart)),
                  SliverToBoxAdapter(child: _bannerCarousel()),
                  SliverToBoxAdapter(child: _timeOffersSection()),
                  SliverToBoxAdapter(child: _pointsCard()),
                  SliverToBoxAdapter(child: _qrCard(context)),
                  SliverToBoxAdapter(child: _categoryRow()),
                  SliverToBoxAdapter(child: _sectionTitle('Menu preview')),
                  SliverToBoxAdapter(child: _previewList(cart)),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
          floatingActionButton: cart.itemCount > 0
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(builder: (_) => const CartPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5C021),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            '${cart.itemCount} · ฿${cart.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _header(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xffF6C744),
      child: Row(
        children: [
          Image.asset('assets/logo.jpg', height: 30),
          const SizedBox(width: 10),
          Text(
            AppConfig.appDisplayName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _english = !_english),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text(_english ? 'EN' : 'TH', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (_) => const CartPage()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.shopping_cart_outlined, size: 22),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerCarousel() {
    final h = 200.0;
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: h,
          child: PageView.builder(
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, i) {
              final b = _banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (b.isAssetFallback || b.imageUrl.isEmpty)
                        Image.asset('assets/yens.png', fit: BoxFit.cover)
                      else
                        CachedNetworkImage(imageUrl: b.imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (b.subtitle.isNotEmpty)
                              Text(
                                b.subtitle,
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _bannerIndex == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _bannerIndex == i ? const Color(0xffF5C021) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeOffersSection() {
    final offers = offersForNow();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Time-based offers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (_streakDays > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEF3D0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Streak $_streakDays d',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xffBA7517)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: offers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final o = offers[i];
              return Container(
                width: 260,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: o.accent.withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(o.icon, color: o.accent.darken()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: o.accent.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              o.badge,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: o.accent.darken()),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(o.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            o.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _pointsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(color: Color(0xffFEF3D0), shape: BoxShape.circle),
              child: const Icon(Icons.stars, color: Color(0xffBA7517)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_pointsUntilNext pts to next reward',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_points pts · keep your streak for bonus multipliers',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
          ),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: QrImageView(
                    data: _qrPayload,
                    version: QrVersions.auto,
                    size: 80,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_customer['name'] ?? 'Member'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_customer['phone'] ?? _loggedInPhone}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.touch_app, size: 14, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Open profile & order history',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryRow() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = _categories[i];
          return GestureDetector(
            onTap: () => _openMenuWithCategory(c['id']! as String),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                  ),
                  child: Icon(c['icon'] as IconData, color: const Color(0xffF5C021)),
                ),
                const SizedBox(height: 6),
                Text(
                  c['label']! as String,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(
            onPressed: () => context.read<MainNavController>().goToTab(1),
            child: const Text('Full menu'),
          ),
        ],
      ),
    );
  }

  Widget _previewList(CartProvider cart) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _previewProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = _previewProducts[index] as Map<String, dynamic>;
        final imageUrl = AppConfig.mediaUrl(product['imageUrl']?.toString());
        final price = double.tryParse('${product['price']}') ?? 0;
        final rewardPts = (product['rewardPoints'] as num?)?.toInt() ?? price.round();
        final id = '${product['id']}';
        final inCart = cart.isInCart(id);
        final qty = cart.quantityOf(id);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: imageUrl.isEmpty
                      ? Container(color: Colors.grey.shade200)
                      : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: _tr('${product['name']}'),
                      builder: (_, s) => Text(
                        s.data ?? '${product['name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '฿${price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xffF5C021), fontWeight: FontWeight.bold),
                    ),
                    Text('+$rewardPts pts', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (inCart)
                Row(
                  children: [
                    _roundIcon(Icons.remove, () => cart.removeItem(id), Colors.grey.shade200, Colors.black),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _roundIcon(Icons.add, () => _add(cart, product), const Color(0xffF5C021), Colors.white),
                  ],
                )
              else
                TextButton(
                  onPressed: () => _add(cart, product),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffF5C021),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Add'),
                ),
            ],
          ),
        );
      },
    );
  }

  void _add(CartProvider cart, Map<String, dynamic> product) {
    final price = double.tryParse('${product['price']}') ?? 0;
    cart.addItem(
      productId: '${product['id']}',
      name: '${product['name']}',
      imageUrl: product['imageUrl']?.toString() ?? '',
      price: price,
      rewardPoints: (product['rewardPoints'] as num?)?.toInt() ?? price.round(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xffF5C021),
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap, Color bg, Color fg) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: fg),
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final l = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }
}
