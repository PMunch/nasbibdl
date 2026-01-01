#!/bin/bash

if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: download.sh <URN of book> [<resize parameters>]"
  echo ""
  echo "Downloads a book from Nasjonalbiblioteket, turns the pages into black"
  echo "and white, collates it into a PDF, and runs OCR on it. The name of the"
  echo "PDF is the name of the book. If the second resize parameter is given it"
  echo "will be passed to imagemagicks -resize flag. It is recommended to"
  echo "resize the PDF to a size which matches the physical resolution of the"
  echo "reader either with the \"Fill area\" flag, ie. '1072x1488^' (notice the"
  echo "caret at the end), or with only the width ie. '1072x'. This means the"
  echo "image will be scaled to at least fill the display or at least fill the"
  echo "width respectively. Most scans will be larger than this, so doing the"
  echo "resize step saves both space in the resulting PDF but also saves the"
  echo "reader from having to do the resizing. More complex operations like"
  echo "trimming large white margins is left as an excercise for the reader but"
  echo "are certainly possible. After the book is downloaded you can use"
  echo "addtoc.sh and addmeta.sh to add metadata and a table of contents to"
  echo "the PDF."
  exit 1
fi

META=$(curl "https://api.nb.no/catalog/v1/items/$1")
TITLE=$(echo "$META" | jq -r '.metadata.title')
PAGES=$(echo "$META" | jq '.metadata.pageCount')
URN=$(echo "$META" | jq -r '.metadata.identifiers.urn')
RESIZE="$2"
if [ -n "$RESIZE" ]; then
  RESIZE="-resize $RESIZE"
fi

echo "Downloading $PAGES from book \"$TITLE\""

dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_C1/info.json" -l "C1.jpg"
dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_C3/info.json" -l "C3.jpg"
dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_I1/info.json" -l "I1.jpg"
dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_I3/info.json" -l "I3.jpg"

magick "C1.jpg" $RESIZE "C1-compress.png"
magick "C3.jpg" $RESIZE "C3-compress.png"
magick "I1.jpg" $RESIZE "I1-compress.png"
magick "I3.jpg" $RESIZE "I3-compress.png"
rm "C1.jpg"
rm "C3.jpg"
rm "I1.jpg"
rm "I3.jpg"

TEXTPAGES=$((PAGES - 5))
echo $TEXTPAGES
for i in $(seq 1 $TEXTPAGES);
do
  dezoomify-rs "https://www.nb.no/services/image/resolver/${URN}_$(printf '%04d' "$i")/info.json" -l "page-$(printf '%04d' "$i").jpg"
  magick "page-$(printf '%04d' "$i").jpg" $RESIZE -colorspace gray -auto-level -level 10%,90% +dither -remap "palette-5.png" "page-$(printf '%04d' "$i")-compress.png"
  rm "page-$(printf '%04d' "$i").jpg"
done

img2pdf C1-compress.png I1-compress.png page-*-compress.png I3-compress.png C3-compress.png | ocrmypdf -O3 -l nor - "$TITLE.pdf"

rm "*.png"
