# Dart Phonetics

[![Build Status](https://travis-ci.com/raycardillo/dart_phonetics.svg?branch=master)](https://travis-ci.com/raycardillo/dart_phonetics)
[![Pub package](https://img.shields.io/pub/v/dart_phonetics)](https://pub.dev/packages/dart_phonetics)
[![Dartdoc reference](https://img.shields.io/badge/dartdoc-reference-blue)](https://pub.dev/documentation/dart_phonetics/latest/)
[![Project license](https://img.shields.io/badge/license-Apache%202.0-informational)](http://www.apache.org/licenses/LICENSE-2.0)

A collection of phonetic algorithms for [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/). These algorithms help find words or names that sound similar by generating an encoding that can be compared or indexed for fuzzy searching.

----------------

## Algorithms Implemented

- **American Soundex** - A highly configurable implementation of the Soundex algorithm. There are better algorithms available, but this algorithm is classic, and is required when analyzing American surnames in genealogy or census data.
- **Refined Soundex** -  The refined soundex is a variation that is better for applications such as spell checking. It uses a mapping that aims to be more precise and does not truncate to 4 characters by default.
- **Double Metaphone** - The metaphone series of algorithms apply "expert rules" based on inconsistencies in the English language in attempt to acheive greater precision (fewer results that are closer in phonetic sound).
- ***More Under Development***


### _Work In Progress_

_This project is a work in progress that is being developed because I need these algorithms for another project. I'll spend time implementing more phonetic algorithms depending on demand, need, or community interest._


### _Other Implementations_

_The [Wikipedia Phonetic Algorithm](https://en.wikipedia.org/wiki/Phonetic_algorithm) page provides a good basic background. There are several other libraries (written in other languages) that may be useful for reference to those interested in exploring various Phonetic Encoding algorithms for various purposes. They are also useful to review special cases in test data._

- **Apache Commons Codes** is a **Java** library that includes many Phonetic algoritms
   - https://commons.apache.org/proper/commons-codec/
   - https://github.com/apache/commons-codec
- **Abydos** is a **Python** library that includes many Phonetic algorithms
   - https://abydos.readthedocs.io/en/latest/index.html
   - https://github.com/chrislit/abydos/tree/master/abydos/phonetic
- **Talisman** is a **Javascript** library that includes many Phonetic algorithms.
   - https://yomguithereal.github.io/talisman/phonetics/
   - https://github.com/Yomguithereal/talisman/tree/master/src/phonetics
- **stringmetric** is a **Scala** library that includes many Phonetic algorithms.
   - https://rockymadden.com/stringmetric/
   - https://github.com/rockymadden/stringmetric/
