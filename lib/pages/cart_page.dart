import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yensss/core/app_config.dart';
import 'package:yensss/core/yens_theme.dart';

import 'cart_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          backgroundColor: YensTheme.cream,
          appBar: AppBar(
            backgroundColor: YensTheme.yellow,
            elevation: 0,
            title: Text(
              'My Cart',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: YensTheme.navy, fontSize: 24),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: YensTheme.navy),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: YensTheme.cream,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: Text('Clear cart', style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w900)),
                        content: Text('Remove all items from your cart?', style: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.8))),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx), 
                            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold))
                          ),
                          TextButton(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.pop(ctx);
                            },
                            child: Text('Clear', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Clear', style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w800)),
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: YensTheme.yellow.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, size: 60, color: YensTheme.navy),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty', 
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: YensTheme.navy)
          ),
          const SizedBox(height: 8),
          Text(
            'Add something delicious from the menu.', 
            style: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.5), fontWeight: FontWeight.w600)
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartProvider cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: YensTheme.navy.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'cart_${item.productId}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                AppConfig.mediaUrl(item.imageUrl),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: YensTheme.cream,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name, 
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: YensTheme.navy)
                ),
                const SizedBox(height: 6),
                Text(
                  '฿${item.price.toStringAsFixed(0)}', 
                  style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w800, fontSize: 15)
                ),
                const SizedBox(height: 2),
                Text(
                  '+${item.rewardPoints} pts each', 
                  style: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600)
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => cart.deleteItem(item.productId),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
              Row(
                children: [
                  _qtyBtn(
                    item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove,
                    () => cart.removeItem(item.productId),
                    isDelete: item.quantity == 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: YensTheme.navy),
                    ),
                  ),
                  _qtyBtn(
                    Icons.add,
                    () => cart.addItem(
                      productId: item.productId,
                      name: item.name,
                      imageUrl: item.imageUrl,
                      price: item.price,
                      rewardPoints: item.rewardPoints,
                    ),
                    isAdd: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, {bool isAdd = false, bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDelete
              ? Colors.red.shade50
              : (isAdd ? YensTheme.yellow : YensTheme.cream),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDelete ? Colors.red.shade700 : YensTheme.navy,
        ),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [BoxShadow(color: YensTheme.navy.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items', style: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.5), fontWeight: FontWeight.w600)),
              Text('${cart.itemCount}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: YensTheme.navy)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('You will earn', style: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.5), fontWeight: FontWeight.w600)),
              Text('+${cart.totalPoints} pts', style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w900)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: YensTheme.navy)),
              Text(
                '฿${cart.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: YensTheme.navy),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: YensTheme.yellow,
                foregroundColor: YensTheme.navy,
                elevation: 4,
                shadowColor: YensTheme.yellow.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: onCheckout,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    'PROCEED TO CHECKOUT', 
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
