import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kYensOnboardingDoneKey = 'yens_onboarding_done';

class OnboardingSplashScreen extends StatefulWidget {
  const OnboardingSplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingSplashScreen> createState() => _OnboardingSplashScreenState();
}

class _OnboardingSplashScreenState extends State<OnboardingSplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(kYensOnboardingDoneKey, true);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    const Color yensYellow = Color(0xFFFFD541);
    const Color yensNavy = Color(0xFF10367A);

    return Scaffold(
      backgroundColor: yensYellow,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'v3',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: yensNavy.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                // 1. CIRCULAR LOGO
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: Image.asset(
                      'assets/logo.jpg', // No '/' at the start
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),

                // 2. HERO IMAGE PAGEVIEW
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildHeroImage('assets/logo.jpg'),
                      _buildHeroImage('assets/icecream.jpeg'),
                      // _buildHeroImage('assets/imagee (2).png'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 3. DOT INDICATORS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == _currentPage ? 24 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: index == _currentPage ? yensNavy : Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 25),

                // 4. TAGLINE (Yellow Background par Navy color)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Amazing Taste\nof Thai Ice Cream',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: yensNavy,
                      height: 1.1,
                    ),
                  ),
                ),
                
                const SizedBox(height: 140), // Button ke liye jagah
              ],
            ),
          ),
          
          // 5. GET STARTED BUTTON (Floating White Capsule)
          Positioned(
            left: 30,
            right: 30,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: yensNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _complete,
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Debugging ke liye agar image na mile
          return Center(child: Text("Missing: $assetPath", style: const TextStyle(color: Colors.red)));
        },
      ),
    );
  }
}