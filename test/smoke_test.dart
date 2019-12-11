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

import 'package:dart_phonetics/dart_phonetics.dart';
import 'package:test/test.dart';

void main() {
  group('Utility Smoke Tests', () {
    test('null behavior', () {
      expect(PhoneticUtils.clean(null), null);
      expect(PhoneticUtils.clean(''), '');
      expect(PhoneticUtils.differenceEncoded(null, ''), 0);
      expect(PhoneticUtils.differenceEncoded('', null), 0);
    });
  });

  group('Encoder Smoke Tests', () {
    test('smoke test - Soundex', () {
      final soundex = Soundex.usEnglishEncoder;
      expect(soundex.encode('Raymond'), 'R553');
      expect(soundex.encode('Cardillo'), 'C634');
      expect(soundex.encode('Who! What?'), 'W300');
    });

    test('smoke test - Refined Soundex', () {
      final soundex = Soundex.usEnglishEncoder;
      expect(soundex.encode('Raymond'), 'R553');
      expect(soundex.encode('Cardillo'), 'C634');
      expect(soundex.encode('Who! What?'), 'W300');
    });
  });
}
