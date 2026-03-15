import 'package:flutter/material.dart';
import 'package:yensss/pages/home_screen.dart';
import 'package:yensss/pages/profile_screen.dart';
import 'product_screen.dart';
import 'package:yensss/pages/loyalty_screen.dart';
import 'package:yensss/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const ProductScreen(),
    const LoyaltyScreen(),
    const ProfileScreen(),
  ];

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: pages[selectedIndex],
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
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home_outlined, "Home", 0),
            navItem(Icons.icecream_outlined, "Menu", 1),
            navItem(Icons.star_border, "Loyalty", 2),
            navItem(Icons.person_outline, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    bool active = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        changePage(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: active ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: active ? Colors.blue : Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
