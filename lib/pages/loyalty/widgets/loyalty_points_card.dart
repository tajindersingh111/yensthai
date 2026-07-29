import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yensss/core/yens_theme.dart';

class LoyaltyPointsCard extends StatelessWidget {
  final int points;
  final int streak;

  const LoyaltyPointsCard({
    super.key,
    required this.points,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: YensTheme.yellow,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: YensTheme.yellow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YENS REWARDS',
                    style: GoogleFonts.outfit(
                      color: YensTheme.navy,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Points Balance',
                    style: GoogleFonts.outfit(
                      color: YensTheme.navy.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: YensTheme.navy.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: YensTheme.navy, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$points',
            style: GoogleFonts.outfit(
              color: YensTheme.navy,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: YensTheme.navy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: YensTheme.navy, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    streak > 0
                        ? '$streak Day Streak! +${(streak * 5).clamp(0, 50)} bonus on next order.'
                        : 'Start your daily streak to earn bonus points!',
                    style: GoogleFonts.outfit(
                      color: YensTheme.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
