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

import 'package:dart_phonetics/src/encoder.dart';
import 'package:test/test.dart';

/// Verify an encoding matches [expected] for a single [input].
void expectEncodingEquals(
    PhoneticEncoder encoder, String input1, String input2) {
  final encoding1 = encoder.encode(input1);
  final encoding1Alternates = encoding1?.alternates;
  final encoding2 = encoder.encode(input2);
  final encoding2Alternates = encoding2?.alternates;

  final foundMatch = ((encoding1?.primary == encoding2?.primary) ||
      (encoding1Alternates != null &&
          encoding1Alternates.contains(encoding2?.primary)) ||
      (encoding2Alternates != null &&
          encoding2Alternates.contains(encoding1?.primary)));

  expect(true, foundMatch,
      reason: 'Match not found between '
          '$input1 => $encoding1 and $input2 => $encoding2');
}

/// Verify an encoding matches [expected] for a single [input].
void expectEncoding(
    PhoneticEncoder encoder, String input, String? expectedPrimary,
    [List<String>? expectedAlternates]) {
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
    PhoneticEncoder encoder, List<String> inputs, String? expectedPrimary,
    [List<String>? expectedAlternates]) {
  for (var input in inputs) {
    expectEncoding(encoder, input, expectedPrimary, expectedAlternates);
  }
}
