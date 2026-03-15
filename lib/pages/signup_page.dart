import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  bool hidePassword = true;
  int gender = 0;

  TextEditingController dobController = TextEditingController();

  Widget inputField(String hint, IconData icon) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 18),

      child: TextField(

        decoration: InputDecoration(

          hintText: hint,

          prefixIcon: Icon(icon),

          filled: true,
          fillColor: Colors.grey.shade200,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),

        ),
      ),
    );
  }

  Future pickDate() async {

    DateTime? date = await showDatePicker(

      context: context,

      initialDate: DateTime(2000),

      firstDate: DateTime(1950),

      lastDate: DateTime.now(),

    );

    if (date != null) {

      setState(() {
        dobController.text =
        "${date.day}/${date.month}/${date.year}";
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

              /// LOGO
              Image.asset(
                "assets/logo.jpg",
                height: 170,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 15),

              /// TITLE
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// UPDATED SIGNUP MESSAGE
              const Text(
                "Join Yen’s Rewards Club and earn points every time you enjoy Yen’s ice cream.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              /// EMAIL
              inputField("Email Address", Icons.email),

              /// PHONE
              inputField("Telephone Number", Icons.phone),

              /// LINE ID
              inputField("LINE ID", Icons.chat),

              /// PASSWORD
              Padding(

                padding: const EdgeInsets.only(bottom: 18),

                child: TextField(

                  obscureText: hidePassword,

                  decoration: InputDecoration(

                    hintText: "Password",

                    prefixIcon: const Icon(Icons.lock),

                    suffixIcon: IconButton(

                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {

                        setState(() {
                          hidePassword = !hidePassword;
                        });

                      },

                    ),

                    filled: true,
                    fillColor: Colors.grey.shade200,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),

                  ),
                ),
              ),

              /// DATE OF BIRTH
              Padding(

                padding: const EdgeInsets.only(bottom: 18),

                child: TextField(

                  controller: dobController,

                  readOnly: true,

                  onTap: pickDate,

                  decoration: InputDecoration(

                    hintText: "Date of Birth",

                    prefixIcon:
                    const Icon(Icons.calendar_today),

                    filled: true,
                    fillColor: Colors.grey.shade200,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),

                  ),
                ),
              ),

              /// GENDER
              Row(

                children: [

                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Male"),
                      selected: gender == 0,
                      onSelected: (v) {
                        setState(() {
                          gender = 0;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Female"),
                      selected: gender == 1,
                      onSelected: (v) {
                        setState(() {
                          gender = 1;
                        });
                      },
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 30),

              /// CREATE ACCOUNT BUTTON
              SizedBox(

                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: const Color(0xffF5C021),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),

                  ),

                  onPressed: () {

                    Navigator.pushReplacement(

                      context,

                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),

                    );

                  },

                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ),
              ),

              const SizedBox(height: 25),

              /// LOGIN LINK
              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  const Text("Already have an account? "),

                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),

                      );

                    },

                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )

                ],
              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}