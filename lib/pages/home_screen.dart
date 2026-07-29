import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yensss/controllers/main_nav_controller.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/data/local/rewards_local_store.dart';
import 'package:yensss/data/repositories/yens_repository.dart';
import 'package:yensss/presentation/widgets/error_retry_view.dart';
import 'package:yensss/presentation/widgets/home_promo_carousel.dart';
import 'package:yensss/presentation/widgets/product_menu_card.dart';
import 'package:yensss/widgets/yens_app_drawer.dart';
import 'package:yensss/widgets/yens_decorative_shapes.dart';
import 'package:yensss/widgets/yens_main_header.dart';
import 'cart_page.dart';
import 'cart_provider.dart';
import 'package:yensss/pages/product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _search = TextEditingController();

  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic> _customer = {};
  String _loggedInPhone = '';
  String _activeStore = '';
  bool _loading = true;
  String? _error;
  Set<String> _favoriteIds = {};
  int _featuredIndex = 0;
  int _promoRefreshKey = 0; // incremented on pull-to-refresh to force carousel rebuild

  // ── Greeting ──────────────────────────────────────────────────────────────
  late String _greeting;
  Timer? _greetingTimer;

  /// Computes greeting from device local time (5-12 morning, 12-17 afternoon,
  /// 17-22 evening, otherwise night). Never uses a fixed/mocked timestamp.
  String _computeGreeting() {
    final hour = DateTime.now().toLocal().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 22) return 'Good Evening';
    return 'Good Night';
  }

  /// Schedules the greeting timer to fire at the start of the next hour.
  void _scheduleGreetingRefresh() {
    _greetingTimer?.cancel();
    final now = DateTime.now().toLocal();
    // Time until the next full hour (+ 1 second buffer).
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    final delay = nextHour.difference(now) + const Duration(seconds: 1);
    _greetingTimer = Timer(delay, () {
      if (mounted) setState(() => _greeting = _computeGreeting());
      _scheduleGreetingRefresh(); // reschedule for following hour
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _greeting = _computeGreeting();
    _scheduleGreetingRefresh();
    _load();
    RewardsLocalStore.favoriteIds().then((ids) {
      if (mounted) setState(() => _favoriteIds = ids.toSet());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recalculate greeting when app returns to foreground.
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _greeting = _computeGreeting());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _greetingTimer?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = context.read<YensRepository>();
    final prefs = await SharedPreferences.getInstance();
    _loggedInPhone = prefs.getString('customer_phone') ?? '';
    _activeStore = prefs.getString('yens_active_pickup_store') ?? '';

    // Invalidate weekly special cache so the carousel re-fetches on pull-to-refresh
    repo.invalidateWeeklySpecialCache();
    if (mounted) setState(() => _promoRefreshKey++);

    try {
      final raw = await repo.fetchProducts();
      if (mounted) {
        setState(() {
          _products = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _featuredIndex = 0;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Products: ${e.toString()}';
          _loading = false;
        });
      }
      return;
    }

    if (_loggedInPhone.isNotEmpty) {
      try {
        final c = await repo.fetchCustomerByPhone(_loggedInPhone);
        if (c != null && mounted) {
          setState(() => _customer = c);
        }
      } catch (_) {}
    }
  }

  int get _points => (_customer['points'] as num?)?.toInt() ?? 0;
  String get _name => _customer['name']?.toString() ?? 'Boutique Guest';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: YensTheme.cream,
        body: Center(child: CircularProgressIndicator(color: YensTheme.navy, strokeWidth: 3)),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: YensTheme.cream,
        body: ErrorRetryView(
          message: 'We could not load the menu.',
          onRetry: _load,
        ),
      );
    }

    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white, // Pure white background for parts of the new design
          drawer: YensAppDrawer(customerName: _name),
          body: SafeArea(
            child: RefreshIndicator(
              color: YensTheme.navy,
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  // 1. DYNAMIC GREETING & STORE FINDER
                  SliverToBoxAdapter(child: _buildGreetingHeader()),
                  
                  // 2. QUICK ACTIONS
                  SliverToBoxAdapter(child: _buildQuickActions()),
                  
                  // 3. LOYALTY STATUS CARD (Premium Navy)
                  SliverToBoxAdapter(child: _buildLoyaltyStatusCard()),
                  
                  // 4. NEWS & PROMOTION HEADER
                  SliverToBoxAdapter(child: _buildSectionHeader('NEWS & PROMOTION')),
                  
                  // 5. PROMO CAROUSEL
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 30),
                      child: HomePromoCarousel(
                        key: ValueKey(_promoRefreshKey),
                        featuredProduct: _products.isNotEmpty ? _products[0] : null,
                        onProductTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductScreen(isPushed: true),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 6. BESTSELLERS SECTION
                  SliverToBoxAdapter(
                    child: _horizontalProductSection('Top Bestsellers', _bestsellers, cart, badge: 'BESTSELLER'),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 7. FOOTER
                  SliverToBoxAdapter(child: _homeFooter()),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 60)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingHeader() {
    return Column(
      children: [
        ClipPath(
          clipper: YensHeaderWaveClipper(),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, YensTheme.yellow],
                stops: [0.3, 1],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icons Row: [Logo] [Spacer] [Language] [Bell] [Menu]
                Row(
                  children: [
                    // Yens Logo on far left
                    ClipOval(
                      child: Image.asset(
                        'assets/logo.jpg',
                        width: 44, height: 44,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.icecream, color: YensTheme.navy),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: YensTheme.navy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'v3',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: YensTheme.navy,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Tools Group: Language -> Bell -> Cart -> Menu
                    const LanguageToggleButton(),
                    const SizedBox(width: 8),
                    const NotificationBellButton(),
                    const SizedBox(width: 8),
                    const _HomeScreenCartButton(), // NEW Cart button
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      icon: const Icon(Icons.menu_rounded, color: YensTheme.navy, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  '$_greeting, \n$_name',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: YensTheme.navy,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Find Store (Outside the wave for better visibility)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: InkWell(
            onTap: () => _showPickupSheet(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: YensTheme.yellow, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: YensTheme.navy.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: YensTheme.navy, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _activeStore.isNotEmpty 
                          ? 'Pickup from: $_activeStore' 
                          : 'Find a store / Select pickup location',
                      style: GoogleFonts.outfit(
                        color: YensTheme.navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: YensTheme.navy, size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
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
            'In-store Pickup',
            Icons.storefront_rounded,
            () => _showPickupSheet(context),
          ),
          _quickActionItem(
            'Order to Table',
            Icons.table_restaurant_rounded,
            () => _showOrderToTableSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _quickActionItem(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 80,
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
                width: 56,
                height: 56,
                child: Icon(icon, color: YensTheme.navy, size: 26),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: YensTheme.navy,
              height: 1.25,
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
                  'DONE',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 30),
            child: SingleChildScrollView(
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
                      Expanded(
                        child: Text(
                          'Delivery Details',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: YensTheme.navy,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          addressController.clear();
                          districtController.clear();
                          noteController.clear();
                          setModalState(() {});
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.outfit(
                            color: YensTheme.navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
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
                      hintText: 'Building, Floor, Unit #',
                      filled: true,
                      fillColor: YensTheme.cream,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'DISTRICT / AREA',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: districtController,
                    style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'e.g. Pathum Wan, Bangkok',
                      filled: true,
                      fillColor: YensTheme.cream,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'BARISTA NOTE',
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
                        
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Delivery address set to: $addr, $dist!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: YensTheme.navy,
                          ),
                        );
                        
                        context.read<MainNavController>().goToTab(2);
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
            ),
          );
        },
      ),
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
                              
                              if (mounted) {
                                setState(() {
                                  _activeStore = name;
                                });
                              }
                              
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pickup store set to: $name!'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: YensTheme.navy,
                                ),
                              );
                              context.read<MainNavController>().goToTab(2);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProductScreen(isPushed: true),
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
                      
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Table #$tableNum selected! Routing to menu...'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: YensTheme.navy,
                        ),
                      );
                      
                      context.read<MainNavController>().goToTab(2);
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

  Widget _buildLoyaltyStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: YensTheme.yellow, // Switched to Yellow as requested
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: YensTheme.yellow.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _points >= 400 ? 'Platinum' : (_points >= 150 ? 'Gold' : 'Silver'),
                    style: GoogleFonts.outfit(
                      color: YensTheme.navy,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$_points',
                    style: GoogleFonts.outfit(
                      color: YensTheme.navy,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.stars_rounded, color: YensTheme.navy, size: 28),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: YensTheme.navy, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Points earned for Yens Rewards',
            style: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          
          _buildProgressBar(),
          
          const SizedBox(height: 48),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Size Upgrade',
                      style: GoogleFonts.outfit(color: YensTheme.navy, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Get a free upsize on your favorite drinks today.',
                      style: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.6), fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Image.asset('assets/logo.jpg', height: 60, opacity: const AlwaysStoppedAnimation(0.8)),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: YensTheme.navy, // Swapped: Button is now Navy
              foregroundColor: YensTheme.yellow, // Text is Yellow
              elevation: 4,
              shadowColor: YensTheme.navy.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              'REDEEM 80 STARS',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final List<int> milestones = [20, 60, 120, 160, 350, 500];
    return Column(
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(color: YensTheme.navy.withOpacity(0.1), borderRadius: BorderRadius.circular(2)),
            ),
            FractionallySizedBox(
              widthFactor: (_points / 500).clamp(0.0, 1.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: YensTheme.navy, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: milestones.map((m) {
                final active = _points >= m;
                return Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? YensTheme.navy : Colors.white,
                    border: Border.all(color: active ? YensTheme.navy : YensTheme.navy.withOpacity(0.2), width: 2),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: milestones.map((m) => Text(
            '$m',
            style: GoogleFonts.outfit(color: _points >= m ? YensTheme.navy : YensTheme.navy.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: YensTheme.yellow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: YensTheme.navy,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _horizontalProductSection(String title, List<Map<String, dynamic>> items, CartProvider cart, {String? badge, Color? badgeColor}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: UnconstrainedBox(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: YensTheme.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16, // Slightly smaller for section sub-headers
                  fontWeight: FontWeight.w900,
                  color: YensTheme.navy,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) => SizedBox(
              width: 170,
              child: ProductMenuCard(
                product: items[i],
                badgeLabel: badge != null ? (badge == 'BESTSELLER' ? '#${i + 1} Popular' : badge) : null,
                badgeColor: badgeColor,
                onAdd: () => _addCart(cart, items[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _homeFooter() {
    return Column(
      children: [
        Image.asset('assets/logo.jpg', height: 40, opacity: const AlwaysStoppedAnimation(0.2)),
        const SizedBox(height: 16),
        Text(
          'Yens Boutique • Quality First',
          style: GoogleFonts.outfit(color: Colors.grey.shade400, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.5),
        ),
      ],
    );
  }

  double _price(Map<String, dynamic> p) => double.tryParse('${p['price']}') ?? 0;

  void _addCart(CartProvider cart, Map<String, dynamic> p) {
    final price = _price(p);
    cart.addItem(
      productId: '${p['id']}',
      name: '${p['name']}',
      imageUrl: p['imageUrl']?.toString() ?? '',
      price: price,
      rewardPoints: (p['rewardPoints'] as num?)?.toInt() ?? price.round(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p['name']} added'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: YensTheme.navy,
      ),
    );
  }

  List<Map<String, dynamic>> get _bestsellers {
    var list = List<Map<String, dynamic>>.from(_products);
    list.sort((a, b) {
      final isBestsellerA = (a['badge']?.toString().toUpperCase() == 'BESTSELLER' ||
          a['isBestseller'] == true ||
          a['featured'] == true) ? 1 : 0;
      final isBestsellerB = (b['badge']?.toString().toUpperCase() == 'BESTSELLER' ||
          b['isBestseller'] == true ||
          b['featured'] == true) ? 1 : 0;
      if (isBestsellerA != isBestsellerB) {
        return isBestsellerB.compareTo(isBestsellerA);
      }
      final pa = a['popularity'] ?? a['sales'] ?? a['salesCount'] ?? 0;
      final pb = b['popularity'] ?? b['sales'] ?? b['salesCount'] ?? 0;
      return (pb as num).compareTo(pa as num);
    });
    return list.take(10).toList();
  }
}

class _HomeScreenCartButton extends StatelessWidget {
  const _HomeScreenCartButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final count = cart.itemCount;
        return Material(
          color: Colors.white.withOpacity(0.92),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CartPage()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Badge(
                isLabelVisible: count > 0,
                label: Text(
                  '$count',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.red.shade600,
                child: const Icon(Icons.shopping_cart_outlined, size: 22, color: YensTheme.navy),
              ),
            ),
          ),
        );
      },
    );
  }
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
