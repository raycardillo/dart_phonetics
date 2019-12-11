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
  /// Private implementation of [isLetter] without the extra error checking.
  static bool _isLetter(int codeUnit) =>
      (codeUnit >= $A && codeUnit <= $Z || codeUnit >= $a && codeUnit <= $z);

  /// This is currently only checking for characters in the range of `A-Z` or `a-z`.
  static bool isLetter(int codeUnit) {
    if (codeUnit == null) {
      return null;
    }

    return _isLetter(codeUnit);
  }

  /// Private implementation of [isDigit] without the extra error checking.
  static bool _isDigit(int codeUnit) => (codeUnit >= $0 && codeUnit <= $9);

  /// This is currently only checking for radix 10 digit characters in the range of `0-9`.
  static bool isDigit(int codeUnit) {
    if (codeUnit == null) {
      return null;
    }

    return _isDigit(codeUnit);
  }

  /// Uses [isLetter] and [isDigit] to determine if the character code is a letter or digit.
  /// Returns `true` if [isLetter] is `true` or [isDigit] is `true`, `false` otherwise.
  static bool isLetterOrDigit(int codeUnit) =>
      (codeUnit == null ? null : _isLetter(codeUnit) || _isDigit(codeUnit));

  /// Cleans up the input string before Soundex processing by only returning valid upper case letters.
  /// Returns a cleaned version of the string.
  static String clean(final String str) {
    if (str == null || str.isEmpty) {
      return str;
    }

    var codeUnits = str.codeUnits;
    var cleanedCodeUnits = codeUnits.where((codeUnit) => isLetter(codeUnit));

    if (codeUnits.length == cleanedCodeUnits.length) {
      // no need to do the extra create
      return str.toUpperCase();
    }

    // create a new string from the cleaned version
    return String.fromCharCodes(cleanedCodeUnits).toUpperCase();
  }

  /// Encodes [s1] and [s2] using [encoder] and then returns the number of characters that are the same.
  /// Despite the name, this is actually a measure of similarity.
  /// This naming is consistent with the SQL `DIFFERENCE` function definition.
  ///
  /// - For [Soundex], this return value ranges from `0` through `4`, where `0` indicates
  /// little or no similarity, and `4` indicates strong similarity or identical values.
  /// - For [RefinedSoundex], the return value can be greater than `4`.
  static int difference(
      final PhoneticEncoder encoder, final String s1, final String s2) {
    return differenceEncoded(encoder.encode(s1), encoder.encode(s2));
  }

  /// Returns the number of characters that are the same in [es1] and [es2].
  /// Despite the name, this is actually a measure of similarity.
  /// This naming is consistent with the SQL `DIFFERENCE` function definition.
  ///
  /// - For [Soundex], this return value ranges from `0` through `4`, where `0` indicates
  /// little or no similarity, and `4` indicates strong similarity or identical values.
  /// - For [RefinedSoundex], the return value can be greater than `4`.
  static int differenceEncoded(final String es1, final String es2) {
    if (es1 == null || es1.isEmpty || es2 == null || es2.isEmpty) {
      return 0;
    }

    var iterator1 = es1.codeUnits.iterator;
    var iterator2 = es2.codeUnits.iterator;

    var diff = 0;
    while (iterator1.moveNext() && iterator2.moveNext()) {
      if (iterator1.current == iterator2.current) {
        diff++;
      }
    }

    return diff;
  }
}
