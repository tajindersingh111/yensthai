import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/language_controller.dart';

class AppHeader extends StatelessWidget {

  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {

    final language = Provider.of<LanguageController>(context);

    return Container(
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
                "Yen's Thai",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )

            ],
          ),

          Row(
            children: [

              GestureDetector(

                onTap: () {
                  language.toggleLanguage();
                },

                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    language.english ? "EN" : "TH",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Icon(Icons.refresh)

            ],
          )

        ],
      ),
    );

  }

}