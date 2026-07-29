import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yensss/core/app_config.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/widgets/translation_widgets.dart';

class LoyaltyFavoriteCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const LoyaltyFavoriteCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.mediaUrl(product['imageUrl']?.toString());

    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: YensTheme.navy.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: YensTheme.cardCream.withOpacity(0.5),
                borderRadius: BorderRadius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: url.isEmpty
                  ? const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey))
                  : CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(height: 10),
          YensTranslateText(
            product['name']?.toString() ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: YensTheme.navy.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
