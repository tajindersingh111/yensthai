// import 'package:flutter/material.dart';
// import 'home_page.dart';
// import 'signup_page.dart';
// import 'forgot_password.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   bool hidePassword = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//
//               /// LOGO
//               Image.asset(
//                 "assets/logo.jpg",
//                 height: 170,
//                 fit: BoxFit.contain,
//               ),
//
//               const SizedBox(height: 15),
//
//               /// TITLE
//               const Text(
//                 "Welcome back!",
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               const Text(
//                 "Sign in to enjoy your favorite Yen’s Thai ice cream treats",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.grey,
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               /// EMAIL
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: "Email Address",
//                   prefixIcon: const Icon(Icons.email),
//                   filled: true,
//                   fillColor: Colors.grey.shade200,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(25),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               /// PASSWORD
//               TextField(
//                 obscureText: hidePassword,
//                 decoration: InputDecoration(
//                   hintText: "Password",
//                   prefixIcon: const Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       hidePassword ? Icons.visibility_off : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         hidePassword = !hidePassword;
//                       });
//                     },
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey.shade200,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(25),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 25),
//
//               /// SIGN IN BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xffF5C021),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const HomePage(),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     "Sign In",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               /// FORGOT PASSWORD
//               /// FORGOT PASSWORD  ← YAHAN UPDATE HUA HAI
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ForgotPasswordPage(),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     "Forgot Password?",
//                     style: TextStyle(
//                       color: Colors.orange.shade700,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               /// OR DIVIDER
//               Row(
//                 children: const [
//                   Expanded(child: Divider()),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     child: Text("Or sign in with"),
//                   ),
//                   Expanded(child: Divider()),
//                 ],
//               ),
//
//               const SizedBox(height: 25),
//
//               /// LINE BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xff06C755),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   onPressed: () {},
//                   icon: const Icon(
//                     Icons.chat_bubble,
//                     color: Colors.white,
//                   ),
//                   label: const Text(
//                     "Continue with LINE",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               /// SIGNUP
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Don't have an account? "),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const SignupPage(),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       "Sign Up",
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   )
//                 ],
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
import '../core/app_config.dart';
import '../core/yens_theme.dart';
import '../core/session_service.dart';
import 'otp_verify_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _ensureSystemToken() async {
    final token = await SessionService.instance.bearerToken();
    if (token != null && token.isNotEmpty) return;

    final url = Uri.parse("${AppConfig.apiBase}/api/auth/login");
    final body = {
      "email": "pos@yensrewards.com",
      "password": "yenspos123",
      "app_id": "customer_app"
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final accessToken = data['accessToken'] as String?;
      if (accessToken != null) {
        await SessionService.instance.persistCustomerSession(
          customerData: {},
          customToken: accessToken,
        );
      }
    }
  }

  Future<void> handleContinue() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() => errorMessage = "Please enter your phone number.");
      return;
    }
    if (phone.length < 8) {
      setState(() => errorMessage = "Please enter a valid phone number.");
      return;
    }

    setState(() { isLoading = true; errorMessage = null; });

    try {
      final formattedPhone = phone.startsWith('+') ? phone : '+$phone';

      // 1. Ensure system client token is fetched and saved
      await _ensureSystemToken();
      final systemToken = await SessionService.instance.bearerToken();

      // 2. Query lookup customer by phone with the system token
      final url = Uri.parse(
          "${AppConfig.apiBase}/api/customers/phone/$formattedPhone");

      print("DEBUG: Checking phone → $url");

      final res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (systemToken != null) "Authorization": "Bearer $systemToken",
        },
      ).timeout(const Duration(seconds: 15));

      print("DEBUG: Status code → ${res.statusCode}");
      print("DEBUG: Response body → ${res.body}");

      if (res.statusCode == 200) {
        // Customer exists!
        final data = json.decode(res.body);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerifyPage(
              phone: formattedPhone,
              exists: true,
              customerData: Map<String, dynamic>.from(data as Map),
            ),
          ),
        );
      } else if (res.statusCode == 404) {
        // Customer does not exist! Go to OTP simulation, then signup
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerifyPage(
              phone: formattedPhone,
              exists: false,
              customerData: null,
            ),
          ),
        );
      } else {
        setState(() => errorMessage = "Server error: ${res.statusCode}. Please try again.");
      }
    } on http.ClientException catch (e) {
      print("DEBUG: ClientException → $e");
      setState(() => errorMessage = "Connection failed: ${e.message}");
    } catch (e) {
      print("DEBUG: Exception → $e");
      setState(() => errorMessage = "Error: ${e.toString()}");
    } finally {
      setState(() { if (mounted) isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Image.asset("assets/logo.jpg", height: 170, fit: BoxFit.contain),
              const SizedBox(height: 15),
              const Text("Welcome!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "Enter your phone number to get started with Yen's Thai Rewards.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 35),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Phone Number (e.g. +447584156695)",
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YensTheme.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: isLoading ? null : handleContinue,
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: YensTheme.navy, strokeWidth: 2.5))
                      : const Text("Continue", style: TextStyle(color: YensTheme.navy, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 30),
              Row(children: const [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Or continue with")),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff06C755),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble, color: Colors.white),
                  label: const Text("Continue with LINE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}