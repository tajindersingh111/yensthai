import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
    final id = widget.orderId;
    if (id != null) {
      Future<void>.delayed(const Duration(seconds: 5), () => _markDeliveredIfConfirmed(id));
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
            : 'Order saved on device. Points will sync when you are back online.';
      case 'confirmed':
        return 'Payment received. We are preparing your order.';
      case 'delivered':
        return 'Delivered. Thanks for ordering with Yens!';
      default:
        return widget.apiSuccess
            ? 'Your order has been confirmed!'
            : 'Order saved! Points will sync when connected.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F1EA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// SUCCESS ANIMATION
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xffF5C021),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 55, color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Order placed",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                _statusMessage(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 30),

              /// POINTS EARNED CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffF5C021), width: 2),
                ),
                child: Column(
                  children: [
                    const Text("Points Earned", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars, color: Colors.orange, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          "+${widget.earnedPoints} pts",
                          style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ORDER SUMMARY CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),

                    /// ITEMS
                    ...widget.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "https://app.yensthai.com${item.imageUrl}",
                              width: 45, height: 45, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 45, height: 45,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text("x${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            "฿${item.totalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )).toList(),

                    const Divider(),

                    /// TOTAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          "฿${widget.totalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xffF5C021)),
                        ),
                      ],
                    ),

                    /// API STATUS
                    if (!widget.apiSuccess) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Points will be synced when server is available.",
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// BACK TO HOME BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF5C021),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                          (route) => false,
                    );
                  },
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}