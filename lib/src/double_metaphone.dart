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

/// Internal data class helper for writing to the [_primary] and [_alternate]
/// metaphone values.
class _DoubleMetaphoneEncoding {
  final StringBuffer _primary = StringBuffer();
  final StringBuffer _alternate = StringBuffer();
  final int _maxLength;

  _DoubleMetaphoneEncoding([this._maxLength]);

  void appendBoth(final int charCode) {
    appendPrimary(charCode);
    appendAlternate(charCode);
  }

  void appendEach(final int primaryCharCode, final int alternateCharCode) {
    appendPrimary(primaryCharCode);
    appendAlternate(alternateCharCode);
  }

  void appendPrimary(final int charCode) {
    if (_maxLength != null && _primary.length < _maxLength) {
      _primary.writeCharCode(charCode);
    }
  }

  void appendAlternate(final int charCode) {
    if (_maxLength != null && _alternate.length < _maxLength) {
      _alternate.writeCharCode(charCode);
    }
  }

  void appendBothString(final String value) {
    appendPrimaryString(value);
    appendAlternateString(value);
  }

  void appendEachString(
      final String primaryValue, final String alternateValue) {
    appendPrimaryString(primaryValue);
    appendAlternateString(alternateValue);
  }

  void appendPrimaryString(final String value) {
    final charsRemaining = _maxLength - _primary.length;
    if (value.length <= charsRemaining) {
      _primary.write(value);
    } else {
      _primary.write(value.substring(0, charsRemaining));
    }
  }

  void appendAlternateString(final String value) {
    final charsRemaining = _maxLength - _alternate.length;
    if (value.length <= charsRemaining) {
      _alternate.write(value);
    } else {
      _alternate.write(value.substring(0, charsRemaining));
    }
  }

  bool isMaxedOut() {
    return _primary.length >= _maxLength && _alternate.length >= _maxLength;
  }

  String get primary {
    return _primary.toString();
  }

  String get alternate {
    return _alternate.toString();
  }
}

/// Encodes a string to a Double Metaphone value. This implementation is
/// based on the [algorithm that was published by Lawrence Philips in Dr.
/// Dobbs](https://www.drdobbs.com/the-double-metaphone-search-algorithm/184401251?pgno=2).
/// and includes the fixes published by others. Per specification, the
/// encoding always contains two values. If there is no alternate, the
/// primary and the alternate encodings will be the same.
///
/// Note that this implementation avoids any class corruption or concurrency
/// problems by avoiding class properties. All of the data required is passed
/// on the stack when each internal method is called.
///
/// This algorithm improves on the Soundex algorithm by using expert rules
/// about inconsistencies in English spelling and pronunciation to produce a
/// more accurate encoding, which does a better job of matching words and
/// names which sound similar. Just like Soundex, similar-sounding words
/// should share the same keys.
///
/// If you want (or need) to understand more details, here are some good
/// references that help explain the details:
/// - https://en.wikipedia.org/wiki/Metaphone#Double_Metaphone
/// - http://aspell.net/metaphone/
class DoubleMetaphone implements PhoneticEncoder {
  /// Default metaphone encoding length to use.
  static const int defaultMaxLength = 4;

  /// Maximum length of the encoding, where `null` indicates no maximum.
  final int maxLength;

  // Set.contains() for single character matches are fast and convenient
  static const Set<int> _L_R_N_M_B_H_F_V_W_SPACE = {
    $L,
    $R,
    $N,
    $M,
    $B,
    $H,
    $F,
    $V,
    $W,
    $space
  };
  static const Set<int> _T_D = {$T, $D};
  static const Set<int> _T_S = {$T, $S};
  static const Set<int> _A_O = {$A, $O};
  static const Set<int> _A_O_U_E = {$A, $O, $U, $E};
  static const Set<int> _C_K_Q = {$C, $K, $Q};
  static const Set<int> _C_X = {$C, $X};
  static const Set<int> _E_I = {$E, $I};
  static const Set<int> _E_I_Y = {$E, $I, $Y};
  static const Set<int> _E_I_H = {$E, $I, $H};
  static const Set<int> _B_D_H = {$B, $D, $H};
  static const Set<int> _B_H = {$B, $H};
  static const Set<int> _P_B = {$P, $B};
  static const Set<int> _S_Z = {$S, $Z};
  static const Set<int> _S_K_L = {$S, $K, $L};
  static const Set<int> _C_G_L_R_T = {$C, $G, $L, $R, $T};
  static const Set<int> _M_N_L_W = {$M, $N, $L, $W};
  static const Set<int> _L_T_K_S_N_M_B_Z = {$L, $T, $K, $S, $N, $M, $B, $Z};

  // RegExp compiles patterns to achieve an efficient traversal
  static final _SILENT_START_REGEXP = RegExp(r'GN|KN|PN|WR|PS');
  static final _SLAVO_GERMANIC_REGEXP = RegExp(r'W|K|CZ|WITZ');
  static final _AS_OS_REGEXP = RegExp(r'AS|OS');
  static final _AI_OI_REGEXP = RegExp(r'AI|OI');
  static final _AU_OU_REGEXP = RegExp(r'AU|OU');
  static final _ME_MA_REGEXP = RegExp(r'ME|MA');
  static final _ER_EN_REGEXP = RegExp(r'ER|EN');
  static final _OM_AM_REGEXP = RegExp(r'OM|AM');
  static final _CE_CI_REGEXP = RegExp(r'CE|CI');
  static final _DT_DD_REGEXP = RegExp(r'DT|DD');
  static final _RGY_OGY_REGEXP = RegExp(r'RGY|OGY');
  static final _ISL_YSL_REGEXP = RegExp(r'ISL|YSL');
  static final _IAU_EAU_REGEXP = RegExp(r'IAU|EAU');
  static final _TIA_TCH_REGEXP = RegExp(r'TIA|TCH');
  static final _CK_CG_CQ_REGEXP = RegExp(r'CK|CG|CQ');
  static final _CI_CE_CY_REGEXP = RegExp(r'CI|CE|CY');
  static final _ZO_ZI_ZA_REGEXP = RegExp(r'ZO|ZI|ZA');
  static final _sC_sQ_sG_REGEXP = RegExp(r'\s(C|Q|G)');
  static final _AGGI_OGGI_REGEXP = RegExp(r'AGGI|OGGI');
  static final _WICZ_WITZ_REGEXP = RegExp(r'WICZ|WITZ');
  static final _VANs_VONs_REGEXP = RegExp(r'(VAN|VON)\s');
  static final _OO_UY_ED_EM_REGEXP = RegExp(r'OO|UY|ED|EM');
  static final _CIO_CIE_CIA_REGEXP = RegExp(r'CIO|CIE|CIA');
  static final _UCCEE_UCCES_REGEXP = RegExp(r'UCCEE|UCCES');
  static final _HARAC_HARIS_REGEXP = RegExp(r'HARAC|HARIS');
  static final _SIO_SIA_SIAN_REGEXP = RegExp(r'SIO|SIA|SIAN');
  static final _BACHER_MACHER_REGEXP = RegExp(r'BACHER|MACHER');
  static final _ILLO_ILLA_ALLE_REGEXP = RegExp(r'ILLO|ILLA|ALLE');
  static final _HOR_HYM_HIA_HEM_REGEXP = RegExp(r'HOR|HYM|HIA|HEM');
  static final _HEIM_HOEK_HOLM_HOLZ_REGEXP = RegExp(r'HEIM|HOEK|HOLM|HOLZ');
  static final _ORCHES_ARCHIT_ORCHID_REGEXP = RegExp(r'ORCHES|ARCHIT|ORCHID');
  static final _DANGER_RANGER_MANGER_REGEXP = RegExp(r'DANGER|RANGER|MANGER');
  static final _EWSKI_EWSKY_OWSKI_OWSKY_REGEXP =
      RegExp(r'EWSKI|EWSKY|OWSKI|OWSKY');
  static final _ES_EP_EB_EL_EY_IB_IL_IN_IE_EI_ER_REGEXP =
      RegExp(r'ES|EP|EB|EL|EY|IB|IL|IN|IE|EI|ER');

  /// An instance that uses [defaultMaxLength] for [maxLength].
  static final DoubleMetaphone defaultEncoder =
      DoubleMetaphone.withMaxLength(defaultMaxLength);

  //#region Constructors

  /// Private constructor for initializing an instance.
  DoubleMetaphone._internal(this.maxLength);

  /// Creates an instance with a custom [maxLength].
  factory DoubleMetaphone.withMaxLength(int maxLength) =>
      DoubleMetaphone._internal(maxLength);

  /// Gets the [defaultEncoder] instance of the encoder by default.
  factory DoubleMetaphone() => defaultEncoder;

  //#endregion

  //#region Helper Functions

  /// Returns `true` if [value] contains [_SLAVO_GERMANIC_REGEXP].
  static bool _isSlavoGermanic(final String value) {
    return value.contains(_SLAVO_GERMANIC_REGEXP);
  }

  /// Returns `true` if the value starts with [_SILENT_START_REGEXP].
  static bool _isSilentStart(final String value) {
    return value.startsWith(_SILENT_START_REGEXP);
  }

  /// Returns the character from [value] at [index] or $nul if the index is
  /// out of range.
  static int _codeUnitAt(final String value, final int index) {
    return (index < 0 || index >= value.length)
        ? $nul
        : value.codeUnitAt(index);
  }

  /// Returns `true` if the character from [value] at [index] matches
  /// [pattern] or `false` (including if [index] is if out of range).
  static bool _startsWith(final String value, final Pattern pattern,
      [final int index = 0]) {
    return (index < 0 || index >= value.length)
        ? false
        : value.startsWith(pattern, index);
  }

  //#endregion

  /// Per specification, the encoding always contains two values. If there is
  /// no alternate, the primary and the alternate encodings will be the same.
  @override
  PhoneticEncoding encode(String input) {
    // clean up the input and convert to uppercase
    input = PhoneticUtils.clean(input);
    if (input == null) {
      return null;
    }

    final encoding = _DoubleMetaphoneEncoding(maxLength);

    final slavoGermanic = _isSlavoGermanic(input);
    final silentStart = _isSilentStart(input);

    // using an iterator allows us to iterate through the characters when
    // possible and avoid using more expensive operations except when needed.
    final iterator = input.codeUnits.iterator;

    var index = 0;
    if (silentStart) {
      // skip the first character if it's a silent start
      iterator.moveNext();
      index++;
    } else if (PhoneticUtils.isVowel(_codeUnitAt(input, 0))) {
      encoding.appendBoth($A);
      iterator.moveNext();
      index++;
    }

    while (iterator.moveNext() && !encoding.isMaxedOut()) {
      final currentChar = iterator.current;

      var advance = 1;
      switch (currentChar) {
        case $B:
          encoding.appendBoth($P);
          advance = _codeUnitAt(input, index + 1) == $B ? 2 : 1;
          break;
        case $Ccedil:
          encoding.appendBoth($S);
          break;
        case $C:
          advance = _encodeC(encoding, input, index);
          break;
        case $D:
          advance = _encodeD(encoding, input, index);
          break;
        case $F:
          encoding.appendBoth($F);
          advance = _codeUnitAt(input, index + 1) == $F ? 2 : 1;
          break;
        case $G:
          advance = _encodeG(encoding, input, index, slavoGermanic);
          break;
        case $H:
          advance = _encodeH(encoding, input, index);
          break;
        case $J:
          advance = _encodeJ(encoding, input, index, slavoGermanic);
          break;
        case $K:
          encoding.appendBoth($K);
          advance = _codeUnitAt(input, index + 1) == $K ? 2 : 1;
          break;
        case $L:
          advance = _encodeL(encoding, input, index);
          break;
        case $M:
          advance = _encodeM(encoding, input, index);
          break;
        case $N:
          encoding.appendBoth($N);
          advance = _codeUnitAt(input, index + 1) == $N ? 2 : 1;
          break;
        case $Ntilde:
          encoding.appendBoth($N);
          break;
        case $P:
          advance = _encodeP(encoding, input, index);
          break;
        case $Q:
          encoding.appendBoth($K);
          advance = _codeUnitAt(input, index + 1) == $Q ? 2 : 1;
          break;
        case $R:
          advance = _encodeR(encoding, input, index, slavoGermanic);
          break;
        case $S:
          advance = _encodeS(encoding, input, index, slavoGermanic);
          break;
        case $T:
          advance = _encodeT(encoding, input, index);
          break;
        case $V:
          encoding.appendBoth($F);
          advance = _codeUnitAt(input, index + 1) == $V ? 2 : 1;
          break;
        case $W:
          advance = _encodeW(encoding, input, index);
          break;
        case $X:
          advance = _encodeX(encoding, input, index);
          break;
        case $Z:
          advance = _encodeZ(encoding, input, index, slavoGermanic);
          break;
        default:
          break;
      }

      // move through more until we're at a standard advance
      while (advance-- > 1) {
        iterator.moveNext();
        index++;
      }

      index++;
    }

    final primary = encoding.primary;
    final alternate = encoding.alternate;
    return PhoneticEncoding(primary, (alternate.isEmpty ? null : {alternate}));
  }

  //#region Special Encoding Rules

  static int _encodeC(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (_isSpecialC(value, index)) {
      encoding.appendBoth($K);
      return 2;
    } else if (index == 0 && _startsWith(value, 'CAESAR', index)) {
      encoding.appendBoth($S);
      return 2;
    } else if (_startsWith(value, 'CH', index)) {
      return _encodeCH(encoding, value, index);
    } else if (_startsWith(value, 'CZ', index) &&
        (index < 2 || !_startsWith(value, 'WI', index - 2))) {
      //-- "Czerny" but not "WICZ" --//
      encoding.appendEach($S, $X);
      return 2;
    } else if (_startsWith(value, 'CIA', index + 1)) {
      //-- "focaccia" --//
      encoding.appendBoth($X);
      return 3;
    } else if (_startsWith(value, 'CC', index) &&
        !(index == 1 && _codeUnitAt(value, 0) == $M)) {
      //-- double "cc" but not "McClelland" --//
      return _encodeCC(encoding, value, index);
    } else if (_startsWith(value, _CK_CG_CQ_REGEXP, index)) {
      encoding.appendBoth($K);
      return 2;
    } else if (_startsWith(value, _CI_CE_CY_REGEXP, index)) {
      //-- Italian vs. English --//
      if (_startsWith(value, _CIO_CIE_CIA_REGEXP, index)) {
        encoding.appendEach($S, $X);
      } else {
        encoding.appendBoth($S);
      }
      return 2;
    }

    encoding.appendBoth($K);
    if (_startsWith(value, _sC_sQ_sG_REGEXP, index + 1)) {
      //-- Mac Caffrey, Mac Gregor --//
      return 3;
    } else if (_C_K_Q.contains(_codeUnitAt(value, index + 1)) &&
        !_startsWith(value, _CE_CI_REGEXP, index + 1)) {
      return 2;
    }

    return 1;
  }

  static bool _isSpecialC(final String value, final int index) {
    if (_startsWith(value, 'CHIA', index)) {
      return true;
    } else if (index <= 1) {
      return false;
    } else if (PhoneticUtils.isVowel(_codeUnitAt(value, index - 2))) {
      return false;
    } else if (!_startsWith(value, 'ACH', index - 1)) {
      return false;
    } else {
      final char = _codeUnitAt(value, index + 2);
      return (char != $I && char != $E) ||
          ((index >= 2) &&
              _startsWith(value, _BACHER_MACHER_REGEXP, index - 2));
    }
  }

  static int _encodeCC(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (_E_I_H.contains(_codeUnitAt(value, index + 2)) &&
        !_startsWith(value, 'HU', index + 2)) {
      //-- "bellocchio" but not "bacchus" --//
      if ((index == 1 && _codeUnitAt(value, index - 1) == $A) ||
          _startsWith(value, _UCCEE_UCCES_REGEXP, index - 1)) {
        //-- "accident", "accede", "succeed" --//
        encoding.appendBothString('KS');
      } else {
        //-- "bacci", "bertucci", other Italian --//
        encoding.appendBoth($X);
      }
      return 3;
    }

    // Pierce's rule
    encoding.appendBoth($K);
    return 2;
  }

  static int _encodeCH(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (index > 0 && _startsWith(value, 'CHAE', index)) {
      // Michael
      encoding.appendEach($K, $X);
      return 2;
    } else if (_isSpecialCH1(value, index)) {
      //-- Greek roots ("chemistry", "chorus", etc.) --//
      encoding.appendBoth($K);
      return 2;
    } else if (_isSpecialCH2(value, index)) {
      //-- Germanic, Greek, or otherwise 'ch' for 'kh' sound --//
      encoding.appendBoth($K);
      return 2;
    }

    if (index > 0) {
      if (_startsWith(value, 'MC', 0)) {
        encoding.appendBoth($K);
      } else {
        encoding.appendEach($X, $K);
      }
    } else {
      encoding.appendBoth($X);
    }

    return 2;
  }

  static bool _isSpecialCH1(final String value, final int index) {
    if (index != 0) {
      return false;
    } else if (!_startsWith(value, _HARAC_HARIS_REGEXP, index + 1) &&
        !_startsWith(value, _HOR_HYM_HIA_HEM_REGEXP, index + 1)) {
      return false;
    } else if (_startsWith(value, 'CHORE', 0)) {
      return false;
    } else {
      return true;
    }
  }

  static bool _isSpecialCH2(final String value, final int index) {
    return ((_startsWith(value, _VANs_VONs_REGEXP, 0) ||
            _startsWith(value, 'SCH', 0)) ||
        _startsWith(value, _ORCHES_ARCHIT_ORCHID_REGEXP, index - 2) ||
        _T_S.contains(_codeUnitAt(value, index + 2)) ||
        ((index == 0 || _A_O_U_E.contains(_codeUnitAt(value, index - 1))) &&
            (_L_R_N_M_B_H_F_V_W_SPACE.contains(_codeUnitAt(value, index + 2)) ||
                index + 1 == value.length - 1)));
  }

  static int _encodeD(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (_startsWith(value, 'DG', index)) {
      //-- "Edge" --//
      if (_E_I_Y.contains(_codeUnitAt(value, index + 2))) {
        encoding.appendBoth($J);
        return 3;
        //-- "Edgar" --//
      } else {
        encoding.appendBothString('TK');
        return 2;
      }
    } else if (_startsWith(value, _DT_DD_REGEXP, index)) {
      encoding.appendBoth($T);
      return 2;
    }

    encoding.appendBoth($T);
    return 1;
  }

  static int _encodeG(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index, final bool slavoGermanic) {
    final nextChar = _codeUnitAt(value, index + 1);
    if (nextChar == $H) {
      return _encodeGH(encoding, value, index);
    } else if (nextChar == $N) {
      if (index == 1 &&
          PhoneticUtils.isVowel(_codeUnitAt(value, 0)) &&
          !slavoGermanic) {
        encoding.appendEachString('KN', 'N');
      } else if (!_startsWith(value, 'EY', index + 2) &&
          nextChar != $Y &&
          !slavoGermanic) {
        encoding.appendEachString('N', 'KN');
      } else {
        encoding.appendBothString('KN');
      }
      return 2;
    } else if (_startsWith(value, 'LI', index + 1) && !slavoGermanic) {
      encoding.appendEachString('KL', 'L');
      return 2;
    } else if (index == 0 &&
        (nextChar == $Y ||
            _startsWith(
                value, _ES_EP_EB_EL_EY_IB_IL_IN_IE_EI_ER_REGEXP, index + 1))) {
      //-- -ges-, -gep-, -gel-, -gie- at beginning --//
      encoding.appendEach($K, $J);
      return 2;
    } else if ((_startsWith(value, 'ER', index + 1) || nextChar == $Y) &&
        !_startsWith(value, _DANGER_RANGER_MANGER_REGEXP, 0) &&
        !_E_I.contains(_codeUnitAt(value, index - 1)) &&
        !_startsWith(value, _RGY_OGY_REGEXP, index - 1)) {
      //-- -ger-, -gy- --//
      encoding.appendEach($K, $J);
      return 2;
    } else if (_E_I_Y.contains(_codeUnitAt(value, index + 1)) ||
        _startsWith(value, _AGGI_OGGI_REGEXP, index - 1)) {
      //-- Italian "biaggi" --//
      if (_startsWith(value, _VANs_VONs_REGEXP, 0) ||
          _startsWith(value, 'SCH', 0) ||
          _startsWith(value, 'ET', index + 1)) {
        //-- obvious germanic --//
        encoding.appendBoth($K);
      } else if (_startsWith(value, 'IER', index + 1)) {
        encoding.appendBoth($J);
      } else {
        encoding.appendEach($J, $K);
      }
      return 2;
    } else if (nextChar == $G) {
      encoding.appendBoth($K);
      return 2;
    }

    encoding.appendBoth($K);
    return 1;
  }

  static int _encodeGH(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    final prevChar = _codeUnitAt(value, index - 1);
    if (index > 0 && !PhoneticUtils.isVowel(prevChar)) {
      encoding.appendBoth($K);
      return 2;
    } else if (index == 0) {
      if (_codeUnitAt(value, index + 2) == $I) {
        encoding.appendBoth($J);
      } else {
        encoding.appendBoth($K);
      }
      return 2;
    } else if ((index > 1 && _B_D_H.contains(_codeUnitAt(value, index - 2))) ||
        (index > 2 && _B_D_H.contains(_codeUnitAt(value, index - 3))) ||
        (index > 3 && _B_H.contains(_codeUnitAt(value, index - 4)))) {
      //-- Parker's rule (with some further refinements) - "hugh"
      return 2;
    }

    if (index > 2 &&
        prevChar == $U &&
        _C_G_L_R_T.contains(_codeUnitAt(value, index - 3))) {
      //-- "laugh", "McLaughlin", "cough", "gough", "rough", "tough"
      encoding.appendBoth($F);
    } else if (index > 0 && prevChar != $I) {
      encoding.appendBoth($K);
    }

    return 2;
  }

  static int _encodeH(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    //-- only keep if first & before vowel or between 2 vowels --//
    if ((index == 0 || PhoneticUtils.isVowel(_codeUnitAt(value, index - 1))) &&
        PhoneticUtils.isVowel(_codeUnitAt(value, index + 1))) {
      encoding.appendBoth($H);
      return 2;
      //-- also takes car of "HH" --//
    }

    return 1;
  }

  static int _encodeJ(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index, bool slavoGermanic) {
    if (_startsWith(value, 'JOSE', index) || _startsWith(value, 'SAN ')) {
      //-- obvious Spanish, "Jose", "San Jacinto" --//
      if ((index == 0 && (_codeUnitAt(value, index + 4) == $space) ||
              value.length == 4) ||
          _startsWith(value, 'SAN ')) {
        encoding.appendBoth($H);
      } else {
        encoding.appendEach($J, $H);
      }
    } else {
      if (index == 0 && !_startsWith(value, 'JOSE', index)) {
        encoding.appendEach($J, $A);
      } else if (PhoneticUtils.isVowel(_codeUnitAt(value, index - 1)) &&
          !slavoGermanic &&
          _A_O.contains(_codeUnitAt(value, index + 1))) {
        encoding.appendEach($J, $H);
      } else if (index == value.length - 1) {
        encoding.appendPrimary($J);
      } else if (!_L_T_K_S_N_M_B_Z.contains(_codeUnitAt(value, index + 1)) &&
          !_S_K_L.contains(_codeUnitAt(value, index - 1))) {
        encoding.appendBoth($J);
      }

      if (_codeUnitAt(value, index + 1) == $J) {
        return 2;
      }
    }

    return 1;
  }

  static int _encodeL(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (_codeUnitAt(value, index + 1) == $L) {
      if (_isSpecialL(value, index)) {
        encoding.appendPrimary($L);
      } else {
        encoding.appendBoth($L);
      }
      return 2;
    }

    encoding.appendBoth($L);
    return 1;
  }

  static bool _isSpecialL(final String value, final int index) {
    if (index == value.length - 3 &&
        _startsWith(value, _ILLO_ILLA_ALLE_REGEXP, index - 1)) {
      return true;
    } else if ((_startsWith(value, _AS_OS_REGEXP, value.length - 2) ||
            _A_O.contains(value.length - 1)) &&
        _startsWith(value, 'ALLE', index - 1)) {
      return true;
    } else {
      return false;
    }
  }

  static int _encodeM(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    encoding.appendBoth($M);

    if (_codeUnitAt(value, index + 1) == $M) {
      return 2;
    }

    if (_startsWith(value, 'UMB', index - 1) &&
        ((index + 1) == value.length - 1 ||
            _startsWith(value, 'ER', index + 2))) {
      return 2;
    }

    return 1;
  }

  static int _encodeP(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (_codeUnitAt(value, index + 1) == $H) {
      encoding.appendBoth($F);
      return 2;
    }

    encoding.appendBoth($P);
    return _P_B.contains(_codeUnitAt(value, index + 1)) ? 2 : 1;
  }

  static int _encodeR(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index, bool slavoGermanic) {
    if (index == value.length - 1 &&
        !slavoGermanic &&
        _startsWith(value, 'IE', index - 2) &&
        !_startsWith(value, _ME_MA_REGEXP, index - 4)) {
      encoding.appendAlternate($R);
    } else {
      encoding.appendBoth($R);
    }

    return _codeUnitAt(value, index + 1) == $R ? 2 : 1;
  }

  static int _encodeS(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index, bool slavoGermanic) {
    if (_startsWith(value, _ISL_YSL_REGEXP, index - 1)) {
      //-- special cases "island", "isle", "carlisle", "carlysle" --//
      return 1;
    } else if (index == 0 && _startsWith(value, 'SUGAR', index)) {
      //-- special case "sugar-" --//
      encoding.appendEach($X, $S);
      return 1;
    } else if (_startsWith(value, 'SH', index)) {
      if (_startsWith(value, _HEIM_HOEK_HOLM_HOLZ_REGEXP, index + 1)) {
        //-- germanic --//
        encoding.appendBoth($S);
      } else {
        encoding.appendBoth($X);
      }
      return 2;
    } else if (_startsWith(value, _SIO_SIA_SIAN_REGEXP, index)) {
      //-- Italian and Armenian --//
      if (slavoGermanic) {
        encoding.appendBoth($S);
      } else {
        encoding.appendEach($S, $X);
      }
      return 3;
    } else if ((index == 0 && _M_N_L_W.contains(_codeUnitAt(value, 1))) ||
        _codeUnitAt(value, index + 1) == $Z) {
      //-- german & anglicisations, e.g. "smith" match "schmidt" //
      // "snider" match "schneider" --//
      //-- also, -sz- in slavic language although in hungarian it //
      //   is pronounced "s" --//
      encoding.appendEach($S, $X);
      return (_codeUnitAt(value, index + 1) == $Z) ? 2 : 1;
    } else if (_startsWith(value, 'SC', index)) {
      return _encodeSC(encoding, value, index);
    }

    if ((index == value.length - 1) &&
        _startsWith(value, _AI_OI_REGEXP, index - 2)) {
      //-- french e.g. "resnais", "artois" --//
      encoding.appendAlternate($S);
    } else {
      encoding.appendBoth($S);
    }

    return _S_Z.contains(_codeUnitAt(value, index + 1)) ? 2 : 1;
  }

  static int _encodeSC(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (_codeUnitAt(value, index + 2) == $H) {
      //-- Schlesinger's rule --//
      final hasEREN = _startsWith(value, _ER_EN_REGEXP, index + 3);
      if (hasEREN) {
        //-- "schermerhorn", "schenker" --//
        encoding.appendEachString('X', 'SK');
      } else if (_startsWith(value, _OO_UY_ED_EM_REGEXP, index + 3)) {
        encoding.appendBothString('SK');
      } else {
        if (index == 0) {
          final charCode3 = _codeUnitAt(value, 3);
          if (!PhoneticUtils.isVowel(charCode3) && charCode3 != $W) {
            encoding.appendEach($X, $S);
          } else {
            encoding.appendBoth($X);
          }
        } else {
          encoding.appendBoth($X);
        }
      }
    } else if (_E_I_Y.contains(_codeUnitAt(value, index + 2))) {
      encoding.appendBoth($S);
    } else {
      encoding.appendBothString('SK');
    }

    return 3;
  }

  static int _encodeT(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (_startsWith(value, 'TION', index)) {
      encoding.appendBoth($X);
      return 3;
    } else if (_startsWith(value, _TIA_TCH_REGEXP, index)) {
      encoding.appendBoth($X);
      return 3;
    } else if (_startsWith(value, 'TH', index) ||
        _startsWith(value, 'TTH', index)) {
      if (_startsWith(value, _OM_AM_REGEXP, index + 2) ||
          //-- special case "thomas", "thames" or germanic --//
          _startsWith(value, _VANs_VONs_REGEXP, 0) ||
          _startsWith(value, 'SCH', 0)) {
        encoding.appendBoth($T);
      } else {
        encoding.appendEach($0, $T);
      }
      return 2;
    }

    encoding.appendBoth($T);
    return _T_D.contains(_codeUnitAt(value, index + 1)) ? 2 : 1;
  }

  static int _encodeW(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (_startsWith(value, 'WR', index)) {
      //-- can also be in middle of word --//
      encoding.appendBoth($R);
      return 2;
    } else {
      if (index == 0) {
        if (PhoneticUtils.isVowel(_codeUnitAt(value, index + 1))) {
          //-- Wasserman should match Vasserman --//
          encoding.appendEach($A, $F);
        } else if (_startsWith(value, 'WH', index)) {
          //-- need Uomo to match Womo --//
          encoding.appendBoth($A);
        }
      } else if ((index == value.length - 1 &&
              PhoneticUtils.isVowel(_codeUnitAt(value, index - 1))) ||
          _startsWith(value, _EWSKI_EWSKY_OWSKI_OWSKY_REGEXP, index - 1) ||
          _startsWith(value, 'SCH', 0)) {
        //-- Arnow should match Arnoff --//
        encoding.appendAlternate($F);
      } else if (_startsWith(value, _WICZ_WITZ_REGEXP, index)) {
        //-- Polish e.g. "filipowicz" --//
        encoding.appendEachString('TS', 'FX');
        return 4;
      }
    }

    return 1;
  }

  static int _encodeX(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index) {
    if (index == 0) {
      encoding.appendBoth($S);
      return 1;
    } else {
      if (!((index == value.length - 1) &&
          (_startsWith(value, _IAU_EAU_REGEXP, index - 3) ||
              _startsWith(value, _AU_OU_REGEXP, index - 2)))) {
        //-- French e.g. breaux --//
        encoding.appendBothString('KS');
      }
    }

    return _C_X.contains(_codeUnitAt(value, index + 1)) ? 2 : 1;
  }

  static int _encodeZ(final _DoubleMetaphoneEncoding encoding,
      final String value, final int index, bool slavoGermanic) {
    final nextChar = _codeUnitAt(value, index + 1);
    if (nextChar == $H) {
      //-- Chinese pinyin e.g. "zhao" or Angelina "Zhang" --//
      encoding.appendBoth($J);
      return 2;
    }

    if (_startsWith(value, _ZO_ZI_ZA_REGEXP, index + 1) ||
        (slavoGermanic && (index > 0 && _codeUnitAt(value, index - 1) != $T))) {
      encoding.appendEachString('S', 'TS');
    } else {
      encoding.appendBoth($S);
    }

    return nextChar == $Z ? 2 : 1;
  }

//#endregion

}
