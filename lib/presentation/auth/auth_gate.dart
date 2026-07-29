import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/session_service.dart';
import '../../core/yens_theme.dart';
import '../../pages/home_page.dart';
import '../../pages/onboarding_splash_screen.dart';
import '../../pages/rewards_intro_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isLoading = true;
  bool _onboardingDone = false;
  bool _loggedIn = false;
  String _customerName = "";

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );

    _animationController.forward();
    _checkStatusAndTransition();
  }

  Future<void> _checkStatusAndTransition() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool(kYensOnboardingDoneKey) ?? false;
    _loggedIn = await SessionService.instance.isLoggedIn();
    _customerName = prefs.getString(SessionService.keyCustomerName) ?? "";

    // Allow the animation to play for at least 1.2 seconds for a smooth visual experience
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading) {
      if (!_onboardingDone) {
        return OnboardingSplashScreen(
          onFinished: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(kYensOnboardingDoneKey, true);
            if (mounted) {
              setState(() {
                _onboardingDone = true;
              });
            }
          },
        );
      }
      return _loggedIn ? const HomePage() : const RewardsIntroPage();
    }

    return Scaffold(
      backgroundColor: YensTheme.yellow,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              right: 24,
              child: Text(
                'v3',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: YensTheme.navy.withOpacity(0.5),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: YensTheme.navy.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Image.asset(
                                'assets/logo.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(
                                  Icons.icecream_rounded,
                                  size: 80,
                                  color: YensTheme.navy,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            _loggedIn && _customerName.isNotEmpty
                                ? 'Welcome Back, $_customerName!'
                                : 'Amazing Taste of Thai Ice Cream',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: YensTheme.navy,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: YensTheme.navy,
                              strokeWidth: 3.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
