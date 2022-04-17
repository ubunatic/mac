#!/usr/bin/env bash
set -o errexit

SRC_DIR=Sources/Mousepaste
SRC="$SRC_DIR/main.swift $(find Sources -name '[A-Z]*.swift')"

echo -e "#!/usr/bin/env swift -O
// Mousepaste Script
// =================
// Single-file script version of Mousepaste.
// This script is a smart concatenation of all Mousepaste swift files.
// It has no additional or less code and provides the same features as
// the regular app.
//
// Usage:
//    swift mousepaste.swift      # runs the code as script
//    ./mousepaste.swift          # runs the code as script via it's shebang
//    swiftc -O mousepaste.swift  # compile your own binary
//
// ----------------------------
// GENERATED CODE, DO NOT EDIT!
// ----------------------------
//
// This file is a concatenation of the following sources:
"
for f in $SRC; do
    echo -e "// * $f"
    test -e $f || exit 1
done

echo -e "\n// START merged imports"
cat $SRC | grep '^import ' | sort -u
echo -e "// END merged imports\n"

for f in $SRC; do
    echo -e "// GENERATED CODE, DO NOT EDIT!"
    echo -e "//\n// START file: $f\n//\n"
    cat $f | grep -E -v '^import |^#!|^main\(\)|^\s*trace\(.*\)$' || true
    echo -e "//\n// END file: $f\n//\n"
done

echo -e "\n// START main\nmain()\n// END main\n"
