import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {

  List products = [];
  bool loading = true;

  bool english = false;

  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  /// API CALL

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

      backgroundColor: const Color(0xffF5F1EA),

      body: SafeArea(

        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(

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

            /// LIST

            Expanded(

              child: ListView.builder(

                padding: const EdgeInsets.symmetric(horizontal: 16),

                itemCount: products.length,

                itemBuilder: (context, index) {

                  final product = products[index];

                  String name = product['name'];

                  String imageUrl =
                      "https://app.yensthai.com${product['imageUrl']}";

                  return Container(

                    margin: const EdgeInsets.only(bottom: 16),

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [

                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                          offset: const Offset(0,4),
                        )

                      ],

                    ),

                    child: Row(

                      children: [

                        /// IMAGE

                        ClipRRect(

                          borderRadius: BorderRadius.circular(12),

                          child: Container(

                            height: 80,
                            width: 80,

                            color: Colors.grey.shade100,

                            child: Padding(

                              padding: const EdgeInsets.all(6),

                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stack) {
                                  return const Icon(
                                    Icons.image,
                                    size: 40,
                                  );
                                },
                              ),

                            ),

                          ),

                        ),

                        const SizedBox(width: 14),

                        /// NAME + POINTS

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              FutureBuilder<String>(

                                future: translateText(name),

                                builder: (context, snapshot) {

                                  if (!snapshot.hasData) {
                                    return Text(name);
                                  }

                                  return Text(
                                    snapshot.data!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );

                                },

                              ),

                              const SizedBox(height: 6),

                              Container(

                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4),

                                decoration: BoxDecoration(

                                  color: const Color(0xffF6C744),

                                  borderRadius:
                                  BorderRadius.circular(20),

                                ),

                                child: const Text(

                                  "50 Points",

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),

                                ),

                              ),

                            ],

                          ),

                        ),

                      ],

                    ),

                  );

                },

              ),

            )

          ],

        ),

      ),

    );

  }

}