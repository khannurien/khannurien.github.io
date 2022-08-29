#!/usr/bin/env sh

# 1
echo "$USER"
# 2
pwd
# 3
cd ../..
cd /
# 4
ls
ls .
ls /
# 5
cd "$HOME" || exit
# 6
mkdir -p exercices
mkdir -p "$HOME/exercices"
# 7
cd "$HOME/exercices" || exit
# 8
touch exercices.txt
# 9
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
# 10
echo "Pack my box with five dozen liquor jugs." >> exercices.txt
# 11
cat exercices.txt
# 12
wc -l exercices.txt
# 13
grep -o "quick" exercices.txt | wc -l
# 14
uniq < exercices.txt | sort > pangrammes.txt
# 15
rm exercices.txt
mv pangrammes.txt td0.txt
# 16
diff exercices.txt pangrammes.txt > diff.txt
# 17
base64 -d << EOT
TmV2ZXIgZ29ubmEgZ2l2ZSB5b3UgdXAKTmV2ZXIgZ29ubmEgbGV0IHlvdSBkb3duCk5ldmVyIGdv
bm5hIHJ1biBhcm91bmQgYW5kIGRlc2VydCB5b3UKTmV2ZXIgZ29ubmEgbWFrZSB5b3UgY3J5Ck5l
dmVyIGdvbm5hIHNheSBnb29kYnllCk5ldmVyIGdvbm5hIHRlbGwgYSBsaWUgYW5kIGh1cnQgeW91
Cg==
EOT
# 18
cp -r exercices td0
# 19
tar cvf td0.tar td0
# 20
du -b td0.tar
# 21
rm -r exercices
