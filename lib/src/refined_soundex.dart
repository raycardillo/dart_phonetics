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

/// Encodes a string to a RefinedSoundex value. RefinedSoundex contains more
/// groupings, no maximum length, and is optimized for spell checking words.
///
/// The strategy used by this class is unique because it's possible to
/// support other languages or character sets by providing a custom mapping.
///
/// See [Soundex] for more background and references to Soundex algorithms.
class RefinedSoundex implements PhoneticEncoder {
  /// The character mapping to use when encoding. A value of [$nul] means
  /// ignore the input character and do not encode it (e.g., vowels).
  final Map<int, int> soundexMapping;

  /// Maximum length of the encoding (and how much to pad if [paddingEnabled]).
  final int maxLength;

  /// This is a default mapping of the 26 letters used in US English.
  static const Map<int, int> defaultMapping = {
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

  /// An instance of Soundex using the [defaultMapping] mapping.
  static final RefinedSoundex defaultEncoder =
      RefinedSoundex.fromMapping(defaultMapping);

  //#region Constructors

  /// Private constructor for initializing an instance.
  RefinedSoundex._internal(this.soundexMapping, this.maxLength);

  /// Creates a custom Soundex instance. This constructor can be used to
  /// provide custom mappings for non-Western character sets, etc.
  factory RefinedSoundex.fromMapping(final Map<int, int> soundexMapping,
          {int maxLength}) =>
      RefinedSoundex._internal(Map.unmodifiable(soundexMapping), maxLength);

  /// Gets the [defaultEncoder] instance of a RefinedSoundex encoder.
  factory RefinedSoundex() => defaultEncoder;

  //#endregion

  /// Returns a [PhoneticEncoding] for the [input] String.
  /// Returns `null` if the input is `null` or empty (after cleaning up).
  @override
  PhoneticEncoding encode(String input) {
    // clean up the input and convert to uppercase
    input = PhoneticUtils.clean(input);
    if (input == null) {
      return null;
    }

    // we'll write to a buffer to avoid string copies
    final soundex = StringBuffer();

    // always write first character
    soundex.writeCharCode(input.codeUnitAt(0));

    int last, current;
    last = $asterisk;

    // encode all characters
    for (var charCode in input.codeUnits) {
      current = soundexMapping[charCode];
      if (current == last) {
        continue;
      } else if (current != null) {
        soundex.writeCharCode(current);
      }

      if (maxLength != null && soundex.length >= maxLength) {
        break;
      }

      last = current;
    }

    return PhoneticEncoding(soundex.toString());
  }
}
