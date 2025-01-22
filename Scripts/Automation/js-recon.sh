#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -j               All JS File Find "
    # echo "  -multi           Multi Domain Parameter Spidering"
    # echo "  -mass            Path of urls to Parameter Spidering(path/to/parameter_urls.txt)"
    echo ""
    echo "Required Tools:"
    echo "    https://github.com/tomnomnom/unfurl
              https://github.com/lc/gau
             
              https://github.com/projectdiscovery/katana
              
              https://github.com/m4ll0k/SecretFinder"
    exit 0
}

if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi


if [[ "$1" == "-j" ]]; then

    domain_Without_Protocol=$(head -n 1 "$2" | unfurl -u apexes)
    mkdir -p $domain_Without_Protocol/js

    allurls="$2"


    echo "===================================================="
    echo "========= Subjs URLs collecting ============"
    echo "===================================================="
    echo ""

    cat $allurls | subjs | tee $domain_Without_Protocol/js/subjs.txt

    echo ""
    echo "######################################################"
    echo "########### JS Links Collecting finished #############"
    echo "######################################################"
    echo ""


    echo "===================================================="
    echo "========= getJS URLs collecting ============"
    echo "===================================================="
    echo ""

    cat $allurls | getJS --complete | tee -a $domain_Without_Protocol/js/getjs.txt

    echo ""
    echo "######################################################"
    echo "########### JS Links Collecting finished #############"
    echo "######################################################"
    echo ""


    echo "===================================================="
    echo "========= katana URLs collecting ============"
    echo "===================================================="
    echo ""

    katana -list "$allurls" -jc -silent | grep ".js$" | tee -a $domain_Without_Protocol/js/katana.txt

    echo ""
    echo "######################################################"
    echo "########### JS Links Collecting finished #############"
    echo "######################################################"
    echo ""

    cat $domain_Without_Protocol/js/subjs.txt $domain_Without_Protocol/js/katana.txt $domain_Without_Protocol/js/getjs.txt | sort -u | tee -a $domain_Without_Protocol/js/alljs.txt

    echo ""
    echo "######################################################"
    echo "####### JS secrets and Endpoints Collecting ###########"
    echo "######################################################"
    echo ""

    cat $domain_Without_Protocol/js/alljs.txt | while read url; do secretfinder -i "$url" -o cli | tee -a $domain_Without_Protocol/js/secetfinder.txt; done

    echo ""
    echo "######################################################"
    echo "####### JS secrets and Endpoints Collected ###########"
    echo "######################################################"
    echo ""

    exit 0
fi
