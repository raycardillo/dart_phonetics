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

import 'dart:math';

import 'package:charcode/charcode.dart';

/// Quick experiment to see how well Dart is optimizing when using various
/// single character matching strategies on a random character input stream.
///
/// Set.contains() is more convenient code to write and performs ever so
/// slightly better (on average after analyzing multiple runs).
void main() {
  final rand = Random.secure();
  final watch = Stopwatch();

  const numIterations = 2000000;
  var vowelsFound;

  vowelsFound = 0;
  print('running if statement matching...');
  watch.start();
  for (var i = 0; i < numIterations; i++) {
    final charCode = $A + rand.nextInt(25);
    if (charCode == $A ||
        charCode == $E ||
        charCode == $I ||
        charCode == $O ||
        charCode == $U) {
      vowelsFound++;
    }
  }
  watch.stop();
  print('elapsed: ${watch.elapsed}');
  print('found $vowelsFound vowels in $numIterations random iterations');

  watch.reset();
  print('');

  final vowelsSet = {$A, $E, $I, $O, $U};
  vowelsFound = 0;
  print('running Set.contains statement matching...');
  watch.start();
  for (var i = 0; i < numIterations; i++) {
    final charCode = $A + rand.nextInt(25);
    if (vowelsSet.contains(charCode)) {
      vowelsFound++;
    }
  }
  watch.stop();
  print('elapsed: ${watch.elapsed}');
  print('found $vowelsFound vowels in $numIterations random iterations');

  watch.reset();
  print('');

  // this test is a little unfair because of the extra work to convert from
  // character code to string format but is interesting for analysis. In
  // general RegExp is best for complex patterns so that the string is only
  // traversed once (or as efficiently as possible) when finding patterns.
  final vowelsRegExp = RegExp(r'A|E|I|O|U');
  vowelsFound = 0;
  print('running RegExp.hasMatch statement matching...');
  watch.start();
  for (var i = 0; i < numIterations; i++) {
    final charCode = $A + rand.nextInt(25);
    if (vowelsRegExp.hasMatch(String.fromCharCode(charCode))) {
      vowelsFound++;
    }
  }
  watch.stop();
  print('elapsed: ${watch.elapsed}');
  print('found $vowelsFound vowels in $numIterations random iterations');
}
