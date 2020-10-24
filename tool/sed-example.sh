#!/bin/bash

# Convert given this format:
#
# //{"unknown", "ANKN", "ANKN"},
# //{"Uomo", "AM", "AM"},

sed -E "s/.*{\"(.*)/expectEncoding(dm, '\1/" convert.txt | sed -E "s/\"/'/g" | sed -E "s/(.*, )'(.*)('},)/\1['\2']);/"


# Convert given this format:
#
# self.assertEqual(self.pa.encode('aubrey'), ('APR', ''))

sed -E "s/.*encode\('(.*)/expectEncoding(dm, '\1/" convert.txt | sed -E "s/\), \(/, /" | sed -E "s/(.*, )'(.*)('\)\))/\1['\2']);/"
