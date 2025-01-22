#!/bin/bash

# IISRecon
# Recon script to bruteforce IIS shortname to full name and find parameters

tmp="./.tmp"
wordlists="/usr/share/secLists/Discovery/Web-Content/IIS.fuzz.txt" # Corrected file name
ext=(".asp" ".aspx" ".ash" ".ashx" ".config" ".html" ".wsdl" ".wadl" ".asmx" ".xml" ".zip" ".txt" ".asar" ".asax" ".mas")
output="result.json"

mkdir -p "$tmp"

while getopts "u:o:" flag
do
    case "${flag}" in
        u) url=${OPTARG};;
        o) output=${OPTARG};;
    esac
done

domain="$(echo "$url" | cut -d "/" -f 3)"
echo '{"domain":{}}' > "$output"

##########FUNCTIONS##########

extractSn(){
    echo "$1" | cut -d "~" -f 1 
}

dirBruteForce(){
    shortName=$(extractSn "$1")
    echo "Bruteforcing $shortName"
    grep -e "^$shortName" "$wordlists" | cut -d ":" -f 2 | cut -d "." -f 1 | cut -d "/" -f 1 | sort -uf > "$tmp/${shortName}_list.txt"
    echo "$shortName" >> "$tmp/${shortName}_list.txt"
    ffufResult=$(ffuf -u "$url/FUZZ/" -w "$tmp/${shortName}_list.txt" -s -fc 302)
    if [[ ! -z $ffufResult ]]; then
        echo "$ffufResult" | tr " " "\n" | while read l; do
            jq --arg ffufResult "$l" '.domain += {($ffufResult):{}}' "$output" > "$output.tmp" && mv "$output.tmp" "$output"
        done
    else
        jq --arg shortName "$shortName" '.domain += {($shortName):{}}' "$output" > "$output.tmp" && mv "$output.tmp" "$output"
    fi
}

fileBruteForce(){
    shortName=$(extractSn "$1")
    extToUse=""
    echo "Bruteforcing $shortName"
    grep -e "^$shortName" "$wordlists" | cut -d ":" -f 2 | cut -d "." -f 1 | cut -d "/" -f 1 | sort -uf > "$tmp/${shortName}_list.txt"
    echo "$shortName" >> "$tmp/${shortName}_list.txt"
    shortExt="$(echo "$1" | cut -d "." -f 2 | cut -d "*" -f 1)"
    for e in "${ext[@]}"; do
        if [[ $e == ".$shortExt" || $e == ".$shortExt"* ]]; then
            if [[ -z "$extToUse" ]]; then
                extToUse=$e
            else
                extToUse=$extToUse","$e
            fi
        fi
    done
    if [[ -z $extToUse ]]; then
        extToUse=".$shortExt"
    fi
    ffufResult=$(ffuf -u "$url/FUZZ/" -w "$tmp/${shortName}_list.txt" -s -e "$extToUse" -fc 302 | sort -u)
    if [[ ! -z $ffufResult ]]; then
        echo "$ffufResult" | tr " " "\n" | while read l; do
            jq --arg ffufResult "$l" '.domain += {($ffufResult):[]}' "$output" > "$output.tmp" && mv "$output.tmp" "$output"
        done
    else
        jq --arg shortName "$shortName" '.domain += {($shortName):[]}' "$output" > "$output.tmp" && mv "$output.tmp" "$output"
    fi
}

paramDiscovery(){
    file=$1
    echo "Bruteforcing parameter on $url"
    arjun -u "$url" -oT "$tmp/arjun.txt" -t 30 -q

    if [[ -f "$/tmp/arjun.txt" ]]; then
        arjunResult=$(jq --arg url "$url" '.[($url)].params[]' "$/tmp/arjun.txt" | tr -d "\"")
        if [[ ! -z $arjunResult ]]; then
            echo "$arjunResult" | tr " " "\n" | while read l; do
                jq --arg arjunResult "$l" --arg file "$file" '.domain[($file)] += [($arjunResult)]' "$output" > "$output.tmp" && mv "$output.tmp" "$output"
            done
        fi
    else
        echo "Arjun did not create the file $tmp/arjun.txt. Skipping parameter discovery for $file."
    fi
}

##########PROGRAM##########

echo "Running Shortname Scan"
sns -u "$url" -s > "$tmp/sub_sns.txt"

while IFS= read -r l; do
    shortName="$(extractSn "$l")"
    if [[ $l == *"Directory"* ]]; then
        dirBruteForce "$l"
    fi
    if [[ $l == *"File"* ]]; then
        fileBruteForce "$l"
    fi
done < "$tmp/sub_sns.txt"

jq '.domain' "$output" | grep "." | grep -v "~" | tr -d "\"{}\ :[]," | while read -r l; do
    if [[ ! -z $l ]]; then
        paramDiscovery "$l"
    fi
done

cat "$output"
rm -r "$tmp"
