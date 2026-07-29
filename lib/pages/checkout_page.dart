import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/controllers/notifications_controller.dart';
import 'package:yensss/data/repositories/yens_repository.dart';
import 'package:yensss/presentation/widgets/yens_text_field.dart';
import 'package:yensss/widgets/translation_widgets.dart';
import 'cart_provider.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _line1 = TextEditingController();
  final _district = TextEditingController();
  final _note = TextEditingController();
  int _payingStep = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('yens_default_address');
    if (raw == null) return;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      _line1.text = '${m['line1'] ?? ''}';
      _district.text = '${m['district'] ?? ''}';
      _note.text = '${m['note'] ?? ''}';
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _line1.dispose();
    _district.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'yens_default_address',
      jsonEncode({
        'line1': _line1.text.trim(),
        'district': _district.text.trim(),
        'note': _note.text.trim(),
      }),
    );
  }

  String _formatAddress() {
    final parts = [_line1.text.trim(), _district.text.trim()]
        .where((e) => e.isNotEmpty)
        .join(', ');
    return parts.isEmpty ? 'Store Pickup' : parts;
  }

  Future<void> _mockRazorpayPay(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCardRaw = prefs.getString('yens_saved_card');
    String savedCardNum = '4242 4242 4242 4242';
    String savedExpiry = '12/28';
    String savedCvv = '123';
    bool hasSavedCard = false;

    if (savedCardRaw != null) {
      try {
        final m = jsonDecode(savedCardRaw) as Map<String, dynamic>;
        savedCardNum = m['cardNumber'] ?? savedCardNum;
        savedExpiry = m['expiry'] ?? savedExpiry;
        savedCvv = m['cvv'] ?? savedCvv;
        hasSavedCard = true;
      } catch (_) {}
    }

    final cardCtrl = TextEditingController(text: savedCardNum);
    final expiryCtrl = TextEditingController(text: savedExpiry);
    final cvvCtrl = TextEditingController(text: savedCvv);
    bool saveCard = true;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(ctx).viewInsets.bottom + 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.payment_rounded, color: Colors.indigo.shade700, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure Card Checkout',
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: YensTheme.navy),
                            ),
                            Text(
                              hasSavedCard ? 'Saved Card Auto-Populated' : '256-bit Encrypted Payment',
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                            ),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx, false), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '฿${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.w900, color: YensTheme.navy),
                    ),
                  ),
                  const SizedBox(height: 24),
                  YensTextField(
                    controller: cardCtrl,
                    label: 'Card Number',
                    hint: '4242 4242 4242 4242',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: YensTextField(controller: expiryCtrl, label: 'Expiry Date', hint: 'MM/YY')),
                      const SizedBox(width: 14),
                      Expanded(child: YensTextField(controller: cvvCtrl, label: 'CVV', hint: '123', obscureText: true)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Checkbox(
                        value: saveCard,
                        activeColor: YensTheme.navy,
                        onChanged: (v) => setSheetState(() => saveCard = v ?? true),
                      ),
                      Expanded(
                        child: Text(
                          'Save card details securely for future orders',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: YensTheme.navy.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: () async {
                        if (saveCard) {
                          await prefs.setString(
                            'yens_saved_card',
                            jsonEncode({
                              'cardNumber': cardCtrl.text.trim(),
                              'expiry': expiryCtrl.text.trim(),
                              'cvv': cvvCtrl.text.trim(),
                            }),
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: YensTheme.navy,
                        foregroundColor: YensTheme.yellow,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text('Complete Order & Pay', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (ok != true || !mounted) return;

    setState(() => _payingStep = 1);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _payingStep = 2);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    await _completeOrder(paid: true);
  }

  Future<void> _completeOrder({required bool paid}) async {
    final cart = context.read<CartProvider>();
    final repo = context.read<YensRepository>();
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customer_id') ?? '';
    final customerName = prefs.getString('customer_name') ?? '';

    if (customerId.isEmpty) {
      if (mounted) setState(() => _error = 'Session expired. Please sign in again.');
      return;
    }

    final itemsSnapshot = cart.items.toList();
    final totalAmount = cart.totalPrice;
    final itemCount = cart.itemCount;
    final earnedPoints = totalAmount.round();
    final address = _formatAddress();

    final body = {
      'points': earnedPoints,
      'type': 'earn',
      'location': 'Yens App',
      'note': 'Order — $address',
      'amount': totalAmount,
      'paymentProvider': 'razorpay_mock',
      'items': itemsSnapshot.map((e) => e.toJson()).toList(),
    };

    var apiOk = false;
    try {
      apiOk = await repo.postTransaction(customerId: customerId, body: body);
    } catch (_) {
      apiOk = false;
    }

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final status = paid ? (apiOk ? 'confirmed' : 'pending') : 'pending';

    await _persistOrder(
      orderId: orderId,
      customerId: customerId,
      customerName: customerName,
      items: itemsSnapshot,
      totalAmount: totalAmount,
      earnedPoints: earnedPoints,
      apiSuccess: apiOk,
      address: address,
      status: status,
    );

    if (!mounted) return;
    context.read<NotificationsController>().addOrderUpdate(
      title: 'Order Status Update',
      body: apiOk
          ? 'Great news! Your order #$orderId is confirmed. You earned +$earnedPoints Reward Points!'
          : 'Order #$orderId saved securely. We will sync your points once you are back online.',
    );
    cart.clearCart();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          orderId: orderId,
          totalAmount: totalAmount,
          earnedPoints: earnedPoints,
          itemCount: itemCount,
          items: itemsSnapshot,
          apiSuccess: apiOk,
          orderStatus: status,
        ),
      ),
    );
  }

  Future<void> _persistOrder({
    required String orderId,
    required String customerId,
    required String customerName,
    required List<CartItem> items,
    required double totalAmount,
    required int earnedPoints,
    required bool apiSuccess,
    required String address,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('local_orders') ?? '[]';
    final orders = jsonDecode(ordersJson) as List<dynamic>;
    final newOrder = {
      'id': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'earnedPoints': earnedPoints,
      'date': DateTime.now().toIso8601String(),
      'status': status,
      'synced': apiSuccess,
      'address': address,
    };
    orders.insert(0, newOrder);
    if (orders.length > 50) orders.removeRange(50, orders.length);
    await prefs.setString('local_orders', jsonEncode(orders));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: YensTheme.cream,
      appBar: AppBar(
        backgroundColor: YensTheme.yellow,
        elevation: 0,
        title: Text(
          'Complete Order',
          style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w900),
        ),
        iconTheme: const IconThemeData(color: YensTheme.navy),
        centerTitle: true,
      ),
      body: _payingStep > 0 
        ? _processingView()
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _sectionHeader('Shipping Details'),
              const SizedBox(height: 16),
              YensTextField(controller: _line1, label: 'Full Address', hint: 'Building, Floor, Unit #', prefixIcon: Icons.location_on_outlined),
              const SizedBox(height: 20),
              YensTextField(controller: _district, label: 'District', hint: 'e.g. Chatuchak, Bangkok', prefixIcon: Icons.map_outlined),
              const SizedBox(height: 20),
              YensTextField(controller: _note, label: 'Barista Note', hint: 'e.g. Extra ice, less sweet please', maxLines: 2, prefixIcon: Icons.edit_note_rounded),
              const SizedBox(height: 40),
              
              _sectionHeader('Order Summary'),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: YensTheme.navy.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ...cart.items.map((e) => _cartItemRow(e)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Total', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: YensTheme.navy)),
                        Text(
                          '฿${cart.totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: YensTheme.navy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text(_error!, style: GoogleFonts.outfit(color: Colors.red.shade900, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
              
              const SizedBox(height: 48),
              SizedBox(
                height: 60,
                child: FilledButton(
                  onPressed: cart.items.isEmpty ? null : () => _mockRazorpayPay(cart.totalPrice),
                  style: FilledButton.styleFrom(
                    backgroundColor: YensTheme.yellow,
                    foregroundColor: YensTheme.navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                    shadowColor: YensTheme.yellow.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.security_rounded, size: 20),
                      const SizedBox(width: 12),
                      Text('Pay ฿${cart.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
    );
  }

  Widget _sectionHeader(String title) {
    return YensTranslateText(
      title,
      style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w900, color: YensTheme.navy),
    );
  }

  Widget _cartItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: YensTheme.yellow.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text('${item.quantity}x', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: YensTheme.navy, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: YensTranslateText(
              item.name,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: YensTheme.navy.withOpacity(0.8)),
            ),
          ),
          Text(
            '฿${item.totalPrice.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: YensTheme.navy),
          ),
        ],
      ),
    );
  }

  Widget _processingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: YensTheme.navy, strokeWidth: 5),
            const SizedBox(height: 32),
            Text(
              'Securing your order...',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: YensTheme.navy),
            ),
            const SizedBox(height: 12),
            Text(
              'Please do not close the app while we process your payment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: YensTheme.navy.withOpacity(0.6), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
