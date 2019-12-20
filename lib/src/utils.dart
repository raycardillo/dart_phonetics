/*
 * dart_phonetics is a collection of phonetics algorithms implemented in Dart.
 * Copyright (C) 2019 Raymond Cardillo (dba Cardillo's Creations)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'package:charcode/charcode.dart';
import 'package:dart_phonetics/src/encoder.dart';

/// Common helpers and utilities.
class PhoneticUtils {
  /// All characters that could be considered vowels.
  static const Set<int> _VOWELS = {
    $A,
    $Agrave,
    $Aacute,
    $Acirc,
    $Atilde,
    $Auml,
    $Aring,
    $E,
    $Egrave,
    $Eacute,
    $Ecirc,
    $Euml,
    $I,
    $Igrave,
    $Iacute,
    $Icirc,
    $Iuml,
    $O,
    $Ograve,
    $Oacute,
    $Ocirc,
    $Otilde,
    $Ouml,
    $Oslash,
    $U,
    $Ugrave,
    $Uacute,
    $Ucirc,
    $Uuml,
    $Y,
    $Yacute
  };

  /// Filter pattern for cleaning simple characters.
  static final _cleanRegExpSimple =
      RegExp(r"[^A-Z'\-\.\\\/\s]", unicode: false);

  /// Filter pattern for cleaning latin characters.
  static final _cleanRegExpLatin =
      RegExp(r"[^A-ZÇÑÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖØÙÚÛÜÝ'\-\.\\\/\s]", unicode: false);

  /// Returns `true` if [charCode] is in a vowel (including special latin
  /// characters). The input should be cleaned first (which optionally removes
  /// latin characters if they are not desired).
  static bool isVowel(final int charCode) {
    return _VOWELS.contains(charCode);
  }

  /// Returns a cleaned input string (that is ready for encoding) by removing
  /// any illegal characters and converting the string to uppercase.
  /// Note that we're not going to clean up valid characters that appear in
  /// the wrong location because that would affect performance negatively for
  /// an edge case that users of this function can do if they really need to.
  static String clean(final String str, {bool latin = true}) {
    if (str == null || str.isEmpty) {
      return null;
    }

    final cleaned = str
        .trim()
        .toUpperCase()
        .replaceAll((latin) ? _cleanRegExpLatin : _cleanRegExpSimple, '');
    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  /// Encodes [s1] and [s2] using [encoder] and then returns the similarity
  /// for the [PhoneticEncoding.primary] encoding.
  ///
  /// Despite the name, this is actually a measure of similarity.
  /// This naming is consistent with the SQL `DIFFERENCE` function definition.
  static int primaryDifference(
      final PhoneticEncoder encoder, final String s1, final String s2) {
    final encoding1 = encoder.encode(s1);
    final encoding2 = encoder.encode(s2);

    return differenceEncoded(encoding1?.primary, encoding2?.primary);
  }

  /// Returns the number of characters that are the same in the [e1] and [e2]
  /// encoded strings.
  ///
  /// Despite the name, this is actually a measure of similarity.
  /// This naming is consistent with the SQL `DIFFERENCE` function definition.
  static int differenceEncoded(final String e1, final String e2) {
    if (e1 == null || e1.isEmpty || e2 == null || e2.isEmpty) {
      return 0;
    }

    var iterator1 = e1.codeUnits.iterator;
    var iterator2 = e2.codeUnits.iterator;

    var diff = 0;
    while (iterator1.moveNext() && iterator2.moveNext()) {
      if (iterator1.current == iterator2.current) {
        diff++;
      }
    }

    return diff;
  }
}
