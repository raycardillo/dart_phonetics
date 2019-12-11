# due to a bug when Flutter is installed, we need to exclude a bunch for generating locally during development

rm -rf doc/

dartdoc --no-include-source --exclude 'dart:async,dart:collection,dart:convert,dart:core,dart:developer,dart:ffi,dart:html,dart:io,dart:isolate,dart:js,dart:js_util,dart:math,dart:typed_data,dart:ui'

open doc/api/index.html
