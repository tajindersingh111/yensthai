import 'package:translator/translator.dart';

final _translator = GoogleTranslator();

/// Translates text to the specified target language ('en' or 'th').
/// If the text is already likely in the target language or translation fails, returns original.
Future<String> translateText(String text, {required String to}) async {
  if (text.trim().isEmpty) return text;

  try {
    // If we want English, we assume source is Thai.
    // If we want Thai, we assume source is English.
    final from = to == 'en' ? 'th' : 'en';
    
    var result = await _translator.translate(
      text,
      from: from,
      to: to,
    );

    return result.text;
  } catch (e) {
    // Silently fallback to original text on any error (like network or API limit)
    return text;
  }
}