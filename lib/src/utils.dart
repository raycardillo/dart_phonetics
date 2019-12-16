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
      return null;
    }

    var codeUnits = str.codeUnits;
    var cleanedCodeUnits = codeUnits.where((codeUnit) => isLetter(codeUnit));

    if (cleanedCodeUnits.isEmpty) {
      return null;
    }

    if (codeUnits.length == cleanedCodeUnits.length) {
      // no need to do the extra create
      return str.toUpperCase();
    }

    // create a new string from the cleaned version
    return String.fromCharCodes(cleanedCodeUnits).toUpperCase();
  }

  /// Encodes [s1] and [s2] using [encoder] and then returns an array
  /// containing the [differenceEncoded] similarity valude for the
  /// [PhoneticEncoding.primary] and [PhoneticEncoding.alternate] encodings.
  ///
  /// Despite the name, this is actually a measure of similarity.
  /// This naming is consistent with the SQL `DIFFERENCE` function definition.
  static List<int> differences(
      final PhoneticEncoder encoder, final String s1, final String s2) {
    final encoding1 = encoder.encode(s1);
    final encoding2 = encoder.encode(s2);

    return [
      differenceEncoded(encoding1?.primary, encoding2?.primary),
      differenceEncoded(encoding1?.alternate, encoding2?.alternate),
    ];
  }

  /// Returns the number of characters that are the same in [e1] and [e2].
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
