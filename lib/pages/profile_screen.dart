import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yensss/core/app_config.dart';
import '../core/yens_theme.dart';
import '../widgets/yens_app_drawer.dart';
import '../widgets/yens_main_header.dart';
import 'rewards_intro_page.dart';
import '../core/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map customer = {};
  bool loading = true;
  String name = "Guest User";
  String phone = "";
  String tier = "member";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('customer_phone') ?? "";
    
    if (phone.isNotEmpty) {
      try {
        final url = Uri.parse("${AppConfig.apiBase}/api/customers/phone/$phone");
        final res = await http.get(url);
        if (res.statusCode == 200) {
          if (mounted) {
            setState(() {
              customer = json.decode(res.body);
              name = customer['name'] ?? "Guest User";
              tier = (customer['tier'] ?? 'member').toString().toLowerCase();
            });
          }
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
    if (mounted) setState(() => loading = false);
  }

  String get _initials {
    if (name.isEmpty || name == "Guest User") return "GU";
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: YensTheme.cream,
      drawer: const YensAppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            YensMainHeader.main(
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // --- TOP SECTION (Avatar & Tier) ---
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: YensTheme.yellow,
                      child: Text(
                        _initials,
                        style: GoogleFonts.dmSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: YensTheme.navy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.dmSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: YensTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTierBadge(),
                    const SizedBox(height: 24),
                    
                    // --- EDIT BUTTON (Tonal Style) ---
                    FilledButton.tonal(
                      onPressed: () => _showPersonalItemPopBox(),
                      style: FilledButton.styleFrom(
                        backgroundColor: YensTheme.yellow.withOpacity(0.3),
                        foregroundColor: YensTheme.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      child: Text('Edit profile', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                    ),
                    
                    const SizedBox(height: 48),

                    // --- BOTTOM LIST SECTION ---
                    _buildSectionHeader("ACCOUNT DETAILS"),
                    _buildProfileItem("Your mobile order(s)", Icons.receipt_long_outlined, () => _showOrdersPopBox()),
                    _buildProfileItem("My credit / debit cards", Icons.credit_card_outlined, () => _showCardsPopBox()),
                    _buildProfileItem("Delivery address", Icons.location_on_outlined, () => _showPopBox("Delivery Address", "Manage your delivery locations.")),
                    _buildProfileItem("Personal information", Icons.person_outline, () => _showPersonalItemPopBox()),
                    _buildProfileItem("Yens Rewards", Icons.star_outline_rounded, () => _showRewardsPopBox()),

                    const SizedBox(height: 32),
                    _buildSectionHeader("SETTINGS"),
                    _buildProfileItem("General", Icons.settings_outlined, () => _showPopBox("General Settings", "App-wide preferences.")),
                    _buildProfileItem("Security", Icons.lock_outline, () => _showSecurityPopBox()),
                    _buildProfileItem(
                      "Language", 
                      Icons.language_outlined, 
                      () => _showPopBox("Language", "Select your preferred language."),
                      trailing: Text(
                        "English",
                        style: GoogleFonts.dmSans(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader("ABOUT"),
                    _buildProfileItem("FAQs", Icons.help_outline, () => _showFAQsPopBox()),
                    _buildProfileItem("Terms of use", Icons.article_outlined, () => _showPopBox("Terms of use", "Review our terms and conditions.")),
                    
                    const SizedBox(height: 48),
                    
                    // --- LOG OUT ---
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await SessionService.instance.logout();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const RewardsIntroPage()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text(
                        "Log Out",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierBadge() {
    Color bg = Colors.grey.shade200;
    Color fg = Colors.grey.shade600;
    if (tier == 'gold') {
      bg = const Color(0xFFFFD700).withOpacity(0.2);
      fg = const Color(0xFFB8860B);
    } else if (tier == 'silver') {
      bg = const Color(0xFFC0C0C0).withOpacity(0.2);
      fg = const Color(0xFF708090);
    } else {
      bg = YensTheme.yellow.withOpacity(0.2);
      fg = YensTheme.navy;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "${tier[0].toUpperCase()}${tier.substring(1)} Member",
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String title, IconData icon, VoidCallback onTap, {Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: YensTheme.navy.withOpacity(0.9),
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 8),
            ],
            Icon(icon, color: YensTheme.navy.withOpacity(0.6), size: 24),
          ],
        ),
      ),
    );
  }

  // --- POP BOX (BOTTOM SHEET) HELPER ---
  void _showPopBox(String title, String content, {Widget? customContent}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: YensTheme.yellow, // Changed to Yellow as requested
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: YensTheme.navy,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: YensTheme.navy),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: customContent ?? Text(
                  content,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: YensTheme.navy.withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SPECIFIC POP BOXES ---
  void _showPersonalItemPopBox() {
    _showPopBox(
      "Personal Information",
      "",
      customContent: Column(
        children: [
          _buildPopBoxTextField("Full Name", name),
          _buildPopBoxTextField("Phone Number", phone),
          _buildPopBoxTextField("Email", customer['email'] ?? "Email not set"),
          _buildPopBoxTextField("Birthday", customer['birthday'] ?? "Set birthday"),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Profile updated locally (Demo)"),
                    backgroundColor: YensTheme.navy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: YensTheme.navy, // Blue Button
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text("Save Changes", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCardsPopBox() {
    _showPopBox(
      "Yens Cards",
      "Securely manage your saved payment methods.",
      customContent: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: YensTheme.navy.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card_rounded, color: YensTheme.navy),
                const SizedBox(width: 16),
                Text("Add New Card", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: YensTheme.navy)),
                const Spacer(),
                const Icon(Icons.add_circle_outline, color: YensTheme.navy),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No cards saved yet. Tap above to add one.", 
            style: GoogleFonts.dmSans(color: YensTheme.navy.withOpacity(0.5), fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  void _showFAQsPopBox() {
    _showPopBox(
      "Help & FAQs",
      "",
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _faqItem("How do I earn points?", "You earn points for every purchase made through the app or by scanning your member QR code in-store."),
          _faqItem("How to redeem rewards?", "Go to the Rewards tab to see available items you can redeem with your points."),
          _faqItem("Can I pay with the app?", "Yes, you can link a card or use our prepaid wallet for contactless payment."),
        ],
      ),
    );
  }

  void _showSecurityPopBox() {
    _showPopBox(
      "Security",
      "",
      customContent: Column(
        children: [
          _buildPopBoxSwitch("Enable Biometric Login", true),
          _buildPopBoxSwitch("Two-Factor Authentication", false),
          _buildPopBoxSwitch("Marketing Communications", true),
          const SizedBox(height: 20),
          _buildProfileItem("Change Password", Icons.keyboard_arrow_right, () {}),
        ],
      ),
    );
  }

  void _showOrdersPopBox() {
    _showPopBox("Order History", "Your recent orders will appear here. No orders found in the last 30 days.");
  }
  
  void _showRewardsPopBox() {
    _showPopBox("Yens Rewards", "View your points history and tier benefits here.");
  }

  // --- POP BOX UI UTILS ---
  Widget _buildPopBoxTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 14, color: YensTheme.navy.withOpacity(0.5), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            style: GoogleFonts.dmSans(color: YensTheme.navy, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopBoxSwitch(String title, bool val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, 
            style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: YensTheme.navy)
          ),
          Switch(
            value: val, 
            onChanged: (_) {}, 
            activeThumbColor: Colors.white,
            activeTrackColor: YensTheme.navy,
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.bold, color: YensTheme.navy)),
          const SizedBox(height: 6),
          Text(a, style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}