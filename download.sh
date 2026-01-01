#!/bin/bash

if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: download.sh <URN of book>"
  echo ""
  echo "Downloads a book from Nasjonalbiblioteket, turns the pages into black"
  echo "and white, collates it into a PDF, and runs OCR on it. Currently"
  echo "hard-coded to my e-readers size, should be an optional argument. The"
  echo "name of the PDF is the name of the book. After the book is downloaded"
  echo "you can use addtoc.sh and addmeta.sh to add metadata and a table of"
  echo "contents to the PDF."
  exit 1
fi

META=$(curl "https://api.nb.no/catalog/v1/items/$1")
TITLE=$(echo "$META" | jq -r '.metadata.title')
PAGES=$(echo "$META" | jq '.metadata.pageCount')
URN=$(echo "$META" | jq -r '.metadata.identifiers.urn')

echo "Downloading $PAGES from book \"$TITLE\""

dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_C1/info.json" -l "C1.jpg"
dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_C3/info.json" -l "C3.jpg"
dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_I1/info.json" -l "I1.jpg"
dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_I3/info.json" -l "I3.jpg"

magick "C1.jpg" -resize 1072x1448 "C1-compress.png"
magick "C3.jpg" -resize 1072x1448 "C3-compress.png"
magick "I1.jpg" -resize 1072x1448 "I1-compress.png"
magick "I3.jpg" -resize 1072x1448 "I3-compress.png"
rm "C1.jpg"
rm "C3.jpg"
rm "I1.jpg"
rm "I3.jpg"

TEXTPAGES=$((PAGES - 5))
echo $TEXTPAGES
for i in $(seq 1 $TEXTPAGES);
do
  dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_$(printf '%04d' "$i")/info.json" -l "page-$(printf '%04d' "$i").jpg"
  magick "page-$(printf '%04d' "$i").jpg" -resize 1072x1448 -colorspace gray -auto-level -level 10%,90% +dither -remap "palette-5.png" "page-$(printf '%04d' "$i")-compress.png"
  rm "page-$(printf '%04d' "$i").jpg"
done

img2pdf C1-compress.png I1-compress.png page-*-compress.png I3-compress.png C3-compress.png | ocrmypdf -O3 -l nor - "$TITLE.pdf"

rm "*.png"
