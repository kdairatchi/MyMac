#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -d               Full scan(sublist3r, assetfinder, subfinder)"
    # echo "  -l               Long scan(sublist3r, subdominator)"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/tomnomnom/unfurl
              https://github.com/aboul3la/Sublist3r
              https://github.com/tomnomnom/assetfinder
              https://github.com/projectdiscovery/subfinder
              https://github.com/RevoltSecurities/Subdominator
              https://github.com/projectdiscovery/httpx
              https://github.com/projectdiscovery/chaos-client"
    exit 0
}

if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

if [[ "$1" == "-d" ]]; then
    domain_Without_Protocol_save=$(echo "$2" | unfurl -u apexes)
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')

    mkdir -p "$domain_Without_Protocol_save" "$domain_Without_Protocol_save/subdomains"

        echo ""
        echo "=================================================================="
        echo "================= Sublist3r checking ============================="
        echo "=================================================================="
        echo ""
        sublist3r -d "$domain_Without_Protocol" -t 20 -o "$domain_Without_Protocol_save/subdomains/sublist3r.txt"
        echo ""
        echo "=================================================================="
        echo "================= Sublist3r finished ============================="
        echo "=================================================================="
        echo ""

        echo ""
        echo "=================================================================="
        echo "================== Assetfinder checking =========================="
        echo "=================================================================="
        echo ""
        assetfinder "$domain_Without_Protocol" | tee "$domain_Without_Protocol_save/subdomains/assetfinder.txt"
        echo ""
        echo "=================================================================="
        echo "================== Assetfinder Finished =========================="
        echo "=================================================================="
        echo ""

        echo ""
        echo "=================================================================="
        echo "================== Subfinder checking ============================"
        echo "=================================================================="
        echo ""
        subfinder -d "$domain_Without_Protocol" -recursive -all -o "$domain_Without_Protocol_save/subdomains/subfinder.txt"
        echo ""
        echo "=================================================================="
        echo "================== Subfinder finished ============================"
        echo "=================================================================="
        echo ""

        echo ""
        echo "=================================================================="
        echo "================= Subdominator checking =========================="
        echo "=================================================================="
        echo ""
        subdominator -d "$domain_Without_Protocol" -o "$domain_Without_Protocol_save/subdomains/subdominator.txt"
        echo ""
        echo "=================================================================="
        echo "============== Subdominator finished ============================="
        echo "=================================================================="
        echo ""  

        # echo ""
        # echo "=================================================================="
        # echo "================= chaos checking =========================="
        # echo "=================================================================="
        # echo ""
        # chaos -d "$domain_Without_Protocol" -silent -key b68fe63f-c973-458a-9c44-ce93a9e7072b -o "$domain_Without_Protocol_save/subdomains/chaos.txt"
        # echo ""
        # echo "=================================================================="
        # echo "============== chaos finished ============================="
        # echo "=================================================================="
        # echo "" 

        echo ""
        echo "=================================================================="
        echo "================= subdomainizer checking =========================="
        echo "=================================================================="
        echo ""
        subdomainizer -u  "$domain_Without_Protocol" -o "$domain_Without_Protocol_save/subdomains/subdomainizer.txt"
        echo ""
        echo "=================================================================="
        echo "============== subdomainizer finished ============================="
        echo "=================================================================="
        echo ""

        echo ""
        echo "=================================================================="
        echo "================= Collecting All Subdomains at once =========================="
        echo "=================================================================="
        echo ""
        # Concatenate links from all text files into one, then sort and remove duplicates
        find "$domain_Without_Protocol_save/subdomains" -type f -name '*.txt' -exec cat {} + | sort -u > "$domain_Without_Protocol_save/subdomains/allsubdomain.txt.temp"

        # Move the temporary file to the final destination
        mv "$domain_Without_Protocol_save/subdomains/allsubdomain.txt.temp" "$domain_Without_Protocol_save/subdomains/allsubdomain.txt"
        echo ""
        echo "=================================================================="
        echo "============== Collecting All Subdomains at once ============================="
        echo "=================================================================="
        echo ""



        echo ""
        echo "=================================================================="
        echo "========== 200,403,404 subdomains checking ======================="
        echo "=================================================================="
        echo ""

        httpx -l "$domain_Without_Protocol/subdomains/allsubdomain.txt" -sc -title -server -td -t 160 -random-agent -o "$domain_Without_Protocol_save/subdomains/httpx.txt"

        echo ""
        echo "=================================================================="
        echo "========== 200,403,404 subdomains checking finished =============="
        echo "=================================================================="
        echo ""

        echo ""
        echo "=================================================================="
        echo "================== 200 subdomains checking ======================="
        echo "=================================================================="
        echo ""
        cat "$domain_Without_Protocol_save/subdomains/httpx.txt" | grep "200" | awk '{print $1}' | sort -u | tee "$domain_Without_Protocol_save/subdomains/200_live_subdomains.txt"


        cat "$domain_Without_Protocol_save/subdomains/subprober.txt" | grep "200" | awk '{print $1}' | sort -u | sed 's,http://,,;s,https://,,;s,www\.,,;' > "$domain_Without_Protocol_save/subdomains/200_subdomains_for_url_finding.txt"


        echo ""
        echo "=================================================================="
        echo "================== 200 subdomains checking finished =============="
        echo "=================================================================="
        echo ""

        echo ""
        echo "=================================================================="
        echo "================== 200 subdomains screenshot taking =============="
        echo "=================================================================="
        echo ""
        httpx -l "$domain_Without_Protocol_save/subdomains/allsubdomain.txt" -mc 200 -system-chrome -ss -srd "$domain_Without_Protocol_save/subdomains/screenshot" -t 160 -random-agent

        echo ""
        echo "=================================================================="
        echo "============ 200 subdomains screenshot taking  finished =========="
        echo "=================================================================="
        echo ""

        echo ""
        echo "=================================================================="
        echo "============= 404 subdomain takeover checking ===================="
        echo "=================================================================="
        echo ""
        # prepare for subdomain takeover

        cat "$domain_Without_Protocol_save/subdomains/httpx.txt" | grep "404" | awk '{print $1}' | sort -u > "$domain_Without_Protocol_save/subdomains/404_httpx.txt"

        echo ""
        echo "=================================================================="
        echo "============= 404 subdomain takeover finished ===================="
        echo "=================================================================="
        echo ""

        echo ""
        echo "=================================================================="
        echo "=========== 403 forbidden subdomains collecting =================="
        echo "=================================================================="
        echo ""

        cat "$domain_Without_Protocol_save/subdomains/httpx.txt" | grep "403" | awk '{print $1}' | sort -u > "$domain_Without_Protocol_save/subdomains/403_httpx.txt"

        echo ""
        echo "=================================================================="
        echo "=========== 403 forbidden subdomains collecting finished ========="
        echo "=================================================================="
        echo ""
        exit 0

fi
