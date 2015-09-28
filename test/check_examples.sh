#!/bin/sh

currdir=$(dirname "$0")
cd "$currdir/../src"

haserrors=0

for infile in ../test/cases/*.in; do
    outfile="${infile%.in}.out"
    result=$(./main.lua "$infile" -o - 2>&1 | diff - "$outfile")
    if [ "$?" != 0 ]; then
        haserrors=1
        echo "In case $infile:"
        echo
        echo "$result"
    fi
done

if [ "$haserrors" = 0 ]; then
    echo "Everything went according to expectations :)"
fi

exit "$haserrors"
