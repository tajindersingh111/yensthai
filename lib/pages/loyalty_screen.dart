import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/data/local/rewards_local_store.dart';
import 'package:yensss/data/repositories/yens_repository.dart';
import 'package:yensss/pages/loyalty/widgets/loyalty_favorite_card.dart';
import 'package:yensss/pages/loyalty/widgets/loyalty_points_card.dart';
import 'package:yensss/pages/loyalty/widgets/loyalty_redeem_tile.dart';
import 'package:yensss/widgets/translation_widgets.dart';
import 'package:yensss/widgets/yens_app_drawer.dart';
import 'package:yensss/widgets/yens_main_header.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> _customer = {};
  List<Map<String, dynamic>> _products = [];
  List<String> _favorites = [];
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = context.read<YensRepository>();
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('customer_phone') ?? '';
    final favs = await RewardsLocalStore.favoriteIds();
    final streak = await RewardsLocalStore.streakDays();

    Map<String, dynamic> customer = {};
    List<Map<String, dynamic>> products = [];
    try {
      if (phone.isNotEmpty) {
        final c = await repo.fetchCustomerByPhone(phone);
        if (c != null) customer = c;
      }
      final raw = await repo.fetchProducts();
      products = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _customer = customer;
      _products = products;
      _favorites = favs;
      _streak = streak;
      _loading = false;
    });
  }

  int get _points => (_customer['points'] as num?)?.toInt() ?? 0;

  Future<void> _redeem(int cost, String label) async {
    if (_points < cost) return;

    final repo = context.read<YensRepository>();
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('customer_id') ?? '';
    var ok = false;
    try {
      ok = await repo.postTransaction(
        customerId: id,
        body: {
          'points': cost,
          'type': 'redeem',
          'location': 'Yens Rewards',
          'note': 'Redeem: $label',
        },
      );
    } catch (_) {
      ok = false;
    }

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redeemed: $label'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: YensTheme.navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification required. Present this to cashier: $label'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: YensTheme.navy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProducts = _products.where((p) => _favorites.contains('${p['id']}')).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: YensTheme.cream,
      drawer: const YensAppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            YensMainHeader.main(onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer()),
            Expanded(
              child: RefreshIndicator(
                color: YensTheme.navy,
                onRefresh: _load,
                child: _loading 
                  ? const Center(child: CircularProgressIndicator(color: YensTheme.navy))
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        // Points Dashboard
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            child: LoyaltyPointsCard(points: _points, streak: _streak),
                          ),
                        ),

                        // Redemption Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Row(
                              children: [
                                YensTranslateText(
                                  'Redeem Rewards',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: YensTheme.navy,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.stars_rounded, color: YensTheme.yellow, size: 20),
                              ],
                            ),
                          ),
                        ),

                        // Redemption List
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              LoyaltyRedeemTile(
                                label: 'Free Topping',
                                cost: 80,
                                icon: Icons.cake_outlined,
                                isAvailable: _points >= 80,
                                onTap: () => _redeem(80, 'Free Topping'),
                              ),
                              LoyaltyRedeemTile(
                                label: 'Size Upgrade',
                                cost: 150,
                                icon: Icons.arrow_circle_up_outlined,
                                isAvailable: _points >= 150,
                                onTap: () => _redeem(150, 'Size Upgrade'),
                              ),
                              LoyaltyRedeemTile(
                                label: 'Signature Drink',
                                cost: 400,
                                icon: Icons.emoji_events_outlined,
                                isAvailable: _points >= 400,
                                onTap: () => _redeem(400, 'Signature Drink'),
                              ),
                            ]),
                          ),
                        ),

                        // Favorites Section
                        if (favoriteProducts.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                              child: YensTranslateText(
                                'Your Favorites',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: YensTheme.navy,
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 140,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                scrollDirection: Axis.horizontal,
                                itemCount: favoriteProducts.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, i) => LoyaltyFavoriteCard(product: favoriteProducts[i]),
                              ),
                            ),
                          ),
                        ],

                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
