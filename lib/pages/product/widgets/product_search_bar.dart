import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yensss/core/yens_theme.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onFilterTap;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: YensTheme.navy.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          style: GoogleFonts.outfit(color: YensTheme.navy, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: const Icon(Icons.search, color: YensTheme.navy, size: 24),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                    onPressed: () {
                      controller.clear();
                      onChanged();
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.tune_rounded, color: YensTheme.navy, size: 22),
                    onPressed: onFilterTap,
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
