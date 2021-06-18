import 'package:dart_phonetics/dart_phonetics.dart';

void _printResult(PhoneticEncoder encoder, String input) {
  final encoding = encoder.encode(input);
  print(
      '${encoder.runtimeType.toString()} - "$input"\n  primary = ${encoding?.primary}\n  alternate = ${encoding?.alternates}\n');
}

void main() {
  final inputString = 'Cardillo-Ashcroft';

  final soundex = Soundex.americanEncoder;
  _printResult(soundex, inputString);

  final customSoundex = Soundex.fromMapping(Soundex.americanMapping,
      maxLength: null, paddingEnabled: false, ignoreHW: false);
  _printResult(customSoundex, inputString);

  final refinedSoundex = RefinedSoundex.defaultEncoder;
  _printResult(refinedSoundex, inputString);

  final nysiisOriginal = Nysiis.originalEncoder;
  _printResult(nysiisOriginal, inputString);

  final nysiisModified =
      Nysiis.withOptions(maxLength: null, enableModified: true);
  _printResult(nysiisModified, inputString);

  final doubleMetaphone = DoubleMetaphone.withMaxLength(12);
  _printResult(doubleMetaphone, inputString);
}
