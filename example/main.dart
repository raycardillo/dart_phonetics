import 'package:dart_phonetics/dart_phonetics.dart';

void _printResult(Object encoder, String input, PhoneticEncoding encoding) {
  print(
      '${encoder?.runtimeType?.toString()} - "$input"\n  primary = ${encoding?.primary}\n  alternate = ${encoding?.alternates}\n');
}

void main() {
  final inputString = 'Cardillo-Ashcroft';

  final soundex = Soundex.americanEncoder;
  _printResult(soundex, inputString, soundex.encode(inputString));

  final customSoundex = Soundex.fromMapping(Soundex.americanMapping,
      maxLength: null, paddingEnabled: false, ignoreHW: false);
  _printResult(customSoundex, inputString, customSoundex.encode(inputString));

  final refinedSoundex = RefinedSoundex.defaultEncoder;
  _printResult(refinedSoundex, inputString, refinedSoundex.encode(inputString));
}
