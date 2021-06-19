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

import 'package:dart_phonetics/dart_phonetics.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('Constructor Tests', () {
    test('test basic constructors', () {
      expectEncoding(Nysiis(), 'Knight', 'NAGT');
      expectEncoding(Nysiis.originalEncoder, 'Mac Afee', 'MCAFY');
      expectEncoding(Nysiis.modifiedEncoder, 'Mac Afee', 'MCAFY');
      expectEncoding(
          Nysiis.withOptions(maxLength: 10), 'Mac Allister', 'MCALASTAR');
    });
  });

  group('Original Encoding Tests', () {
    test('test original basic encoding', () {
      final encoder = Nysiis.originalEncoder;
      expectEncoding(encoder, 'MACINTOSH', 'MCANT');
      expectEncoding(encoder, 'KNUTH', 'NAT');
      expectEncoding(encoder, 'KOEHN', 'CAN');
      expectEncoding(encoder, 'PHILLIPSON', 'FALAPS');
      expectEncoding(encoder, 'PFEISTER', 'FASTAR');
      expectEncoding(encoder, 'SCHOENHOEFT', 'SANAFT');
    });

    test('test original max length', () {
      final encoder8 = Nysiis.withOptions(maxLength: 8);
      expectEncoding(encoder8, 'PHILLIPSON', 'FALAPSAN');
      expectEncoding(encoder8, 'PFEISTER', 'FASTAR');
      expectEncoding(encoder8, 'SCHOENHOEFT', 'SANAFT');

      final encoderNoMax = Nysiis.withOptions(maxLength: 0);
      expectEncoding(encoderNoMax, 'PHILLIPSON', 'FALAPSAN');
      expectEncoding(encoderNoMax, 'PFEISTER', 'FASTAR');
      expectEncoding(encoderNoMax, 'SCHOENHOEFT', 'SANAFT');
    });

    // Examples from Table 2 of paper:
    // Performance Evaluation of Phonetic Matching Algorithms on [...]
    // https://scholar.google.com/scholar?cluster=634245576371390488&hl=en&as_sdt=0,21&as_vis=1
    test('test performance paper examples', () {
      final encoder = Nysiis.originalEncoder;
      final encoderNoMax = Nysiis.withOptions(maxLength: 0);

      expectEncoding(encoder, 'Phonetic', 'FANATA');
      expectEncoding(encoderNoMax, 'Phonetic', 'FANATAC');

      expectEncoding(encoder, 'Matching', 'MATCAN');
      expectEncoding(encoderNoMax, 'Matching', 'MATCANG');
    });

    // NOTE: This implementation is NOT 100% compatible with the dropby.com
    // examples because their "original" implementation has some errors
    // (duplicate first letters, KOEHN should be CAN, etc). Also, their
    // version the "modified" implementation is not the same as the USDA
    // version of the modified algorithm that is implemented here.
    test('test original dropby.com examples', () {
      final encoder = Nysiis.withOptions(maxLength: 0);
      expectEncoding(encoder, 'MACINTOSH', 'MCANT');
      expectEncoding(encoder, 'KNUTH', 'NAT');
      expectEncoding(encoder, 'KOEHN', 'CAN');
      expectEncoding(encoder, 'PHILLIPSON', 'FALAPSAN');
      expectEncoding(encoder, 'PFEISTER', 'FASTAR');
      expectEncoding(encoder, 'SCHOENHOEFT', 'SANAFT');
      expectEncoding(encoder, 'MCKEE', 'MCY');
      expectEncoding(encoder, 'MACKIE', 'MCY');
      expectEncoding(encoder, 'HEITSCHMIDT', 'HATSNAD');
      expectEncoding(encoder, 'BART', 'BAD');
      expectEncoding(encoder, 'HURD', 'HAD');
      expectEncoding(encoder, 'HUNT', 'HAD');
      expectEncoding(encoder, 'WESTERLUND', 'WASTARLAD');
      expectEncoding(encoder, 'CASSTEVENS', 'CASTAFAN');
      expectEncoding(encoder, 'VASQUEZ', 'VASG');
      expectEncoding(encoder, 'FRAZIER', 'FRASAR');
      expectEncoding(encoder, 'BOWMAN', 'BANAN');
      expectEncoding(encoder, 'MCKNIGHT', 'MCNAGT');
      expectEncoding(encoder, 'RICKERT', 'RACAD');
      expectEncoding(encoder, 'DEUTSCH', 'DAT');
      expectEncoding(encoder, 'WESTPHAL', 'WASTFAL');
      expectEncoding(encoder, 'SHRIVER', 'SRAVAR');
      expectEncoding(encoder, 'KUHL', 'CAL');
      expectEncoding(encoder, 'RAWSON', 'RASAN');
      expectEncoding(encoder, 'JILES', 'JAL');
      expectEncoding(encoder, 'CARRAWAY', 'CARY');
      expectEncoding(encoder, 'YAMADA', 'YANAD');
    });

    // http://coryodaniel.com/index.php/2009/12/30/ruby-nysiis-implementation/
    test('test performance paper examples', () {
      final encoder = Nysiis.originalEncoder;
      expectEncoding(encoder, "O'Daniel", 'ODANAL');
      expectEncoding(encoder, "O'Donnel", 'ODANAL');
      expectEncoding(encoder, 'Cory', 'CARY');
      expectEncoding(encoder, 'Corey', 'CARY');
      expectEncoding(encoder, 'Kory', 'CARY');
    });

    // http://ntz-develop.blogspot.com/2011/03/phonetic-algorithms.html
    test('test ntz examples', () {
      final encoder = Nysiis.withOptions(maxLength: 0);
      expectEncoding(encoder, 'Diggell', 'DAGAL');
      expectEncoding(encoder, 'Dougal', 'DAGAL');
      expectEncoding(encoder, 'Doughill', 'DAGAL');
      expectEncoding(encoder, 'Dougill', 'DAGAL');
      expectEncoding(encoder, 'Dowgill', 'DAGAL');
      expectEncoding(encoder, 'Dugall', 'DAGAL');
      expectEncoding(encoder, 'Dugall', 'DAGAL');
      expectEncoding(encoder, 'Glinde', 'GLAND');
      expectEncoding(encoder, 'Plumridge', 'PLANRADG');
      expectEncoding(encoder, 'Chinnick', 'CANAC');
      expectEncoding(encoder, 'Chinnock', 'CANAC');
      expectEncoding(encoder, 'Chinnock', 'CANAC');
      expectEncoding(encoder, 'Chomicki', 'CANAC');
      expectEncoding(encoder, 'Chomicz', 'CANAC');
      expectEncoding(encoder, 'Schimek', 'SANAC');
      expectEncoding(encoder, 'Shimuk', 'SANAC');
      expectEncoding(encoder, 'Simak', 'SANAC');
      expectEncoding(encoder, 'Simek', 'SANAC');
      expectEncoding(encoder, 'Simic', 'SANAC');
      expectEncoding(encoder, 'Sinnock', 'SANAC');
      expectEncoding(encoder, 'Sinnocke', 'SANAC');
      expectEncoding(encoder, 'Sunnex', 'SANAX');
      expectEncoding(encoder, 'Sunnucks', 'SANAC');
      expectEncoding(encoder, 'Sunock', 'SANAC');
      expectEncoding(encoder, 'Webberley', 'WABARLY');
      expectEncoding(encoder, 'Wibberley', 'WABARLY');
    });

    test('test original misc examples', () {
      final encoder = Nysiis.originalEncoder;
      expectEncoding(encoder, 'Alpharades', 'ALFARA');
      expectEncoding(encoder, 'Aschenputtel', 'ASANPA');
      expectEncoding(encoder, 'Beverly', 'BAFARL');
      expectEncoding(encoder, 'Hardt', 'HARD');
      expectEncoding(encoder, 'acknowledge', 'ACNALA');
      expectEncoding(encoder, 'MacNeill', 'MCNAL');
      expectEncoding(encoder, 'Knight', 'NAGT');
      expectEncoding(encoder, 'Pfarr', 'FAR');
      expectEncoding(encoder, 'Phair', 'FAR');
      expectEncoding(encoder, 'Cherokee', 'CARACY');
      expectEncoding(encoder, 'Iraq', 'IRAG');

      // Data Quality and Record Linkage Techniques P.121 claims this is SNAT,
      // but it should be SNAD
      expectEncoding(encoder, 'Schmidt', 'SNAD');
      // test SNAT
      expectEncoding(encoder, 'Smith', 'SNAT');
      expectEncoding(encoder, 'Schmit', 'SNAT');
      // test special branches
      expectEncoding(encoder, 'Kobwick', 'CABWAC');
      expectEncoding(encoder, 'Kocher', 'CACAR');
      expectEncoding(encoder, 'Fesca', 'FASC');
      expectEncoding(encoder, 'Shom', 'SAN');
      expectEncoding(encoder, 'Ohlo', 'OL');
      expectEncoding(encoder, 'Uhu', 'UH');
      expectEncoding(encoder, 'Um', 'UN');
      // test Trueman
      expectEncoding(encoder, 'Trueman', 'TRANAN');
      expectEncoding(encoder, 'Truman', 'TRANAN');
    });

    test('test original rules details', () {
      final encoder = Nysiis.originalEncoder;
      // first characters
      expectEncoding(encoder, 'MACX', 'MCX');
      expectEncoding(encoder, 'KNX', 'NX');
      expectEncoding(encoder, 'KX', 'CX');
      expectEncoding(encoder, 'PHX', 'FX');
      expectEncoding(encoder, 'PFX', 'FX');
      expectEncoding(encoder, 'SCHX', 'SX');
      // last characters
      expectEncoding(encoder, 'XEE', 'XY');
      expectEncoding(encoder, 'XIE', 'XY');
      expectEncoding(encoder, 'XDT', 'XD');
      expectEncoding(encoder, 'XRT', 'XD');
      expectEncoding(encoder, 'XRD', 'XD');
      expectEncoding(encoder, 'XNT', 'XD');
      expectEncoding(encoder, 'XND', 'XD');
      // EV and AEIOU
      expectEncoding(encoder, 'XEV', 'XAF');
      expectEncoding(encoder, 'XAX', 'XAX');
      expectEncoding(encoder, 'XEX', 'XAX');
      expectEncoding(encoder, 'XIX', 'XAX');
      expectEncoding(encoder, 'XOX', 'XAX');
      expectEncoding(encoder, 'XUX', 'XAX');
      // Q, Z, M rules
      expectEncoding(encoder, 'XQ', 'XG');
      expectEncoding(encoder, 'XZ', 'X');
      expectEncoding(encoder, 'XM', 'XN');
      // K rule
      expectEncoding(encoder, 'XKNX', 'XNX');
      expectEncoding(encoder, 'XKX', 'XCX');
      // SCH rule
      expectEncoding(encoder, 'SCHX', 'SX');
      expectEncoding(encoder, 'XSCHX', 'XSX');
      // PH rule
      expectEncoding(encoder, 'PHX', 'FX');
      expectEncoding(encoder, 'XPHX', 'XFX');
      expectEncoding(encoder, 'XPH', 'XF');
      // H rules
      expectEncoding(encoder, 'XH', 'X');
      expectEncoding(encoder, 'XHA', 'X');
      expectEncoding(encoder, 'XHX', 'X');
      expectEncoding(encoder, 'XHHHX', 'X');
      expectEncoding(encoder, 'HXH', 'HX');
      expectEncoding(encoder, 'AHA', 'AH');
      expectEncoding(encoder, 'XAHA', 'XAH');
      expectEncoding(encoder, 'XAHB', 'XAB');
      expectEncoding(encoder, 'BXHA', 'BX');
      // W rules
      expectEncoding(encoder, 'XW', 'XW');
      expectEncoding(encoder, 'XWA', 'XW');
      expectEncoding(encoder, 'XWX', 'XWX');
      expectEncoding(encoder, 'WXW', 'WXW');
      expectEncoding(encoder, 'AWA', 'A');
      expectEncoding(encoder, 'XAWA', 'X');
      expectEncoding(encoder, 'XAWB', 'XAB');
      expectEncoding(encoder, 'BXWA', 'BXW');
      expectEncoding(encoder, 'XWWWW', 'XW');
      expectEncoding(encoder, 'AWWWW', 'A');
      // repeated character rules
      expectEncoding(encoder, 'XAEIOU', 'X');
      expectEncoding(encoder, 'XAEIOUX', 'XAX');
      expectEncoding(encoder, 'KNNNOOOWWW', 'N');
      expectEncoding(encoder, 'IKNNNOOOWWW', 'IN');
      // ending S rule
      expectEncoding(encoder, 'XSCH', 'X');
      expectEncoding(encoder, 'XAHS', 'X');
      expectEncoding(encoder, 'ZACHS', 'ZAC');
      // ending AY rule
      expectEncoding(encoder, 'XAY', 'XY');
      expectEncoding(encoder, 'XAYS', 'XY');
      // last A rule
      expectEncoding(encoder, 'XA', 'X');
      expectEncoding(encoder, 'XAS', 'X');
      // edge cases
      expectEncoding(encoder, 'A', 'A');
      expectEncoding(encoder, 'AE', 'A');
      expectEncoding(encoder, 'HA', 'H');
      expectEncoding(encoder, 'AW', 'A');
      expectEncoding(encoder, 'AS', 'A');
      expectEncoding(encoder, 'AY', 'Y');
    });
  });

  group('Modified Encoding Tests', () {
    test('test modified basic encoding', () {
      final encoder = Nysiis.modifiedEncoder;
      expectEncoding(encoder, 'MACINTOSH', 'MCANTAS');
      expectEncoding(encoder, 'KNUTH', 'NAT');
      expectEncoding(encoder, 'KOEHN', 'CAN');
      expectEncoding(encoder, 'PHILLIPSON', 'FALAPSAN');
      expectEncoding(encoder, 'PFEISTER', 'FASTAR');
      expectEncoding(encoder, 'SCHOENHOEFT', 'SANAFT');
    });

    test('test modified max length', () {
      final encoder8 = Nysiis.withOptions(maxLength: 7, enableModified: true);
      expectEncoding(encoder8, 'PHILLIPSON', 'FALAPSA');
      expectEncoding(encoder8, 'PFEISTER', 'FASTAR');
      expectEncoding(encoder8, 'SCHOENHOEFT', 'SANAFT');

      final encoderNoMax =
          Nysiis.withOptions(maxLength: 0, enableModified: true);
      expectEncoding(encoderNoMax, 'PHILLIPSON', 'FALAPSAN');
      expectEncoding(encoderNoMax, 'PFEISTER', 'FASTAR');
      expectEncoding(encoderNoMax, 'SCHOENHOEFT', 'SANAFT');
    });

    // NOTE: This implementation is NOT 100% compatible with the dropby.com
    // examples because their "original" implementation has some errors
    // (duplicate first letters, KOEHN should be CAN, etc). Also, their
    // version the "modified" implementation is not the same as the USDA
    // version of the modified algorithm that is implemented here.
    test('test modified dropby.com examples', () {
      final encoder = Nysiis.withOptions(maxLength: 0, enableModified: true);
      expectEncoding(encoder, 'MACINTOSH', 'MCANTAS');
      expectEncoding(encoder, 'KNUTH', 'NAT');
      expectEncoding(encoder, 'KOEHN', 'CAN');
      expectEncoding(encoder, 'PHILLIPSON', 'FALAPSAN');
      expectEncoding(encoder, 'PFEISTER', 'FASTAR');
      expectEncoding(encoder, 'SCHOENHOEFT', 'SANAFT');
      expectEncoding(encoder, 'MCKEE', 'MCY');
      expectEncoding(encoder, 'MACKIE', 'MCY');
      expectEncoding(encoder, 'HEITSCHMIDT', 'HATSNAD');
      expectEncoding(encoder, 'BART', 'BAD');
      expectEncoding(encoder, 'HURD', 'HAD');
      expectEncoding(encoder, 'HUNT', 'HAN');
      expectEncoding(encoder, 'WESTERLUND', 'WASTARLAN');
      expectEncoding(encoder, 'CASSTEVENS', 'CASTAFAN');
      expectEncoding(encoder, 'VASQUEZ', 'VASG');
      expectEncoding(encoder, 'FRAZIER', 'FRASAR');
      expectEncoding(encoder, 'BOWMAN', 'BANAN');
      expectEncoding(encoder, 'MCKNIGHT', 'MCNAT');
      expectEncoding(encoder, 'RICKERT', 'RACAD');
      expectEncoding(encoder, 'DEUTSCH', 'DATS');
      expectEncoding(encoder, 'WESTPHAL', 'WASTFAL');
      expectEncoding(encoder, 'SHRIVER', 'SRAVAR');
      expectEncoding(encoder, 'KUHL', 'CAL');
      expectEncoding(encoder, 'RAWSON', 'RASAN');
      expectEncoding(encoder, 'JILES', 'JAL');
      expectEncoding(encoder, 'CARRAWAY', 'CARY');
      expectEncoding(encoder, 'YAMADA', 'YANAD');
    });

    test('test modified examples from other sources', () {
      final encoder = Nysiis.modifiedEncoder;

      expectEncoding(encoder, 'Andrew', 'ANDR');
      expectEncoding(encoder, 'Robertson', 'RABARTSA');
      expectEncoding(encoder, 'Nolan', 'NALAN');

      // note that generation should be stripped first
      expectEncoding(encoder, 'Louis XVI', 'L');

      expectEncoding(encoder, 'Case', 'CAS');
      expectEncoding(encoder, 'Mclaughlin', 'MCLAGLAN');
      expectEncoding(encoder, 'Awale', 'AL');
      expectEncoding(encoder, 'Aegir', 'AGAR');
      expectEncoding(encoder, 'Lundgren', 'LANGRAN');
      expectEncoding(encoder, 'Philbert', 'FALBAD');
      expectEncoding(encoder, 'Harry', 'HARY');
      expectEncoding(encoder, 'Mackenzie', 'MCANSY');

      expectEncoding(encoder, 'Daves', 'DAV');
      expectEncoding(encoder, 'Davies', 'DAVY');
      expectEncoding(encoder, 'Devies', 'DAFY');
      expectEncoding(encoder, 'Divish', 'DAVAS');
      expectEncoding(encoder, 'Dove', 'DAV');
      expectEncoding(encoder, 'Devese', 'DAFAS');
      expectEncoding(encoder, 'Devies', 'DAFY');
      expectEncoding(encoder, 'Devos', 'DAF');

      expectEncoding(encoder, 'Schmit', 'SNAT');
      expectEncoding(encoder, 'Schmitt', 'SNAT');
      expectEncoding(encoder, 'Schmitz', 'SNAT');
      expectEncoding(encoder, 'Schmoutz', 'SNAT');
      expectEncoding(encoder, 'Schnitt', 'SNAT');
      expectEncoding(encoder, 'Smit', 'SNAT');
      expectEncoding(encoder, 'Smite', 'SNAT');
      expectEncoding(encoder, 'Smits', 'SNAT');
      expectEncoding(encoder, 'Smoot', 'SNAT');
      expectEncoding(encoder, 'Smuts', 'SNAT');
      expectEncoding(encoder, 'Sneath', 'SNAT');
      expectEncoding(encoder, 'Smyth', 'SNAT');
      expectEncoding(encoder, 'Smithy', 'SNATY');
      expectEncoding(encoder, 'Smithey', 'SNATY');

      expectEncoding(encoder, 'Edwards', 'ADWAD');
      expectEncoding(encoder, 'Perez', 'PAR');
      expectEncoding(encoder, 'Macintosh', 'MCANTAS');
      expectEncoding(encoder, 'Phillipson', 'FALAPSAN');
      expectEncoding(encoder, 'Haddix', 'HADAC');
      expectEncoding(encoder, 'Essex', 'ASAC');
      expectEncoding(encoder, 'Moye', 'MY');
      expectEncoding(encoder, 'McKee', 'MCY');
      expectEncoding(encoder, 'Mackie', 'MCY');
      expectEncoding(encoder, 'Heitschmidt', 'HATSNAD');
      expectEncoding(encoder, 'Bart', 'BAD');
      expectEncoding(encoder, 'Hurd', 'HAD');
      expectEncoding(encoder, 'Hunt', 'HAN');
      expectEncoding(encoder, 'Westerlund', 'WASTARLA');
      expectEncoding(encoder, 'Evers', 'AVAR');
      expectEncoding(encoder, 'Devito', 'DAFAT');
      expectEncoding(encoder, 'Rawson', 'RASAN');
      expectEncoding(encoder, 'Shoulders', 'SALDAR');
      expectEncoding(encoder, 'Leighton', 'LATAN');
      expectEncoding(encoder, 'Wooldridge', 'WALDRAG');
      expectEncoding(encoder, 'Oliphant', 'ALAFAN');
      expectEncoding(encoder, 'Hatchett', 'HATCAT');
      expectEncoding(encoder, 'McKnight', 'MCNAT');
      expectEncoding(encoder, 'Rickert', 'RACAD');
      expectEncoding(encoder, 'Bowman', 'BANAN');
      expectEncoding(encoder, 'Vasquez', 'VASG');
      expectEncoding(encoder, 'Bashaw', 'BAS');
      expectEncoding(encoder, 'Schoenhoeft', 'SANAFT');
      expectEncoding(encoder, 'Heywood', 'HAD');
      expectEncoding(encoder, 'Hayman', 'HANAN');
      expectEncoding(encoder, 'Seawright', 'SARAT');
      expectEncoding(encoder, 'Kratzer', 'CRATSAR');
      expectEncoding(encoder, 'Canaday', 'CANADY');
      expectEncoding(encoder, 'Crepeau', 'CRAP');
    });

    test('test modified rules details', () {
      final encoder = Nysiis.modifiedEncoder;
      // first characters
      expectEncoding(encoder, 'MACX', 'MCX');
      expectEncoding(encoder, 'KNX', 'NX');
      expectEncoding(encoder, 'KX', 'CX');
      expectEncoding(encoder, 'PHX', 'FX');
      expectEncoding(encoder, 'PFX', 'FX');
      expectEncoding(encoder, 'SCHX', 'SX');
      expectEncoding(encoder, 'WRX', 'RX'); // WR modified
      expectEncoding(encoder, 'RHX', 'RX'); // WR modified
      expectEncoding(encoder, 'DGX', 'GX'); // WR modified
      expectEncoding(encoder, 'AN', 'AN'); // A modified
      expectEncoding(encoder, 'EN', 'AN'); // E modified
      expectEncoding(encoder, 'IN', 'AN'); // I modified
      expectEncoding(encoder, 'ON', 'AN'); // O modified
      expectEncoding(encoder, 'UN', 'AN'); // U modified
      // drop terminal S and Z
      expectEncoding(encoder, 'XS', 'X');
      expectEncoding(encoder, 'XZ', 'X');
      expectEncoding(encoder, 'XSHS', 'XS');
      expectEncoding(encoder, 'XSHZ', 'XS');
      expectEncoding(encoder, 'WICSZ', 'WAC'); // Z is terminal S dropped later
      // last characters
      expectEncoding(encoder, 'XEE', 'XY');
      expectEncoding(encoder, 'XIE', 'XY');
      expectEncoding(encoder, 'XYE', 'XY'); // YE modified
      expectEncoding(encoder, 'XDT', 'XD');
      expectEncoding(encoder, 'XRT', 'XD');
      expectEncoding(encoder, 'XRD', 'XD');
      expectEncoding(encoder, 'XNT', 'XN'); // NT modified
      expectEncoding(encoder, 'XND', 'XN'); // ND modified
      expectEncoding(encoder, 'WIX', 'WAC'); // IX modified
      expectEncoding(encoder, 'WEX', 'WAC'); // EX modified
      // EV and AEIOU
      expectEncoding(encoder, 'XEV', 'XAF');
      expectEncoding(encoder, 'XYX', 'XAX'); // Y modified
      expectEncoding(encoder, 'XEWY', 'XY'); // Y modified
      expectEncoding(encoder, 'XEY', 'XY'); // Y modified
      expectEncoding(encoder, 'XAX', 'XAX');
      expectEncoding(encoder, 'XEX', 'XAC'); // EX modified
      expectEncoding(encoder, 'XIX', 'XAC'); // IX modified
      expectEncoding(encoder, 'XOX', 'XAX');
      expectEncoding(encoder, 'XUX', 'XAX');
      // Q, Z, M rules
      expectEncoding(encoder, 'XQ', 'XG');
      expectEncoding(encoder, 'XZ', 'X');
      expectEncoding(encoder, 'XM', 'XN');
      // K rule
      expectEncoding(encoder, 'XKNX', 'XNX');
      expectEncoding(encoder, 'XKX', 'XCX');
      // SCH rule - modified = SSA if at end SSS otherwise
      expectEncoding(encoder, 'SCHOX', 'SAX');
      expectEncoding(encoder, 'BUSCH', 'BAS');
      expectEncoding(encoder, 'BABUSCH', 'BABAS');
      expectEncoding(encoder, 'BUSCHI', 'BAS');
      expectEncoding(encoder, 'BOWRUSCH', 'BARAS');
      // SH rule - modified = SA if at end SS otherwise
      expectEncoding(encoder, 'SHOX', 'SAX');
      expectEncoding(encoder, 'BUSH', 'BAS');
      expectEncoding(encoder, 'BABUSH', 'BABAS');
      expectEncoding(encoder, 'BUSHI', 'BAS');
      // PH rule
      expectEncoding(encoder, 'PHX', 'FX');
      expectEncoding(encoder, 'XPHX', 'XFX');
      expectEncoding(encoder, 'XPH', 'XF');
      // H rules
      expectEncoding(encoder, 'XH', 'X');
      expectEncoding(encoder, 'XHA', 'X');
      expectEncoding(encoder, 'XHX', 'X');
      expectEncoding(encoder, 'XHHHX', 'X');
      expectEncoding(encoder, 'HXH', 'HX');
      expectEncoding(encoder, 'AHA', 'AH');
      expectEncoding(encoder, 'XAHA', 'XAH');
      expectEncoding(encoder, 'XAHB', 'XAB');
      expectEncoding(encoder, 'BXHA', 'BX');
      // W rules
      expectEncoding(encoder, 'XW', 'XW');
      expectEncoding(encoder, 'XWA', 'XW');
      expectEncoding(encoder, 'XWX', 'XWX');
      expectEncoding(encoder, 'WXW', 'WXW');
      expectEncoding(encoder, 'AWA', 'A');
      expectEncoding(encoder, 'XAWA', 'X');
      expectEncoding(encoder, 'XAWB', 'XAB');
      expectEncoding(encoder, 'BXWA', 'BXW');
      expectEncoding(encoder, 'XWWWW', 'XW');
      expectEncoding(encoder, 'AWWWW', 'A');
      // repeated character rules
      expectEncoding(encoder, 'XAEIOU', 'X');
      expectEncoding(encoder, 'XAEIOUX', 'XAX');
      expectEncoding(encoder, 'KNNNOOOWWW', 'N');
      expectEncoding(encoder, 'IKNNNOOOWWW', 'AN');
      // ending S rule
      expectEncoding(encoder, 'XSCH', 'XS');
      expectEncoding(encoder, 'XAHS', 'XAH'); // modified removes terminal S
      expectEncoding(encoder, 'ZACHS', 'ZAC');
      // ending AY rule
      expectEncoding(encoder, 'XAY', 'XY');
      expectEncoding(encoder, 'XAYS', 'XY');
      // last A rule
      expectEncoding(encoder, 'XA', 'X');
      expectEncoding(encoder, 'XAS', 'X');
      // edge cases
      expectEncoding(encoder, 'A', 'A');
      expectEncoding(encoder, 'AE', 'A');
      expectEncoding(encoder, 'HA', 'H');
      expectEncoding(encoder, 'AW', 'A');
      expectEncoding(encoder, 'AS', 'A');
      expectEncoding(encoder, 'AY', 'Y');
    });
  });
}
