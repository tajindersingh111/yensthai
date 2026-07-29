import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yensss/controllers/main_nav_controller.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/data/local/rewards_local_store.dart';
import 'package:yensss/data/repositories/yens_repository.dart';
import 'package:yensss/pages/cart_page.dart';
import 'package:yensss/pages/cart_provider.dart';
import 'package:yensss/pages/product/widgets/product_search_bar.dart';
import 'package:yensss/presentation/widgets/error_retry_view.dart';
import 'package:yensss/presentation/widgets/menu_category_ribbon.dart';
import 'package:yensss/presentation/widgets/product_menu_card.dart';
import 'package:yensss/widgets/yens_app_drawer.dart';
import 'package:yensss/widgets/yens_main_header.dart';

enum _SortMode { popularity, priceLow, priceHigh }
enum _PriceBand { any, under100, mid, over200 }

class ProductScreen extends StatefulWidget {
  final bool isPushed;
  const ProductScreen({super.key, this.isPushed = false});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _all = [];
  bool _loading = true;
  String? _error;
  String _categoryId = 'all';
  _SortMode _sort = _SortMode.popularity;
  _PriceBand _priceBand = _PriceBand.any;
  int _visibleCount = 24;
  Set<String> _favoriteIds = {};

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

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
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

  double _priceOf(Map<String, dynamic> p) => double.tryParse('${p['price']}') ?? 0;
  int _popularityOf(Map<String, dynamic> p) {
    final v = p['popularity'] ?? p['orderCount'] ?? p['sales'];
    return v is num ? v.toInt() : 0;
  }

  List<Map<String, dynamic>> get _dynamicCategories {
    final Set<String> set = {};
    final List<Map<String, dynamic>> cats = [
      {'id': 'all', 'name': 'Best Sellers', 'icon': Icons.star_rounded}
    ];
    for (var p in _all) {
      final c = p['category']?.toString();
      if (c != null && c.isNotEmpty && !set.contains(c)) {
        set.add(c);
        cats.add({
          'id': c,
          'name': _formatCatName(c),
          'icon': _getCatIcon(c),
        });
      }
    }
    return cats;
  }

  String _formatCatName(String cat) {
    return cat.split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join(' ');
  }

  IconData _getCatIcon(String cat) {
    cat = cat.toLowerCase();
    if (cat.contains('tea')) return Icons.local_drink_outlined;
    if (cat.contains('milk')) return Icons.coffee_outlined;
    if (cat.contains('shake')) return Icons.blender_outlined;
    if (cat.contains('ice')) return Icons.icecream_outlined;
    if (cat.contains('sundae')) return Icons.bakery_dining_outlined;
    return Icons.star_border_rounded;
  }

  List<Map<String, dynamic>> get _filteredSorted {
    var list = List<Map<String, dynamic>>.from(_all);
    
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) => '${p['name']}'.toLowerCase().contains(q)).toList();
    }

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
        backgroundColor: YensTheme.navy,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (_loading) return const Scaffold(backgroundColor: YensTheme.cream, body: Center(child: CircularProgressIndicator(color: YensTheme.navy)));
        if (_error != null) {
          return Scaffold(
            backgroundColor: YensTheme.cream, 
            body: ErrorRetryView(
              message: 'Unable to load menu. Check your connection.',
              onRetry: () => _fetch(refresh: true),
            ),
          );
        }

        final filtered = _filteredSorted;
        final slice = filtered.take(_visibleCount).toList();
        final width = MediaQuery.sizeOf(context).width;
        final crossCount = width > 900 ? 4 : (width > 600 ? 3 : 2);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: YensTheme.cream,
          drawer: const YensAppDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                widget.isPushed
                    ? YensMainHeader.pushed(
                        title: 'Yens Menu',
                        onBack: () => Navigator.pop(context),
                      )
                    : YensMainHeader.main(
                        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                ProductSearchBar(
                  controller: _searchController,
                  onChanged: () => setState(() => _visibleCount = 24),
                  onFilterTap: _showFilterSheet,
                ),
                const SizedBox(height: 12),
                MenuCategoryRibbon(
                  categories: _dynamicCategories,
                  selectedCategoryId: _categoryId,
                  onCategoryTap: (id) => setState(() {
                    _categoryId = id;
                    _visibleCount = 24;
                  }),
                  showHeader: false, // Cleaner for the product list
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: slice.length,
                    itemBuilder: (context, index) {
                      final p = slice[index];
                      return ProductMenuCard(
                        product: p,
                        isFavorite: _favoriteIds.contains('${p['id']}'),
                        onFavoriteToggle: () => _toggleFavorite('${p['id']}'),
                        onAdd: () => _addToCart(cart, p),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: cart.itemCount > 0 ? _cartFab(cart) : null,
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Option',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: YensTheme.navy),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () {
                          setState(() {
                            _sort = _SortMode.popularity;
                            _priceBand = _PriceBand.any;
                          });
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sheetSection('Sort By'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _sheetChip('Popularity', _sort == _SortMode.popularity, () {
                        setState(() => _sort = _SortMode.popularity);
                        setSheetState(() {});
                      }),
                      _sheetChip('Price: Low to High', _sort == _SortMode.priceLow, () {
                        setState(() => _sort = _SortMode.priceLow);
                        setSheetState(() {});
                      }),
                      _sheetChip('Price: High to Low', _sort == _SortMode.priceHigh, () {
                        setState(() => _sort = _SortMode.priceHigh);
                        setSheetState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sheetSection('Price Range'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _sheetChip('Any', _priceBand == _PriceBand.any, () {
                        setState(() => _priceBand = _PriceBand.any);
                        setSheetState(() {});
                      }),
                      _sheetChip('Under ฿100', _priceBand == _PriceBand.under100, () {
                        setState(() => _priceBand = _PriceBand.under100);
                        setSheetState(() {});
                      }),
                      _sheetChip('฿100 - ฿200', _priceBand == _PriceBand.mid, () {
                        setState(() => _priceBand = _PriceBand.mid);
                        setSheetState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: YensTheme.yellow,
                        foregroundColor: YensTheme.navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Apply Selection', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetSection(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: YensTheme.navy.withOpacity(0.7)),
    );
  }

  Widget _sheetChip(String label, bool sel, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: sel,
      onSelected: (_) => onTap(),
      selectedColor: YensTheme.yellow,
      checkmarkColor: YensTheme.navy,
      labelStyle: GoogleFonts.outfit(
        color: sel ? YensTheme.navy : Colors.black54,
        fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: sel ? YensTheme.navy : Colors.grey.shade300),
      ),
    );
  }

  Widget _cartFab(CartProvider cart) => FloatingActionButton.extended(
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
    backgroundColor: YensTheme.navy,
    foregroundColor: YensTheme.yellow,
    label: Text('${cart.itemCount} · ฿${cart.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
    icon: const Icon(Icons.shopping_bag_outlined),
  );
}
