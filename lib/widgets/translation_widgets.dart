import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/cart_provider.dart';
import '../utils/translator_helper.dart';

/// A reactive widget that translates text based on the global language state.
class YensTranslateText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  
  /// The language the [text] is provided in. Default is 'th' (Thai).
  final String sourceLanguage;

  const YensTranslateText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.sourceLanguage = 'th',
  });

  @override
  Widget build(BuildContext context) {
    // Listen to the global language state
    final isEnglishMode = context.select<CartProvider, bool>((p) => p.isEnglish);

    // Logic:
    // 1. If we are in English Mode AND the source is Thai -> Translate TH to EN.
    // 2. If we are in Thai Mode AND the source is English -> Translate EN to TH.
    // 3. Otherwise -> Just show the original text.

    final needsTranslation = (isEnglishMode && sourceLanguage == 'th') || 
                             (!isEnglishMode && sourceLanguage == 'en');

    if (!needsTranslation) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final targetLang = isEnglishMode ? 'en' : 'th';

    return FutureBuilder<String>(
      key: ValueKey('${text}_$targetLang'),
      future: translateText(text, to: targetLang),
      builder: (context, snapshot) {
        final tr = snapshot.data ?? text; // Fallback to original text while loading
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            tr,
            key: ValueKey(tr), // Smooth transition when translation arrives
            style: style,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
          ),
        );
      },
    );
  }
}
