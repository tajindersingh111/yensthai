import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/yens_theme.dart';
import '../widgets/yens_main_header.dart';

class SupportInfoScreen extends StatelessWidget {
  const SupportInfoScreen({
    super.key,
    required this.title,
    this.isNews = false,
  });

  final String title;
  final bool isNews;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YensTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            YensMainHeader.pushed(
              title: title,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: isNews ? _buildNewsFeed() : _buildInfoContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsFeed() {
    final news = [
      {
        'title': 'New Store Opening in Central World!',
        'date': 'Oct 12, 2026',
        'desc': 'We are excited to announce our newest branch. Come visit us for special opening rewards!',
      },
      {
        'title': 'Golden Mango Seasonal Special',
        'date': 'Oct 08, 2026',
        'desc': 'Our limited time Golden Mango series is back by popular demand. Try it today!',
      },
      {
        'title': 'Double Points Weekend',
        'date': 'Oct 01, 2026',
        'desc': 'Earn double reward points on all orders this weekend. Only for Yens members.',
      },
    ];

    return Column(
      children: news.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: YensTheme.accent, borderRadius: BorderRadius.circular(10)),
                  child: const Text('NEWS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: YensTheme.navy)),
                ),
                Text(item['date']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(item['title']!, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: YensTheme.navy)),
            const SizedBox(height: 8),
            Text(item['desc']!, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black54, height: 1.5)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('Read More →', style: TextStyle(fontWeight: FontWeight.bold, color: YensTheme.navy)),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Updated: October 2026',
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),
        _infoSection('1. Introduction', 'Welcome to Yen\'s Thai. By using our app, you agree to these terms. We strive to provide the best Thai tea experience...'),
        _infoSection('2. Membership & Rewards', 'Reward points are non-transferable and can only be redeemed for products shown in the rewards section...'),
        _infoSection('3. Privacy & Data', 'Your privacy is important to us. We only collect data necessary to provide and improve our services...'),
        _infoSection('4. Refund Policy', 'Orders placed through the app are final. If you have an issue with your order, please contact our support team immediately.'),
      ],
    );
  }

  Widget _infoSection(String subtitle, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: YensTheme.navy),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87, height: 1.6),
          ),
        ],
      ),
    );
  }
}
