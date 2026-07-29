import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/yens_theme.dart';
import '../widgets/yens_main_header.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedRating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  String _selectedCategory = 'Food Quality';

  final List<String> _categories = [
    'Food Quality',
    'Service',
    'App Experience',
    'Delivery',
    'Rewards Issue',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YensTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            YensMainHeader.pushed(
              title: 'Feedback',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Rate your experience',
                      style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: YensTheme.navy),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) => GestureDetector(
                        onTap: () => setState(() => _selectedRating = index + 1),
                        child: Icon(
                          index < _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 48,
                          color: index < _selectedRating ? Colors.amber : Colors.grey.shade400,
                        ),
                      )),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'What would you like to talk about?',
                      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: YensTheme.navy),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((c) => ChoiceChip(
                        label: Text(c),
                        selected: _selectedCategory == c,
                        onSelected: (val) => setState(() => _selectedCategory = c),
                        selectedColor: YensTheme.navy,
                        labelStyle: TextStyle(
                          color: _selectedCategory == c ? Colors.white : YensTheme.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      )).toList(),
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Tell us more',
                      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: YensTheme.navy),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts here...',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: YensTheme.navy)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: YensTheme.navy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thank you! Your feedback has been sent.'), backgroundColor: YensTheme.navy),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Submit Feedback',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
