import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yensss/core/app_config.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/widgets/translation_widgets.dart';

class ProductMenuCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String? badgeLabel;
  final Color? badgeColor;
  final VoidCallback onAdd;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductMenuCard({
    super.key,
    required this.product,
    this.badgeLabel,
    this.badgeColor,
    required this.onAdd,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  String _img(String? path) => AppConfig.mediaUrl(path);

  @override
  Widget build(BuildContext context) {
    final url = _img(product['imageUrl']?.toString());
    final price = double.tryParse('${product['price']}') ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: YensTheme.navy.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _productImage(url),
                const SizedBox(height: 12),
                YensTranslateText(
                  '${product['name']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: YensTheme.navy.withOpacity(0.85),
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '฿${price.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: YensTheme.navy,
                        fontSize: 17,
                        letterSpacing: -0.5,
                      ),
                    ),
                    _premiumAddBtn(onAdd),
                  ],
                ),
              ],
            ),
          ),
          if (badgeLabel != null)
            _premiumBadge(
              label: badgeLabel!,
              color: badgeColor ?? YensTheme.navy,
            ),
          if (onFavoriteToggle != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.pink : Colors.black26,
                  size: 20,
                ),
                onPressed: onFavoriteToggle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _productImage(String url) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey))
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade50,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: YensTheme.navy),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
    );
  }

  Widget _premiumAddBtn(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: YensTheme.yellow,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: YensTheme.yellow.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: YensTheme.navy, size: 20),
      ),
    );
  }

  Widget _premiumBadge({required String label, required Color color}) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
