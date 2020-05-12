

for i in *.pdf; do
  j=${i/.pdf/_thumb.png}
  echo $i
  convert $i -bordercolor Blue -thumbnail 560x128 -border 3x3 $j
done