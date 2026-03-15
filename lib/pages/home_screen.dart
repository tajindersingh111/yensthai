import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Map customer = {};
  List products = [];

  bool loading = true;
  bool english = false;

  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    await fetchCustomer();
    await fetchProducts();

    setState(() {
      loading = false;
    });
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

  /// CUSTOMER API

  Future fetchCustomer() async {
    final url =
    Uri.parse("https://app.yensthai.com/api/customers/phone/+447584156695");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      setState(() {
        customer = json.decode(res.body);
      });
    }
  }

  /// PRODUCTS API

  Future fetchProducts() async {
    final url = Uri.parse("https://app.yensthai.com/api/products");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      setState(() {
        products = json.decode(res.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      backgroundColor: const Color(0xffF5F1EA),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Column(

            children: [

              /// HEADER

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xffF6C744),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Row(
                      children: [
                        Image.asset(
                          "assets/logo.jpg",
                          height: 30,
                        ),
                        const SizedBox(width: 10),
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
                          onTap: (){
                            setState(() {
                              english = !english;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal:10, vertical:6),
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

                        const SizedBox(width:10),

                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            loadData();
                          },
                        ),

                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// PROMO BANNER

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage("assets/yens.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// POINTS CARD

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [

                    SizedBox(width:50,height:50),

                    SizedBox(width:12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You're 25 points away!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Points until your next reward",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )

                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// QR CARD

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [

                    Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.qr_code),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        FutureBuilder<String>(

                          future: translateText(customer['name'] ?? ""),

                          builder: (context, snapshot) {

                            if (!snapshot.hasData) {
                              return Text(customer['name'] ?? "");
                            }

                            return Text(
                              snapshot.data!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );

                          },

                        ),

                        FutureBuilder<String>(

                          future: translateText("Show this to the barista"),

                          builder: (context, snapshot) {

                            if (!snapshot.hasData) {
                              return const Text("Show this to the barista");
                            }

                            return Text(
                              snapshot.data!,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            );

                          },

                        )

                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// PRODUCT LIST

              ListView.builder(

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: products.length,

                itemBuilder: (context, index) {

                  final product = products[index];

                  String imageUrl =
                      "https://app.yensthai.com${product['imageUrl']}";

                  return Container(

                    margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Row(

                      children: [

                        /// IMAGE

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// PRODUCT INFO

                        Expanded(
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );

                                },

                              ),

                              Text(
                                "${product['rewardPoints'] ?? 50} Points",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                            ],
                          ),
                        ),

                        const Icon(Icons.more_horiz)

                      ],

                    ),

                  );

                },

              ),

              const SizedBox(height: 20),

            ],

          ),

        ),

      ),

    );

  }

}