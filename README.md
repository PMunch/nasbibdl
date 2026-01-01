# Nasjonalbiblioteket-nedlaster

Denne lille samlingen med programmer kan brukes til å hente ned, prosessere, og
annotere bøker fra Nasjonalbiblioteket for lesing på lesebrett.
Nasjonalbiblioteket er en fantastisk ressurs av bøker, men den nettbaserte
leseren er ikke optimal for folk som foretrekker å lese bøker på lesebrett. Med
disse små programmene, og programmene de belager seg på, kan man laste ned
bøker som relativt små PDF-er med innholdsfortegnelse, metadata og OCR. Dette
gjør at man enkelt kan bla gjennom boken, velge partier med tekst for kopiering
eller annotering, og organisere dem sammen med sine øvrige bøker. Programmere er
som følger:

- `download.sh`: Dette er hovedprogrammet som laster ned alle sidene, lager
  PDFen og legger på OCR. Det belager seg på:
    - [deezomify-rs](https://github.com/lovasoa/dezoomify-rs)
    - [imagemagick](https://github.com/ImageMagick/ImageMagick)
    - [img2pdf](https://github.com/myollie/img2pdf)
    - [curl](https://github.com/curl/curl)
    - [jq](https://github.com/jqlang/jq)
    - [ocrmypdf](https://github.com/ocrmypdf/OCRmyPDF)
  For å kjøre programmet trenger du en URN fra Nasjonalbiblioteket. Den finner
  du under informasjonsfanen for en bok, ved navnet "Varig lenke" og har
  formatet: `URN:NBN:no-nb_digibok_<tall>` for bøker på bokmål. I tilleg kan man
  gi en størrelse som vil bli brukt av ImageMagick for å få sidene til å passe
  sitt lesebrett. Anbefalt er `<bredde>x` hvor `<bredde>` er den horisontale
  oppløsningen på lesebrettet i piksler, e.g. `1072x`. Eventuelt det dobbelte
  for bøker med to kolonner og lesebrett med modus for å lese slike bøker.
- `addtoc.sh`: Dette lille programmet legger til en innholdsfortegnelse i
  bøkene. Den trenger i tillegg til noe av det `download.sh` belager seg på
  trenger det også:
   - [pdfftk](https://github.com/MeteorPackaging/pdftk)
   - [pdftotext](https://github.com/jalan/pdftotext)
  For å kjøre programmet trenger du samme URN som til `download.sh`, samt navnet
  på PDF-en som ble laget. I tilleg kan du også gi et sidetall hvor
  innholdsfortegnelsen finnes. Om formatet er rett henter den ut OCR-resultatet
  fra PDFen og bruker det til å legge til en større inholdsfortegnelse. Om man
  gir et slikt sidetall kan man også gi et tall som justering for å passe på at
  sidetallene passer. Om et sidetall ikke er gitt får man bare
  innholdsfortegnelsen fra Nasjonalbiblioteket som ofte er ganske mangelfull.
  Spytter ut en PDF ved samme navn som den ble gitt men nå med filendelsen
  `.toc.pdf`.
- `addmeta.sh`: Det siste lille programmer legger til metadata, mer bestemt
  forfatter, tittel, og nøkkelord til PDFen. Dette brukes av lesebrett til å
  vise bokens tittel, og å sortere og kategorisere den. Belager seg på de samme
  ting som `addtoc.sh` og kjøres på samme måte (dog uten noe sidetall). Spytter
  også ut en ny PDF, denne gang med filendingen `.meta.pdf`.

## Lovlighet
Bøkene i Nasjonalbiblioteket er ikke for fri distribusjon. Denne behandlingen er
kun ment for å kunne lese bøker du ellers ville kunne lest på nett på en mer
behagelig måte på lesebrett. Vennligst respekter opphavsretten og eventuelt
motta samtykke før videre deling av bøkene. Det er uvisst om bruk av disse
programmene er lovlig. Deles uten noen form for garantier og uten forbehold.
