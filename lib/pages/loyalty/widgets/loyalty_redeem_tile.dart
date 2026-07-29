import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/widgets/translation_widgets.dart';

class LoyaltyRedeemTile extends StatelessWidget {
  final String label;
  final int cost;
  final IconData icon;
  final bool isAvailable;
  final VoidCallback onTap;

  const LoyaltyRedeemTile({
    super.key,
    required this.label,
    required this.cost,
    required this.icon,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: YensTheme.navy.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable ? onTap : null,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAvailable ? YensTheme.yellow : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isAvailable ? YensTheme.navy : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      YensTranslateText(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isAvailable ? YensTheme.navy : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cost Points Required',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? YensTheme.navy.withOpacity(0.5) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: YensTheme.navy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Redeem',
                      style: GoogleFonts.outfit(
                        color: YensTheme.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else
                  Icon(Icons.lock_outline_rounded, color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
