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
      final soundex = Soundex();
      expectEncoding(soundex, 'testing', 'T235');
      expectEncoding(soundex, 'TESTING', 'T235');
      expectEncoding(soundex, 'The', 'T000');
      expectEncoding(soundex, 'quick', 'Q200');
      expectEncoding(soundex, 'brown', 'B650');
      expectEncoding(soundex, 'fox', 'F200');
      expectEncoding(soundex, 'jumped', 'J513');
      expectEncoding(soundex, 'over', 'O160');
      expectEncoding(soundex, 'the', 'T000');
      expectEncoding(soundex, 'lazy', 'L200');
      expectEncoding(soundex, 'dogs', 'D200');
    });

    test('test max length', () {
      final soundex3 =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: 3);
      expectEncoding(soundex3, 'testing', 'T23');
      expectEncoding(soundex3, 'The', 'T00');
      expectEncoding(soundex3, 'quick', 'Q20');
      expectEncoding(soundex3, 'brown', 'B65');
      expectEncoding(soundex3, 'fox', 'F20');
      expectEncoding(soundex3, 'jumped', 'J51');
      expectEncoding(soundex3, 'over', 'O16');
      expectEncoding(soundex3, 'the', 'T00');
      expectEncoding(soundex3, 'lazy', 'L20');
      expectEncoding(soundex3, 'dogs', 'D20');

      final soundex5 =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: 5);
      expectEncoding(soundex5, 'testing', 'T2352');
      expectEncoding(soundex5, 'The', 'T0000');
      expectEncoding(soundex5, 'quick', 'Q2000');
      expectEncoding(soundex5, 'brown', 'B6500');
      expectEncoding(soundex5, 'fox', 'F2000');
      expectEncoding(soundex5, 'jumped', 'J5130');
      expectEncoding(soundex5, 'over', 'O1600');
      expectEncoding(soundex5, 'the', 'T0000');
      expectEncoding(soundex5, 'lazy', 'L2000');
      expectEncoding(soundex5, 'dogs', 'D2000');

      final soundex20 =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: 20);
      expectEncoding(soundex20, 'testing', 'T2352000000000000000');
      expectEncoding(soundex20, 'supercalifragilistic', 'S1624162423200000000');

      final soundex10 = Soundex.fromMapping(Soundex.americanMapping,
          maxLength: 10, paddingEnabled: false);
      expectEncoding(soundex10, 'testing', 'T2352');
      expectEncoding(soundex10, 'supercalifragilistic', 'S162416242');

      final soundexNoMax =
          Soundex.fromMapping(Soundex.americanMapping, maxLength: null);
      expectEncoding(soundexNoMax, 'testing', 'T2352');
      expectEncoding(soundexNoMax, 'supercalifragilistic', 'S16241624232');
    });

    test('test irregular characters', () {
      final soundex = Soundex();

      expectEncoding(soundex, '#@', null);
      expectEncoding(soundex, '<test&ing>', 'T235');
      expectEncoding(soundex, '\0#tes@ting!', 'T235');
      expectEncoding(soundex, ' \t\n\r Washington \t\n\r ', 'W252');
    });

    test('test B650', () {
      final soundex = Soundex();
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
      expectEncodings(soundex, inputs, 'B650');
    });

    test('test normal encoding of special cases', () {
      final soundex = Soundex();

      // http://www.genealogyintime.com/GenealogyResources/Articles/what_is_soundex_and_how_does_soundex_work_page2.html
      expectEncoding(soundex, 'Johnston', 'J523');

      // in the standard mapping 'Lippmann' is 'L155' (see genealogy for alt)
      expectEncoding(soundex, 'Lippmann', 'L155');

      // Examples from http://www.bradandkathy.com/genealogy/overviewofsoundex.html
      expectEncoding(soundex, 'Allricht', 'A462');
      expectEncoding(soundex, 'Eberhard', 'E166');
      expectEncoding(soundex, 'Engebrethson', 'E521');
      expectEncoding(soundex, 'Heimbach', 'H512');
      expectEncoding(soundex, 'Hanselmann', 'H524');
      expectEncoding(soundex, 'Hildebrand', 'H431');
      expectEncoding(soundex, 'Kavanagh', 'K152');
      expectEncoding(soundex, 'Lind', 'L530');
      expectEncoding(soundex, 'Lukaschowsky', 'L222');
      expectEncoding(soundex, 'McDonnell', 'M235');
      expectEncoding(soundex, 'McGee', 'M200');
      expectEncoding(soundex, 'Opnian', 'O155');
      expectEncoding(soundex, 'Oppenheimer', 'O155');
      expectEncoding(soundex, 'Riedemanas', 'R355');
      expectEncoding(soundex, 'Zita', 'Z300');
      expectEncoding(soundex, 'Zitzmeinn', 'Z325');

      // Examples from http://www.archives.gov/research_room/genealogy/census/soundex.html
      expectEncoding(soundex, 'Washington', 'W252');
      expectEncoding(soundex, 'Lee', 'L000');
      expectEncoding(soundex, 'Gutierrez', 'G362');
      expectEncoding(soundex, 'Pfister', 'P236');
      expectEncoding(soundex, 'Jackson', 'J250');
      expectEncoding(soundex, 'Tymczak', 'T522');
      expectEncoding(soundex, 'VanDeusen', 'V532');

      // Examples from: http://www.myatt.demon.co.uk/sxalg.htm
      expectEncoding(soundex, 'HOLMES', 'H452');
      expectEncoding(soundex, 'ADOMOMI', 'A355');
      expectEncoding(soundex, 'VONDERLEHR', 'V536');
      expectEncoding(soundex, 'BALL', 'B400');
      expectEncoding(soundex, 'SHAW', 'S000');
      expectEncoding(soundex, 'JACKSON', 'J250');
      expectEncoding(soundex, 'SCANLON', 'S545');
      expectEncoding(soundex, 'SAINTJOHN', 'S532');

      // https://issues.apache.org/jira/browse/CODEC-54 https://issues.apache.org/jira/browse/CODEC-56
      expectEncoding(soundex, 'Williams', 'W452');

      // http://en.wikipedia.org/wiki/Soundex#American_Soundex as of December 2019.
      expectEncoding(soundex, 'Robert', 'R163');
      expectEncoding(soundex, 'Rupert', 'R163');
      expectEncoding(soundex, 'Ashcraft', 'A261');
      expectEncoding(soundex, 'Ashcroft', 'A261');
      expectEncoding(soundex, 'Tymczak', 'T522');
      expectEncoding(soundex, 'Pfister', 'P236');

      // and a few more for good measure
      expectEncoding(soundex, 'Ashclown', 'A245');
      expectEncoding(soundex, 'Shishko', 'S200');
      expectEncoding(soundex, 'Qashqar', 'Q260');

      // prefixes and double barrels should not be encoded when not enabled
      expectEncoding(soundex, 'von Neumann', 'V555', null);
      expectEncoding(soundex, 'WILLIAMS-LLOYD', 'W452', null);
    });

    test('test ignore apostrophes', () {
      final soundex = Soundex();
      final inputs = [
        'OBrien',
        "'OBrien",
        "O'Brien",
        "OB'rien",
        "OBr'ien",
        "OBri'en",
        "OBrie'n",
        "OBrien'"
      ];

      expectEncodings(soundex, inputs, 'O165');
    });

    test('test ignore hyphens', () {
      final soundex = Soundex.fromMapping(Soundex.americanMapping,
          hyphenatedPartsEnabled: false);
      final inputs = [
        'KINGSMITH',
        '-KINGSMITH',
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
      expectEncodings(soundex, inputs, 'K525');
    });

    test('test HW rules', () {
      final soundex = Soundex();

      // Consonants from the same code group separated by W or H are treated as one.
      // From http://www.archives.gov/research_room/genealogy/census/soundex.html:
      // Ashcraft is coded A261 (A, 2 for the S, C ignored, 6 for the R, 1 for the F).
      expectEncoding(soundex, 'Ashcraft', 'A261');
      expectEncoding(soundex, 'Ashcroft', 'A261');
      expectEncoding(soundex, 'yehudit', 'Y330');
      expectEncoding(soundex, 'yhwdyt', 'Y330');

      // Consonants from the same code group separated by W or H are treated as one.
      // Test data from http://www.myatt.demon.co.uk/sxalg.htm
      expectEncoding(soundex, 'BOOTHDAVIS', 'B312');
      expectEncoding(soundex, 'BOOTH-DAVIS', 'B300', ['D120']);

      // Consonants from the same code group separated by W or H are treated as one.
      expectEncoding(soundex, 'Sgler', 'S460');
      expectEncoding(soundex, 'Swhgler', 'S460');
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
      expectEncodings(soundex, inputs, 'S460');
    });

    test('test MsSql special cases', () {
      final soundex = Soundex();

      expectEncoding(soundex, 'Smith', 'S530');
      expectEncoding(soundex, 'Smythe', 'S530');
      final inputs = [
        'Erickson',
        'Erickson',
        'Erikson',
        'Ericson',
        'Ericksen',
        'Ericsen'
      ];
      expectEncodings(soundex, inputs, 'E625');

      expectEncoding(soundex, 'Ann', 'A500');
      expectEncoding(soundex, 'Andrew', 'A536');
      expectEncoding(soundex, 'Janet', 'J530');
      expectEncoding(soundex, 'Margaret', 'M626');
      expectEncoding(soundex, 'Steven', 'S315');
      expectEncoding(soundex, 'Michael', 'M240');
      expectEncoding(soundex, 'Robert', 'R163');
      expectEncoding(soundex, 'Laura', 'L600');
      expectEncoding(soundex, 'Anne', 'A500');
    });

    test('test special character cases', () {
      final soundex = Soundex();

      // Simple 'e' should work fine
      expectEncoding(soundex, 'e', 'E000');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(soundex, String.fromCharCode($Eacute), null);
      expectEncoding(soundex, String.fromCharCode($eacute), null);

      // Simple 'o' should work fine
      expectEncoding(soundex, 'o', 'O000');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(soundex, String.fromCharCode($Ouml), null);
      expectEncoding(soundex, String.fromCharCode($ouml), null);
    });

    test('test ntz examples', () {
      final soundex = Soundex();

      // testing examples from:
      // http://ntz-develop.blogspot.com/2011/03/phonetic-algorithms.html

      expectEncoding(soundex, 'Fusedale', 'F234');

      var inputs;

      inputs = [
        'Genthner',
        'Gentner',
        'Gianettini',
        'Gunton',
      ];
      expectEncodings(soundex, inputs, 'G535');

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
      expectEncodings(soundex, inputs, 'G640');

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
      expectEncodings(soundex, inputs, 'H326');

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
      expectEncodings(soundex, inputs, 'P630');
    });

    test('test genealogy encoder', () {
      final soundex = Soundex.genealogyEncoder;

      // examples and algorithm rules from:  http://www.genealogy.com/articles/research/00000060.html
      expectEncoding(soundex, 'Albright', 'A416');
      expectEncoding(soundex, 'Greenbaum', 'G651');
      expectEncoding(soundex, 'Del Principe', 'D416');
      expectEncoding(soundex, 'Heggenburger', 'H251');
      expectEncoding(soundex, 'Blackman', 'B425');
      expectEncoding(soundex, 'Schmidt', 'S530');
      expectEncoding(soundex, 'Lippmann', 'L150');

      // 'o' is not a separator here - it is silent
      expectEncoding(soundex, 'Dodds', 'D200');

      // 'h' is silent
      expectEncoding(soundex, 'Dhdds', 'D200');

      // 'w' is silent
      expectEncoding(soundex, 'Dwdds', 'D200');
    });

    test('test special encodings', () {
      final soundex = Soundex.specialEncoder;

      expectEncoding(soundex, 'Ashcraft', 'A226');
      expectEncoding(soundex, 'Ashcroft', 'A226');
      expectEncoding(soundex, 'Ashclown', 'A224');
      expectEncoding(soundex, 'Shishko', 'S220');
      expectEncoding(soundex, 'Qashqar', 'Q226');

      // examples from references where H and W are not ignored
      expectEncoding(soundex, 'WILLIAMS', 'W452');
      expectEncoding(soundex, 'BARAGWANATH', 'B625');
      expectEncoding(soundex, 'DONNELL', 'D540');
      expectEncoding(soundex, 'LLOYD', 'L300');
      expectEncoding(soundex, 'WOOLCOCK', 'W422');
      expectEncoding(soundex, 'Dodds', 'D320');
      expectEncoding(soundex, 'Dwdds', 'D320'); // w is a separator
      expectEncoding(soundex, 'Dhdds', 'D320'); // h is a separator
    });

    test('test prefix encodings', () {
      final soundex = Soundex.fromMapping(Soundex.americanMapping,
          prefixesEnabled: true, hyphenatedPartsEnabled: false);

      // make sure that we don't get alternates when not relevant
      expectEncoding(soundex, 'testing', 'T235', null);

      // https://www.ics.uci.edu/~dan/genealogy/Miller/javascrp/soundex.htm
      expectEncoding(soundex, 'vanDever', 'V531', ['D160']);

      expectEncoding(soundex, "Conway", 'C500', ['W000']);
      expectEncoding(soundex, 'DeHunt', 'D530', ['H530']);
      expectEncoding(soundex, 'De Hunt', 'D530', ['H530']);
      expectEncoding(soundex, 'DelaHunt', 'D453', ['H530']);
      expectEncoding(soundex, 'Dela Hunt', 'D453', ['H530']);
      expectEncoding(soundex, 'De la Hunt', 'D453', ['H530']);
      expectEncoding(soundex, "DiOrio", 'D600', ['O600']);
      expectEncoding(soundex, "Dupont", 'D153', ['P530']);
      expectEncoding(soundex, "DeCicco", 'D220', ['C200']);
      expectEncoding(soundex, "D'Asti", 'D230', ['A230']);
      expectEncoding(soundex, 'la Cruz', 'L262', ['C620']);
      expectEncoding(soundex, 'LaFontaine', 'L153', ['F535']);
      expectEncoding(soundex, 'LeFavre', 'L116', ['F160']);
      expectEncoding(soundex, "L'Cruz", 'L262', ['C620']);
      expectEncoding(soundex, "L'Favre", 'L116', ['F160']);
      expectEncoding(soundex, 'Vandeusen', 'V532', ['D250']);
      expectEncoding(soundex, 'van Deusen', 'V532', ['D250']);
      expectEncoding(soundex, 'vanDamme', 'V535', ['D500']);
      expectEncoding(soundex, 'VonNewman', 'V555', ['N550']);
      expectEncoding(soundex, 'von Neumann', 'V555', ['N550']);

      // verify that Mc, Mac, and O' are not treated as a prefix
      expectEncoding(soundex, 'McDonald', 'M235', null);
      expectEncoding(soundex, 'MacDonald', 'M235', null);
      expectEncoding(soundex, 'Mac Donald', 'M235', null);
      expectEncoding(soundex, "O'Donnell", 'O354', null);

      // double barrel names do not provide alts when not configured
      expectEncoding(soundex, 'WILLIAMS-LLOYD', 'W452', null);
      // notice that this one catches the 'W' as well when hyphens are enabled
      expectEncoding(soundex, 'Smith - Wesson', 'S532', null);
    });

    test('test hyphenated encodings', () {
      final soundex = Soundex.fromMapping(Soundex.americanMapping,
          prefixesEnabled: true, hyphenatedPartsEnabled: true);

      // make sure that we don't get alternates when not relevant
      expectEncoding(soundex, 'testing', 'T235', null);

      // make sure simple prefixes are working as expected
      expectEncoding(soundex, 'DelaHunt', 'D453', ['H530']);

      // hyphenated names provide alternates when enabled
      expectEncoding(soundex, 'WILLIAMS-LLOYD', 'W452', ['L300']);
      expectEncoding(soundex, 'Smith - Wesson', 'S530', ['W250']);
      expectEncoding(soundex, 'Smith - Wesson-WILLIAMS-LLOYD', 'S530',
          ['W250', 'W452', 'L300']);

      // hyphenated with prefixes provide even more alternates
      expectEncoding(soundex, "von Neumann - D'Asti - L'Cruz - De la Hunt",
          'V555', ['N550', 'D230', 'A230', 'L262', 'C620', 'D453', 'H530']);
    });
  });

  group('Difference Tests', () {
    test('test standard differences', () {
      final soundex = Soundex();

      // Edge cases
      expect(0, PhoneticUtils.primaryDifference(soundex, null, null));
      expect(0, PhoneticUtils.primaryDifference(soundex, '', ''));
      expect(0, PhoneticUtils.primaryDifference(soundex, ' ', ' '));

      // Normal cases
      expect(4, PhoneticUtils.primaryDifference(soundex, 'Smith', 'Smythe'));
      expect(2, PhoneticUtils.primaryDifference(soundex, 'Ann', 'Andrew'));
      expect(1, PhoneticUtils.primaryDifference(soundex, 'Margaret', 'Andrew'));
      expect(0, PhoneticUtils.primaryDifference(soundex, 'Janet', 'Margaret'));

      // Special cases
      expect(4, PhoneticUtils.primaryDifference(soundex, 'Green', 'Greene'));
      expect(0,
          PhoneticUtils.primaryDifference(soundex, 'Blotchet-Halls', 'Greene'));
      expect(
          4, PhoneticUtils.primaryDifference(soundex, 'Smithers', 'Smythers'));
      expect(
          2, PhoneticUtils.primaryDifference(soundex, 'Anothers', 'Brothers'));
    });
  });
}
