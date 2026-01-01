#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: addmeta.sh <URN of book> <pdf to add metadata to>"
  echo ""
  echo "Adds a author, title, and keywords as metadata to the pdf from Nasjonalbiblioteket"
  exit 1
fi

META=$(curl "https://api.nb.no/catalog/v1/items/$1")
TITLE=$(echo "$META" | jq -r '.metadata.title')
AUTHOR=$(echo "$META" | jq -r '.metadata.people[0].name')
TOPICS=$(echo "$META" | jq -r '.metadata.subject.topics | @csv' | sed 's/"//g')
AUTHOR=$(echo "$AUTHOR" | sed 's/\(.*\),\(.*\)/\2 \1/')

{
echo "InfoBegin"
echo "InfoKey: Title"
echo "InfoValue: $TITLE"
echo "InfoBegin"
echo "InfoKey: Author"
echo "InfoValue: $AUTHOR"
echo "InfoBegin"
echo "InfoKey: Keywords"
echo "InfoValue: $TOPICS"
} > metadata.txt

NEWPDF="${2/%.pdf/.meta.pdf}"
pdftk "$2" update_info metadata.txt output "$NEWPDF"
