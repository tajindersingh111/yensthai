import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:yensss/core/app_config.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/core/session_service.dart';
import 'package:yensss/pages/home_page.dart';
import 'package:yensss/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  final String phone;
  const SignupPage({super.key, required this.phone});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  late final TextEditingController phoneController;
  
  String? selectedGender;
  bool isLoading = false;
  String? errorMessage;

  bool acceptMarketing = false;
  bool acceptTerms = false;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String? validate() {
    if (firstNameController.text.trim().isEmpty) return "First name is required.";
    if (lastNameController.text.trim().isEmpty) return "Last name is required.";
    if (emailController.text.trim().isEmpty) return "Email is required.";
    if (!emailController.text.contains('@')) return "Enter a valid email.";
    if (birthdayController.text.trim().isEmpty) return "Birthday is required.";
    if (selectedGender == null) return "Gender is required.";
    if (!acceptTerms) return "You must accept the terms of use.";
    return null;
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: YensTheme.navy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: YensTheme.navy,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        birthdayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> handleSignup() async {
    final error = validate();
    if (error != null) {
      setState(() => errorMessage = error);
      return;
    }

    setState(() { 
      isLoading = true; 
      errorMessage = null; 
    });

    try {
      final url = Uri.parse("${AppConfig.apiBase}/api/customers");
      final body = {
        "name": "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "birthday": birthdayController.text.trim(),
        "gender": selectedGender,
      };

      final systemToken = await SessionService.instance.bearerToken();

      final res = await http.post(
        url, 
        headers: {
          "Content-Type": "application/json",
          if (systemToken != null) "Authorization": "Bearer $systemToken",
        }, 
        body: json.encode(body)
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        
        await SessionService.instance.persistCustomerSession(
          customerData: data,
        );

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } else {
        final data = json.decode(res.body);
        setState(() => errorMessage = data['message'] ?? "Signup failed.");
      }
    } catch (e) {
      setState(() => errorMessage = "Network error. Please try again.");
    } finally {
      setState(() { if (mounted) isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: YensTheme.yellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: YensTheme.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Register',
          style: GoogleFonts.outfit(
            color: YensTheme.navy,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 32),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: YensTheme.yellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: YensTheme.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If you already have an account, sign in with your phone number.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: YensTheme.navy.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: YensTheme.navy, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          foregroundColor: YensTheme.navy,
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _sectionTitle('Personal info'),
                _buildUnderlineTextField('First Name', controller: firstNameController),
                _buildUnderlineTextField('Last Name', controller: lastNameController),
                _buildUnderlineTextField('Phone Number', controller: phoneController, readOnly: true),
                _buildUnderlineDropdown(
                  'Gender', 
                  selectedGender, 
                  ['Male', 'Female', 'Other', 'Prefer not to say'], 
                  (val) => setState(() => selectedGender = val),
                ),
                
                const SizedBox(height: 40),
                _sectionTitle('Contact Details'),
                _buildUnderlineTextField('Email Address', controller: emailController, keyboardType: TextInputType.emailAddress),

                const SizedBox(height: 40),
                _sectionTitle('Birthday'),
                Text(
                  'Add your birthdate, so we can send you our best wishes and a free birthday coupon on your birthday.',
                  style: GoogleFonts.outfit(fontSize: 14, color: YensTheme.navy.withOpacity(0.8), height: 1.4),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectBirthday(context),
                  child: IgnorePointer(
                    child: _buildUnderlineTextField(
                      'Birthday (YYYY-MM-DD)', 
                      controller: birthdayController,
                      readOnly: true,
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                Text(
                  'Always be ready for delicious ice cream',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: YensTheme.navy,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildToggleRow(
                  'Yes. I want to hear about exclusive offers, announcements and the newest products from Yen\'s Thai.',
                  acceptMarketing,
                  (val) => setState(() => acceptMarketing = val),
                ),

                const SizedBox(height: 40),
                _sectionTitle('Terms of Use'),
                _buildToggleRow(
                  'I accept the Terms of Use',
                  acceptTerms,
                  (val) => setState(() => acceptTerms = val),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Terms of Use', style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                ),

                const SizedBox(height: 20),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      errorMessage!,
                      style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YensTheme.yellow,
                    foregroundColor: YensTheme.navy,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: YensTheme.navy)
                      : Text(
                          'Join Rewards',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: YensTheme.navy),
      ),
    );
  }

  Widget _buildUnderlineTextField(String label, {required TextEditingController controller, TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: YensTheme.navy),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.5)),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 1)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: YensTheme.navy, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildUnderlineDropdown(String label, String? current, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: DropdownButtonFormField<String>(
        value: current,
        style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: YensTheme.navy.withOpacity(0.5)),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 1)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.outfit(color: YensTheme.navy)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildToggleRow(String text, bool value, Function(bool) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(fontSize: 14, color: YensTheme.navy, height: 1.4),
          ),
        ),
        const SizedBox(width: 20),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: YensTheme.yellow,
        ),
      ],
    );
  }
}