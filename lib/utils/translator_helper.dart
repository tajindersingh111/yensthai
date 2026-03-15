import 'package:translator/translator.dart';

final translator = GoogleTranslator();

Future<String> translateText(String text, bool english) async {

  if (!english) return text;

  try {

    var result = await translator.translate(
      text,
      from: 'th',
      to: 'en',
    );

    return result.text;

  } catch (e) {

    return text;

  }

}