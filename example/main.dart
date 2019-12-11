import 'package:dart_phonetics/dart_phonetics.dart';

void _printResult(Object encoder, String input, String encoded) {
  print('${encoder.runtimeType.toString().padRight(20)}: $input => $encoded');
}

void main() {
  final inputString = 'Cardillo';

  final soundex = Soundex.usEnglishEncoder;
  _printResult(soundex, inputString, soundex.encode(inputString));

  final refinedSoundex = RefinedSoundex.usEnglishEncoder;
  _printResult(refinedSoundex, inputString, refinedSoundex.encode(inputString));
}
