import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class OtpVerifyPage extends StatefulWidget {
  final String phone;
  final Map customerData;

  const OtpVerifyPage({
    super.key,
    required this.phone,
    required this.customerData,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String? verificationId;
  bool isLoading = false;
  bool isSending = true;
  bool resendCooldown = false;
  int cooldownSeconds = 30;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  @override
  void dispose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> sendOtp() async {
    setState(() { isSending = true; errorMessage = null; });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInAndNavigate(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isSending = false;
          errorMessage = "Failed to send OTP: ${e.message}";
        });
      },

      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          isSending = false;
          resendCooldown = true;
          cooldownSeconds = 30;
        });
        startCooldown();
      },

      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  void startCooldown() async {
    for (int i = 30; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => cooldownSeconds = i);
    }
    if (mounted) setState(() => resendCooldown = false);
  }

  Future<void> handleVerify() async {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => errorMessage = "Please enter the complete 6-digit OTP.");
      return;
    }
    if (verificationId == null) {
      setState(() => errorMessage = "Please wait, OTP is being sent.");
      return;
    }
    setState(() { isLoading = true; errorMessage = null; });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );
      await _signInAndNavigate(credential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.code == 'invalid-verification-code'
            ? "Wrong OTP. Please try again."
            : "Verification failed. Please try again.";
        for (var c in otpControllers) {
          c.clear();
        }
        focusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _signInAndNavigate(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customer_id', widget.customerData['id'] ?? '');
      await prefs.setString('customer_name', widget.customerData['name'] ?? '');
      await prefs.setString('customer_phone', widget.customerData['phone'] ?? '');
      await prefs.setBool('is_logged_in', true);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Sign in failed: ${e.message}";
      });
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 5),
              Image.asset("assets/logo.jpg", height: 170, fit: BoxFit.contain),
              const SizedBox(height: 15),
              const Text("Verify OTP", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                isSending
                    ? "Sending OTP to\n${widget.phone}..."
                    : "Enter the 6-digit code sent to\n${widget.phone}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 35),

              if (isSending)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Color(0xffF5C021), strokeWidth: 3),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 58,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xffF5C021), width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            focusNodes[index - 1].requestFocus();
                          }
                          final otp = otpControllers.map((c) => c.text).join();
                          if (otp.length == 6) handleVerify();
                        },
                      ),
                    );
                  }),
                ),

              const SizedBox(height: 25),

              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                      Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF5C021),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: (isLoading || isSending) ? null : handleVerify,
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text("Verify OTP", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 16),

              resendCooldown
                  ? Text("Resend OTP in ${cooldownSeconds}s", style: const TextStyle(color: Colors.grey))
                  : TextButton(
                onPressed: sendOtp,
                child: Text("Resend OTP", style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w600, fontSize: 15)),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}