// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:translator/translator.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//
//   Map customer = {};
//   List products = [];
//
//   bool loading = true;
//   bool english = false;
//
//   final translator = GoogleTranslator();
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   Future loadData() async {
//     await fetchCustomer();
//     await fetchProducts();
//
//     setState(() {
//       loading = false;
//     });
//   }
//
//   /// TRANSLATE FUNCTION
//
//   Future<String> translateText(String text) async {
//
//     if (!english) return text;
//
//     try {
//
//       var translated = await translator.translate(
//         text,
//         from: 'th',
//         to: 'en',
//       );
//
//       return translated.text;
//
//     } catch (e) {
//
//       return text;
//
//     }
//
//   }
//
//   /// CUSTOMER API
//
//   Future fetchCustomer() async {
//     final url =
//     Uri.parse("https://app.yensthai.com/api/customers/phone/+447584156695");
//
//     final res = await http.get(url);
//
//     if (res.statusCode == 200) {
//       setState(() {
//         customer = json.decode(res.body);
//       });
//     }
//   }
//
//   /// PRODUCTS API
//
//   Future fetchProducts() async {
//     final url = Uri.parse("https://app.yensthai.com/api/products");
//
//     final res = await http.get(url);
//
//     if (res.statusCode == 200) {
//       setState(() {
//         products = json.decode(res.body);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//
//       backgroundColor: const Color(0xffF5F1EA),
//
//       body: SafeArea(
//
//         child: SingleChildScrollView(
//
//           child: Column(
//
//             children: [
//
//               /// HEADER
//
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 color: const Color(0xffF6C744),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//
//                     Row(
//                       children: [
//                         Image.asset(
//                           "assets/logo.jpg",
//                           height: 30,
//                         ),
//                         const SizedBox(width: 10),
//                         const Text(
//                           "Yen's Thai",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         )
//                       ],
//                     ),
//
//                     Row(
//                       children: [
//
//                         /// LANGUAGE BUTTON
//
//                         GestureDetector(
//                           onTap: (){
//                             setState(() {
//                               english = !english;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal:10, vertical:6),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               english ? "EN" : "TH",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(width:10),
//
//                         IconButton(
//                           icon: const Icon(Icons.refresh),
//                           onPressed: () {
//                             loadData();
//                           },
//                         ),
//
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               /// PROMO BANNER
//
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 height: 320,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   image: const DecorationImage(
//                     image: AssetImage("assets/yens.png"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               /// POINTS CARD
//
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: const Row(
//                   children: [
//
//                     SizedBox(width:50,height:50),
//
//                     SizedBox(width:12),
//
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "You're 25 points away!",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             "Points until your next reward",
//                             style: TextStyle(
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               /// QR CARD
//
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//
//                     Container(
//                       width: 90,
//                       height: 90,
//                       color: Colors.grey.shade200,
//                       child: const Icon(Icons.qr_code),
//                     ),
//
//                     const SizedBox(width: 12),
//
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//
//                         FutureBuilder<String>(
//
//                           future: translateText(customer['name'] ?? ""),
//
//                           builder: (context, snapshot) {
//
//                             if (!snapshot.hasData) {
//                               return Text(customer['name'] ?? "");
//                             }
//
//                             return Text(
//                               snapshot.data!,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             );
//
//                           },
//
//                         ),
//
//                         FutureBuilder<String>(
//
//                           future: translateText("Show this to the barista"),
//
//                           builder: (context, snapshot) {
//
//                             if (!snapshot.hasData) {
//                               return const Text("Show this to the barista");
//                             }
//
//                             return Text(
//                               snapshot.data!,
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                               ),
//                             );
//
//                           },
//
//                         )
//
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               /// PRODUCT LIST
//
//               ListView.builder(
//
//                 shrinkWrap: true,
//
//                 physics: const NeverScrollableScrollPhysics(),
//
//                 itemCount: products.length,
//
//                 itemBuilder: (context, index) {
//
//                   final product = products[index];
//
//                   String imageUrl =
//                       "https://app.yensthai.com${product['imageUrl']}";
//
//                   return Container(
//
//                     margin:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//
//                     padding: const EdgeInsets.all(12),
//
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//
//                     child: Row(
//
//                       children: [
//
//                         /// IMAGE
//
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.network(
//                             imageUrl,
//                             height: 50,
//                             width: 50,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//
//                         const SizedBox(width: 12),
//
//                         /// PRODUCT INFO
//
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//
//                               FutureBuilder<String>(
//
//                                 future: translateText(product['name']),
//
//                                 builder: (context, snapshot) {
//
//                                   if (!snapshot.hasData) {
//                                     return Text(product['name']);
//                                   }
//
//                                   return Text(
//                                     snapshot.data!,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   );
//
//                                 },
//
//                               ),
//
//                               Text(
//                                 "${product['rewardPoints'] ?? 50} Points",
//                                 style: const TextStyle(
//                                   color: Colors.grey,
//                                 ),
//                               ),
//
//                             ],
//                           ),
//                         ),
//
//                         const Icon(Icons.more_horiz)
//
//                       ],
//
//                     ),
//
//                   );
//
//                 },
//
//               ),
//
//               const SizedBox(height: 20),
//
//             ],
//
//           ),
//
//         ),
//
//       ),
//
//     );
//
//   }
//
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:yensss/pages/profile_screen.dart';

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

  String loggedInPhone = "";

  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    await getLoggedInUser();
    await fetchCustomer();
    await fetchProducts();
    setState(() => loading = false);
  }

  /// GET LOGGED IN USER FROM SHARED PREFERENCES
  Future getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    loggedInPhone = prefs.getString('customer_phone') ?? "";
  }

  /// TRANSLATE FUNCTION
  Future<String> translateText(String text) async {
    if (!english) return text;
    try {
      var translated = await translator.translate(text, from: 'th', to: 'en');
      return translated.text;
    } catch (e) {
      return text;
    }
  }

  /// CUSTOMER API — logged in user ka data
  Future fetchCustomer() async {
    if (loggedInPhone.isEmpty) return;

    final url = Uri.parse(
        "https://app.yensthai.com/api/customers/phone/$loggedInPhone");

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

  /// QR DATA — phone ya customer ID se
  String get qrData {
    if (customer['id'] != null) return customer['id'];
    if (loggedInPhone.isNotEmpty) return loggedInPhone;
    return "unknown";
  }

  /// POINTS PROGRESS
  int get points => customer['points'] ?? 0;
  int get pointsUntilNext {
    int next = ((points ~/ 100) + 1) * 100;
    return next - points;
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xffF6C744),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/logo.jpg", height: 30),
                        const SizedBox(width: 10),
                        const Text(
                          "Yen's Thai",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => english = !english),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              english ? "EN" : "TH",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: loadData,
                        ),
                      ],
                    ),
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
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xffFEF3D0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: Color(0xffBA7517)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You're $pointsUntilNext points away!",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "$points pts • Points until your next reward",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// QR CARD — click karo profile khulega
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [

                      /// QR CODE
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 90,
                          backgroundColor: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// USER NAME
                            FutureBuilder<String>(
                              future: translateText(customer['name'] ?? ""),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? customer['name'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 4),

                            /// PHONE
                            Text(
                              customer['phone'] ?? loggedInPhone,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// SHOW THIS TO BARISTA
                            FutureBuilder<String>(
                              future: translateText("Show this to the barista"),
                              builder: (context, snapshot) {
                                return Row(
                                  children: [
                                    const Icon(Icons.touch_app, size: 14, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      snapshot.data ?? "Show this to the barista",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                          ],
                        ),
                      ),

                      /// ARROW
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
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
                  String imageUrl = "https://app.yensthai.com${product['imageUrl']}";

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String>(
                                future: translateText(product['name']),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? product['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                              Text(
                                "${product['rewardPoints'] ?? 50} Points",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_horiz),
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