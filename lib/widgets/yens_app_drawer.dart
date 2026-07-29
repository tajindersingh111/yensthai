import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/main_nav_controller.dart';
import '../core/yens_theme.dart';
import '../pages/cart_page.dart';
import '../pages/cart_provider.dart';
import '../pages/restaurant_finder_screen.dart';
import '../pages/feedback_screen.dart';
import '../pages/support_info_screen.dart';
import '../pages/rewards_intro_page.dart';
import '../core/session_service.dart';

/// Shared navigation drawer for all tab scaffolds.
class YensAppDrawer extends StatelessWidget {
  const YensAppDrawer({super.key, this.customerName});

  /// When null, name is read from SharedPreferences (`customer_name`).
  final String? customerName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          // 1. Ultra-Premium Loyalty Card Header
          _buildPremiumHeader(context),
          
          const SizedBox(height: 8),

          // 2. Scrollable Menu Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _drawerTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Personal Information',
                  onTap: () {
                    Navigator.pop(context);
                    context.read<MainNavController>().goToTab(3);
                  },
                ),
                _drawerTile(
                  icon: Icons.list_alt_outlined,
                  label: 'Order History',
                  onTap: () {
                    Navigator.pop(context);
                    context.read<MainNavController>().goToTab(3);
                  },
                ),
                _drawerTile(
                  icon: Icons.shopping_bag_outlined,
                  label: 'My Cart',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const CartPage()));
                  },
                ),

                const SizedBox(height: 24),
                _sectionHeader('STORE & MENU'),
                _drawerTile(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Full Menu Explorer',
                  onTap: () {
                    Navigator.pop(context);
                    context.read<MainNavController>().goToTab(1);
                  },
                ),
                _drawerTile(
                  icon: Icons.location_on_outlined,
                  label: 'Restaurant Finder',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const RestaurantFinderScreen()));
                  },
                ),

                const SizedBox(height: 24),
                _sectionHeader('SUPPORT & LEGAL'),
                _drawerTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help Center & FAQ',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const SupportInfoScreen(title: 'Help and Support')));
                  },
                ),
                _drawerTile(
                  icon: Icons.feedback_outlined,
                  label: 'Send Feedback',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const FeedbackScreen()));
                  },
                ),
                _drawerTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy & Terms',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const SupportInfoScreen(title: 'Legal Info')));
                  },
                ),

                const SizedBox(height: 24),
                _sectionHeader('SETTINGS'),
                _drawerTile(
                  icon: Icons.settings_outlined,
                  label: 'General Settings',
                  onTap: () => _comingSoon(context),
                ),
                _drawerTile(
                  icon: Icons.translate_rounded,
                  label: 'Switch Language',
                  onTap: () {
                    Navigator.pop(context);
                    context.read<CartProvider>().toggleLanguage();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // --- Yellow Reset Session Button (No background box) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await SessionService.instance.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const RewardsIntroPage()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text('LOG OUT', style: GoogleFonts.dmSans(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // 3. Footer Branding
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.jpg', width: 24, height: 24, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                    const SizedBox(width: 8),
                    Text(
                      'YENS BOUTIQUE v1.0.4',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: YensTheme.navy.withOpacity(0.3),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: YensTheme.navy,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The "Loyalty Card"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [YensTheme.yellow, Color(0xFFEBB400)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: FutureBuilder<String>(
                  future: _resolveName(),
                  builder: (context, snap) {
                    final name = customerName ?? snap.data ?? 'Guest';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.jpg',
                                  width: 44, height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: YensTheme.navy),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: YensTheme.navy,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'GOLD',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: YensTheme.yellow,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          name.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: YensTheme.navy,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yens Loyalty Member',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: YensTheme.navy.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats Row
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _headerStat('250', 'Points'),
                              Container(width: 1, height: 16, color: YensTheme.navy.withOpacity(0.1)),
                              _headerStat('฿1.2K', 'Saved'),
                              Container(width: 1, height: 16, color: YensTheme.navy.withOpacity(0.1)),
                              _headerStat('5', 'Rewards'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w900, color: YensTheme.navy)),
        Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.bold, color: YensTheme.navy.withOpacity(0.5))),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: YensTheme.navy.withOpacity(0.3),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _drawerTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: YensTheme.navy.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: YensTheme.navy, size: 18),
        ),
        title: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: YensTheme.navy.withOpacity(0.85),
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, size: 18, color: YensTheme.navy.withOpacity(0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This feature is coming soon!', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: YensTheme.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  Future<String> _resolveName() async {
    if (customerName != null && customerName!.isNotEmpty) return customerName!;
    final p = await SharedPreferences.getInstance();
    return p.getString('customer_name') ?? 'Guest';
  }
}
