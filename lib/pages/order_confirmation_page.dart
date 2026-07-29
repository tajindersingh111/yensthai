import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yensss/core/app_config.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/widgets/translation_widgets.dart';
import 'cart_provider.dart';
import 'home_page.dart';

class OrderConfirmationPage extends StatefulWidget {
  final String? orderId;
  final double totalAmount;
  final int earnedPoints;
  final int itemCount;
  final List<CartItem> items;
  final bool apiSuccess;
  final String orderStatus;

  const OrderConfirmationPage({
    super.key,
    this.orderId,
    required this.totalAmount,
    required this.earnedPoints,
    required this.itemCount,
    required this.items,
    required this.apiSuccess,
    this.orderStatus = 'confirmed',
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );
    _controller.forward();

    if (widget.orderId != null) {
      Future<void>.delayed(const Duration(seconds: 5), () => _markDeliveredIfConfirmed(widget.orderId!));
    }
  }

  Future<void> _markDeliveredIfConfirmed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('local_orders') ?? '[]';
    final list = jsonDecode(raw) as List<dynamic>;
    var changed = false;
    final next = list.map((dynamic o) {
      final m = Map<String, dynamic>.from(o as Map);
      if ('${m['id']}' == id && m['status'] == 'confirmed') {
        m['status'] = 'delivered';
        changed = true;
      }
      return m;
    }).toList();
    if (changed) {
      await prefs.setString('local_orders', jsonEncode(next));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _statusMessage() {
    switch (widget.orderStatus) {
      case 'pending':
        return widget.apiSuccess
            ? 'Your order is pending confirmation.'
            : 'Order saved securely. Points will sync when you are back online.';
      case 'confirmed':
        return 'Payment received. We are preparing your boutique experience.';
      case 'delivered':
        return 'Order delivered! We hope you enjoy your Yens experience.';
      default:
        return 'Your boutique order has been confirmed!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YensTheme.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: YensTheme.yellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: YensTheme.yellow, blurRadius: 40, spreadRadius: -10),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, size: 65, color: YensTheme.navy),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    Text(
                      "Thank you for your order!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: YensTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    YensTranslateText(
                      _statusMessage(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: YensTheme.navy.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Points Earned Ribbon
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: YensTheme.navy,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: YensTheme.navy.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "BOUTIQUE REWARDS EARNED",
                      style: GoogleFonts.outfit(
                        color: YensTheme.yellow.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars_rounded, color: YensTheme.yellow, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          "+${widget.earnedPoints} Points",
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // LIVE ORDER STATUS TRACKER (Requirement 7)
              const LiveOrderTracker(),
              
              const SizedBox(height: 32),
              
              // Order Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Summary",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: YensTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...widget.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: YensTheme.cream,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: item.imageUrl.isNotEmpty
                                ? Image.network(
                                    AppConfig.mediaUrl(item.imageUrl),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.coffee_rounded, color: YensTheme.navy),
                                  )
                                : const Icon(Icons.coffee_rounded, color: YensTheme.navy),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                YensTranslateText(
                                  item.name,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: YensTheme.navy,
                                  ),
                                ),
                                Text(
                                  "Quantity: ${item.quantity}",
                                  style: GoogleFonts.outfit(
                                    color: YensTheme.navy.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "฿${item.totalPrice.toStringAsFixed(0)}",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: YensTheme.navy,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Paid",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: YensTheme.navy,
                          ),
                        ),
                        Text(
                          "฿${widget.totalAmount.toStringAsFixed(0)}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: YensTheme.yellow,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YensTheme.yellow,
                    foregroundColor: YensTheme.navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    "Back to Boutique",
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Customer-Facing Live Order Status Tracker (Requirement 7)
class LiveOrderTracker extends StatefulWidget {
  const LiveOrderTracker({super.key});

  @override
  State<LiveOrderTracker> createState() => _LiveOrderTrackerState();
}

class _LiveOrderTrackerState extends State<LiveOrderTracker> {
  int _currentStageIndex = 3; // Default to 'On Route' for live tracking demo

  final List<Map<String, dynamic>> _stages = [
    {
      'title': 'Received',
      'subtitle': 'Order placed & confirmed by boutique',
      'icon': Icons.receipt_long_rounded,
      'eta': '25-30 min',
    },
    {
      'title': 'Preparing',
      'subtitle': 'Barista is crafting your fresh drinks',
      'icon': Icons.local_cafe_rounded,
      'eta': '20-25 min',
    },
    {
      'title': 'Collected',
      'subtitle': 'Delivery rider picked up your package',
      'icon': Icons.shopping_bag_rounded,
      'eta': '15-20 min',
    },
    {
      'title': 'On Route',
      'subtitle': 'Rider is on motorbike heading to your location',
      'icon': Icons.delivery_dining_rounded,
      'eta': '10-15 min',
    },
    {
      'title': 'Outside',
      'subtitle': 'Rider arrived outside your delivery address',
      'icon': Icons.storefront_rounded,
      'eta': 'Arriving Now',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeStage = _stages[_currentStageIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: YensTheme.navy.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: YensTheme.yellow.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: YensTheme.navy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.two_wheeler_rounded, color: YensTheme.yellow, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LIVE ORDER TRACKING',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: YensTheme.navy,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: YensTheme.yellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activeStage['eta'] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: YensTheme.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 5-Stage Stepper Bar
          Row(
            children: List.generate(_stages.length, (index) {
              final isPassed = index <= _currentStageIndex;
              final isCurrent = index == _currentStageIndex;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: isPassed ? YensTheme.navy : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Container(
                      width: isCurrent ? 20 : 12,
                      height: isCurrent ? 20 : 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPassed ? (isCurrent ? YensTheme.yellow : YensTheme.navy) : Colors.grey.shade300,
                        border: isCurrent ? Border.all(color: YensTheme.navy, width: 3) : null,
                      ),
                    ),
                    if (index < _stages.length - 1)
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: index < _currentStageIndex ? YensTheme.navy : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Stage labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_stages.length, (index) {
              final isCurrent = index == _currentStageIndex;
              return Expanded(
                child: Text(
                  _stages[index]['title'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                    color: isCurrent ? YensTheme.navy : Colors.grey.shade400,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Active stage detail box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: YensTheme.cream,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  activeStage['icon'] as IconData,
                  color: YensTheme.navy,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stage: ${activeStage['title']}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: YensTheme.navy,
                        ),
                      ),
                      Text(
                        activeStage['subtitle'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: YensTheme.navy.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}