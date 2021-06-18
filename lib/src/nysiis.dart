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
import 'package:dart_phonetics/src/utils.dart';

/// Encodes a string using The New York State Identification and Intelligence
/// System (NYSIIS) algorithm. It is basically a more modern alternative to
/// the original Soundex. It was intended to match names and surnames so it
/// may not perform as well on dictionary words.
///
/// This implementation follows the "original" and "modified" algorithms as
/// documented in the USDA reference below (Appendix B). Each algorithm is very
/// specific but many of the other implementations that were reviewed did not
/// seem to produce the same results. This implementation aims to reproduce
/// the algorithm exactly as stated in the USDA reference, whereas others have
/// taken some liberties with their implementations, which seems to be the
/// cause of many of the discrepancies.
///
/// Some examples of discrepancies discovered in other implementations:
/// - The "dropby.com" original algorithm includes duplicates in the first
/// character position, but this should be removed in step 6 of the step
/// 4-5-6 loop. Also, their "modified" version is not the same as the USDA
/// "modified" version (e.g., SH, SCH, YW).
/// - Some implementations seem to get the logic wrong for an H or W
/// encoding at the beginning of a string because they operate on a substring
/// starting at the second character instead of using a pointer based
/// approach as specified in the original algorithm. So they miss the
/// preceding character that a pointer based approach would have picked up if
/// the algorithm is followed as stated.
///
/// If you want (or need) to understand more details, here are some good
/// references that help explain the history and variants:
/// - https://naldc.nal.usda.gov/download/27833/PDF (also in curated references)
/// - http://www.dropby.com/NYSIIS.html (does not follow the USDA algorithms).
class Nysiis implements PhoneticEncoder {
  /// Default encoding length to use for the original algorithm.
  static const int defaultOriginalMaxLength = 6;

  /// Default encoding length to use for the modified algorithm.
  static const int defaultModifiedMaxLength = 8;

  /// Maximum length of the encoding, where `null` indicates no maximum.
  final int? maxLength;

  /// Indicates if the "modified" rules should be applied when encoding.
  final bool enableModified;

  /// An instance that uses [defaultOriginalMaxLength] for [maxLength] and sets
  /// [enableModified] to `false` to replicate the original NYSIIS algorithm.
  static final Nysiis originalEncoder = Nysiis.withOptions(
      maxLength: defaultOriginalMaxLength, enableModified: false);

  /// An instance that uses [defaultModifiedMaxLength] for [maxLength] and sets
  /// [enableModified] to `true` to replicate the modified NYSIIS algorithm.
  static final Nysiis modifiedEncoder = Nysiis.withOptions(
      maxLength: defaultModifiedMaxLength, enableModified: true);

  //#region Constructors

  /// Private constructor for initializing an instance.
  Nysiis._internal(this.maxLength, this.enableModified);

  /// Creates an instance with a custom [maxLength] and [enableModified]. The
  /// defaults are consistent with the [originalEncoder].
  factory Nysiis.withOptions(
          {int? maxLength = defaultOriginalMaxLength,
          bool enableModified = false}) =>
      Nysiis._internal(maxLength, enableModified);

  /// Gets the [originalEncoder] instance of the encoder.
  factory Nysiis() => originalEncoder;

  //#endregion

  /// Transcode using the first letter rules.
  void _transcodeFirstLetters(List<int> chars) {
    if (chars.length < 2) {
      return;
    }

    final firstChar = chars[0];

    // go through the original rules first
    switch (firstChar) {
      case $M:
        if (chars.length > 2 && chars[1] == $A && chars[2] == $C) {
          // MAC » MCC
          chars[1] = $C;
          chars[2] = $C;
        }
        break;
      case $K:
        if (chars[1] == $N) {
          // KN » NN
          chars[0] = $N;
          chars[1] = $N;
        } else {
          // K » C
          chars[0] = $C;
        }
        break;
      case $P:
        final nextChar = chars[1];
        if (nextChar == $H || nextChar == $F) {
          // PH » FF
          // PF » FF
          chars[0] = $F;
          chars[1] = $F;
        }
        break;
      case $S:
        if (chars.length > 2 && chars[1] == $C && chars[2] == $H) {
          // SCH » SSS
          chars[1] = $S;
          chars[2] = $S;
        }
        break;
      default:
        break;
    }

    // exit early if not applying modified rules
    if (!enableModified) {
      return;
    }

    // if the name starts with any vowels then convert them all to 'A' and
    // then exit early since none of the other rules would apply.
    if (PhoneticUtils.isSimpleVowel(firstChar)) {
      chars[0] = $A;
      for (var i = 1;
          i < chars.length && PhoneticUtils.isSimpleVowel(chars[i]);
          i++) {
        chars[i] = $A;
      }
      return;
    }

    // go through the rest of the modified rules
    switch (firstChar) {
      case $W:
        if (chars[1] == $R) {
          // WR » RR
          chars[0] = $R;
          chars[1] = $R;
        }
        break;
      case $R:
        if (chars[1] == $H) {
          // RH » RR
          chars[0] = $R;
          chars[1] = $R;
        }
        break;
      case $D:
        if (chars[1] == $G) {
          // DG » GG
          chars[0] = $G;
          chars[1] = $G;
        }
        break;
      default:
        break;
    }
  }

  /// Transcode using the last letter rules.
  void _transcodeLastLetters(List<int> chars) {
    if (chars.length < 2) {
      return;
    }

    var lastIndex = chars.length - 1;
    var lastChar = chars[lastIndex];

    // remove terminal S and Z if applying modified rules
    if (enableModified && (lastChar == $S || lastChar == $Z)) {
      chars.removeLast();

      if (chars.length < 2) {
        return;
      } else {
        lastChar = chars[--lastIndex];
      }
    }

    switch (lastChar) {
      case $E:
        final nextLastIndex = lastIndex - 1;
        final nextLastChar = chars[nextLastIndex];
        if (nextLastChar == $E || nextLastChar == $I) {
          // EE » Y (original + modified)
          // IE » Y (original + modified)
          chars.removeLast();
          chars.last = $Y;
        } else if (enableModified && nextLastChar == $Y) {
          // YE » Y (modified)
          chars.removeLast();
        }
        break;
      case $T:
        final nextLastIndex = lastIndex - 1;
        final nextLastChar = chars[nextLastIndex];
        if (nextLastChar == $D || nextLastChar == $R) {
          // DT » D (original + modified)
          // RT » D (original + modified)
          chars.removeLast();
          chars.last = $D;
        } else if (nextLastChar == $N) {
          if (enableModified) {
            // NT » N (modified)
            chars.removeLast();
          } else {
            // NT » D (original)
            chars.removeLast();
            chars.last = $D;
          }
        }
        break;
      case $D:
        final nextLastIndex = lastIndex - 1;
        final nextLastChar = chars[nextLastIndex];
        if (nextLastChar == $R) {
          // RD » D (original + modified)
          chars.removeAt(nextLastIndex);
        } else if (nextLastChar == $N) {
          if (enableModified) {
            // ND » N (modified)
            chars.removeLast();
          } else {
            // ND » D (original)
            chars.removeAt(nextLastIndex);
          }
        }
        break;
      case $X:
        if (enableModified) {
          final nextLastIndex = lastIndex - 1;
          final nextLastChar = chars[nextLastIndex];
          if (nextLastChar == $I || nextLastChar == $E) {
            // IX » ICK (modified)
            // EX » ECK (modified)
            chars.removeLast();
            chars.addAll([$C, $K]);
          }
        }
        break;
      default:
        break;
    }
  }

  /// Encode using the main encoding loop rules.
  List<int> _encodeLetters(List<int> chars) {
    // this will be used to "retain" characters per the original algorithm
    // first character at this point is the first character of the encoding
    final encoding = <int>[chars[0]];

    // NOTE: per specification, this loop starts at the second character.
    for (var i = 1; i < chars.length; i++) {
      final char = chars[i];
      if (char == null) {
        break;
      } else if (PhoneticUtils.isSpecialCharacter(char)) {
        continue;
      }

      if (PhoneticUtils.isSimpleVowel(char)) {
        // VOWELS » A
        chars[i] = $A;

        if (char == $E && i + 1 < chars.length && chars[i + 1] == $V) {
          // EV » AF
          chars[i + 1] = $F;
        }
      } else if (enableModified && char == $Y && i != chars.length - 1) {
        // Y » A (modified) - if not last letter
        chars[i] = $A;
      } else if (char == $Q) {
        // Q » G
        chars[i] = $G;
      } else if (char == $Z) {
        // Z » S
        chars[i] = $S;
      } else if (char == $M) {
        // M » N
        chars[i] = $N;
      } else if (char == $K) {
        if (i + 1 < chars.length && chars[i + 1] == $N) {
          // KN » K goes to N
          chars[i] = $N;
        } else {
          // K » C
          chars[i] = $C;
        }
      } else if (char == $S) {
        if (i + 2 < chars.length && chars[i + 1] == $C && chars[i + 2] == $H) {
          chars[i + 1] = $S;
          if (enableModified && i == chars.length - 3) {
            // SCH » SSA (modified) - if at end of name
            chars[i + 2] = $A;
          } else {
            // SCH » SSS
            chars[i + 2] = $S;
          }
        } else if (enableModified &&
            i + 1 < chars.length &&
            chars[i + 1] == $H) {
          if (i + 2 == chars.length) {
            // SH » SA (modified) - if at end of name
            chars[i + 1] = $A;
          } else {
            // SH » SS (modified) - if not at end of name
            chars[i + 1] = $S;
          }
        }
      } else if (char == $P) {
        if (i + 1 < chars.length && chars[i + 1] == $H) {
          // PH » FF
          chars[i] = $F;
          chars[i + 1] = $F;
        } else {
          chars[i] = $P;
        }
      } else if (enableModified &&
          char == $G &&
          i + 2 < chars.length &&
          chars[i + 1] == $H &&
          chars[i + 2] == $T) {
        // GHT » TTT (modified)
        chars[i] = $T;
        chars[i + 1] = $T;
      } else if (enableModified &&
          char == $D &&
          i + 1 < chars.length &&
          chars[i + 1] == $G) {
        // DG » GG (modified)
        chars[i] = $G;
      } else if (enableModified &&
          char == $W &&
          i + 1 < chars.length &&
          chars[i + 1] == $R) {
        // WR » RR (modified)
        chars[i] = $R;
      } else if (char == $H &&
          (!PhoneticUtils.isSimpleVowel(chars[i - 1]) ||
              (i + 1 < chars.length &&
                  !PhoneticUtils.isSimpleVowel(chars[i + 1])))) {
        chars[i] = chars[i - 1];
      } else if (char == $W && PhoneticUtils.isSimpleVowel(chars[i - 1])) {
        chars[i] = chars[i - 1];
      } else {
        chars[i] = char;
      }

      // don't write duplicates
      if (chars[i] != encoding.last) {
        encoding.add(chars[i]);
      }
    }

    return encoding;
  }

  // Apply the final rules to the encoding.
  void _applyFinalRules(List<int> encoding) {
    // remove last character if it's an S
    if (encoding.last == $S && encoding.length > 1) {
      encoding.removeLast();
    }

    // replace ending AY with Y
    if (encoding.last == $Y &&
        encoding.length > 1 &&
        encoding[encoding.length - 2] == $A) {
      encoding.removeAt(encoding.length - 2);
    }

    // remove last character if it's an A
    if (encoding.last == $A && encoding.length > 1) {
      encoding.removeLast();
    }
  }

  /// Encodes a string using the NYSIIS algorithm as configured. This encoder
  /// does not produce any [PhoneticEncoding.alternates] values.
  @override
  PhoneticEncoding? encode(String? input) {
    // clean up the input and convert to uppercase
    input = PhoneticUtils.clean(input);
    if (input == null) {
      return null;
    }

    // NOTE: This implementation performs the transcoding "in-place" by using
    // a strategy that would be similar to the pointer based strategy that is
    // inferred in the original algorithm.

    // copy the string so we can get a modifiable array/list of chars
    final chars = List<int>.from(input.codeUnits);

    // transcode first letters
    _transcodeFirstLetters(chars);

    // transcode last letters
    _transcodeLastLetters(chars);

    // encode remaining letters
    final encoding = _encodeLetters(chars);

    // apply the final rules to the encoding
    _applyFinalRules(encoding);

    // truncate the encoding to maxLength if required
    var finalEncoding = String.fromCharCodes(encoding);
    if (maxLength != null && finalEncoding.length > maxLength!) {
      finalEncoding = finalEncoding.substring(0, maxLength);
    }

    return PhoneticEncoding(finalEncoding);
  }
}
