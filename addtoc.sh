#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: addtoc.sh <URN of book> <pdf to add TOC to> [<page number of TOC in book>]"
  echo ""
  echo "Adds a table of contents to the Nasjonalbiblioteket-book created by the download script"
  echo "If the metadata doesn't have the full TOC then an optional page number can be given with OCRed text giving the table of contents"
  exit 1
fi

META=$(curl "https://api.nb.no/catalog/v1/items/$1")
PAGES=$(echo "$META" | jq '.metadata.pageCount')
MURL=$(echo "$META" | jq -r '._links.presentation.href')
echo "$META"
echo "$MURL"
MANIFEST=$(curl "$MURL")
SEQUENCES=$(echo "$MANIFEST" | jq '.structures | length')

echo "" > bookmarks.txt

for i in $(seq 1 "$SEQUENCES");
do
  PAGE=$(echo "$MANIFEST" | jq -r ".structures[$((i - 1))].canvases[0]" | sed 's/.*_\(.*\)/\1/g')
  PAGETITLE=$(echo "$MANIFEST" | jq -r ".structures[$((i - 1))].label")
  echo "$PAGE"
  case "$PAGE" in
    "C1") PAGECOUNT=1 ;;
    "I1") PAGECOUNT=2 ;;
    "I3") PAGECOUNT=$((PAGES + 3)) ;;
    "C3") PAGECOUNT=$((PAGES + 4)) ;;
    *) PAGECOUNT=$((PAGE + 2)) ;;
  esac
  printf '%d 1 %s\n' "$PAGECOUNT" "$PAGETITLE" >> bookmarks.txt
done

if [ -n "$3" ]; then
  PAGETOC=$(pdftotext -f "$3" -l "$3" -raw "$2" -)
  echo "$PAGETOC" | awk '{if (NF == 2 && $2 ~ /^[0-9]+$/) print ($2 + 2) " " (($1 ~ /^[[:upper:]]*$/)?"1":"2") " " $1}' >> bookmarks.txt
fi

BOOKMARKS=$(cat bookmarks.txt)
echo "$BOOKMARKS" | sort -g | sed -n 's/^\([0-9]*\) \([0-9]*\) \(.*\)$/BookmarkBegin\nBookmarkTitle: \3\nBookmarkLevel: \2\nBookmarkPageNumber: \1/p' > bookmarks.txt

NEWPDF="${2/%.pdf/.toc.pdf}"
pdftk "$2" update_info bookmarks.txt output "$NEWPDF"
