import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
              'My Cart',
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
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Clear cart'),
                        content: const Text('Remove all items from your cart?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Clear', style: TextStyle(color: Colors.black87)),
                ),
            ],
          ),
          body: cart.items.isEmpty ? _buildEmptyCart() : _buildBody(context, cart),
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add something delicious from the menu.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartProvider cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartLine(item: item, cart: cart);
            },
          ),
        ),
        _BottomSummary(
          onCheckout: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (_) => const CheckoutPage()),
            );
          },
          cart: cart,
        ),
      ],
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item, required this.cart});

  final CartItem item;
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://app.yensthai.com${item.imageUrl}',
              width: 65,
              height: 65,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 65,
                height: 65,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('฿${item.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text('+${item.rewardPoints} pts each', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => cart.removeItem(item.productId),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(color: Color(0xffF5C021), shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomSummary extends StatelessWidget {
  const _BottomSummary({required this.cart, required this.onCheckout});

  final CartProvider cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items', style: TextStyle(color: Colors.grey)),
              Text('${cart.itemCount}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('You will earn', style: TextStyle(color: Colors.grey)),
              Text('+${cart.totalPoints} pts', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '฿${cart.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xffF5C021)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF5C021),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: onCheckout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Proceed to checkout', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
