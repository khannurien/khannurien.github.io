#!/usr/bin/env sh

# 1
echo "$USER"
# 2
pwd
# 3
mkdir "$HOME/exercices"
# 4
cd "$HOME/exercices" || exit
# 5
touch exercices.txt
# 6
cat << EOT >> exercices.txt
The quick brown fox jumps over the lazy dog.
Waltz, bad nymph, for quick jigs vex.
Glib jocks quiz nymph to vex dwarf.
Sphinx of black quartz, judge my vow.
Sphinx of black quartz, judge my vow.
How vexingly quick daft zebras jump!
The five boxing wizards jump quickly.
Jackdaws love my big sphinx of quartz.
Pack my box with five dozen liquor jugs.
EOT
# 7
echo "Pack my box with five dozen liquor jugs." >> exercices.txt
# 8
cat exercices.txt
# 9
wc -l exercices.txt
# 10
grep -o "quick" exercices.txt | wc -l
# 11
uniq < exercices.txt | sort > pangrammes.txt
