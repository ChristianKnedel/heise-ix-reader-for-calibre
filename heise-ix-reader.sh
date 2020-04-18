#!/bin/bash
#apt-get update && apt-get install -y xpdf calibre
export LANG=C.UTF-8
mkdir /tmp/worker1/

find /books/ -type f -iname 'IX*.pdf'  -print0 | 
while IFS= read -r -d '' line; do 
        calibreID=$(echo  "$line" | sed -r 's/.*\(([0-9]+)\).*/\1/g')
        
        echo "bearbeite $clearName"
        echo "id $calibreID";

        cp "$line" /tmp/worker1/test.pdf

        echo "ocr "
        pdftotext -f 0 -l 10 /tmp/worker1/test.pdf /tmp/worker1/tmp.txt

        echo "text aufbereitung"
        cat /tmp/worker1/tmp.txt  | grep  -i -F -w -v -f  /books/blacklist.txt | sed -r s/[^a-zA-ZäöüÄÖÜ]+//g | grep -iE '[A-Za-z]{2,212}' |  sed ':begin;$!N;s/\n/,/;tbegin' > /tmp/worker1/final.txt

        echo "aktualisier db"
        calibredb set_metadata --with-library=/books/ --field tags:"$(cat /tmp/worker1/final.txt) " --field series:"Heise IX" --field languages:"Deutsch" --field authors:"Hansa Verlag" $calibreID
        
        #rm /tmp/worker1/*
   
done
