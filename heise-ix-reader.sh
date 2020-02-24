#!/bin/bash
mkdir /tmp/worker1/

find /books/ -type f -iname '*.pdf'  -print0 | 
while IFS= read -r -d '' line; do 
        calibreID=$(echo  "$line" | sed -r 's/.*\(([0-9]+)\).*/\1/g')
        
        echo "bearbeite $clearName"
        echo "id $calibreID";

        cp "$line" /tmp/worker1/test.pdf

        echo "ocr "
        pdftotext -f 0 -l 10 /tmp/worker1/test.pdf /tmp/worker1/tmp.txt

        echo "text aufbereitung"
        cat /tmp/worker1/tmp.txt | sed ':begin;N;s/ /\n/;tbegin' | grep -iE '[A-Za-z]{2,212}' | grep  -i -F -w -v -f  blacklist.txt |  sed -r s/[^a-zA-Z0-9]+/-/g | sed ':begin;$!N;s/\n/,/;tbegin' > /tmp/worker1/final.txt

        echo "aktualisier db"
        calibredb set_metadata --with-library=/books/ --field tags:"$(cat /tmp/worker1/final.txt) " $calibreID
        rm /tmp/worker1/*
   
done



