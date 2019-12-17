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

import 'package:dart_phonetics/src/encoder.dart';
import 'package:test/test.dart';

/// Verify an encoding matches [expected] for a single [input].
void expectEncoding(
    PhoneticEncoder encoder, String input, String expectedPrimary,
    [List<String> expectedAlternates]) {
  final encoding = encoder.encode(input);
  expect(encoding?.primary, expectedPrimary,
      reason: 'Primary failed for input=$input');
  if (expectedAlternates != null) {
    expect(encoding?.alternates, expectedAlternates,
        reason: 'Alternates failed for input=$input');
  }
}

/// Verify an encoding matches [expected] for a list of [inputs].
void expectEncodings(
    PhoneticEncoder encoder, List<String> inputs, String expectedPrimary,
    [List<String> expectedAlternates]) {
  inputs.forEach((input) {
    expectEncoding(encoder, input, expectedPrimary, expectedAlternates);
  });
}
