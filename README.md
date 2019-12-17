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
- ***More Under Development***


### _Work In Progress_

_This project is a work in progress that is being developed because I need these algorithms for another project. I'll spend time implementing more phonetic algorithms depending on demand, need, or community interest._
