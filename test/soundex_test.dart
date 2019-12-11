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
      expectEncoding(Soundex.usEnglishEncoder, 'Williams', 'W452');
      expectEncoding(Soundex.usEnglishSimplifiedEncoder, 'Williams', 'W452');
      expectEncoding(Soundex.usEnglishGenealogyEncoder, 'Williams', 'W452');
      expectEncoding(Soundex.fromMapping(Soundex.usEnglishMapping), 'Williams', 'W452');
      expectEncoding(Soundex.fromMapping(Soundex.usEnglishGenealogyMapping), 'Williams', 'W452');
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

    test('test irregular characters', () {
      final soundex = Soundex();

      expectEncoding(soundex, '#@', '');
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

    test('test special encoding cases', () {
      final soundex = Soundex();

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

      // For VanDeusen: D-250 (D, 2 for the S, 5 for the N, 0 added) is also possible.
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

      // Tests example from http://en.wikipedia.org/wiki/Soundex#American_Soundex as of 2015-03-22.
      expectEncoding(soundex, 'Robert', 'R163');
      expectEncoding(soundex, 'Rupert', 'R163');
      expectEncoding(soundex, 'Ashcraft', 'A261');
      expectEncoding(soundex, 'Ashcroft', 'A261');
      expectEncoding(soundex, 'Tymczak', 'T522');
      expectEncoding(soundex, 'Pfister', 'P236');
    });

    test('test ignore apostrophes', () {
      final soundex = Soundex();
      final inputs = ['OBrien', "'OBrien", "O'Brien", "OB'rien", "OBr'ien", "OBri'en", "OBrie'n", "OBrien'"];

      expectEncodings(soundex, inputs, 'O165');
    });

    test('test ignore hyphens', () {
      final soundex = Soundex();
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
      // Ashcraft is coded A-261 (A, 2 for the S, C ignored, 6 for the R, 1 for the F). It is not coded A-226.
      expectEncoding(soundex, 'Ashcraft', 'A261');
      expectEncoding(soundex, 'Ashcroft', 'A261');
      expectEncoding(soundex, 'yehudit', 'Y330');
      expectEncoding(soundex, 'yhwdyt', 'Y330');

      // Consonants from the same code group separated by W or H are treated as one.
      // Test data from http://www.myatt.demon.co.uk/sxalg.htm
      expectEncoding(soundex, 'BOOTHDAVIS', 'B312');
      expectEncoding(soundex, 'BOOTH-DAVIS', 'B312');

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
      final inputs = ['Erickson', 'Erickson', 'Erikson', 'Ericson', 'Ericksen', 'Ericsen'];
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
      expectEncoding(soundex, String.fromCharCode($Eacute), '');
      expectEncoding(soundex, String.fromCharCode($eacute), '');

      // Simple 'o' should work fine
      expectEncoding(soundex, 'o', 'O000');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(soundex, String.fromCharCode($Ouml), '');
      expectEncoding(soundex, String.fromCharCode($ouml), '');
    });

    test('test genealogy mapping', () {
      final soundex = Soundex.usEnglishGenealogyEncoder;

      // examples and algorithm rules from:  http://www.genealogy.com/articles/research/00000060.html
      expectEncoding(soundex, 'Heggenburger', 'H251');
      expectEncoding(soundex, 'Blackman', 'B425');
      expectEncoding(soundex, 'Schmidt', 'S530');
      expectEncoding(soundex, 'Lippmann', 'L150');
      expectEncoding(soundex, 'Dodds', 'D200'); // 'o' is not a separator here - it is silent
      expectEncoding(soundex, 'Dhdds', 'D200'); // 'h' is silent
      expectEncoding(soundex, 'Dwdds', 'D200'); // 'w' is silent
    });

    test('test simplified mapping', () {
      final soundex = Soundex.usEnglishSimplifiedEncoder;

      // examples and algorithm rules from:  http://west-penwith.org.uk/misc/soundex.htm
      expectEncoding(soundex, 'WILLIAMS', 'W452');
      expectEncoding(soundex, 'BARAGWANATH', 'B625');
      expectEncoding(soundex, 'DONNELL', 'D540');
      expectEncoding(soundex, 'LLOYD', 'L300');
      expectEncoding(soundex, 'WOOLCOCK', 'W422');
      expectEncoding(soundex, 'Dodds', 'D320');
      expectEncoding(soundex, 'Dwdds', 'D320'); // w is a separator
      expectEncoding(soundex, 'Dhdds', 'D320'); // h is a separator
    });

    test('test similarity measure', () {
      final soundex = Soundex();

      // Edge cases
      expect(0, soundex.difference(null, null));
      expect(0, soundex.difference('', ''));
      expect(0, soundex.difference(' ', ' '));

      // Normal cases
      expect(4, soundex.difference('Smith', 'Smythe'));
      expect(2, soundex.difference('Ann', 'Andrew'));
      expect(1, soundex.difference('Margaret', 'Andrew'));
      expect(0, soundex.difference('Janet', 'Margaret'));

      // Special cases
      expect(4, soundex.difference('Green', 'Greene'));
      expect(0, soundex.difference('Blotchet-Halls', 'Greene'));
      expect(4, soundex.difference('Smithers', 'Smythers'));
      expect(2, soundex.difference('Anothers', 'Brothers'));
    });
  });
}
