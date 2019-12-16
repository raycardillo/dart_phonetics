import 'package:dart_phonetics/dart_phonetics.dart';

void _printResult(Object encoder, String input, PhoneticEncoding encoding) {
  print('${encoder?.runtimeType?.toString()} - "$input"\n  primary = ${encoding
      ?.primary}\n  alternate = ${encoding?.alternate}\n');
}

void main() {
  final inputString = 'Cardillo';

  final soundex = Soundex.americanEncoder;
  _printResult(soundex, inputString, soundex.encode(inputString));

  final refinedSoundex = RefinedSoundex.defaultEncoder;
  _printResult(refinedSoundex, inputString, refinedSoundex.encode(inputString));
}
