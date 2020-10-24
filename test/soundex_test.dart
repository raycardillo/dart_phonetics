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
import 'package:dart_phonetics/dart_phonetics.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('Constructor Tests', () {
    test('test basic constructors', () {
      expectEncoding(Soundex(), 'Williams', 'W452');
      expectEncoding(Soundex.americanEncoder, 'Williams', 'W452');
      expectEncoding(Soundex.americanEncoder, 'Williams', 'W452');
      expectEncoding(Soundex.americanEncoder, 'Williams', 'W452');
      expectEncoding(
          Soundex.fromMapping(Soundex.americanMapping), 'Williams', 'W452');
      expectEncoding(
          Soundex.fromMapping(Soundex.americanMapping), 'Williams', 'W452');
    });
  });

  group('Encoding Tests', () {
    test('test basic encoding', () {
      final encoder = Soundex();
      expectEncoding(encoder, 'testing', 'T235');
      expectEncoding(encoder, 'TESTING', 'T235');
      expectEncoding(encoder, 'The', 'T000');
      expectEncoding(encoder, 'quick', 'Q200');
      expectEncoding(encoder, 'brown', 'B650');
      expectEncoding(encoder, 'fox', 'F200');
      expectEncoding(encoder, 'jumped', 'J513');
      expectEncoding(encoder, 'over', 'O160');
      expectEncoding(encoder, 'the', 'T000');
      expectEncoding(encoder, 'lazy', 'L200');
      expectEncoding(encoder, 'dogs', 'D200');
    });

    test('test max length', () {
      final encoder3 =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: 3);
      expectEncoding(encoder3, 'testing', 'T23');
      expectEncoding(encoder3, 'The', 'T00');
      expectEncoding(encoder3, 'quick', 'Q20');
      expectEncoding(encoder3, 'brown', 'B65');
      expectEncoding(encoder3, 'fox', 'F20');
      expectEncoding(encoder3, 'jumped', 'J51');
      expectEncoding(encoder3, 'over', 'O16');
      expectEncoding(encoder3, 'the', 'T00');
      expectEncoding(encoder3, 'lazy', 'L20');
      expectEncoding(encoder3, 'dogs', 'D20');

      final encoder5 =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: 5);
      expectEncoding(encoder5, 'testing', 'T2352');
      expectEncoding(encoder5, 'The', 'T0000');
      expectEncoding(encoder5, 'quick', 'Q2000');
      expectEncoding(encoder5, 'brown', 'B6500');
      expectEncoding(encoder5, 'fox', 'F2000');
      expectEncoding(encoder5, 'jumped', 'J5130');
      expectEncoding(encoder5, 'over', 'O1600');
      expectEncoding(encoder5, 'the', 'T0000');
      expectEncoding(encoder5, 'lazy', 'L2000');
      expectEncoding(encoder5, 'dogs', 'D2000');

      final encoder20 =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: 20);
      expectEncoding(encoder20, 'testing', 'T2352000000000000000');
      expectEncoding(encoder20, 'supercalifragilistic', 'S1624162423200000000');

      final encoder10 = Soundex.fromMapping(Soundex.americanMapping,
          maxLength: 10, paddingEnabled: false);
      expectEncoding(encoder10, 'testing', 'T2352');
      expectEncoding(encoder10, 'supercalifragilistic', 'S162416242');

      final encoderNoMax =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: null);
      expectEncoding(encoderNoMax, 'testing', 'T2352');
      expectEncoding(encoderNoMax, 'supercalifragilistic', 'S16241624232');
    });

    test('test irregular characters', () {
      final encoder = Soundex();

      expectEncoding(encoder, '#@', null);
      expectEncoding(encoder, '<test&ing>', 'T235');
      expectEncoding(encoder, '\0#tes@ting!', 'T235');
      expectEncoding(encoder, ' \t\n\r Washington \t\n\r ', 'W252');
    });

    // Examples from Table 2 of paper:
    // Performance Evaluation of Phonetic Matching Algorithms on [...]
    // https://scholar.google.com/scholar?cluster=634245576371390488&hl=en&as_sdt=0,21&as_vis=1
    test('test performance paper examples', () {
      final encoder = Soundex();
      final encoderNoMax =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: null);

      expectEncoding(encoder, 'Phonetic', 'P532');
      expectEncoding(encoderNoMax, 'Phonetic', 'P532');

      expectEncoding(encoder, 'Matching', 'M325');
      expectEncoding(encoderNoMax, 'Matching', 'M3252');
    });

    test('test B650', () {
      final encoder = Soundex();
      final inputs = [
        'BARHAM',
        'BARONE',
        'BARRON',
        'BERNA',
        'BIRNEY',
        'BIRNIE',
        'BOOROM',
        'BOREN',
        'BORN',
        'BOURN',
        'BOURNE',
        'BOWRON',
        'BRAIN',
        'BRAME',
        'BRANN',
        'BRAUN',
        'BREEN',
        'BRIEN',
        'BRIM',
        'BRIMM',
        'BRINN',
        'BRION',
        'BROOM',
        'BROOME',
        'BROWN',
        'BROWNE',
        'BRUEN',
        'BRUHN',
        'BRUIN',
        'BRUMM',
        'BRUN',
        'BRUNO',
        'BRYAN',
        'BURIAN',
        'BURN',
        'BURNEY',
        'BYRAM',
        'BYRNE',
        'BYRON',
        'BYRUM'
      ];
      expectEncodings(encoder, inputs, 'B650');
    });

    test('test normal encoding of special cases', () {
      final encoder = Soundex();

      // http://www.genealogyintime.com/GenealogyResources/Articles/what_is_soundex_and_how_does_soundex_work_page2.html
      expectEncoding(encoder, 'Johnston', 'J523');

      // in the standard mapping 'Lippmann' is 'L155' (see genealogy for alt)
      expectEncoding(encoder, 'Lippmann', 'L155');

      // Examples from http://www.bradandkathy.com/genealogy/overviewofsoundex.html
      expectEncoding(encoder, 'Allricht', 'A462');
      expectEncoding(encoder, 'Eberhard', 'E166');
      expectEncoding(encoder, 'Engebrethson', 'E521');
      expectEncoding(encoder, 'Heimbach', 'H512');
      expectEncoding(encoder, 'Hanselmann', 'H524');
      expectEncoding(encoder, 'Hildebrand', 'H431');
      expectEncoding(encoder, 'Kavanagh', 'K152');
      expectEncoding(encoder, 'Lind', 'L530');
      expectEncoding(encoder, 'Lukaschowsky', 'L222');
      expectEncoding(encoder, 'McDonnell', 'M235');
      expectEncoding(encoder, 'McGee', 'M200');
      expectEncoding(encoder, 'Opnian', 'O155');
      expectEncoding(encoder, 'Oppenheimer', 'O155');
      expectEncoding(encoder, 'Riedemanas', 'R355');
      expectEncoding(encoder, 'Zita', 'Z300');
      expectEncoding(encoder, 'Zitzmeinn', 'Z325');

      // Examples from http://www.archives.gov/research_room/genealogy/census/soundex.html
      expectEncoding(encoder, 'Washington', 'W252');
      expectEncoding(encoder, 'Lee', 'L000');
      expectEncoding(encoder, 'Gutierrez', 'G362');
      expectEncoding(encoder, 'Pfister', 'P236');
      expectEncoding(encoder, 'Jackson', 'J250');
      expectEncoding(encoder, 'Tymczak', 'T522');
      expectEncoding(encoder, 'VanDeusen', 'V532');

      // Examples from: http://www.myatt.demon.co.uk/sxalg.htm
      expectEncoding(encoder, 'HOLMES', 'H452');
      expectEncoding(encoder, 'ADOMOMI', 'A355');
      expectEncoding(encoder, 'VONDERLEHR', 'V536');
      expectEncoding(encoder, 'BALL', 'B400');
      expectEncoding(encoder, 'SHAW', 'S000');
      expectEncoding(encoder, 'JACKSON', 'J250');
      expectEncoding(encoder, 'SCANLON', 'S545');
      expectEncoding(encoder, 'SAINTJOHN', 'S532');

      // https://issues.apache.org/jira/browse/CODEC-54 https://issues.apache.org/jira/browse/CODEC-56
      expectEncoding(encoder, 'Williams', 'W452');

      // http://en.wikipedia.org/wiki/Soundex#American_Soundex as of December 2019.
      expectEncoding(encoder, 'Robert', 'R163');
      expectEncoding(encoder, 'Rupert', 'R163');
      expectEncoding(encoder, 'Ashcraft', 'A261');
      expectEncoding(encoder, 'Ashcroft', 'A261');
      expectEncoding(encoder, 'Tymczak', 'T522');
      expectEncoding(encoder, 'Pfister', 'P236');

      // and a few more for good measure
      expectEncoding(encoder, 'Ashclown', 'A245');
      expectEncoding(encoder, 'Shishko', 'S200');
      expectEncoding(encoder, 'Qashqar', 'Q260');

      // prefixes and double barrels should not be encoded when not enabled
      expectEncoding(encoder, 'von Neumann', 'V555', null);
      expectEncoding(encoder, 'WILLIAMS-LLOYD', 'W452', null);
    });

    test('test ignore apostrophes', () {
      final encoder = Soundex();
      final inputs = [
        "O'Brien",
        "OB'rien",
        "OBr'ien",
        "OBri'en",
        "OBrie'n",
        "OBrien'"
      ];

      expectEncodings(encoder, inputs, 'O165');
    });

    test('test ignore hyphens', () {
      final encoder = Soundex.fromMapping(Soundex.americanMapping,
          hyphenatedPartsEnabled: false);
      final inputs = [
        'KINGSMITH',
        'K-INGSMITH',
        'KI-NGSMITH',
        'KIN-GSMITH',
        'KING-SMITH',
        'KINGS-MITH',
        'KINGSM-ITH',
        'KINGSMI-TH',
        'KINGSMIT-H',
        'KINGSMITH-'
      ];
      expectEncodings(encoder, inputs, 'K525');
    });

    test('test HW rules', () {
      final encoder = Soundex();

      // Consonants from the same code group separated by W or H are treated as one.
      // From http://www.archives.gov/research_room/genealogy/census/soundex.html:
      // Ashcraft is coded A261 (A, 2 for the S, C ignored, 6 for the R, 1 for the F).
      expectEncoding(encoder, 'Ashcraft', 'A261');
      expectEncoding(encoder, 'Ashcroft', 'A261');
      expectEncoding(encoder, 'yehudit', 'Y330');
      expectEncoding(encoder, 'yhwdyt', 'Y330');

      // Consonants from the same code group separated by W or H are treated as one.
      // Test data from http://www.myatt.demon.co.uk/sxalg.htm
      expectEncoding(encoder, 'BOOTHDAVIS', 'B312');
      expectEncoding(encoder, 'BOOTH-DAVIS', 'B300', ['D120']);

      // Consonants from the same code group separated by W or H are treated as one.
      expectEncoding(encoder, 'Sgler', 'S460');
      expectEncoding(encoder, 'Swhgler', 'S460');
      final inputs = [
        'Sgler',
        'Swhgler',
        'SAILOR',
        'SALYER',
        'SAYLOR',
        'SCHALLER',
        'SCHELLER',
        'SCHILLER',
        'SCHOOLER',
        'SCHULER',
        'SCHUYLER',
        'SEILER',
        'SEYLER',
        'SHOLAR',
        'SHULER',
        'SILAR',
        'SILER',
        'SILLER'
      ];
      expectEncodings(encoder, inputs, 'S460');
    });

    test('test MsSql special cases', () {
      final encoder = Soundex();

      expectEncoding(encoder, 'Smith', 'S530');
      expectEncoding(encoder, 'Smythe', 'S530');
      final inputs = [
        'Erickson',
        'Erickson',
        'Erikson',
        'Ericson',
        'Ericksen',
        'Ericsen'
      ];
      expectEncodings(encoder, inputs, 'E625');

      expectEncoding(encoder, 'Ann', 'A500');
      expectEncoding(encoder, 'Andrew', 'A536');
      expectEncoding(encoder, 'Janet', 'J530');
      expectEncoding(encoder, 'Margaret', 'M626');
      expectEncoding(encoder, 'Steven', 'S315');
      expectEncoding(encoder, 'Michael', 'M240');
      expectEncoding(encoder, 'Robert', 'R163');
      expectEncoding(encoder, 'Laura', 'L600');
      expectEncoding(encoder, 'Anne', 'A500');
    });

    test('test special character cases', () {
      final encoder = Soundex();

      // Simple 'e' should work fine
      expectEncoding(encoder, 'e', 'E000');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(encoder, String.fromCharCode($Eacute), null);
      expectEncoding(encoder, String.fromCharCode($eacute), null);

      // Simple 'o' should work fine
      expectEncoding(encoder, 'o', 'O000');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(encoder, String.fromCharCode($Ouml), null);
      expectEncoding(encoder, String.fromCharCode($ouml), null);
    });

    test('test stringmetric examples', () {
      final encoder = Soundex();
      expectEncoding(encoder, 'abc', 'A120');
      expectEncoding(encoder, 'xyz', 'X200');
      expectEncoding(encoder, 'robert', 'R163');
      expectEncoding(encoder, 'rupert', 'R163');
      expectEncoding(encoder, 'rubin', 'R150');
      expectEncoding(encoder, 'ashcraft', 'A261');
      expectEncoding(encoder, 'tymczak', 'T522');
      expectEncoding(encoder, 'pfister', 'P236');
      expectEncoding(encoder, 'euler', 'E460');
      expectEncoding(encoder, 'gauss', 'G200');
      expectEncoding(encoder, 'hilbert', 'H416');
      expectEncoding(encoder, 'knuth', 'K530');
      expectEncoding(encoder, 'lloyd', 'L300');
      expectEncoding(encoder, 'lukasiewicz', 'L222');
      expectEncoding(encoder, 'ashcroft', 'A261');
      expectEncoding(encoder, 'tymczak', 'T522');
      expectEncoding(encoder, 'pfister', 'P236');
      expectEncoding(encoder, 'ellery', 'E460');
      expectEncoding(encoder, 'ghosh', 'G200');
      expectEncoding(encoder, 'heilbronn', 'H416');
      expectEncoding(encoder, 'kant', 'K530');
      expectEncoding(encoder, 'ladd', 'L300');
      expectEncoding(encoder, 'lissajous', 'L222');
      expectEncoding(encoder, 'fusedale', 'F234');
    });

    test('test ntz examples', () {
      final encoder = Soundex();

      // testing examples from:
      // http://ntz-develop.blogspot.com/2011/03/phonetic-algorithms.html

      expectEncoding(encoder, 'Fusedale', 'F234');

      var inputs;

      inputs = [
        'Genthner',
        'Gentner',
        'Gianettini',
        'Gunton',
      ];
      expectEncodings(encoder, inputs, 'G535');

      inputs = [
        'Garlee',
        'Garley',
        'Garwell',
        'Gerrell',
        'Gerrill',
        'Giral',
        'Gorelli',
        'Gorioli',
        'Gourlay',
        'Gourley',
        'Gourlie',
        'Graal',
        'Grahl',
        'Grayley',
        'Grealey',
        'Greally',
        'Grealy',
        'Grioli',
        'Groll',
        'Grolle',
        'Guerola',
        'Gurley',
      ];
      expectEncodings(encoder, inputs, 'G640');

      inputs = [
        'Hadcroft',
        'Hadgraft',
        'Hatchard',
        'Hatcher',
        'Hatzar',
        'Hedger',
        'Hitscher',
        'Hodcroft',
        'Hutchcraft',
      ];
      expectEncodings(encoder, inputs, 'H326');

      inputs = [
        'Parade',
        'Pardew',
        'Pardey',
        'Pardi',
        'Pardie',
        'Pardoe',
        'Pardue',
        'Pardy',
        'Parradye',
        'Parratt',
        'Parrett',
        'Parrot',
        'Parrott',
        'Pearde',
        'Peart',
        'Peaurt',
        'Peert',
        'Perdue',
        'Peret',
        'Perett',
        'Perot',
        'Perott',
        'Perotti',
        'Perrat',
        'Perrett',
        'Perritt',
        'Perrot',
        'Perrott',
        'Pert',
        'Perutto',
        'Pirdue',
        'Pirdy',
        'Pirot',
        'Pirouet',
        'Pirt',
        'Porrett',
        'Porritt',
        'Port',
        'Porte',
        'Prati',
        'Prate',
        'Pratt',
        'Pratte',
        'Pratty',
        'Preddy',
        'Preedy',
        'Preto',
        'Pretti',
        'Pretty',
        'Prewett',
        'Priddey',
        'Priddie',
        'Priddy',
        'Pride',
        'Pridie',
        'Pritty',
        'Prott',
        'Proud',
        'Prout',
        'Pryde',
        'Prydie',
        'Purdey',
        'Purdie',
        'Purdy',
      ];
      expectEncodings(encoder, inputs, 'P630');
    });

    test('test genealogy encoder', () {
      final encoder = Soundex.genealogyEncoder;

      // examples and algorithm rules from:  http://www.genealogy.com/articles/research/00000060.html
      expectEncoding(encoder, 'Albright', 'A416');
      expectEncoding(encoder, 'Greenbaum', 'G651');
      expectEncoding(encoder, 'Del Principe', 'D416');
      expectEncoding(encoder, 'Heggenburger', 'H251');
      expectEncoding(encoder, 'Blackman', 'B425');
      expectEncoding(encoder, 'Schmidt', 'S530');
      expectEncoding(encoder, 'Lippmann', 'L150');

      // 'o' is not a separator here - it is silent
      expectEncoding(encoder, 'Dodds', 'D200');

      // 'h' is silent
      expectEncoding(encoder, 'Dhdds', 'D200');

      // 'w' is silent
      expectEncoding(encoder, 'Dwdds', 'D200');
    });

    test('test special encodings', () {
      final encoder = Soundex.specialEncoder;

      expectEncoding(encoder, 'Ashcraft', 'A226');
      expectEncoding(encoder, 'Ashcroft', 'A226');
      expectEncoding(encoder, 'Ashclown', 'A224');
      expectEncoding(encoder, 'Shishko', 'S220');
      expectEncoding(encoder, 'Qashqar', 'Q226');

      // examples from references where H and W are not ignored
      expectEncoding(encoder, 'WILLIAMS', 'W452');
      expectEncoding(encoder, 'BARAGWANATH', 'B625');
      expectEncoding(encoder, 'DONNELL', 'D540');
      expectEncoding(encoder, 'LLOYD', 'L300');
      expectEncoding(encoder, 'WOOLCOCK', 'W422');
      expectEncoding(encoder, 'Dodds', 'D320');
      expectEncoding(encoder, 'Dwdds', 'D320'); // w is a separator
      expectEncoding(encoder, 'Dhdds', 'D320'); // h is a separator
    });

    test('test prefix encodings', () {
      final encoder = Soundex.fromMapping(Soundex.americanMapping,
          prefixesEnabled: true, hyphenatedPartsEnabled: false);

      // make sure that we don't get alternates when not relevant
      expectEncoding(encoder, 'testing', 'T235', null);

      // https://www.ics.uci.edu/~dan/genealogy/Miller/javascrp/soundex.htm
      expectEncoding(encoder, 'vanDever', 'V531', ['D160']);

      expectEncoding(encoder, 'Conway', 'C500', ['W000']);
      expectEncoding(encoder, 'DeHunt', 'D530', ['H530']);
      expectEncoding(encoder, 'De Hunt', 'D530', ['H530']);
      expectEncoding(encoder, 'DelaHunt', 'D453', ['H530']);
      expectEncoding(encoder, 'Dela Hunt', 'D453', ['H530']);
      expectEncoding(encoder, 'De la Hunt', 'D453', ['H530']);
      expectEncoding(encoder, 'DiOrio', 'D600', ['O600']);
      expectEncoding(encoder, 'Dupont', 'D153', ['P530']);
      expectEncoding(encoder, 'DeCicco', 'D220', ['C200']);
      expectEncoding(encoder, "D'Asti", 'D230', ['A230']);
      expectEncoding(encoder, 'la Cruz', 'L262', ['C620']);
      expectEncoding(encoder, 'LaFontaine', 'L153', ['F535']);
      expectEncoding(encoder, 'LeFavre', 'L116', ['F160']);
      expectEncoding(encoder, "L'Cruz", 'L262', ['C620']);
      expectEncoding(encoder, "L'Favre", 'L116', ['F160']);
      expectEncoding(encoder, 'Vandeusen', 'V532', ['D250']);
      expectEncoding(encoder, 'van Deusen', 'V532', ['D250']);
      expectEncoding(encoder, 'vanDamme', 'V535', ['D500']);
      expectEncoding(encoder, 'VonNewman', 'V555', ['N550']);
      expectEncoding(encoder, 'von Neumann', 'V555', ['N550']);

      // verify that Mc, Mac, and O' are not treated as a prefix
      expectEncoding(encoder, 'McDonald', 'M235', null);
      expectEncoding(encoder, 'MacDonald', 'M235', null);
      expectEncoding(encoder, 'Mac Donald', 'M235', null);
      expectEncoding(encoder, "O'Donnell", 'O354', null);

      // double barrel names do not provide alts when not configured
      expectEncoding(encoder, 'WILLIAMS-LLOYD', 'W452', null);
      // notice that this one catches the 'W' as well when hyphens are enabled
      expectEncoding(encoder, 'Smith - Wesson', 'S532', null);
    });

    test('test hyphenated encodings', () {
      final encoder = Soundex.fromMapping(Soundex.americanMapping,
          prefixesEnabled: true, hyphenatedPartsEnabled: true);

      // make sure that we don't get alternates when not relevant
      expectEncoding(encoder, 'testing', 'T235', null);

      // make sure simple prefixes are working as expected
      expectEncoding(encoder, 'DelaHunt', 'D453', ['H530']);

      // hyphenated names provide alternates when enabled
      expectEncoding(encoder, 'WILLIAMS-LLOYD', 'W452', ['L300']);
      expectEncoding(encoder, 'Smith - Wesson', 'S530', ['W250']);
      expectEncoding(encoder, 'Smith - Wesson-WILLIAMS-LLOYD', 'S530',
          ['W250', 'W452', 'L300']);

      // hyphenated with prefixes provide even more alternates
      expectEncoding(encoder, "von Neumann - D'Asti - L'Cruz - De la Hunt",
          'V555', ['N550', 'D230', 'A230', 'L262', 'C620', 'D453', 'H530']);
    });
  });

  group('Difference Tests', () {
    test('test standard differences', () {
      final encoder = Soundex();

      // Edge cases
      expect(0, PhoneticUtils.primaryDifference(encoder, null, null));
      expect(0, PhoneticUtils.primaryDifference(encoder, '', ''));
      expect(0, PhoneticUtils.primaryDifference(encoder, ' ', ' '));

      // Normal cases
      expect(4, PhoneticUtils.primaryDifference(encoder, 'Smith', 'Smythe'));
      expect(2, PhoneticUtils.primaryDifference(encoder, 'Ann', 'Andrew'));
      expect(1, PhoneticUtils.primaryDifference(encoder, 'Margaret', 'Andrew'));
      expect(0, PhoneticUtils.primaryDifference(encoder, 'Janet', 'Margaret'));

      // Special cases
      expect(4, PhoneticUtils.primaryDifference(encoder, 'Green', 'Greene'));
      expect(0,
          PhoneticUtils.primaryDifference(encoder, 'Blotchet-Halls', 'Greene'));
      expect(
          4, PhoneticUtils.primaryDifference(encoder, 'Smithers', 'Smythers'));
      expect(
          2, PhoneticUtils.primaryDifference(encoder, 'Anothers', 'Brothers'));
    });
  });

  group('Matching Tests', () {
    test('test homophones', () {
      final encoder = Soundex();
      expectEncodingEquals(encoder, 'Ray', 'Rae');
      expectEncodingEquals(encoder, 'tolled', 'told');
      expectEncodingEquals(encoder, 'brian', 'bryan');
      expectEncodingEquals(encoder, 'poor', 'pour');
      expectEncodingEquals(encoder, 'flour', 'flower');
      expectEncodingEquals(encoder, 'brake', 'break');
    });

    test('test similar names', () {
      final encoder = Soundex();
      expectEncodingEquals(encoder, 'Smith', 'Schmidt');
      expectEncodingEquals(encoder, 'Bartosz', 'Bartos');
      expectEncodingEquals(encoder, 'Blansett', 'Blancett');
      expectEncodingEquals(encoder, 'Hicks', 'Hix');
      expectEncodingEquals(encoder, 'Shoemaker', 'Shumaker');
    });
  });
}
