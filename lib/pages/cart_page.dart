import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'cart_provider.dart';
import 'order_confirmation_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isPlacingOrder = false;

  Future<void> placeOrder(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.items.isEmpty) return;

    setState(() => isPlacingOrder = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id') ?? '';
      final customerName = prefs.getString('customer_name') ?? '';
      final customerPhone = prefs.getString('customer_phone') ?? '';

      if (customerId.isEmpty) {
        _showError(context, "User not logged in. Please login again.");
        return;
      }

      /// Calculate total points — 1 point per 1 THB spent
      final int earnedPoints = cart.totalPrice.round();

      /// POST to yensthai transactions API
      final url = Uri.parse(
          "https://app.yensthai.com/api/customers/$customerId/transactions");

      final body = {
        "points": earnedPoints,
        "type": "earn",
        "location": "Yen's Thai App",
        "note": "Order via app - ${cart.items.length} items",
        "amount": cart.totalPrice,
        "items": cart.items.map((e) => e.toJson()).toList(),
      };

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      /// Save order locally regardless of API response
      await _saveOrderLocally(
        customerId: customerId,
        customerName: customerName,
        cart: cart,
        earnedPoints: earnedPoints,
        apiSuccess: res.statusCode == 200 || res.statusCode == 201,
      );

      if (!mounted) return;

      /// Navigate to confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            totalAmount: cart.totalPrice,
            earnedPoints: earnedPoints,
            itemCount: cart.itemCount,
            items: cart.items.toList(),
            apiSuccess: res.statusCode == 200 || res.statusCode == 201,
          ),
        ),
      );

      cart.clearCart();
    } catch (e) {
      /// Even if API fails — save locally
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id') ?? '';
      final cart = Provider.of<CartProvider>(context, listen: false);
      final earnedPoints = cart.totalPrice.round();

      await _saveOrderLocally(
        customerId: customerId,
        customerName: prefs.getString('customer_name') ?? '',
        cart: cart,
        earnedPoints: earnedPoints,
        apiSuccess: false,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            totalAmount: cart.totalPrice,
            earnedPoints: earnedPoints,
            itemCount: cart.itemCount,
            items: cart.items.toList(),
            apiSuccess: false,
          ),
        ),
      );
      cart.clearCart();
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  /// Save order to local storage
  Future<void> _saveOrderLocally({
    required String customerId,
    required String customerName,
    required CartProvider cart,
    required int earnedPoints,
    required bool apiSuccess,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    /// Get existing orders
    final String ordersJson = prefs.getString('local_orders') ?? '[]';
    final List orders = json.decode(ordersJson);

    /// Add new order
    final newOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'customerId': customerId,
      'customerName': customerName,
      'items': cart.items.map((e) => e.toJson()).toList(),
      'totalAmount': cart.totalPrice,
      'earnedPoints': earnedPoints,
      'date': DateTime.now().toIso8601String(),
      'status': 'placed',
      'synced': apiSuccess,
    };

    orders.insert(0, newOrder);

    /// Keep only last 50 orders
    if (orders.length > 50) orders.removeRange(50, orders.length);

    await prefs.setString('local_orders', json.encode(orders));

    /// Update local points
    if (!apiSuccess) {
      final currentPoints = prefs.getInt('local_points') ?? 0;
      await prefs.setInt('local_points', currentPoints + earnedPoints);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F1EA),
          appBar: AppBar(
            backgroundColor: const Color(0xffF6C744),
            elevation: 0,
            title: const Text(
              "My Cart",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text("Clear Cart"),
                        content: const Text("Remove all items from cart?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                          TextButton(
                            onPressed: () { cart.clearCart(); Navigator.pop(ctx); },
                            child: const Text("Clear", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Clear", style: TextStyle(color: Colors.black87)),
                ),
            ],
          ),
          body: cart.items.isEmpty
              ? _buildEmptyCart()
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, item, cart);
                  },
                ),
              ),
              _buildBottomSummary(context, cart),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text("Your cart is empty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Add some items to get started!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "https://app.yensthai.com${item.imageUrl}",
              width: 65, height: 65,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 65, height: 65,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("฿${item.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text("+${item.rewardPoints} pts each", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          /// QUANTITY CONTROLS
          Row(
            children: [
              GestureDetector(
                onTap: () => cart.removeItem(item.productId),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              GestureDetector(
                onTap: () => cart.addItem(
                  productId: item.productId,
                  name: item.name,
                  imageUrl: item.imageUrl,
                  price: item.price,
                  rewardPoints: item.rewardPoints,
                ),
                child: Container(
                  width: 30, height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xffF5C021),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          /// SUMMARY ROWS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Items", style: TextStyle(color: Colors.grey)),
              Text("${cart.itemCount}", style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("You'll earn", style: TextStyle(color: Colors.grey)),
              Text("+${cart.totalPoints} pts", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("฿${cart.totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xffF5C021))),
            ],
          ),
          const SizedBox(height: 16),

          /// PLACE ORDER BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF5C021),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: isPlacingOrder ? null : () => placeOrder(context),
              child: isPlacingOrder
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Place Order", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}