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

/// Encodes a string to a Soundex value. Soundex is a classic encoding scheme
/// used to compare names that sound similar. It can also be used to find
/// words that sound similar.
///
/// While the algorithm is fairly simple, there are several variants, so make
/// sure you know which variant you need if working with existing data. The
/// most notable exceptions are in census data and SQL implementations.
///
/// The implementation of this class is unique because it uses a mapping
/// strategy with several configurable behaviors that can be enabled or
/// disabled to support many variants. it's also possible to use a custom
/// mapping for other languages or character sets.
///
/// For convenience, there are several static instances available for some of
/// the more common implementations:
/// - [americanEncoder] - Implements the standard American Soundex algorithm
/// as described by _The National Archives and Records Administration (NARA)_
/// (https://www.archives.gov/research/census/soundex.html).
/// - [specialEncoder] - This is the same as [americanEncoder] but the `H` and
/// `W` are not ignored like they were supposed to have been. The census data
/// for 1880 through 1910 included standard codes as well as these special
/// codes randomly intermixed.
/// - [genealogyEncoder] - Implements the rules from the _genealogy.com_
/// (https://www.genealogy.com/articles/research/00000060.html) website. This
/// is the same as the [americanEncoder] but ignored characters are not
/// tracked for consonant breaks and are completely ignored instead.
///
/// If you want (or need) to understand more details, here are some good
/// references that help explain the history and variants:
/// - https://web.archive.org/web/20011107131342/http://www.bluepoof.com/Soundex/info.html
/// - http://creativyst.com/Doc/Articles/SoundEx1/SoundEx1.htm
/// - https://west-penwith.org.uk/misc/soundex.htm
class Soundex implements PhoneticEncoder {
  /// The character mapping to use when encoding. A value of [$nul] means
  /// ignore the input character and do not encode it (e.g., vowels).
  final Map<int, int> soundexMapping;

  /// Indicates that prefix processing is enabled (and will be returned as
  /// [PhoneticEncoding.alternate] when available). This also detects the
  /// second part of a double barreled name.
  final bool prefixesEnabled;

  /// Indicates that hyphenated parts processing is enabled. When enabled,
  /// any parts that are found are also encoded and returned as alternates.
  final bool hyphenatedPartsEnabled;

  /// Indicates if [$H] and [$W] should be completely ignored and not mapped
  /// at all. This is a special case for some census data.
  final bool ignoreHW;

  /// Indicates if ignored characters are tracked or completely ignored.
  /// When enabled, ignored characters still act as a separator when it
  /// occurs between consonants, otherwise they are completely ignored.
  final bool trackIgnored;

  /// Indicates if the string will be padded. If `true`, the encoded output
  /// will be padded with [paddingChar] to the length of [maxLength].
  final bool paddingEnabled;

  /// The character to use for padding (when [paddingEnabled] is `true`).
  final int paddingChar;

  /// Maximum length of the encoding (and how much to pad if [paddingEnabled]).
  final int maxLength;

  /// This is a default mapping of the 26 letters used in US English.
  static const Map<int, int> americanMapping = {
    $A: $nul,
    $B: $1,
    $C: $2,
    $D: $3,
    $E: $nul,
    $F: $1,
    $G: $2,
    $H: $nul,
    $I: $nul,
    $J: $2,
    $K: $2,
    $L: $4,
    $M: $5,
    $N: $5,
    $O: $nul,
    $P: $1,
    $Q: $2,
    $R: $6,
    $S: $2,
    $T: $3,
    $U: $nul,
    $V: $1,
    $W: $nul,
    $X: $2,
    $Y: $nul,
    $Z: $2
  };

  /// An instance of Soundex using the [americanMapping] mapping.
  static final Soundex americanEncoder = Soundex.fromMapping(americanMapping);

  /// An instance of Soundex using the [americanMapping] mapping, but
  /// configured for the special case, and does not ignore H and W.
  static final Soundex specialEncoder =
      Soundex.fromMapping(americanMapping, ignoreHW: false);

  /// An instance of Soundex using the [americanMapping] mapping, but
  /// configured for the special case, and does not ignore H and W.
  static final Soundex genealogyEncoder =
      Soundex.fromMapping(americanMapping, trackIgnored: false);

  //#region Constructors

  /// Private constructor for initializing an instance.
  Soundex._internal(
      this.soundexMapping,
      this.prefixesEnabled,
      this.hyphenatedPartsEnabled,
      this.ignoreHW,
      this.trackIgnored,
      this.maxLength,
      this.paddingChar,
      this.paddingEnabled);

  /// Creates a custom Soundex instance. This constructor can be used to
  /// provide custom mappings for non-Western character sets, etc.
  factory Soundex.fromMapping(final Map<int, int> soundexMapping,
          {bool prefixesEnabled = true,
          bool hyphenatedPartsEnabled = true,
          bool ignoreHW = true,
          bool trackIgnored = true,
          int maxLength = 4,
          int paddingChar = $0,
          bool paddingEnabled = true}) =>
      Soundex._internal(
          Map.unmodifiable(soundexMapping),
          prefixesEnabled,
          hyphenatedPartsEnabled,
          ignoreHW,
          trackIgnored,
          maxLength,
          paddingChar,
          paddingEnabled);

  /// Gets the [americanEncoder] instance of the Soundex encoder by default.
  factory Soundex() => americanEncoder;

  //#endregion

  /// Trims well known surname prefixes. This is very subject to interpretation
  /// but see the NARA specification as well as the following reference that
  /// provided some additional information and guidance:
  /// http://www.genealogyintime.com/GenealogyResources/Articles/what_is_soundex_and_how_does_soundex_work_page2.html
  String _trimPrefixes(String input) {
    return input.replaceFirst(
        RegExp(r"^(Con|Dela|De La|Di|Du|De|D'|La|Le|L'|Van|Von)\s*",
            caseSensitive: false),
        '');
  }

  /// Splits the string into two parts of a double barrel (using the hyphen).
  /// The second part will be `null` if a double barrel name was not found.
  List<String> _splitHyphenatedParts(String input) {
    return input.split(RegExp(r'\s*-\s*'));
  }

  /// Returns a single encoding for the [input] String.
  /// Returns `null` if the input is `null` or empty (after cleaning up).
  String _encode(String input) {
    // clean up the input and convert to uppercase
    input = PhoneticUtils.clean(input);
    if (input == null) {
      return null;
    }

    // we'll write to a buffer to avoid string copies
    final soundex = StringBuffer();

    // the first character gets special treatment
    final firstMapped = input.codeUnitAt(0);
    soundex.writeCharCode(firstMapped);
    var lastMapped = soundexMapping[firstMapped];

    // encode the rest of the characters
    for (var charCode in input.codeUnits.sublist(1)) {
      if (ignoreHW && (charCode == $H || charCode == $W)) {
        // completely ignore
        continue;
      }

      final mapped = soundexMapping[charCode];
      if (mapped == null) {
        // skip if no mapping at all
        continue;
      }

      // only write if it's not ignored and not a repeat
      if (mapped == $nul) {
        if (trackIgnored) {
          lastMapped = mapped;
        }
      } else {
        if (mapped != lastMapped) {
          soundex.writeCharCode(mapped);
          lastMapped = mapped;
        }
      }

      if (maxLength != null && soundex.length >= maxLength) {
        break;
      }
    }

    // pad the encoding if required
    if (paddingEnabled && maxLength != null) {
      while (soundex.length < maxLength) {
        soundex.writeCharCode(paddingChar);
      }
    }

    return soundex.toString();
  }

  /// Adds an encoding to [alternates] if there was a known prefix present.
  void _addTrimmedPrefixToAlternates(
      final Set<String> alternates, final String input) {
    final trimmed = _trimPrefixes(input);
    if (trimmed.length < input.length) {
      alternates.add(_encode(trimmed));
    }
  }

  /// Returns a [PhoneticEncoding] for the [input] String.
  /// Returns `null` if the input is `null` or empty (after cleaning up).
  @override
  PhoneticEncoding encode(String input) {
    if (input == null || input.isEmpty) {
      return null;
    }

    List<String> parts;
    if (hyphenatedPartsEnabled) {
      parts = _splitHyphenatedParts(input);
    } else {
      parts = [input];
    }

    final iterator = parts.iterator;
    if (!iterator.moveNext()) {
      return null;
    }

    // first we encode the primary part
    final firstPart = iterator.current;
    final primary = _encode(firstPart);

    // ignore: prefer_collection_literals
    final alternates = Set<String>();

    if (prefixesEnabled) {
      _addTrimmedPrefixToAlternates(alternates, firstPart);
    }

    // now go through all parts and add more alternates
    while (iterator.moveNext()) {
      final part = iterator.current;
      if (part != null) {
        alternates.add(_encode(part));
        if (prefixesEnabled) {
          _addTrimmedPrefixToAlternates(alternates, part);
        }
      }
    }

    // remove the primary if it made it into the alternate list from others
    alternates.remove(primary);

    return PhoneticEncoding(primary, alternates.isEmpty ? null : alternates);
  }
}
