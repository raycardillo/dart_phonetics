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
      expectEncoding(RefinedSoundex(), 'Williams', 'W07083');
      expectEncoding(RefinedSoundex.defaultEncoder, 'Williams', 'W07083');
      expectEncoding(RefinedSoundex.fromMapping(RefinedSoundex.defaultMapping),
          'Williams', 'W07083');
    });
  });

  group('Encoding Tests', () {
    test('test basic encoding', () {
      final encoder = RefinedSoundex();
      expectEncoding(encoder, 'testing', 'T6036084');
      expectEncoding(encoder, 'TESTING', 'T6036084');
      expectEncoding(encoder, 'The', 'T60');
      expectEncoding(encoder, 'quick', 'Q503');
      expectEncoding(encoder, 'brown', 'B1908');
      expectEncoding(encoder, 'fox', 'F205');
      expectEncoding(encoder, 'jumped', 'J408106');
      expectEncoding(encoder, 'over', 'O0209');
      expectEncoding(encoder, 'the', 'T60');
      expectEncoding(encoder, 'lazy', 'L7050');
      expectEncoding(encoder, 'dogs', 'D6043');
    });

    test('test max length', () {
      final encoder4 = RefinedSoundex.fromMapping(RefinedSoundex.defaultMapping,
          maxLength: 4);
      expectEncoding(encoder4, 'testing', 'T603');
      expectEncoding(encoder4, 'The', 'T60');
      expectEncoding(encoder4, 'quick', 'Q503');
      expectEncoding(encoder4, 'brown', 'B190');
      expectEncoding(encoder4, 'fox', 'F205');
      expectEncoding(encoder4, 'jumped', 'J408');
      expectEncoding(encoder4, 'over', 'O020');
      expectEncoding(encoder4, 'the', 'T60');
      expectEncoding(encoder4, 'lazy', 'L705');
      expectEncoding(encoder4, 'dogs', 'D604');

      final encoder5 = RefinedSoundex.fromMapping(RefinedSoundex.defaultMapping,
          maxLength: 5);
      expectEncoding(encoder5, 'testing', 'T6036');
      expectEncoding(encoder5, 'The', 'T60');
      expectEncoding(encoder5, 'quick', 'Q503');
      expectEncoding(encoder5, 'brown', 'B1908');
      expectEncoding(encoder5, 'fox', 'F205');
      expectEncoding(encoder5, 'jumped', 'J4081');
      expectEncoding(encoder5, 'over', 'O0209');
      expectEncoding(encoder5, 'the', 'T60');
      expectEncoding(encoder5, 'lazy', 'L7050');
      expectEncoding(encoder5, 'dogs', 'D6043');

      final encoder20 = RefinedSoundex.fromMapping(
          RefinedSoundex.defaultMapping,
          maxLength: 20);
      expectEncoding(encoder20, 'testing', 'T6036084');
      expectEncoding(encoder20, 'supercalifragilistic', 'S3010930702904070360');
    });

    test('test irregular characters', () {
      final encoder = RefinedSoundex();

      // test some strings with irregular characters
      expectEncoding(encoder, '#@', null);
      expectEncoding(encoder, '<test&ing>', 'T6036084');
      expectEncoding(encoder, '\0#tes@ting!', 'T6036084');
      expectEncoding(encoder, ' \t\n\r Washington \t\n\r ', 'W03084608');
    });

    test('test apostrophes', () {
      final encoder = RefinedSoundex();
      final inputs = [
        "O'Brien",
        "OB'rien",
        "OBr'ien",
        "OBri'en",
        "OBrie'n",
        "OBrien'"
      ];

      expectEncodings(encoder, inputs, 'O01908');
    });

    test('test special character cases', () {
      final encoder = RefinedSoundex();

      // Simple 'e' should work fine
      expectEncoding(encoder, 'e', 'E0');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(encoder, String.fromCharCode($Eacute), null);
      expectEncoding(encoder, String.fromCharCode($eacute), null);

      // Simple 'o' should work fine
      expectEncoding(encoder, 'o', 'O0');

      // Special characters are not mapped by the US_ENGLISH mapping.
      expectEncoding(encoder, String.fromCharCode($Ouml), null);
      expectEncoding(encoder, String.fromCharCode($ouml), null);
    });

    test('test ntz examples', () {
      final encoder = RefinedSoundex();

      // testing examples from:
      // http://ntz-develop.blogspot.com/2011/03/phonetic-algorithms.html

      var inputs;

      inputs = [
        'Braz',
        'Broz',
      ];
      expectEncodings(encoder, inputs, 'B1905');

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
      expectEncodings(encoder, inputs, 'C30908');

      inputs = [
        'Hairs',
        'Hark',
        'Hars',
        'Hayers',
        'Heers',
        'Hiers',
      ];
      expectEncodings(encoder, inputs, 'H093');

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
      expectEncodings(encoder, inputs, 'L7081096');

      inputs = [
        'Nolton',
        'Noulton',
      ];
      expectEncodings(encoder, inputs, 'N807608');
    });
  });

  group('Difference Tests', () {
    test('test similarity measure', () {
      final encoder = RefinedSoundex();

      // Edge cases
      expect(0, PhoneticUtils.primaryDifference(encoder, null, null));
      expect(0, PhoneticUtils.primaryDifference(encoder, '', ''));
      expect(0, PhoneticUtils.primaryDifference(encoder, ' ', ' '));

      // Normal cases
      expect(6, PhoneticUtils.primaryDifference(encoder, 'Smith', 'Smythe'));
      expect(3, PhoneticUtils.primaryDifference(encoder, 'Ann', 'Andrew'));
      expect(1, PhoneticUtils.primaryDifference(encoder, 'Margaret', 'Andrew'));
      expect(1, PhoneticUtils.primaryDifference(encoder, 'Janet', 'Margaret'));

      // Special cases
      expect(5, PhoneticUtils.primaryDifference(encoder, 'Green', 'Greene'));
      expect(1,
          PhoneticUtils.primaryDifference(encoder, 'Blotchet-Halls', 'Greene'));
      expect(
          8, PhoneticUtils.primaryDifference(encoder, 'Smithers', 'Smythers'));
      expect(
          5, PhoneticUtils.primaryDifference(encoder, 'Anothers', 'Brothers'));
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
