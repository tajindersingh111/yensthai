import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_config.dart';
import '../data/local/rewards_local_store.dart';
import '../data/repositories/yens_repository.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
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
    if (_points < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough points yet.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

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
        SnackBar(content: Text('Redeemed: $label'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green.shade700),
      );
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redeem queued offline. Visit the store with this screen — ref: $label'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xffF5C021))));
    }

    final favoriteProducts = _products.where((p) => _favorites.contains('${p['id']}')).take(12).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F1EA),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xffF5C021),
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffF6C744), Color(0xffF5C021)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/logo.jpg', height: 32),
                          const SizedBox(width: 10),
                          Text('${AppConfig.appDisplayName} Rewards', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('$_points', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                      const Text('available points', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 12),
                      Text(
                        'Earn on every purchase. Streak bonus: +${(_streak * 5).clamp(0, 50)} pts on next qualifying order.',
                        style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.75)),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _streakCard()),
              SliverToBoxAdapter(child: _redeemSection()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text('Favorite drinks', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              if (favoriteProducts.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Heart items from the menu to pin them here.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: favoriteProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final p = favoriteProducts[i];
                        final url = AppConfig.mediaUrl(p['imageUrl']?.toString());
                        return Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: url.isEmpty
                                      ? Container(color: Colors.grey.shade200)
                                      : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, width: double.infinity),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  '${p['name']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _streakCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
              child: Icon(Icons.local_fire_department, color: Colors.orange.shade800, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily streak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    _streak < 1
                        ? 'Open the app daily to start your streak.'
                        : '$_streak day streak — complete 7 days for a bonus reward.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              '$_streak',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xffF5C021)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _redeemSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _redeemTile('Free topping', 80, Icons.cake_outlined),
          _redeemTile('Size upgrade', 150, Icons.arrow_circle_up_outlined),
          _redeemTile('Signature drink', 400, Icons.emoji_events_outlined),
        ],
      ),
    );
  }

  Widget _redeemTile(String label, int cost, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _redeem(cost, label),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xffF5C021)),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
                Text('$cost pts', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
