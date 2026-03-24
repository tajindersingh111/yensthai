// import 'package:flutter/material.dart';
// import 'login_page.dart';
// import 'home_page.dart';
//
// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});
//
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//
//   bool hidePassword = true;
//   int gender = 0;
//
//   TextEditingController dobController = TextEditingController();
//
//   Widget inputField(String hint, IconData icon) {
//
//     return Padding(
//
//       padding: const EdgeInsets.only(bottom: 18),
//
//       child: TextField(
//
//         decoration: InputDecoration(
//
//           hintText: hint,
//
//           prefixIcon: Icon(icon),
//
//           filled: true,
//           fillColor: Colors.grey.shade200,
//
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(25),
//             borderSide: BorderSide.none,
//           ),
//
//         ),
//       ),
//     );
//   }
//
//   Future pickDate() async {
//
//     DateTime? date = await showDatePicker(
//
//       context: context,
//
//       initialDate: DateTime(2000),
//
//       firstDate: DateTime(1950),
//
//       lastDate: DateTime.now(),
//
//     );
//
//     if (date != null) {
//
//       setState(() {
//         dobController.text =
//         "${date.day}/${date.month}/${date.year}";
//       });
//
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       backgroundColor: Colors.white,
//
//       body: SafeArea(
//
//         child: SingleChildScrollView(
//
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//
//           child: Column(
//
//             children: [
//
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
//                 "Create Account",
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               /// UPDATED SIGNUP MESSAGE
//               const Text(
//                 "Join Yen’s Rewards Club and earn points every time you enjoy Yen’s ice cream.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.grey,
//                 ),
//               ),
//
//               const SizedBox(height: 25),
//
//               /// EMAIL
//               inputField("Email Address", Icons.email),
//
//               /// PHONE
//               inputField("Telephone Number", Icons.phone),
//
//               /// LINE ID
//               inputField("LINE ID", Icons.chat),
//
//               /// PASSWORD
//               Padding(
//
//                 padding: const EdgeInsets.only(bottom: 18),
//
//                 child: TextField(
//
//                   obscureText: hidePassword,
//
//                   decoration: InputDecoration(
//
//                     hintText: "Password",
//
//                     prefixIcon: const Icon(Icons.lock),
//
//                     suffixIcon: IconButton(
//
//                       icon: Icon(
//                         hidePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                       ),
//
//                       onPressed: () {
//
//                         setState(() {
//                           hidePassword = !hidePassword;
//                         });
//
//                       },
//
//                     ),
//
//                     filled: true,
//                     fillColor: Colors.grey.shade200,
//
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(25),
//                       borderSide: BorderSide.none,
//                     ),
//
//                   ),
//                 ),
//               ),
//
//               /// DATE OF BIRTH
//               Padding(
//
//                 padding: const EdgeInsets.only(bottom: 18),
//
//                 child: TextField(
//
//                   controller: dobController,
//
//                   readOnly: true,
//
//                   onTap: pickDate,
//
//                   decoration: InputDecoration(
//
//                     hintText: "Date of Birth",
//
//                     prefixIcon:
//                     const Icon(Icons.calendar_today),
//
//                     filled: true,
//                     fillColor: Colors.grey.shade200,
//
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(25),
//                       borderSide: BorderSide.none,
//                     ),
//
//                   ),
//                 ),
//               ),
//
//               /// GENDER
//               Row(
//
//                 children: [
//
//                   Expanded(
//                     child: ChoiceChip(
//                       label: const Text("Male"),
//                       selected: gender == 0,
//                       onSelected: (v) {
//                         setState(() {
//                           gender = 0;
//                         });
//                       },
//                     ),
//                   ),
//
//                   const SizedBox(width: 10),
//
//                   Expanded(
//                     child: ChoiceChip(
//                       label: const Text("Female"),
//                       selected: gender == 1,
//                       onSelected: (v) {
//                         setState(() {
//                           gender = 1;
//                         });
//                       },
//                     ),
//                   ),
//
//                 ],
//               ),
//
//               const SizedBox(height: 30),
//
//               /// CREATE ACCOUNT BUTTON
//               SizedBox(
//
//                 width: double.infinity,
//                 height: 55,
//
//                 child: ElevatedButton(
//
//                   style: ElevatedButton.styleFrom(
//
//                     backgroundColor: const Color(0xffF5C021),
//
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//
//                   ),
//
//                   onPressed: () {
//
//                     Navigator.pushReplacement(
//
//                       context,
//
//                       MaterialPageRoute(
//                         builder: (context) => const HomePage(),
//                       ),
//
//                     );
//
//                   },
//
//                   child: const Text(
//                     "Create Account",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//
//                 ),
//               ),
//
//               const SizedBox(height: 25),
//
//               /// LOGIN LINK
//               Row(
//
//                 mainAxisAlignment: MainAxisAlignment.center,
//
//                 children: [
//
//                   const Text("Already have an account? "),
//
//                   GestureDetector(
//
//                     onTap: () {
//
//                       Navigator.push(
//
//                         context,
//
//                         MaterialPageRoute(
//                           builder: (context) => const LoginPage(),
//                         ),
//
//                       );
//
//                     },
//
//                     child: const Text(
//                       "Sign In",
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   )
//
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
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
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'otp_verify_page.dart';

class SignupPage extends StatefulWidget {
  final String phone;
  const SignupPage({super.key, required this.phone});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool hidePassword = true;
  bool isLoading = false;
  int gender = 0;
  String? errorMessage;

  late final TextEditingController phoneController;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController lineIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    lineIdController.dispose();
    passwordController.dispose();
    dobController.dispose();
    super.dispose();
  }

  String? validate() {
    if (nameController.text.trim().isEmpty) return "Please enter your name.";
    if (emailController.text.trim().isEmpty) return "Please enter your email.";
    if (!emailController.text.contains('@')) return "Please enter a valid email.";
    if (passwordController.text.isEmpty) return "Please enter a password.";
    if (passwordController.text.length < 6) return "Password must be at least 6 characters.";
    if (dobController.text.isEmpty) return "Please select your date of birth.";
    return null;
  }

  Future<void> handleSignup() async {
    final error = validate();
    if (error != null) { setState(() => errorMessage = error); return; }
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final url = Uri.parse("https://app.yensthai.com/api/customers");
      final body = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "password": passwordController.text,
        if (lineIdController.text.trim().isNotEmpty) "lineUid": lineIdController.text.trim(),
        if (dobController.text.isNotEmpty) "birthday": dobController.text,
        "gender": gender == 0 ? "male" : "female",
      };
      final res = await http.post(url, headers: {"Content-Type": "application/json"}, body: json.encode(body));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => OtpVerifyPage(phone: phoneController.text.trim(), customerData: data),
        ));
      } else {
        final data = json.decode(res.body);
        setState(() => errorMessage = data['message'] ?? "Signup failed. Please try again.");
      }
    } catch (e) {
      setState(() => errorMessage = "Network error. Please check your connection.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future pickDate() async {
    DateTime? date = await showDatePicker(
      context: context, initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xffF5C021), onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (date != null) setState(() => dobController.text = "${date.day}/${date.month}/${date.year}");
  }

  Widget inputField(String hint, IconData icon, {TextEditingController? controller, TextInputType keyboard = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller, keyboardType: keyboard, readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(icon), filled: true, fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
        ),
      ),
    );
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
              Align(alignment: Alignment.centerLeft, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context))),
              Image.asset("assets/logo.jpg", height: 140, fit: BoxFit.contain),
              const SizedBox(height: 15),
              const Text("Create Account", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Join Yen's Rewards Club and earn points every time you enjoy Yen's ice cream.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              inputField("Full Name", Icons.person, controller: nameController),
              inputField("Email Address", Icons.email, controller: emailController, keyboard: TextInputType.emailAddress),
              inputField("Phone Number", Icons.phone, controller: phoneController, keyboard: TextInputType.phone, readOnly: true),
              inputField("LINE ID (optional)", Icons.chat, controller: lineIdController),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: TextField(
                  controller: passwordController, obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: "Password", prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => hidePassword = !hidePassword)),
                    filled: true, fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: TextField(
                  controller: dobController, readOnly: true, onTap: pickDate,
                  decoration: InputDecoration(
                    hintText: "Date of Birth", prefixIcon: const Icon(Icons.calendar_today),
                    filled: true, fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: ChoiceChip(label: const Center(child: Text("Male")), selected: gender == 0, selectedColor: const Color(0xffF5C021), onSelected: (v) => setState(() => gender = 0))),
                  const SizedBox(width: 10),
                  Expanded(child: ChoiceChip(label: const Center(child: Text("Female")), selected: gender == 1, selectedColor: const Color(0xffF5C021), onSelected: (v) => setState(() => gender = 1))),
                ],
              ),
              const SizedBox(height: 20),
              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red.shade200)),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red), const SizedBox(width: 10),
                    Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500))),
                  ]),
                ),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffF5C021), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  onPressed: isLoading ? null : handleSignup,
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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