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

/// Phonetic encoder exceptions that are thrown when there are problems
/// phonetically encoding an input string.
class PhoneticEncoderException implements Exception {
  /// The input that was being processed when the exception occurred.
  /// This may be empty if the input being encoded was empty after cleanup.
  final String input;

  /// A message describing the problem that was encountered.
  final String message;

  /// Optionally indicates another exception that was the root cause.
  final Exception? cause;

  /// Creates a new PhoneticEncoderException with an optional root [cause].
  PhoneticEncoderException(this.input, this.message, [this.cause]);

  /// Returns a description of this exception.
  @override
  String toString() {
    if (cause == null) {
      return 'PhoneticEncoderException: $message (input=$input)';
    }
    return 'PhoneticEncoderException: $message (input=$input)\ncause: $cause}';
  }
}

/// A data class that provides a [primary] encoding as well as a set
/// of _optional_ [alternates].
class PhoneticEncoding {
  /// The primary phonetic encoding.
  final String primary;

  /// An alternative phonetic encoding for algorithms that support this.
  final Set<String>? alternates;

  /// Creates an instance of this data class.
  PhoneticEncoding(this.primary, [this.alternates]);

  /// Returns a [String] that's useful for debugging or diagnostics.
  @override
  String toString() {
    return 'PhoneticEncoding{primary=$primary, alternates=$alternates}';
  }
}

/// The common interface for all phonetic encoders.
abstract class PhoneticEncoder {
  /// Returns a [PhoneticEncoding] for the [input] String or `null`.
  PhoneticEncoding? encode(String input);
}
