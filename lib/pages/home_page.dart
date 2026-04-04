import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yensss/controllers/main_nav_controller.dart';
import 'package:yensss/pages/home_screen.dart';
import 'package:yensss/pages/loyalty_screen.dart';
import 'package:yensss/pages/product_screen.dart';
import 'package:yensss/pages/profile_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    ProductScreen(),
    LoyaltyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MainNavController>(
      builder: (context, nav, _) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F6FA),
          body: _pages[nav.index],
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, Icons.home_outlined, 'Home', 0, nav.index),
                _navItem(context, Icons.icecream_outlined, 'Menu', 1, nav.index),
                _navItem(context, Icons.star_border, 'Rewards', 2, nav.index),
                _navItem(context, Icons.person_outline, 'Profile', 3, nav.index),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int selectedIndex,
  ) {
    final active = selectedIndex == index;
    return GestureDetector(
      onTap: () => context.read<MainNavController>().goToTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: active ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
