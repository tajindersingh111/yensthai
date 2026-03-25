import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'cart_page.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List products = [];
  bool loading = true;
  bool english = false;
  String selectedCategory = "all";
  final translator = GoogleTranslator();

  final List<Map<String, String>> categories = [
    {"id": "all", "label": "All"},
    {"id": "fruit_tea", "label": "Fruit Tea"},
    {"id": "milk_tea", "label": "Milk Tea"},
    {"id": "shakes", "label": "Shakes"},
    {"id": "soft_serve", "label": "Soft Serve"},
    {"id": "sundaes", "label": "Sundaes"},
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future fetchProducts() async {
    final url = Uri.parse("https://app.yensthai.com/api/products");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
        loading = false;
      });
    }
  }

  Future<String> translateText(String text) async {
    if (!english) return text;
    try {
      var translated = await translator.translate(text, from: 'th', to: 'en');
      return translated.text;
    } catch (e) {
      return text;
    }
  }

  List get filteredProducts {
    if (selectedCategory == "all") return products;
    return products.where((p) => p['category'] == selectedCategory).toList();
  }

  void _addToCart(BuildContext context, Map product) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final double price = double.tryParse(product['price'].toString()) ?? 0;
    cart.addItem(
      productId: product['id'],
      name: product['name'],
      imageUrl: product['imageUrl'] ?? '',
      price: price,
      rewardPoints: product['rewardPoints'] ?? price.round(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product['name']} added to cart!"),
        backgroundColor: const Color(0xffF5C021),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF7F7F7),
          body: SafeArea(
            child: loading ? iceCreamLoader() : productBody(cart),
          ),
          floatingActionButton: cart.itemCount > 0
              ? GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xffF5C021),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "${cart.itemCount} items • ฿${cart.totalPrice.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
              : null,
        );
      },
    );
  }

  Widget iceCreamLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 6.28),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value,
                child: const Icon(Icons.icecream, size: 70, color: Colors.orange),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text("Loading delicious ice cream...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget productBody(CartProvider cart) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 900 ? 4 : screenWidth > 600 ? 3 : 2;

    return Column(
      children: [
        /// HEADER
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xffF6C744),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset("assets/logo.jpg", height: 28),
                  const SizedBox(width: 8),
                  const Text("Yen's Thai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => english = !english),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text(english ? "EN" : "TH", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  /// CART ICON WITH BADGE
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.shopping_cart_outlined, size: 22),
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 18, height: 18,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Center(
                                child: Text("${cart.itemCount}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () { setState(() => loading = true); fetchProducts(); },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        /// CATEGORY FILTER
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategory == cat['id'];
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = cat['id']!),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xffF5C021) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? const Color(0xffF5C021) : Colors.grey.shade300),
                  ),
                  child: Text(
                    cat['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        /// PRODUCT GRID
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final String imageUrl = "https://app.yensthai.com${product['imageUrl']}";
              return productCard(product, imageUrl, cart);
            },
          ),
        ),
      ],
    );
  }

  Widget productCard(product, String imageUrl, CartProvider cart) {
    final double price = double.tryParse(product['price'].toString()) ?? 0;
    final bool inCart = cart.isInCart(product['id']);
    final int qty = cart.quantityOf(product['id']);

    return GestureDetector(
      onTap: () => showProductDetails(product, cart),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            SizedBox(
              height: 150,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),

            /// TEXT AREA
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: translateText(product['name']),
                      builder: (context, snapshot) => Text(
                        snapshot.data ?? product['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("฿${price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    Text("+${price.round()} pts", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const Spacer(),

                    /// ADD TO CART BUTTON
                    inCart
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => cart.removeItem(product['id']),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                            child: const Icon(Icons.remove, size: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        GestureDetector(
                          onTap: () => _addToCart(context, product),
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(color: Color(0xffF5C021), shape: BoxShape.circle),
                            child: const Icon(Icons.add, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                        : GestureDetector(
                      onTap: () => _addToCart(context, product),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: const Color(0xffF6C744),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Text("Add to Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showProductDetails(product, CartProvider cart) {
    final String imageUrl = "https://app.yensthai.com${product['imageUrl']}";
    final double price = double.tryParse(product['price'].toString()) ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final inCart = cart.isInCart(product['id']);
            final qty = cart.quantityOf(product['id']);

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: Image.network(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: translateText(product['name']),
                    builder: (context, snapshot) => Text(
                      snapshot.data ?? product['name'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("฿${price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Icon(Icons.stars, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text("+${price.round()} pts", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// CART CONTROLS IN MODAL
                  inCart
                      ? Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () { cart.removeItem(product['id']); setModalState(() {}); },
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                                child: const Icon(Icons.remove),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            ),
                            GestureDetector(
                              onTap: () { _addToCart(context, product); setModalState(() {}); },
                              child: Container(
                                width: 40, height: 40,
                                decoration: const BoxDecoration(color: Color(0xffF5C021), shape: BoxShape.circle),
                                child: const Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      : GestureDetector(
                    onTap: () { _addToCart(context, product); setModalState(() {}); },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: const Color(0xffF6C744), borderRadius: BorderRadius.circular(25)),
                      child: const Center(child: Text("Add to Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}