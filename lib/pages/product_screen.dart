import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

import '../controllers/main_nav_controller.dart';
import '../core/app_config.dart';
import '../data/local/rewards_local_store.dart';
import '../data/repositories/yens_repository.dart';
import '../presentation/widgets/error_retry_view.dart';
import 'cart_page.dart';
import 'cart_provider.dart';

enum _SortMode { popularity, priceLow, priceHigh }

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _translator = GoogleTranslator();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _all = [];
  bool _loading = true;
  String? _error;
  bool _english = false;
  String _categoryId = 'all';
  _SortMode _sort = _SortMode.popularity;
  _PriceBand _priceBand = _PriceBand.any;
  int _visibleCount = 24;
  Set<String> _favoriteIds = {};

  final _categories = const [
    {'id': 'all', 'label': 'All'},
    {'id': 'fruit_tea', 'label': 'Fruit tea'},
    {'id': 'milk_tea', 'label': 'Milk tea'},
    {'id': 'shakes', 'label': 'Shakes'},
    {'id': 'soft_serve', 'label': 'Soft serve'},
    {'id': 'sundaes', 'label': 'Sundaes'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = context.read<MainNavController>();
      final c = nav.menuCategoryId;
      if (c != null && c.isNotEmpty) {
        setState(() => _categoryId = c);
      }
      nav.clearMenuCategory();
    });
    _fetch();
    RewardsLocalStore.favoriteIds().then((list) {
      if (mounted) setState(() => _favoriteIds = list.toSet());
    });
  }

  Future<void> _toggleFavorite(String productId) async {
    await RewardsLocalStore.toggleFavorite(productId);
    setState(() {
      if (_favoriteIds.contains(productId)) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels > pos.maxScrollExtent - 400) {
      final n = _filteredSorted.length;
      if (_visibleCount < n) {
        setState(() => _visibleCount = (_visibleCount + 24).clamp(0, n));
      }
    }
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

  Future<void> _fetch({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<YensRepository>();
      final raw = await repo.fetchProducts(forceRefresh: refresh);
      final list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (!mounted) return;
      setState(() {
        _all = list;
        _visibleCount = 24;
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

  int _popularityOf(Map<String, dynamic> p) {
    final v = p['popularity'] ?? p['orderCount'] ?? p['sales'];
    if (v is num) return v.toInt();
    return 0;
  }

  double _priceOf(Map<String, dynamic> p) => double.tryParse('${p['price']}') ?? 0;

  List<Map<String, dynamic>> get _filteredSorted {
    var list = List<Map<String, dynamic>>.from(_all);
    if (_categoryId != 'all') {
      list = list.where((p) => '${p['category']}' == _categoryId).toList();
    }
    switch (_priceBand) {
      case _PriceBand.under100:
        list = list.where((p) => _priceOf(p) < 100).toList();
        break;
      case _PriceBand.mid:
        list = list.where((p) {
          final x = _priceOf(p);
          return x >= 100 && x <= 200;
        }).toList();
        break;
      case _PriceBand.over200:
        list = list.where((p) => _priceOf(p) > 200).toList();
        break;
      case _PriceBand.any:
        break;
    }
    switch (_sort) {
      case _SortMode.popularity:
        list.sort((a, b) => _popularityOf(b).compareTo(_popularityOf(a)));
        break;
      case _SortMode.priceLow:
        list.sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));
        break;
      case _SortMode.priceHigh:
        list.sort((a, b) => _priceOf(b).compareTo(_priceOf(a)));
        break;
    }
    return list;
  }

  void _addToCart(CartProvider cart, Map<String, dynamic> product) {
    final price = _priceOf(product);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (_loading) {
          return Scaffold(
            backgroundColor: const Color(0xffF7F7F7),
            body: SafeArea(child: _loader()),
          );
        }
        if (_error != null) {
          return Scaffold(
            backgroundColor: const Color(0xffF7F7F7),
            body: SafeArea(child: ErrorRetryView(message: 'Could not load the menu.', onRetry: () => _fetch(refresh: true))),
          );
        }

        final filtered = _filteredSorted;
        final slice = filtered.take(_visibleCount).toList();
        final cross = MediaQuery.sizeOf(context).width > 900
            ? 4
            : MediaQuery.sizeOf(context).width > 600
                ? 3
                : 2;

        return Scaffold(
          backgroundColor: const Color(0xffF7F7F7),
          body: SafeArea(
            child: Column(
              children: [
                _header(cart),
                _filterChips(),
                _sortRow(),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.54,
                    ),
                    itemCount: slice.length,
                    itemBuilder: (context, index) => _card(slice[index], cart),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: cart.itemCount > 0
              ? GestureDetector(
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const CartPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5C021),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
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
                )
              : null,
        );
      },
    );
  }

  Widget _loader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 6.28),
            duration: const Duration(seconds: 2),
            builder: (_, value, __) => Transform.rotate(angle: value, child: const Icon(Icons.icecream, size: 64, color: Colors.orange)),
          ),
          const SizedBox(height: 16),
          Text('Loading menu…', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _header(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xffF6C744),
      child: Row(
        children: [
          Image.asset('assets/logo.jpg', height: 28),
          const SizedBox(width: 8),
          Text(AppConfig.appDisplayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<YensRepository>().invalidateProductsCache();
              _fetch(refresh: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 46,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        scrollDirection: Axis.horizontal,
        children: [
          ..._categories.map((c) {
            final id = c['id']!;
            final sel = _categoryId == id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(c['label']!),
                selected: sel,
                onSelected: (_) {
                  setState(() {
                    _categoryId = id;
                    _visibleCount = 24;
                  });
                },
                selectedColor: const Color(0xffF5C021),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: sel ? Colors.white : Colors.black87,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            );
          }),
          FilterChip(
            label: const Text('< ฿100'),
            selected: _priceBand == _PriceBand.under100,
            onSelected: (_) => setState(() {
              _priceBand = _priceBand == _PriceBand.under100 ? _PriceBand.any : _PriceBand.under100;
              _visibleCount = 24;
            }),
            selectedColor: Colors.teal.shade100,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('฿100–200'),
            selected: _priceBand == _PriceBand.mid,
            onSelected: (_) => setState(() {
              _priceBand = _priceBand == _PriceBand.mid ? _PriceBand.any : _PriceBand.mid;
              _visibleCount = 24;
            }),
            selectedColor: Colors.teal.shade100,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('> ฿200'),
            selected: _priceBand == _PriceBand.over200,
            onSelected: (_) => setState(() {
              _priceBand = _priceBand == _PriceBand.over200 ? _PriceBand.any : _PriceBand.over200;
              _visibleCount = 24;
            }),
            selectedColor: Colors.teal.shade100,
          ),
        ],
      ),
    );
  }

  Widget _sortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: SegmentedButton<_SortMode>(
              segments: const [
                ButtonSegment(value: _SortMode.popularity, label: Text('Popular')),
                ButtonSegment(value: _SortMode.priceLow, label: Text('Price ↑')),
                ButtonSegment(value: _SortMode.priceHigh, label: Text('Price ↓')),
              ],
              selected: {_sort},
              onSelectionChanged: (s) {
                setState(() {
                  _sort = s.first;
                  _visibleCount = 24;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> product, CartProvider cart) {
    final id = '${product['id']}';
    final imageUrl = AppConfig.mediaUrl(product['imageUrl']?.toString());
    final price = _priceOf(product);
    final inCart = cart.isInCart(id);
    final qty = cart.quantityOf(id);
    final pop = _popularityOf(product);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0.5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _sheet(product, cart),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: imageUrl.isEmpty
                          ? Container(color: Colors.grey.shade100)
                          : CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.white70,
                        shape: const CircleBorder(),
                        child: IconButton(
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: Icon(
                            _favoriteIds.contains(id) ? Icons.favorite : Icons.favorite_border,
                            color: _favoriteIds.contains(id) ? Colors.pink : Colors.black54,
                          ),
                          onPressed: () => _toggleFavorite(id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _tr('${product['name']}'),
                builder: (_, s) => Text(
                  s.data ?? '${product['name']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              if (pop > 0)
                Text('Popular: $pop', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              Text('฿${price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (inCart)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _qtyBtn(Icons.remove, () => cart.removeItem(id)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _qtyBtn(Icons.add, () => _addToCart(cart, product), highlight: true),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _addToCart(cart, product),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffF6C744),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Add to cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, {bool highlight = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: highlight ? const Color(0xffF5C021) : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: highlight ? Colors.white : Colors.black87),
      ),
    );
  }

  void _sheet(Map<String, dynamic> product, CartProvider cart) {
    final imageUrl = AppConfig.mediaUrl(product['imageUrl']?.toString());
    final price = _priceOf(product);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final id = '${product['id']}';
            final inCart = cart.isInCart(id);
            final qty = cart.quantityOf(id);

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: imageUrl.isEmpty
                            ? Container(color: Colors.grey.shade100)
                            : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<String>(
                      future: _tr('${product['name']}'),
                      builder: (_, s) => Text(
                        s.data ?? '${product['name']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '฿${price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (inCart)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _qtyBtn(Icons.remove, () {
                            cart.removeItem(id);
                            setModal(() {});
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                          _qtyBtn(Icons.add, () {
                            _addToCart(cart, product);
                            setModal(() {});
                          }, highlight: true),
                        ],
                      )
                    else
                      FilledButton(
                        onPressed: () {
                          _addToCart(cart, product);
                          setModal(() {});
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xffF6C744),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Add to cart'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

enum _PriceBand { any, under100, mid, over200 }
