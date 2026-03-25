// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:translator/translator.dart';
// //
// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({super.key});
// //
// //   @override
// //   State<HomeScreen> createState() => _HomeScreenState();
// // }
// //
// // class _HomeScreenState extends State<HomeScreen> {
// //
// //   Map customer = {};
// //   List products = [];
// //
// //   bool loading = true;
// //   bool english = false;
// //
// //   final translator = GoogleTranslator();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadData();
// //   }
// //
// //   Future loadData() async {
// //     await fetchCustomer();
// //     await fetchProducts();
// //
// //     setState(() {
// //       loading = false;
// //     });
// //   }
// //
// //   /// TRANSLATE FUNCTION
// //
// //   Future<String> translateText(String text) async {
// //
// //     if (!english) return text;
// //
// //     try {
// //
// //       var translated = await translator.translate(
// //         text,
// //         from: 'th',
// //         to: 'en',
// //       );
// //
// //       return translated.text;
// //
// //     } catch (e) {
// //
// //       return text;
// //
// //     }
// //
// //   }
// //
// //   /// CUSTOMER API
// //
// //   Future fetchCustomer() async {
// //     final url =
// //     Uri.parse("https://app.yensthai.com/api/customers/phone/+447584156695");
// //
// //     final res = await http.get(url);
// //
// //     if (res.statusCode == 200) {
// //       setState(() {
// //         customer = json.decode(res.body);
// //       });
// //     }
// //   }
// //
// //   /// PRODUCTS API
// //
// //   Future fetchProducts() async {
// //     final url = Uri.parse("https://app.yensthai.com/api/products");
// //
// //     final res = await http.get(url);
// //
// //     if (res.statusCode == 200) {
// //       setState(() {
// //         products = json.decode(res.body);
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //
// //     if (loading) {
// //       return const Scaffold(
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }
// //
// //     return Scaffold(
// //
// //       backgroundColor: const Color(0xffF5F1EA),
// //
// //       body: SafeArea(
// //
// //         child: SingleChildScrollView(
// //
// //           child: Column(
// //
// //             children: [
// //
// //               /// HEADER
// //
// //               Container(
// //                 padding:
// //                 const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                 color: const Color(0xffF6C744),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //
// //                     Row(
// //                       children: [
// //                         Image.asset(
// //                           "assets/logo.jpg",
// //                           height: 30,
// //                         ),
// //                         const SizedBox(width: 10),
// //                         const Text(
// //                           "Yen's Thai",
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                           ),
// //                         )
// //                       ],
// //                     ),
// //
// //                     Row(
// //                       children: [
// //
// //                         /// LANGUAGE BUTTON
// //
// //                         GestureDetector(
// //                           onTap: (){
// //                             setState(() {
// //                               english = !english;
// //                             });
// //                           },
// //                           child: Container(
// //                             padding: const EdgeInsets.symmetric(
// //                                 horizontal:10, vertical:6),
// //                             decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(20),
// //                             ),
// //                             child: Text(
// //                               english ? "EN" : "TH",
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //
// //                         const SizedBox(width:10),
// //
// //                         IconButton(
// //                           icon: const Icon(Icons.refresh),
// //                           onPressed: () {
// //                             loadData();
// //                           },
// //                         ),
// //
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 12),
// //
// //               /// PROMO BANNER
// //
// //               Container(
// //                 margin: const EdgeInsets.symmetric(horizontal: 16),
// //                 height: 320,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(16),
// //                   image: const DecorationImage(
// //                     image: AssetImage("assets/yens.png"),
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 16),
// //
// //               /// POINTS CARD
// //
// //               Container(
// //                 margin: const EdgeInsets.symmetric(horizontal: 16),
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: const Row(
// //                   children: [
// //
// //                     SizedBox(width:50,height:50),
// //
// //                     SizedBox(width:12),
// //
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             "You're 25 points away!",
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           Text(
// //                             "Points until your next reward",
// //                             style: TextStyle(
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     )
// //
// //                   ],
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 16),
// //
// //               /// QR CARD
// //
// //               Container(
// //                 margin: const EdgeInsets.symmetric(horizontal: 16),
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: Row(
// //                   children: [
// //
// //                     Container(
// //                       width: 90,
// //                       height: 90,
// //                       color: Colors.grey.shade200,
// //                       child: const Icon(Icons.qr_code),
// //                     ),
// //
// //                     const SizedBox(width: 12),
// //
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //
// //                         FutureBuilder<String>(
// //
// //                           future: translateText(customer['name'] ?? ""),
// //
// //                           builder: (context, snapshot) {
// //
// //                             if (!snapshot.hasData) {
// //                               return Text(customer['name'] ?? "");
// //                             }
// //
// //                             return Text(
// //                               snapshot.data!,
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             );
// //
// //                           },
// //
// //                         ),
// //
// //                         FutureBuilder<String>(
// //
// //                           future: translateText("Show this to the barista"),
// //
// //                           builder: (context, snapshot) {
// //
// //                             if (!snapshot.hasData) {
// //                               return const Text("Show this to the barista");
// //                             }
// //
// //                             return Text(
// //                               snapshot.data!,
// //                               style: const TextStyle(
// //                                 color: Colors.grey,
// //                               ),
// //                             );
// //
// //                           },
// //
// //                         )
// //
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 20),
// //
// //               /// PRODUCT LIST
// //
// //               ListView.builder(
// //
// //                 shrinkWrap: true,
// //
// //                 physics: const NeverScrollableScrollPhysics(),
// //
// //                 itemCount: products.length,
// //
// //                 itemBuilder: (context, index) {
// //
// //                   final product = products[index];
// //
// //                   String imageUrl =
// //                       "https://app.yensthai.com${product['imageUrl']}";
// //
// //                   return Container(
// //
// //                     margin:
// //                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //
// //                     padding: const EdgeInsets.all(12),
// //
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(16),
// //                     ),
// //
// //                     child: Row(
// //
// //                       children: [
// //
// //                         /// IMAGE
// //
// //                         ClipRRect(
// //                           borderRadius: BorderRadius.circular(8),
// //                           child: Image.network(
// //                             imageUrl,
// //                             height: 50,
// //                             width: 50,
// //                             fit: BoxFit.cover,
// //                           ),
// //                         ),
// //
// //                         const SizedBox(width: 12),
// //
// //                         /// PRODUCT INFO
// //
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //
// //                               FutureBuilder<String>(
// //
// //                                 future: translateText(product['name']),
// //
// //                                 builder: (context, snapshot) {
// //
// //                                   if (!snapshot.hasData) {
// //                                     return Text(product['name']);
// //                                   }
// //
// //                                   return Text(
// //                                     snapshot.data!,
// //                                     style: const TextStyle(
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   );
// //
// //                                 },
// //
// //                               ),
// //
// //                               Text(
// //                                 "${product['rewardPoints'] ?? 50} Points",
// //                                 style: const TextStyle(
// //                                   color: Colors.grey,
// //                                 ),
// //                               ),
// //
// //                             ],
// //                           ),
// //                         ),
// //
// //                         const Icon(Icons.more_horiz)
// //
// //                       ],
// //
// //                     ),
// //
// //                   );
// //
// //                 },
// //
// //               ),
// //
// //               const SizedBox(height: 20),
// //
// //             ],
// //
// //           ),
// //
// //         ),
// //
// //       ),
// //
// //     );
// //
// //   }
// //
// // }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:translator/translator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:yensss/pages/profile_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   Map customer = {};
//   List products = [];
//
//   bool loading = true;
//   bool english = false;
//
//   String loggedInPhone = "";
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
//     await getLoggedInUser();
//     await fetchCustomer();
//     await fetchProducts();
//     setState(() => loading = false);
//   }
//
//   /// GET LOGGED IN USER FROM SHARED PREFERENCES
//   Future getLoggedInUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     loggedInPhone = prefs.getString('customer_phone') ?? "";
//   }
//
//   /// TRANSLATE FUNCTION
//   Future<String> translateText(String text) async {
//     if (!english) return text;
//     try {
//       var translated = await translator.translate(text, from: 'th', to: 'en');
//       return translated.text;
//     } catch (e) {
//       return text;
//     }
//   }
//
//   /// CUSTOMER API — logged in user ka data
//   Future fetchCustomer() async {
//     if (loggedInPhone.isEmpty) return;
//
//     final url = Uri.parse(
//         "https://app.yensthai.com/api/customers/phone/$loggedInPhone");
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
//   Future fetchProducts() async {
//     final url = Uri.parse("https://app.yensthai.com/api/products");
//     final res = await http.get(url);
//     if (res.statusCode == 200) {
//       setState(() {
//         products = json.decode(res.body);
//       });
//     }
//   }
//
//   /// QR DATA — phone ya customer ID se
//   String get qrData {
//     if (customer['id'] != null) return customer['id'];
//     if (loggedInPhone.isNotEmpty) return loggedInPhone;
//     return "unknown";
//   }
//
//   /// POINTS PROGRESS
//   int get points => customer['points'] ?? 0;
//   int get pointsUntilNext {
//     int next = ((points ~/ 100) + 1) * 100;
//     return next - points;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: const Color(0xffF5F1EA),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//
//               /// HEADER
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 color: const Color(0xffF6C744),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Image.asset("assets/logo.jpg", height: 30),
//                         const SizedBox(width: 10),
//                         const Text(
//                           "Yen's Thai",
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () => setState(() => english = !english),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               english ? "EN" : "TH",
//                               style: const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         IconButton(
//                           icon: const Icon(Icons.refresh),
//                           onPressed: loadData,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               /// PROMO BANNER
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
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       decoration: const BoxDecoration(
//                         color: Color(0xffFEF3D0),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.stars, color: Color(0xffBA7517)),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "You're $pointsUntilNext points away!",
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             "$points pts • Points until your next reward",
//                             style: const TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               /// QR CARD — click karo profile khulega
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ProfileScreen(),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(
//                     children: [
//
//                       /// QR CODE
//                       Container(
//                         width: 90,
//                         height: 90,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: QrImageView(
//                           data: qrData,
//                           version: QrVersions.auto,
//                           size: 90,
//                           backgroundColor: Colors.white,
//                         ),
//                       ),
//
//                       const SizedBox(width: 12),
//
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//
//                             /// USER NAME
//                             FutureBuilder<String>(
//                               future: translateText(customer['name'] ?? ""),
//                               builder: (context, snapshot) {
//                                 return Text(
//                                   snapshot.data ?? customer['name'] ?? "",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 );
//                               },
//                             ),
//
//                             const SizedBox(height: 4),
//
//                             /// PHONE
//                             Text(
//                               customer['phone'] ?? loggedInPhone,
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 13,
//                               ),
//                             ),
//
//                             const SizedBox(height: 6),
//
//                             /// SHOW THIS TO BARISTA
//                             FutureBuilder<String>(
//                               future: translateText("Show this to the barista"),
//                               builder: (context, snapshot) {
//                                 return Row(
//                                   children: [
//                                     const Icon(Icons.touch_app, size: 14, color: Colors.orange),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       snapshot.data ?? "Show this to the barista",
//                                       style: const TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),
//
//                           ],
//                         ),
//                       ),
//
//                       /// ARROW
//                       const Icon(Icons.chevron_right, color: Colors.grey),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               /// PRODUCT LIST
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: products.length,
//                 itemBuilder: (context, index) {
//                   final product = products[index];
//                   String imageUrl = "https://app.yensthai.com${product['imageUrl']}";
//
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Row(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.network(
//                             imageUrl,
//                             height: 50,
//                             width: 50,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               FutureBuilder<String>(
//                                 future: translateText(product['name']),
//                                 builder: (context, snapshot) {
//                                   return Text(
//                                     snapshot.data ?? product['name'],
//                                     style: const TextStyle(fontWeight: FontWeight.bold),
//                                   );
//                                 },
//                               ),
//                               Text(
//                                 "${product['rewardPoints'] ?? 50} Points",
//                                 style: const TextStyle(color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Icon(Icons.more_horiz),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yensss/pages/profile_screen.dart';
import 'package:yensss/pages/cart_page.dart';
import 'cart_provider.dart';

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
    loadData();
  }

  Future loadData() async {
    await getLoggedInUser();
    await fetchCustomer();
    await fetchProducts();
    setState(() => loading = false);
  }

  Future getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    loggedInPhone = prefs.getString('customer_phone') ?? "";
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

  Future fetchCustomer() async {
    if (loggedInPhone.isEmpty) return;
    final url = Uri.parse("https://app.yensthai.com/api/customers/phone/$loggedInPhone");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() => customer = json.decode(res.body));
    }
  }

  Future fetchProducts() async {
    final url = Uri.parse("https://app.yensthai.com/api/products");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() => products = json.decode(res.body));
    }
  }

  List get filteredProducts {
    if (selectedCategory == "all") return products;
    return products.where((p) => p['category'] == selectedCategory).toList();
  }

  String get qrData {
    if (customer['id'] != null) return customer['id'];
    if (loggedInPhone.isNotEmpty) return loggedInPhone;
    return "unknown";
  }

  int get points => customer['points'] ?? 0;
  int get pointsUntilNext {
    int next = ((points ~/ 100) + 1) * 100;
    return next - points;
  }

  void _addToCart(BuildContext context, Map product) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(
      productId: product['id'],
      name: product['name'],
      imageUrl: product['imageUrl'] ?? '',
      price: double.tryParse(product['price'].toString()) ?? 0,
      rewardPoints: product['rewardPoints'] ?? (double.tryParse(product['price'].toString()) ?? 0).round(),
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
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<CartProvider>(
      builder: (context, cart, child) {
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

                            /// CART ICON
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage())),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.shopping_cart_outlined, size: 22),
                                  ),
                                  if (cart.itemCount > 0)
                                    Positioned(
                                      right: 0, top: 0,
                                      child: Container(
                                        width: 18, height: 18,
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: Center(
                                          child: Text(
                                            "${cart.itemCount}",
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

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
                      image: const DecorationImage(image: AssetImage("assets/yens.png"), fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// POINTS CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: const BoxDecoration(color: Color(0xffFEF3D0), shape: BoxShape.circle),
                          child: const Icon(Icons.stars, color: Color(0xffBA7517)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("You're $pointsUntilNext points away!", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("$points pts • Points until your next reward", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// QR CARD
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                            child: QrImageView(data: qrData, version: QrVersions.auto, size: 90, backgroundColor: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(customer['phone'] ?? loggedInPhone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 6),
                                Row(children: const [
                                  Icon(Icons.touch_app, size: 14, color: Colors.orange),
                                  SizedBox(width: 4),
                                  Text("Show this to the barista", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ]),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// MENU TITLE
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Our Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// CATEGORY FILTER
                  SizedBox(
                    height: 40,
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

                  const SizedBox(height: 12),

                  /// PRODUCT LIST
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final String imageUrl = "https://app.yensthai.com${product['imageUrl']}";
                      final double price = double.tryParse(product['price'].toString()) ?? 0;
                      final int rewardPts = product['rewardPoints'] ?? price.round();
                      final inCart = cart.isInCart(product['id']);
                      final qty = cart.quantityOf(product['id']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            /// IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                height: 70, width: 70, fit: BoxFit.contain, // full fit
                                errorBuilder: (_, __, ___) => Container(
                                  height: 70, width: 70,
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
                                  FutureBuilder<String>(
                                    future: translateText(product['name']),
                                    builder: (context, snapshot) => Text(
                                      snapshot.data ?? product['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("฿${price.toStringAsFixed(0)}", style: const TextStyle(color: Color(0xffF5C021), fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text("+$rewardPts pts", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),

                            /// ADD TO CART
                            if (inCart)
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Provider.of<CartProvider>(context, listen: false).removeItem(product['id']),
                                    child: Container(
                                      width: 30, height: 30,
                                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                                      child: const Icon(Icons.remove, size: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  GestureDetector(
                                    onTap: () => _addToCart(context, product),
                                    child: Container(
                                      width: 30, height: 30,
                                      decoration: const BoxDecoration(color: Color(0xffF5C021), shape: BoxShape.circle),
                                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            else
                              GestureDetector(
                                onTap: () => _addToCart(context, product),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF5C021),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
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

          /// FLOATING CART BUTTON
          floatingActionButton: cart.itemCount > 0
              ? GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage())),
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
                  Text("${cart.itemCount} items • ฿${cart.totalPrice.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
              : null,
        );
      },
    );
  }
}