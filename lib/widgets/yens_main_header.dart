import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/notifications_controller.dart';
import '../core/yens_theme.dart';
import '../presentation/notifications/notifications_screen.dart';
import '../pages/cart_provider.dart'; // Ensure this path is correct
import '../pages/cart_page.dart';
import 'yens_decorative_shapes.dart';

/// Unified top bar for all main tabs.
class YensMainHeader extends StatelessWidget {
  const YensMainHeader._({
    super.key,
    required this.child,
  });

  factory YensMainHeader.main({
    Key? key,
    required VoidCallback onOpenDrawer,
  }) {
    return YensMainHeader._(
      key: key,
      child: _MainTabHeaderRow(onOpenDrawer: onOpenDrawer),
    );
  }

  factory YensMainHeader.pushed({
    Key? key,
    required String title,
    required VoidCallback onBack,
  }) {
    return YensMainHeader._(
      key: key,
      child: _PushedHeaderRow(title: title, onBack: onBack),
    );
  }

  final Widget child;

  static PageRoute<T> routeNotifications<T>() {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => const NotificationsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: YensHeaderWaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, YensTheme.yellow],
            stops: [0.15, 1],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 35),
        child: child,
      ),
    );
  }
}

class _MainTabHeaderRow extends StatelessWidget {
  const _MainTabHeaderRow({required this.onOpenDrawer});

  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- LEFT SIDE: YENS LOGO ---
        ClipOval(
          child: Container(
            padding: const EdgeInsets.all(2.0),
            color: Colors.transparent,
            child: Image.asset(
              'assets/logo.jpg',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.icecream, color: YensTheme.navy),
            ),
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

        // --- RIGHT SIDE: TRANSLATOR, CART, BELL & MENU ---
        
        // 1. TRANSLATOR BUTTON (Connected to CartProvider)
        const LanguageToggleButton(),

        // 2. PROMINENT BLUE CART SUMMARY BUTTON
        const ProminentCartHeaderButton(),

        // 3. NOTIFICATION BELL
        const NotificationBellButton(),

        // 4. MENU ICON (Premium Stylized Hamburger)
        _roundIconWidget(const _PremiumMenuIcon(), onOpenDrawer),
      ],
    );
  }
}

class _PremiumMenuIcon extends StatelessWidget {
  const _PremiumMenuIcon();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(width: 20, height: 2, color: YensTheme.navy),
        const SizedBox(height: 4),
        Container(width: 14, height: 2, color: YensTheme.navy),
        const SizedBox(height: 4),
        Container(width: 18, height: 2, color: YensTheme.navy),
      ],
    );
  }
}

/// Updated Translator Widget linked to Global State
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to changes in CartProvider
    final cart = context.watch<CartProvider>();

    return GestureDetector(
      onTap: () => cart.toggleLanguage(), // Call the global toggle method
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: YensTheme.yellow, width: 1.5),
        ),
        child: Text(
          cart.isEnglish ? 'EN' : 'TH',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: YensTheme.navy,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _PushedHeaderRow extends StatelessWidget {
  const _PushedHeaderRow({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _roundIcon(Icons.arrow_back_ios_new_rounded, onBack),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: YensTheme.navy,
            ),
          ),
        ),
        const ProminentCartHeaderButton(),
      ],
    );
  }
}

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Consumer<NotificationsController>(
        builder: (context, ctrl, _) {
          ctrl.ensureSeeded();
          final n = ctrl.unreadCount;
          return Material(
            color: Colors.white.withOpacity(0.92),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).push(YensMainHeader.routeNotifications<void>()),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Badge(
                  isLabelVisible: n > 0,
                  label: Text(
                    n > 9 ? '9+' : '$n',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red.shade600,
                  child: const Icon(Icons.notifications_none_rounded, size: 22, color: YensTheme.navy),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Prominent Navy Blue Cart Summary Header Button (Requirement 3)
class ProminentCartHeaderButton extends StatelessWidget {
  const ProminentCartHeaderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final count = cart.itemCount;
        final total = cart.totalPrice;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Material(
            color: YensTheme.navy,
            borderRadius: BorderRadius.circular(22),
            elevation: 3,
            shadowColor: YensTheme.navy.withOpacity(0.3),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartPage()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      isLabelVisible: count > 0,
                      label: Text(
                        '$count',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.red.shade600,
                      child: const Icon(Icons.shopping_cart_rounded, size: 22, color: YensTheme.yellow),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '฿${total.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _roundIcon(IconData icon, VoidCallback onTap) {
  return _roundIconWidget(Icon(icon, size: 22, color: YensTheme.navy), onTap);
}

Widget _roundIconWidget(Widget icon, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(left: 6),
    child: Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: icon,
        ),
      ),
    ),
  );
}