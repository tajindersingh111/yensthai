import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/pages/login_page.dart';
import 'package:yensss/pages/signup_page.dart';

class RewardsIntroPage extends StatelessWidget {
  const RewardsIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YensTheme.yellow, // Vibrant Yens Yellow Header
      body: Column(
        children: [
          // --- HEADER SECTION (Logo & Rewards Text) ---
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
              width: double.infinity,
              child: Row(
                children: [
                   // Circular Logo container
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "YEN'S",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: YensTheme.navy, // Back to Blue
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: YensTheme.navy.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'v3',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: YensTheme.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'REWARDS',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: YensTheme.navy.withOpacity(0.7), // Back to Blue
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- BODY CARD (White Section) ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Say hello to easy ordering, endless choice & – yes, free coffee',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: YensTheme.navy, // Back to Blue
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),

                      _rewardFeatureItem(
                        icon: Icons.auto_awesome_rounded,
                        iconBg: const Color(0xFFFFF3C4),
                        iconColor: const Color(0xFFFBC02D),
                        title: 'Collect 10 Stars for every ฿50 spent',
                        description: 'Order and pay how you’d like to earn free treats fast.',
                      ),
                      const SizedBox(height: 32),

                      _rewardFeatureItem(
                        icon: Icons.coffee_rounded,
                        iconBg: const Color(0xFFE3F2FD),
                        iconColor: YensTheme.navy, // Back to Blue
                        title: 'Every 500 Stars, have a drink on us',
                        description: 'Redeem your points for any handcrafted beverage.',
                      ),
                      const SizedBox(height: 32),

                      _rewardFeatureItem(
                        icon: Icons.military_tech_rounded,
                        iconBg: const Color(0xFFFBE9E7),
                        iconColor: const Color(0xFFFF5722),
                        title: 'Unlock Gold Level at 2,500 Stars',
                        description: 'Gold members get free extras and special birthday rewards.',
                      ),
                      const SizedBox(height: 32),

                      _rewardFeatureItem(
                        icon: Icons.notifications_active_rounded,
                        iconBg: const Color(0xFFF3E5F5),
                        iconColor: const Color(0xFF9C27B0),
                        title: 'Exclusive Offers & Early Access',
                        description: 'Be the first to know about new flavors and member-only events.',
                      ),

                      const SizedBox(height: 50),

                      Text(
                        'Get started',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: YensTheme.navy, // Back to Blue
                        ),
                      ),
                      const SizedBox(height: 18),
                      
                      // REGISTER BUTTON (Yellow with Blue Text)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => const SignupPage(phone: ""))
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: YensTheme.yellow,
                            foregroundColor: YensTheme.navy,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Register now',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Already a member?',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: YensTheme.navy, // Back to Blue
                        ),
                      ),
                      const SizedBox(height: 18),

                      // SIGN IN BUTTON (Yellow with Blue Text)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => const LoginPage())
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: YensTheme.yellow,
                            foregroundColor: YensTheme.navy,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Sign in',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardFeatureItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: YensTheme.navy, // Back to Blue
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: YensTheme.navy.withOpacity(0.6), // Back to Blue
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
