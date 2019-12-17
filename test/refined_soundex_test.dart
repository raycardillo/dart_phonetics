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
      expectEncoding(RefinedSoundex(), 'Williams', 'W07083');
      expectEncoding(RefinedSoundex.defaultEncoder, 'Williams', 'W07083');
      expectEncoding(RefinedSoundex.fromMapping(RefinedSoundex.defaultMapping),
          'Williams', 'W07083');
    });
  });

  group('Encoding Tests', () {
    test('test basic encoding', () {
      final soundex = RefinedSoundex();
      expectEncoding(soundex, 'testing', 'T6036084');
      expectEncoding(soundex, 'TESTING', 'T6036084');
      expectEncoding(soundex, 'The', 'T60');
      expectEncoding(soundex, 'quick', 'Q503');
      expectEncoding(soundex, 'brown', 'B1908');
      expectEncoding(soundex, 'fox', 'F205');
      expectEncoding(soundex, 'jumped', 'J408106');
      expectEncoding(soundex, 'over', 'O0209');
      expectEncoding(soundex, 'the', 'T60');
      expectEncoding(soundex, 'lazy', 'L7050');
      expectEncoding(soundex, 'dogs', 'D6043');
    });

    test('test max length', () {
      final soundex4 = RefinedSoundex.fromMapping(RefinedSoundex.defaultMapping,
          maxLength: 4);
      expectEncoding(soundex4, 'testing', 'T603');
      expectEncoding(soundex4, 'The', 'T60');
      expectEncoding(soundex4, 'quick', 'Q503');
      expectEncoding(soundex4, 'brown', 'B190');
      expectEncoding(soundex4, 'fox', 'F205');
      expectEncoding(soundex4, 'jumped', 'J408');
      expectEncoding(soundex4, 'over', 'O020');
      expectEncoding(soundex4, 'the', 'T60');
      expectEncoding(soundex4, 'lazy', 'L705');
      expectEncoding(soundex4, 'dogs', 'D604');

      final soundex5 = RefinedSoundex.fromMapping(RefinedSoundex.defaultMapping,
          maxLength: 5);
      expectEncoding(soundex5, 'testing', 'T6036');
      expectEncoding(soundex5, 'The', 'T60');
      expectEncoding(soundex5, 'quick', 'Q503');
      expectEncoding(soundex5, 'brown', 'B1908');
      expectEncoding(soundex5, 'fox', 'F205');
      expectEncoding(soundex5, 'jumped', 'J4081');
      expectEncoding(soundex5, 'over', 'O0209');
      expectEncoding(soundex5, 'the', 'T60');
      expectEncoding(soundex5, 'lazy', 'L7050');
      expectEncoding(soundex5, 'dogs', 'D6043');

      final soundex20 = RefinedSoundex.fromMapping(
          RefinedSoundex.defaultMapping,
          maxLength: 20);
      expectEncoding(soundex20, 'testing', 'T6036084');
      expectEncoding(soundex20, 'supercalifragilistic', 'S3010930702904070360');
    });

    test('test irregular characters', () {
      final soundex = RefinedSoundex();

      // test some strings with irregular characters
      expectEncoding(soundex, '#@', null);
      expectEncoding(soundex, '<test&ing>', 'T6036084');
      expectEncoding(soundex, '\0#tes@ting!', 'T6036084');
      expectEncoding(soundex, ' \t\n\r Washington \t\n\r ', 'W03084608');
    });

    test('test ignore apostrophes', () {
      final soundex = RefinedSoundex();
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

      expectEncodings(soundex, inputs, 'O01908');
    });

    test('test special character cases', () {
      final soundex = RefinedSoundex();

      // Simple 'e' should work fine
      expectEncoding(soundex, 'e', 'E0');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(soundex, String.fromCharCode($Eacute), null);
      expectEncoding(soundex, String.fromCharCode($eacute), null);

      // Simple 'o' should work fine
      expectEncoding(soundex, 'o', 'O0');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(soundex, String.fromCharCode($Ouml), null);
      expectEncoding(soundex, String.fromCharCode($ouml), null);
    });

    test('test ntz examples', () {
      final soundex = RefinedSoundex();

      // testing examples from:
      // http://ntz-develop.blogspot.com/2011/03/phonetic-algorithms.html

      var inputs;

      inputs = [
        'Braz',
        'Broz',
      ];
      expectEncodings(soundex, inputs, 'B1905');

      inputs = [
        'Caren',
        'Caron',
        'Carren',
        'Charon',
        'Corain',
        'Coram',
        'Corran',
        'Corrin',
        'Corwin',
        'Curran',
        'Curreen',
        'Currin',
        'Currom',
        'Currum',
        'Curwen',
      ];
      expectEncodings(soundex, inputs, 'C30908');

      inputs = [
        'Hairs',
        'Hark',
        'Hars',
        'Hayers',
        'Heers',
        'Hiers',
      ];
      expectEncodings(soundex, inputs, 'H093');

      inputs = [
        'Lambard',
        'Lambart',
        'Lambert',
        'Lambird',
        'Lampaert',
        'Lampard',
        'Lampart',
        'Lamperd',
        'Lampert',
        'Lamport',
        'Limbert',
        'Lombard',
      ];
      expectEncodings(soundex, inputs, 'L7081096');

      inputs = [
        'Nolton',
        'Noulton',
      ];
      expectEncodings(soundex, inputs, 'N807608');
    });

    test('test similarity measure', () {
      final soundex = RefinedSoundex();

      // Edge cases
      expect(0, PhoneticUtils.primaryDifference(soundex, null, null));
      expect(0, PhoneticUtils.primaryDifference(soundex, '', ''));
      expect(0, PhoneticUtils.primaryDifference(soundex, ' ', ' '));

      // Normal cases
      expect(6, PhoneticUtils.primaryDifference(soundex, 'Smith', 'Smythe'));
      expect(3, PhoneticUtils.primaryDifference(soundex, 'Ann', 'Andrew'));
      expect(1, PhoneticUtils.primaryDifference(soundex, 'Margaret', 'Andrew'));
      expect(1, PhoneticUtils.primaryDifference(soundex, 'Janet', 'Margaret'));

      // Special cases
      expect(5, PhoneticUtils.primaryDifference(soundex, 'Green', 'Greene'));
      expect(1,
          PhoneticUtils.primaryDifference(soundex, 'Blotchet-Halls', 'Greene'));
      expect(
          8, PhoneticUtils.primaryDifference(soundex, 'Smithers', 'Smythers'));
      expect(
          5, PhoneticUtils.primaryDifference(soundex, 'Anothers', 'Brothers'));
    });
  });
}
