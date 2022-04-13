#!/usr/bin/env bash
set -o errexit

SRC_DIR=Sources/Mousepaste
SRC="
$SRC_DIR/main.swift
$SRC_DIR/Accessibility.swift
$SRC_DIR/Pasteboard.swift
$SRC_DIR/Watcher.swift
$SRC_DIR/Selection.swift
"

echo -e "#!/usr/bin/env swift -O
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
    cat $f | grep -E -v '^import |^#!|^main\(\)' || true
    echo -e "//\n// END file: $f\n//\n"
done

echo -e "\n// START main\nmain()\n// END main\n"
