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
import 'package:dart_phonetics/src/utils.dart';

const int _soundexWidth = 4;

/// Encodes a string to a Soundex value. Soundex is a classic encoding scheme used to relate similar names. It can also
/// be used to find words that sound similar.
class Soundex implements PhoneticEncoder {
  /// The character mapping to use when encoding input strings.
  final Map<int, int> _soundexMapping;

  /// Specifies if `H` and `W` should be treated specially.
  /// When `false`, `H` and `W` are no longer special-cased.
  final bool _specialCaseHW;

  /// The character used to indicate a silent (ignored) character.
  /// These are ignored except when they appear as the first character.
  ///
  /// Note: the [usEnglishMapping] does not use this mechanism because changing it might break existing code.
  /// Mappings that don't contain a silent marker code are treated as though `H` and `W` are silent.
  static const silentIndicator = $minus;

  /// This is a default mapping of the 26 letters used in US English. A value of [$0] for a letter position
  /// means do not encode, but treat as a separator when it occurs between consonants with the same code.
  ///
  /// ***Note that letters `H` and `W` are treated specially.***
  /// They are ignored (after the first letter) and don't act as separators between consonants with the same code.
  ///
  /// Mapping:
  /// ```
  /// 0: A E I O U Y H W
  /// 1: B F P V
  /// 2: C G J K Q S X Z
  /// 3: D T
  /// 4: L
  /// 5: M N
  /// 6: R
  /// ```
  static const Map<int, int> usEnglishMapping = {
    $A: $0,
    $B: $1,
    $C: $2,
    $D: $3,
    $E: $0,
    $F: $1,
    $G: $2,
    $H: $0,
    $I: $0,
    $J: $2,
    $K: $2,
    $L: $4,
    $M: $5,
    $N: $5,
    $O: $0,
    $P: $1,
    $Q: $2,
    $R: $6,
    $S: $2,
    $T: $3,
    $U: $0,
    $V: $1,
    $W: $0,
    $X: $2,
    $Y: $0,
    $Z: $2
  };

  /// An instance of Soundex using the [usEnglishMapping] mapping.
  static final Soundex usEnglishEncoder = Soundex.fromMapping(usEnglishMapping);

  /// An instance of Soundex using the Simplified Soundex mapping, as described here:
  /// http://west-penwith.org.uk/misc/soundex.htm
  ///
  /// This treats `H` and `W` the same as vowels (`AEIOUY`).
  /// Such letters aren't encoded (after the first), but they do act as separators when dropping duplicate codes.
  /// The mapping is otherwise the same as for [usEnglishMapping].
  ///
  static final Soundex usEnglishSimplifiedEncoder =
      Soundex.fromMapping(usEnglishMapping, false);

  /// The Soundex mapping as per the Genealogy site:
  /// http://www.genealogy.com/articles/research/00000060.html
  ///
  /// Mapping:
  /// ```
  /// -: A E I O U Y H W
  /// 1: B F P V
  /// 2: C G J K Q S X Z
  /// 3: D T
  /// 4: L
  /// 5: M N
  /// 6: R
  /// ```
  static const Map<int, int> usEnglishGenealogyMapping = {
    $A: $minus,
    $B: $1,
    $C: $2,
    $D: $3,
    $E: $minus,
    $F: $1,
    $G: $2,
    $H: $minus,
    $I: $minus,
    $J: $2,
    $K: $2,
    $L: $4,
    $M: $5,
    $N: $5,
    $O: $minus,
    $P: $1,
    $Q: $2,
    $R: $6,
    $S: $2,
    $T: $3,
    $U: $minus,
    $V: $1,
    $W: $minus,
    $X: $2,
    $Y: $minus,
    $Z: $2
  };

  /// An instance of Soundex using the mapping as per the Genealogy site:
  /// http://www.genealogy.com/articles/research/00000060.html
  ///
  /// This treats vowels (`AEIOUY`), `H` and `W` as silent letters.
  /// Such letters are ignored (after the first) and do not act as separators when dropping duplicate codes.
  ///
  /// The codes for consonants are otherwise the same as for [usEnglishEncoder] and [usEnglishSimplifiedEncoder].
  static final Soundex usEnglishGenealogyEncoder =
      Soundex.fromMapping(usEnglishGenealogyMapping);

  /// Determines if the silent indicator is in [soundexMapping].
  /// Returns `true` if indicator is present, `false` otherwise.
  static bool _hasSilentIndicator(final Map<int, int> soundexMapping) =>
      soundexMapping.values.any((codeUnit) => (codeUnit == silentIndicator));

  //#region Constructors

  /// Private constructor for initializing an instance.
  /// No copy is done here because we can trust that our own internal collections are not modified.
  Soundex._internal(this._soundexMapping, this._specialCaseHW);

  /// Creates a custom instance using [soundexMapping] and [specialCaseHW]. This constructor can be used to
  /// provide custom mappings for non-Western character sets, etc.
  /// Characters must be mapped to a numerical value (also in character form).
  ///
  /// If [specialCaseHW] is not `null`, the value is used to control how the `H` and `W` characters are handled.
  /// Otherwise, if the mapping contains the [silentIndicator] then `H` and `W` are ***not*** given special treatment.
  factory Soundex.fromMapping(final Map<int, int> soundexMapping,
          [bool specialCaseHW]) =>
      Soundex._internal(Map.from(soundexMapping),
          (specialCaseHW ?? !_hasSilentIndicator(soundexMapping)));

  /// Gets the [usEnglishEncoder] instance of the Soundex encoder.
  factory Soundex() => usEnglishEncoder;

  //#endregion

  /// Despite the name, this is actually a similarity measure between [s1] and [s2].
  /// This naming is consistent with the SQL `DIFFERENCE` function definition.
  ///
  /// Returns a value that ranges from `0` through `4`, where `0` indicates
  /// little or no similarity, and `4` indicates strong similarity or identical values.
  int difference(final String s1, final String s2) =>
      PhoneticUtils.difference(this, s1, s2);

  /// Encodes a single [charCode] using [_soundexMapping] and returns [$0] if not found in the mapping.
  int _map(int charCode) {
    var mapped = _soundexMapping[charCode];
    return mapped ?? $0;
  }

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

    final soundex = StringBuffer();

    // the first character gets special treatment
    final firstMapped = input.codeUnitAt(0);
    soundex.writeCharCode(firstMapped);
    var lastMapped = _map(firstMapped);

    for (var charCode in input.codeUnits.sublist(1)) {
      if ((_specialCaseHW) && (charCode == $H || charCode == $W)) {
        // these are ignored completely
        continue;
      }

      final mapped = _map(charCode);
      if (mapped == silentIndicator) {
        continue;
      }

      if (mapped != $0 && mapped != lastMapped) {
        // don't store vowels or repeats
        soundex.writeCharCode(mapped);
      }

      lastMapped = mapped;

      if (soundex.length >= _soundexWidth) {
        break;
      }
    }

    while (soundex.length < _soundexWidth) {
      soundex.writeCharCode($0);
    }

    return soundex.toString();
  }
}
