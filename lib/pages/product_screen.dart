import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List products = [];
  bool loading = true;
  bool english = false;
  final translator = GoogleTranslator();

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

  /// TRANSLATE FUNCTION

  Future<String> translateText(String text) async {
    if (!english) return text;

    try {
      var translated = await translator.translate(
        text,
        from: 'th',
        to: 'en',
      );

      return translated.text;
    } catch (e) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: SafeArea(
        child: loading ? iceCreamLoader() : productBody(),
      ),
    );
  }

  /// LOADER

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
                child: const Icon(
                  Icons.icecream,
                  size: 70,
                  color: Colors.orange,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "Loading delicious ice cream...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// PRODUCT BODY

  Widget productBody() {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth > 900
        ? 4
        : screenWidth > 600
            ? 3
            : 2;

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
                  Image.asset(
                    "assets/logo.jpg",
                    height: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Yen's Thai",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  /// LANGUAGE BUTTON

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        english = !english;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        english ? "EN" : "TH",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// REFRESH

                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        loading = true;
                      });
                      fetchProducts();
                    },
                  ),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 10),

        /// PRODUCT GRID

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.5,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              String imageUrl =
                  "https://app.yensthai.com${product['imageUrl']}";

              return productCard(product, imageUrl);
            },
          ),
        )
      ],
    );
  }

  /// PRODUCT CARD

  Widget productCard(product, String imageUrl) {
    return GestureDetector(
      onTap: () {
        showProductDetails(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE

            SizedBox(
              height: 150,
              width: double.infinity,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
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
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text(product['name']);
                        }

                        return Text(
                          snapshot.data!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$${product['price']}",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xffF6C744),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// PRODUCT DETAILS POPUP

  void showProductDetails(product) {
    String imageUrl = "https://app.yensthai.com${product['imageUrl']}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1.6,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<String>(
                future: translateText(product['name']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(product['name']);
                  }

                  return Text(
                    snapshot.data!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                "\$${product['price']}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xffF6C744),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Add to Cart",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
