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
import 'package:dart_phonetics/src/double_metaphone.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('Utility Smoke Tests', () {
    test('null behavior', () {
      expect(PhoneticUtils.clean(null), null);
      expect(PhoneticUtils.clean(''), null);
      expect(PhoneticUtils.differenceEncoded(null, ''), 0);
      expect(PhoneticUtils.differenceEncoded('', null), 0);
    });
  });

  group('Encoder Smoke Tests', () {
    test('smoke test - Soundex', () {
      final encoder = Soundex.americanEncoder;
      expectEncoding(encoder, 'Raymond', 'R553');
      expectEncoding(encoder, 'Cardillo', 'C634');
      expectEncoding(encoder, 'Who! What?', 'W300');
    });

    test('smoke test - Refined Soundex', () {
      final encoder = Soundex.americanEncoder;
      expectEncoding(encoder, 'Raymond', 'R553');
      expectEncoding(encoder, 'Cardillo', 'C634');
      expectEncoding(encoder, 'Who! What?', 'W300');
    });

    test('smoke test - Double Metaphone', () {
      final encoder = DoubleMetaphone.defaultEncoder;
      expectEncoding(encoder, 'Raymond', 'RMNT');
      expectEncoding(encoder, 'Cardillo', 'KRTL');
      expectEncoding(encoder, 'Who! What?', 'AT');
    });
  });
}
