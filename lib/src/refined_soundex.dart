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
import 'package:dart_phonetics/dart_phonetics.dart';
import 'package:dart_phonetics/src/soundex.dart';

/// Encodes a string to a RefinedSoundex value. RefinedSoundex is optimized for spell checking words.
class RefinedSoundex implements Soundex {
  /// The character mapping to use when encoding input strings.
  final Map<int, int> _soundexMapping;

  /// This is a default mapping of the 26 letters used in US English. A value of [$0] for a letter position
  /// means do not encode, but treat as a separator when it occurs between consonants with the same code.
  ///
  /// Mapping for US-ENGLISH RefinedSoundex:
  /// ```
  /// 0: A E I O U Y H W
  /// 1: B P
  /// 2: F V
  /// 3: C K S
  /// 4: G J
  /// 5: Q X Z
  /// 6: D T
  /// 7: L
  /// 8: M N
  /// 9: R
  /// ```
  static const Map<int, int> usEnglishMapping = {
    $A: $0,
    $B: $1,
    $C: $3,
    $D: $6,
    $E: $0,
    $F: $2,
    $G: $4,
    $H: $0,
    $I: $0,
    $J: $4,
    $K: $3,
    $L: $7,
    $M: $8,
    $N: $8,
    $O: $0,
    $P: $1,
    $Q: $5,
    $R: $9,
    $S: $3,
    $T: $6,
    $U: $0,
    $V: $2,
    $W: $0,
    $X: $5,
    $Y: $0,
    $Z: $5
  };

  /// An instance of Soundex using the [usEnglishMapping] mapping.
  static final RefinedSoundex usEnglishEncoder =
      RefinedSoundex.fromMapping(usEnglishMapping);

  //#region Constructors

  /// Private constructor for initializing an instance.
  /// No copy is done here because we can trust that our own internal collections are not modified.
  RefinedSoundex._internal(this._soundexMapping);

  /// Creates a custom instance using [soundexMapping]. This constructor can be used to
  /// provide custom mappings for non-Western character sets, etc.
  /// Characters must be mapped to a numerical value (also in character form).
  factory RefinedSoundex.fromMapping(final Map<int, int> soundexMapping) =>
      RefinedSoundex._internal(Map.from(soundexMapping));

  /// Gets the [usEnglishEncoder] instance of a RefinedSoundex encoder.
  factory RefinedSoundex() => usEnglishEncoder;

  //#endregion

  /// Despite the name, this is actually a similarity measure between [s1] and [s2].
  /// This naming is consistent with the SQL `DIFFERENCE` function definition.
  ///
  /// Returns a value that indicates the similarity (larger numbers indicate greater similarity).
  @override
  int difference(String s1, String s2) =>
      PhoneticUtils.difference(this, s1, s2);

  /// Encodes [input] using the Soundex algorithm. Returns an encoded String.
  @override
  String encode(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }

    input = PhoneticUtils.clean(input);
    if (input.isEmpty) {
      return input;
    }

    var stringBuffer = StringBuffer();
    stringBuffer.writeCharCode(input.codeUnitAt(0));

    int last, current;
    last = $asterisk;

    for (var charCode in input.codeUnits) {
      current = _soundexMapping[charCode];
      if (current == last) {
        continue;
      } else if (current != null) {
        stringBuffer.writeCharCode(current);
      }

      last = current;
    }

    return stringBuffer.toString();
  }
}
