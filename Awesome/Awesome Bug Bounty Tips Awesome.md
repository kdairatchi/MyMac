# Awesome Bug Bounty Tips [![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)
A curated list of amazingly bug bounty tips from security researchers around the world.
Here’s a detailed **Awesome Scripting and Automation Tools** list designed to focus on bug bounty automation. It's GitHub-ready, beginner-friendly, and curated with actionable scripts and tools for effective automation.

---

# **Awesome Bug Bounty Scripting & Automation Tools**

> A curated list of scripts, tools, and techniques to automate bug bounty and cybersecurity workflows.

---

## **Table of Contents**

1. [Introduction](#introduction)
2. [Environment Setup](#environment-setup)
3. [Automation Tools](#automation-tools)
4. [Essential Scripts](#essential-scripts)
5. [Automated Recon](#automated-recon)
6. [Reporting Automation](#reporting-automation)
7. [Learning Resources](#learning-resources)

---

## **1. Introduction**

Bug hunting often involves repetitive tasks like subdomain enumeration, vulnerability scanning, and reporting. Automating these tasks helps to:

- Save time and effort.
- Focus on manual, high-value targets.
- Reduce human errors.

This list focuses on tools and scripts that streamline automation while keeping the process beginner-friendly.

---

## **2. Environment Setup**

### Install Essential Tools
Install core tools for scripting and automation:
```bash
sudo apt update && sudo apt install -y git curl jq python3 python3-pip golang
```

### Directory Structure
Organize your workspace:
```bash
mkdir -p ~/bugbounty/{scripts,tools,results,reports}
```

### Install Common Tools
```bash
# Subdomain Enumeration
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# HTTP Probing
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Vulnerability Scanning
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
```

---

## **3. Automation Tools**

### **Recon Tools**
1. **[Subfinder](https://github.com/projectdiscovery/subfinder)** - Passive subdomain enumeration.
2. **[Amass](https://github.com/OWASP/Amass)** - Active reconnaissance.
3. **[Httpx](https://github.com/projectdiscovery/httpx)** - Probe live hosts.

### **Vulnerability Scanning Tools**
1. **[Nuclei](https://github.com/projectdiscovery/nuclei)** - Template-based scanning.
2. **[Dalfox](https://github.com/hahwul/dalfox)** - XSS scanning tool.
3. **[SQLMap](https://github.com/sqlmapproject/sqlmap)** - SQL injection automation.

### **Content Discovery**
1. **[FFuF](https://github.com/ffuf/ffuf)** - Fuzzing tool.
2. **[Dirsearch](https://github.com/maurosoria/dirsearch)** - Directory brute-forcing.

---

## **4. Essential Scripts**

### **Template for a Recon Script**
```bash
#!/bin/bash
# Recon Automation Script

target=$1
output_dir="results/$target"

mkdir -p $output_dir

echo "[+] Enumerating subdomains for $target"
subfinder -d $target -silent | anew $output_dir/subdomains.txt

echo "[+] Probing live subdomains"
cat $output_dir/subdomains.txt | httpx -silent | anew $output_dir/live_subdomains.txt

echo "[+] Scanning for vulnerabilities"
nuclei -l $output_dir/live_subdomains.txt -t vulnerabilities/ -o $output_dir/vulnerabilities.txt
```

### **Git Sync Automation**
```bash
#!/bin/bash
# Auto-sync a GitHub repository

repo_dir="/path/to/repo"
cd $repo_dir

echo "[+] Pulling latest changes..."
git pull origin main

echo "[+] Running automation scripts..."
./scripts/automate.sh

echo "[+] Pushing updates..."
git add .
git commit -m "Automated updates"
git push origin main
```

### **Health Check Script**
```bash
#!/bin/bash
# Server Health Check

hosts=("host1.com" "host2.com" "host3.com")

for host in "${hosts[@]}"; do
  if ping -c 1 $host &> /dev/null; then
    echo "[+] $host is reachable"
  else
    echo "[-] $host is unreachable"
  fi
done
```

---

## **5. Automated Recon**

### **Full Recon Pipeline**
```bash
#!/bin/bash
# Full Recon Automation Script

target=$1
output_dir="recon_results/$target"

mkdir -p $output_dir

echo "[+] Enumerating subdomains"
subfinder -d $target -silent | anew $output_dir/subdomains.txt
amass enum -passive -d $target | anew $output_dir/subdomains.txt

echo "[+] Probing live subdomains"
cat $output_dir/subdomains.txt | httpx -silent | anew $output_dir/live_hosts.txt

echo "[+] Fuzzing directories"
ffuf -w wordlist.txt -u https://FUZZ -t 50 -o $output_dir/fuzzing.txt

echo "[+] Scanning for vulnerabilities"
nuclei -l $output_dir/live_hosts.txt -t vulnerabilities/ -o $output_dir/vulnerabilities.txt
```

---

## **6. Reporting Automation**

### **Generate Markdown Report**
```bash
#!/bin/bash
# Markdown Report Generator

target=$1
output_file="reports/$target.md"

echo "# Vulnerability Report for $target" > $output_file
echo "## Reconnaissance" >> $output_file
echo "- Subdomains: $(wc -l recon_results/$target/subdomains.txt)" >> $output_file
echo "- Live Hosts: $(wc -l recon_results/$target/live_hosts.txt)" >> $output_file

echo "## Vulnerabilities" >> $output_file
cat recon_results/$target/vulnerabilities.txt >> $output_file
```

---

## **7. Learning Resources**

### **Documentation**
- [ProjectDiscovery Docs](https://docs.projectdiscovery.io/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

### **Practice Labs**
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [TryHackMe](https://tryhackme.com/)
- [HackTheBox](https://hackthebox.com/)

---

### **Contribute**
Feel free to fork this repo, add your custom scripts, and submit pull requests!

---

This **Awesome Scripting and Automation Tools** list is designed to grow and adapt. Suggestions and contributions are always welcome! 🚀
## Why?
It is hard to look for Bug Bounty Tips from different social media websites. This repo helps to keep all these scattered tips at one place.

## Contents
- [Website](#website)
- [Mobile](#mobile)
- [Tools](#tools)
- [Others](#others)

### Website

> Look for GitLab instances on targets or belonging to the target. When you stumble across the GitLab login panel (/users/sign_in), navigate to `/explore`. Once you get in, use the search function to find passwords, keys, etc. - [@EdOverflow](https://twitter.com/EdOverflow/status/986214497965740032)

> If you have found an authenticated stored XSS vulnerability that requires specific permissions to exploit — say administrator-level access — always check to see if the POST request that transmitts the payload is vulnerable to CSRF or an IDOR. This will increase the impact, since as an attacker you no longer need an account with certain permissions to exploit the issue. - [@EdOverflow](https://twitter.com/EdOverflow/)

> If you are in heroku, try calling /app/Procfile to get the installation instructions that a dev had when deploying to heroku. If that loads and you know what stack it uses, you should be able to find the source code of the app in /app directory. For example if it is rails, you can pull routes.rb by calling /app/config/routes.rb. The app folder is the main directory where all deployed code is stored. - [@uraniumhacker](https://twitter.com/uraniumhacker/status/1105681791958966272)

> most java web apps allow bypassing common LFI filtering rules by doing the following: http://domain.tld/page.jsp?include=..;/..;/sensitive.txt - [@zer0pwn](https://twitter.com/zer0pwn/status/1093365823106965504)

> If you find jsp page with no parameters. You can actually add path parameters using semicolon. Like this example.com/test.jsp;');alert(1)// & perform XSS. Apache tomcat support this. - [@akshukatkar](https://twitter.com/akshukatkar/status/1074744556036382720)

> When you have a SSRF vulnerability on a Google Cloud server, the fastest way to grab all internal metadata is this "All in one" payload: http://metadata.google.internal/computeMetadata/v1beta1/?recursive=true - [@adrien_jeanneau](https://twitter.com/adrien_jeanneau/status/1062460475387076608)

> Always do printenv to see if your inside a container when you have a RCE you can escalate it further if you break outside the container. - [@Random_Robbie](https://twitter.com/Random_Robbie/status/1057185407367086080)

### Mobile

> Struggling with SSL Pinning or root detection on Android or iOS? Use [Objection] (https://github.com/sensepost/objection) to easily bypass them. - [@skeltavik](https://twitter.com/intigriti/status/1075749882462433280)

> Dont just statically analyze apps. Dynamic analysis is where I find 90% of my mobile bugs. Look at old and new versions of apps. Sometimes you can derive API keys from the older apps that still work! - [@nullenc0de](https://twitter.com/nullenc0de/status/1061636754757861377)

### Tools

> Use commoncrawl for finding subdomains and endpoints. Sometimes you find endpoints that can't directly be visited from the UI but has been indexed from other sites. **curl -sX GET "http://index.commoncrawl.org/CC-MAIN-2018-22-index?url=*.$1&output=json" | jq -r .url | sort -u** - [@streaak](https://twitter.com/streaak/status/1015236009993203712)

> Add to scope all your target subdomains on @Burp_Suite "Target" tab >> "Scope" >> "Use advanced scope control" checkbox >> "Add" button >> Set Protocol: Any - Host/IP range: .*\.domain\.com$ >> Enjoy! - [@_gonzacabrera](https://twitter.com/_gonzacabrera/status/1105340391514099712)

> Threatcrowd is able to list domains registered by a specific email address: https://www.threatcrowd.org/email.php?email=domain@teslamotors.com Very handy for open-scope. - [MrTuxracer](https://twitter.com/MrTuxracer/status/1103913275786354689)

> Need to bypass a firewall? Use securitytrails.com to find the originating server IP. (https://github.com/vincentcox/bypass-firewalls-by-DNS-history) - [@vincentcox_be](https://twitter.com/intigriti/status/1073184104630378501)

> You can enumerate directories in some buckets with Wfuzz. Rule for Wfuzz: http(s)://<bucket-address-here>/FUZZ/ Successful: 200 Status code without content - [@Wh11teW0lf](https://twitter.com/Wh11teW0lf/status/1096009061206761473)

> Want to find some internal code of companies or some sample codes of new features? Checkout with: site:repl.it intext:<companydomain>. In companydomain, if you know the internal domain it is even better. [@uraniumhacker](https://twitter.com/uraniumhacker/status/1061992982847533059)

> To find vulnerable domains and subdomains that is currently pointed to GitHub due to misconfiguration. Try searching the following syntax on publicwww. "There isn't a Github Pages site here". It will return thousands of pages containing domains and subdomains that could be vulnerable to Subdomain Takeover. - [@ajdumanhug](

### Others

> Look for hackathon-related assets. Companies sometimes run hackathons and give attendees special access to certain API endpoints or temporary credentials. I have found GIT repositories that were set up for hackathons full of sensitive information. - [@EdOverflow](https://twitter.com/EdOverflow/status/986316960303591424)

> If you submit a report and want the triage team to quickly triage your report, include your test credenetials in the report. This is especially useful if user permissions and roles are involved. - [@EdOverflow](https://twitter.com/EdOverflow/)

> Do not just inspect source code, check GIT logs for information too. Here are some simple tricks that you can add to your reconnaissance workflow: https://gist.github.com/EdOverflow/a9aad69a690d97a8da20cd4194ca6596 - [@EdOverflow](https://twitter.com/EdOverflow/status/986991389178253318)

> Look for hackathon-related assets. Companies sometimes run hackathons and give attendees special access to certain API endpoints or temporary credentials. I have found GIT repositories that were set up for hackathons full of sensitive information. - [@EdOverflow](https://twitter.com/EdOverflow/status/986316960303591424)

> As a hacker you will come across many different pieces of software that you haven’t used before. It often pays off to take the time to install / use it to 1) create a sandbox to test particular scenarios and 2) understand the software better to find more vulns faster. - [@jobertabma](https://twitter.com/jobertabma/status/1039771086370598912)

> Always check an e-mail's headers and body. They often contain valuable information and endpoints! - [@honoki](https://twitter.com/intigriti/status/1103705724826411009)

> If a bounty target offers premium features, buy them and test the new endpoints. Most of the times, it's worth the investment! - [@vdeschutter](https://twitter.com/intigriti/status/1088471152148787200)

> Follow the marketing guys (e.g., Director or Manager) of the product you're targeting for #BugBounty. These guys are awesome in telling you all the new features that are in pipeline or just released. You will be the first to get your hands dirty. - [@soaj1664ashar](https://twitter.com/soaj1664ashar/status/1085118841359872000)

> Did you know that the character '_' acts like the regex character '.' in SQL queries. https://www.w3resource.com/sql/wildcards-like-operator/wildcards-underscore.php - [@gwendallecoguic](https://twitter.com/gwendallecoguic/status/1076081365777551364)

> If a website does not verify email, try signing up with <whatev>@domain.com (the company email). Sometimes this gives you higher privilege like deleting/viewing any other user's profiles etc. [@uraniumhacker](https://twitter.com/uraniumhacker/status/1066483686655221761)
  
