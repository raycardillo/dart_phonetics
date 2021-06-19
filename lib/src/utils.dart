/*
 * dart_phonetics is a collection of phonetics algorithms implemented in Dart.
 * Copyright (c) 2019 Raymond Cardillo (dba Cardillo's Creations)
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
  /// Simple vowels in the English language ([$A], [$E], [$I], [$O], [$U]).
  /// This does not include [$Y]
  static const Set<int> _simpleVowels = {
    $A,
    $E,
    $I,
    $O,
    $U,
  };

  /// All characters that could be considered vowels. This includes ([$A],
  /// [$E], [$I], [$O], [$U], [$Y], and latin variants with accent marks).
  static const Set<int> _latinVowels = {
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

  /// Special characters that are allowed by the filtering.
  static const _specialCharacters = {
    $apos,
    $minus,
    $dot,
    $space,
    $slash,
    $backslash
  };

  /// Filter pattern for cleaning post nominal designations.
  static final _cleanGenerational =
      RegExp(r'[\W\s]+(SR|JR|[IVX]+)\W*$', unicode: false);

  /// Filter pattern for cleaning simple characters.
  static final _cleanLatinNotAllowed =
      RegExp(r"[^A-Z'\-\.\\\/\s]", unicode: false);

  /// Filter pattern for cleaning latin characters.
  static final _cleanLatinAllowed =
      RegExp(r"[^A-ZÇÑÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖØÙÚÛÜÝ'\-\.\\\/\s]", unicode: false);

  /// Returns `true` if [charCode] is a simple vowel ([$A], [$E], [$I],
  /// [$O], [$U]). This does not include [$Y].
  static bool isSimpleVowel(final int charCode) {
    return _simpleVowels.contains(charCode);
  }

  /// Returns `true` if [charCode] is a vowel (including latin characters).
  static bool isVowel(final int charCode) {
    return _latinVowels.contains(charCode);
  }

  /// Returns `true` if the character at [index] in [value] is a vowel
  /// (including special latin characters). The value should be cleaned first
  /// (which optionally removes latin characters if they are not desired).
  static bool isVowelAt(final String value, final int index) {
    return isVowel(codeUnitAt(value, index));
  }

  /// Returns `true` if [charCode] is a special character.
  static bool isSpecialCharacter(final int charCode) {
    return _specialCharacters.contains(charCode);
  }

  /// Returns a cleaned string (that is ready for encoding) by performing the
  /// following steps on [value] :
  /// * trimming any whitespace and converting to uppercase
  /// * removing any generational suffixes (jr, sr, roman)
  /// * removing any non-word characters including latin vowels if
  ///   [allowLatin] is `false`
  ///
  /// Note that this does not try to clean special characters (such as `-`
  /// and `.`) that appear in the wrong location because that would affect
  /// performance negatively for an edge case that is not common. You may
  /// need to do additional cleaning if you're working with strings
  /// that are particularly dirty.
  static String clean(final String value, {bool allowLatin = true}) {
    if (value.isEmpty) {
      return value;
    }

    final cleaned = value
        .trim()
        .toUpperCase()
        .replaceFirst(_cleanGenerational, '')
        .replaceAll(
            (allowLatin) ? _cleanLatinAllowed : _cleanLatinNotAllowed, '');

    return cleaned;
  }

  /// Returns the character from [value] at [index] or [$nul] if the index is
  /// out of range.
  static int codeUnitAt(final String value, final int index) {
    return (index < 0 || index >= value.length)
        ? $nul
        : value.codeUnitAt(index);
  }

  /// Returns `true` if the character from [value] at [index] matches
  /// [pattern] or `false` (including if [index] is if out of range).
  static bool startsWith(final String value, final Pattern pattern,
      [final int index = 0]) {
    return (index < 0 || index >= value.length)
        ? false
        : value.startsWith(pattern, index);
  }

  /// Removes runs of repeated characters from the [chars] provided.
  static void removeRepeatRuns(final List<int> chars) {
    var writeIndex = 1;
    for (var i = writeIndex; i < chars.length; i++) {
      if (chars[i] != chars[i - 1]) {
        chars[writeIndex++] = chars[i];
      }
    }

    chars.removeRange(writeIndex, chars.length);
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
  static int differenceEncoded(final String? e1, final String? e2) {
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
