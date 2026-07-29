import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yensss/controllers/main_nav_controller.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/pages/home_screen.dart';
import 'package:yensss/pages/loyalty_screen.dart';
import 'package:yensss/pages/profile_screen.dart';
import 'package:yensss/pages/make_order_page.dart';
import 'package:yensss/pages/inbox_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<Widget> _pages = [
    const HomeScreen(),
    const LoyaltyScreen(),
    const MakeOrderPage(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MainNavController>(
      builder: (context, nav, _) {
        return Scaffold(
          backgroundColor: YensTheme.cream,
          body: IndexedStack(
            index: nav.index,
            children: _pages,
          ),
          bottomNavigationBar: _buildBottomNav(context, nav),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, MainNavController nav) {
    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: YensTheme.navy.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Row(
          children: [
            _navItem(context, Icons.home_rounded, 'Home', 0, nav.index),
            _navItem(context, Icons.stars_rounded, 'Rewards', 1, nav.index),
            _navItem(context, Icons.icecream_rounded, 'Order', 2, nav.index),
            _navItem(context, Icons.notifications_rounded, 'Inbox', 3, nav.index),
            _navItem(context, Icons.person_rounded, 'Account', 4, nav.index),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int selectedIndex,
  ) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.read<MainNavController>().goToTab(index),
          splashColor: YensTheme.yellow.withOpacity(0.3),
          highlightColor: YensTheme.yellow.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? YensTheme.yellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: isSelected ? YensTheme.navy : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? YensTheme.navy : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
