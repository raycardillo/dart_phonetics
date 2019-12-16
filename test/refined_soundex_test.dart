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
      expect(0, PhoneticUtils.differences(soundex, null, null)[0]);
      expect(0, PhoneticUtils.differences(soundex, '', '')[0]);
      expect(0, PhoneticUtils.differences(soundex, ' ', ' ')[0]);

      // Normal cases
      expect(6, PhoneticUtils.differences(soundex, 'Smith', 'Smythe')[0]);
      expect(3, PhoneticUtils.differences(soundex, 'Ann', 'Andrew')[0]);
      expect(1, PhoneticUtils.differences(soundex, 'Margaret', 'Andrew')[0]);
      expect(1, PhoneticUtils.differences(soundex, 'Janet', 'Margaret')[0]);

      // Special cases
      expect(5, PhoneticUtils.differences(soundex, 'Green', 'Greene')[0]);
      expect(
          1, PhoneticUtils.differences(soundex, 'Blotchet-Halls', 'Greene')[0]);
      expect(8, PhoneticUtils.differences(soundex, 'Smithers', 'Smythers')[0]);
      expect(5, PhoneticUtils.differences(soundex, 'Anothers', 'Brothers')[0]);
    });
  });
}
