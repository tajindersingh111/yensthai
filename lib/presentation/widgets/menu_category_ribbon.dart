import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/widgets/translation_widgets.dart';

class MenuCategoryRibbon extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategoryId;
  final Function(String) onCategoryTap;
  final bool showHeader;

  const MenuCategoryRibbon({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryTap,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
            child: Row(
              children: [
                YensTranslateText(
                  'Explore Menu',
                  style: GoogleFonts.outfit(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: YensTheme.navy.withOpacity(0.85),
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.star_rounded, color: YensTheme.accent, size: 20),
              ],
            ),
          ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, i) {
              final c = categories[i];
              final isSelected = selectedCategoryId == c['id'].toString();
              return InkWell(
                onTap: () => onCategoryTap(c['id'].toString()),
                borderRadius: BorderRadius.circular(40),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? YensTheme.navy : YensTheme.yellow.withOpacity(0.5),
                          width: isSelected ? 2.5 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? YensTheme.navy.withOpacity(0.18) : YensTheme.navy.withOpacity(0.05),
                            blurRadius: isSelected ? 10 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (c['imageUrl'] != null && c['imageUrl'].toString().isNotEmpty)
                              Image.network(
                                c['imageUrl'].toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _fallbackIcon(c['icon']),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[100],
                                    child: const Center(
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(YensTheme.navy),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              _fallbackIcon(c['icon']),
                            if (!isSelected)
                              Container(
                                color: Colors.black.withOpacity(0.15),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    YensTranslateText(
                      c['name'] ?? c['label'] ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected ? YensTheme.navy : YensTheme.navy.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _fallbackIcon(dynamic iconData) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Icon(
        (iconData is IconData) ? iconData : Icons.local_drink_outlined,
        color: YensTheme.navy.withOpacity(0.6),
        size: 22,
      ),
    );
  }
}
