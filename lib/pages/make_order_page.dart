import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/data/repositories/yens_repository.dart';
import 'package:yensss/widgets/yens_app_drawer.dart';
import 'package:yensss/widgets/yens_main_header.dart';
import 'package:yensss/pages/product_screen.dart';

import 'package:yensss/data/local/rewards_local_store.dart';
import 'package:yensss/pages/cart_provider.dart';
import 'package:yensss/pages/cart_page.dart';
import 'package:yensss/pages/product/widgets/product_search_bar.dart';
import 'package:yensss/presentation/widgets/menu_category_ribbon.dart';
import 'package:yensss/presentation/widgets/product_menu_card.dart';
import 'package:yensss/presentation/widgets/error_retry_view.dart';

class MakeOrderPage extends StatefulWidget {
  const MakeOrderPage({super.key});

  @override
  State<MakeOrderPage> createState() => _MakeOrderPageState();
}

class _MakeOrderPageState extends State<MakeOrderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _all = [];
  bool _loading = true;
  String? _error;
  String _categoryId = 'all';
  int _visibleCount = 24;
  Set<String> _favoriteIds = {};

  // Active status strings
  String _activeAddress = '';
  String _activeStore = '';
  String _activeTable = '';

  @override
  void initState() {
     super.initState();
     _scrollController.addListener(_onScroll);
     _fetch();
     _loadActiveOrderModes();
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

  Future<void> _loadActiveOrderModes() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Address
    String addr = '';
    final rawAddr = prefs.getString('yens_default_address');
    if (rawAddr != null) {
      try {
        final m = jsonDecode(rawAddr) as Map<String, dynamic>;
        addr = m['line1'] ?? '';
      } catch (_) {}
    }

    final store = prefs.getString('yens_active_pickup_store') ?? '';
    final table = prefs.getString('yens_active_table') ?? '';

    if (mounted) {
      setState(() {
        _activeAddress = addr;
        _activeStore = store;
        _activeTable = table;
      });
    }
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

  String _getCatImageUrl(String cat) {
    cat = cat.toLowerCase();
    switch (cat) {
      case 'all':
        return 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=150&auto=format&fit=crop&q=80';
      case 'soft_serve':
      case 'cat_ice':
        return 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=150&auto=format&fit=crop&q=80';
      case 'milk_tea':
      case 'cat_milk':
        return 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?w=150&auto=format&fit=crop&q=80';
      case 'fruit_tea':
      case 'cat_fruit':
        return 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=150&auto=format&fit=crop&q=80';
      case 'shakes':
      case 'cat_smoothie':
        return 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=150&auto=format&fit=crop&q=80';
      case 'sundaes':
        return 'https://images.unsplash.com/photo-1505394033641-4edc63e15226?w=150&auto=format&fit=crop&q=80';
      case 'float_drinks':
        return 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?w=150&auto=format&fit=crop&q=80';
      case 'coffee':
      case 'cat_coffee':
        return 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=150&auto=format&fit=crop&q=80';
      default:
        return 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=150&auto=format&fit=crop&q=80';
    }
  }

  List<Map<String, dynamic>> get _dynamicCategories {
     final Set<String> set = {};
     final List<Map<String, dynamic>> cats = [
       {
         'id': 'all',
         'name': 'Best Sellers',
         'icon': Icons.star_rounded,
         'imageUrl': _getCatImageUrl('all'),
       }
     ];
     for (var p in _all) {
       final c = p['category']?.toString();
       if (c != null && c.isNotEmpty && !set.contains(c)) {
         set.add(c);
         cats.add({
           'id': c,
           'name': _formatCatName(c),
           'icon': _getCatIcon(c),
           'imageUrl': _getCatImageUrl(c),
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
     list.sort((a, b) => _popularityOf(b).compareTo(_popularityOf(a)));
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
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width > 900 ? 4 : (width > 600 ? 3 : 2);

    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final filtered = _filteredSorted;
        final slice = filtered.take(_visibleCount).toList();

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: YensTheme.cream,
          drawer: const YensAppDrawer(),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Standardized header matching Home, Rewards, Profile
                YensMainHeader.main(
                  onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                ),

                // Horizontal Quick Options Row (Instore, Delivery, Pickup, Table)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _quickActionItem(
                        'Instore',
                        Icons.qr_code_scanner_rounded,
                        () => _showPayInStoreSheet(context),
                      ),
                      _quickActionItem(
                        'Delivery',
                        Icons.delivery_dining_rounded,
                        () => _showDeliverySheet(context),
                      ),
                      _quickActionItem(
                        'In-store\nPickup',
                        Icons.storefront_rounded,
                        () => _showPickupSheet(context),
                      ),
                      _quickActionItem(
                        'Order to\nTable',
                        Icons.table_restaurant_rounded,
                        () => _showOrderToTableSheet(context),
                      ),
                    ],
                  ),
                ),

                // Active Mode indicator status bar
                _buildActiveModeBar(),

                const SizedBox(height: 2),
                // Categories ribbon
                MenuCategoryRibbon(
                  categories: _dynamicCategories,
                  selectedCategoryId: _categoryId,
                  onCategoryTap: (id) => setState(() {
                    _categoryId = id;
                    _visibleCount = 24;
                  }),
                  showHeader: false,
                ),
                const SizedBox(height: 2),

                // Search Bar below categories
                ProductSearchBar(
                  controller: _searchController,
                  onChanged: () => setState(() => _visibleCount = 24),
                  onFilterTap: _showFilterSheet,
                ),
                const SizedBox(height: 2),

                // Full Menu product list
                Expanded(
                  child: _loading 
                    ? const Center(child: CircularProgressIndicator(color: YensTheme.navy))
                    : _error != null 
                      ? ErrorRetryView(
                          message: 'Unable to load menu. Check your connection.',
                          onRetry: () => _fetch(refresh: true),
                        )
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 80),
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

  Widget _buildActiveModeBar() {
    String text = '';
    IconData icon = Icons.info_outline_rounded;
    
    if (_activeTable.isNotEmpty) {
      text = 'Ordering to Table #$_activeTable';
      icon = Icons.table_restaurant_rounded;
    } else if (_activeStore.isNotEmpty) {
      text = 'Pickup Store set to: $_activeStore';
      icon = Icons.storefront_rounded;
    } else if (_activeAddress.isNotEmpty) {
      text = 'Delivering to: $_activeAddress';
      icon = Icons.delivery_dining_rounded;
    }

    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: YensTheme.yellowSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: YensTheme.yellow, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: YensTheme.navy, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: YensTheme.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionItem(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: YensTheme.yellow,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: YensTheme.yellow.withOpacity(0.3),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              splashColor: YensTheme.navy.withOpacity(0.15),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, color: YensTheme.navy, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: YensTheme.navy,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  void _showPayInStoreSheet(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('customer_name') ?? 'Guest User';
    final phone = prefs.getString('customer_phone') ?? 'Not Available';
    
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loyalty Card QR',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: YensTheme.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan this code at the counter to collect stars and redeem rewards.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: YensTheme.yellowSoft,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: YensTheme.yellow, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: CustomPaint(
                      painter: _MockQrPainter(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: YensTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: YensTheme.navy.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: YensTheme.navy,
                  foregroundColor: YensTheme.yellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'CLOSE',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliverySheet(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String savedAddress = '';
    String savedDistrict = '';
    String savedNote = '';
    
    final raw = prefs.getString('yens_default_address');
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        savedAddress = m['line1'] ?? '';
        savedDistrict = m['district'] ?? '';
        savedNote = m['note'] ?? '';
      } catch (_) {}
    }
    
    final addressController = TextEditingController(text: savedAddress);
    final districtController = TextEditingController(text: savedDistrict);
    final noteController = TextEditingController(text: savedNote);
    
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: YensTheme.yellow.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delivery_dining_rounded, color: YensTheme.navy, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Delivery Details',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: YensTheme.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'STREET ADDRESS',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Enter street address, building, or room number',
                      filled: true,
                      fillColor: YensTheme.cream,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DISTRICT / AREA',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: districtController,
                    style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Enter district, city, or province',
                      filled: true,
                      fillColor: YensTheme.cream,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DELIVERY NOTE (OPTIONAL)',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'e.g. Leave with security, extra ice please',
                      filled: true,
                      fillColor: YensTheme.cream,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () async {
                        final addr = addressController.text.trim();
                        final dist = districtController.text.trim();
                        final nte = noteController.text.trim();
                        
                        if (addr.isEmpty || dist.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: const Text('Please enter street address and district.'),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        
                        await prefs.setString(
                          'yens_default_address',
                          jsonEncode({
                            'line1': addr,
                            'district': dist,
                            'note': nte,
                          }),
                        );
                        // Reset Table & Store so only 1 is active
                        await prefs.remove('yens_active_pickup_store');
                        await prefs.remove('yens_active_table');
                        
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        
                        _loadActiveOrderModes();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Delivery address set to: $addr, $dist!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: YensTheme.navy,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: YensTheme.yellow,
                        foregroundColor: YensTheme.navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text(
                        'CONFIRM DELIVERY ADDRESS',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
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

  void _showPickupSheet(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedStore = prefs.getString('yens_active_pickup_store') ?? '';
    
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return FutureBuilder<List<dynamic>>(
              future: ctx.read<YensRepository>().fetchSites(),
              builder: (context, snapshot) {
                Widget content;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  content = const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(color: YensTheme.navy),
                    ),
                  );
                } else if (snapshot.hasError) {
                  content = SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Failed to load stores.',
                        style: GoogleFonts.outfit(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                } else {
                  final List<dynamic> sitesList = snapshot.data ?? [];
                  if (sitesList.isEmpty) {
                    content = SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'No stores available.',
                          style: GoogleFonts.outfit(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else {
                    content = ListView.separated(
                      shrinkWrap: true,
                      itemCount: sitesList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final site = sitesList[idx] as Map<String, dynamic>;
                        final name = site['name']?.toString() ?? 'Yens Store';
                        final location = site['location']?.toString() ?? 'Bangkok';
                        final isSelected = selectedStore == name;
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected ? YensTheme.yellowSoft : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? YensTheme.yellow : Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            onTap: () async {
                              await prefs.setString('yens_active_pickup_store', name);
                              // Reset Table & Address so only 1 is active
                              await prefs.remove('yens_default_address');
                              await prefs.remove('yens_active_table');

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);

                              _loadActiveOrderModes();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pickup store set to: $name!'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: YensTheme.navy,
                                ),
                              );
                            },
                            leading: Icon(
                              Icons.location_on_rounded,
                              color: isSelected ? YensTheme.navy : Colors.grey.shade400,
                            ),
                            title: Text(
                              name,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: YensTheme.navy,
                              ),
                            ),
                            subtitle: Text(
                              location,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: isSelected 
                              ? const Icon(Icons.check_circle_rounded, color: YensTheme.navy)
                              : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ),
                        );
                      },
                    );
                  }
                }

                return Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.75,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: YensTheme.yellow.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront_rounded, color: YensTheme.navy, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Select Pickup Store',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: YensTheme.navy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Flexible(child: content),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showOrderToTableSheet(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final activeTable = prefs.getString('yens_active_table') ?? '';
    
    final tableController = TextEditingController(text: activeTable);
    
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: YensTheme.yellow.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.table_restaurant_rounded, color: YensTheme.navy, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Order to Table',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: YensTheme.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'TABLE NUMBER (1 - 50)',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tableController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w900, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Enter table number, e.g. 12',
                    filled: true,
                    fillColor: YensTheme.cream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () async {
                      final tableNum = tableController.text.trim();
                      if (tableNum.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a valid table number.'),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      
                      await prefs.setString('yens_active_table', tableNum);
                      // Reset Store & Address so only 1 is active
                      await prefs.remove('yens_active_pickup_store');
                      await prefs.remove('yens_default_address');
                      
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      
                      _loadActiveOrderModes();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Table #$tableNum selected!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: YensTheme.navy,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: YensTheme.yellow,
                      foregroundColor: YensTheme.navy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      'CONFIRM TABLE NUMBER',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: YensTheme.navy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No filters active.',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
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

class _MockQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = YensTheme.navy
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cellSize = w / 9;

    void drawBlock(int x, int y, int sizeInCells) {
      canvas.drawRect(
        Rect.fromLTWH(x * cellSize, y * cellSize, sizeInCells * cellSize, sizeInCells * cellSize),
        paint,
      );
    }

    void drawFinder(int x, int y) {
      drawBlock(x, y, 3);
      final whitePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH((x + 0.5) * cellSize, (y + 0.5) * cellSize, 2 * cellSize, 2 * cellSize),
        whitePaint,
      );
      drawBlock(x + 1, y + 1, 1);
    }

    drawFinder(0, 0);
    drawFinder(6, 0);
    drawFinder(0, 6);

    drawBlock(4, 1, 1);
    drawBlock(5, 2, 1);
    drawBlock(3, 4, 1);
    drawBlock(4, 5, 2);
    drawBlock(5, 7, 1);
    drawBlock(7, 4, 1);
    drawBlock(8, 5, 1);
    drawBlock(2, 4, 1);
    drawBlock(1, 5, 1);
    drawBlock(5, 0, 1);
    drawBlock(8, 8, 1);
    drawBlock(6, 5, 1);
    drawBlock(7, 7, 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
