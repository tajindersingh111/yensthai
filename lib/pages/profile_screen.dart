import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yensss/pages/rate_experience_screen.dart';
import 'rate_experience_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map customer = {};
  List transactions = [];

  bool loading = true;
  bool showAll = false;

  String customerId = "2d5ecf87-7bee-496e-b4f1-02d6fb7e8954";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future loadProfile() async {
    await fetchCustomer();
    await fetchTransactions();

    setState(() {
      loading = false;
    });
  }

  /// CUSTOMER API
  Future fetchCustomer() async {
    final url =
        Uri.parse("https://app.yensthai.com/api/customers/phone/+447584156695");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      customer = json.decode(res.body);
    }
  }

  /// TRANSACTIONS API
  Future fetchTransactions() async {
    final url = Uri.parse(
        "https://app.yensthai.com/api/customers/$customerId/transactions");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      transactions = json.decode(res.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String name = customer['name'] ?? "";
    String phone = customer['phone'] ?? "";
    String birthday = customer['birthday'] ?? "";
    int points = customer['points'] ?? 0;

    String initial = name.isNotEmpty ? name[0] : "U";

    int visibleTransactions = showAll
        ? transactions.length
        : (transactions.length > 2 ? 2 : transactions.length);

    return Scaffold(
      backgroundColor: const Color(0xffF5F1EA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                          "Yen's Rewards",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          loading = true;
                        });
                        loadProfile();
                      },
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// USER AVATAR
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xffF6C744),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// NAME
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                phone,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Birthday: $birthday",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              /// POINTS CARD
              /// POINTS CARD (FULL WIDTH LIKE RATE EXPERIENCE)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      color: Colors.orange,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Your Reward Points",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "$points pts",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// RATE EXPERIENCE
              /// RATE EXPERIENCE
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RateExperienceScreen(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.star_border),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rate Your Experience",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // DARK TEXT
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Please rate your satisfaction with our service",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new)
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// CONNECT WITH LINE
              /// CONNECT WITH LINE
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConnectLineScreen(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xffEAF6ED), // light green background
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xff1DB446), // LINE green
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      /// LINE ICON
                      Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xff1DB446),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// TEXT
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Connect with LINE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xff1A2B49),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Get 50 bonus points when you connect!",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// TRANSACTION TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// TRANSACTIONS
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleTransactions,
                itemBuilder: (context, index) {
                  final item = transactions[index];

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['location'] ?? "Order",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item['date'] ?? "",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "+${item['points']} pts",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),

              /// VIEW ALL BUTTON
              if (!showAll && transactions.length > 2)
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAll = true;
                    });
                  },
                  child: const Text("View All"),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectLineScreen extends StatelessWidget {
  const ConnectLineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect LINE"),
      ),
      body: const Center(
        child: Text(
          "LINE connection screen",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
