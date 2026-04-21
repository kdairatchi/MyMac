---
tags: [bugbounty, recon, subdomain, enumeration]
aliases: [Subdomain Enumeration, Asset Discovery, Recon Pipeline]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Subdomain Enumeration & Asset Discovery

> [!tldr] Hunter Summary
> **Goal:** Find the full attack surface before hunting. More subdomains = more targets.
> **Priority:** Find dev/staging/internal subdomains — less secure, less monitored.
> **Time:** 10–30 min automated, then manual triage.

---

## Full Pipeline (copy-paste)

```bash
TARGET=target.com

# 1. Passive subdomain collection (no DNS queries to target)
subfinder -d $TARGET -silent -o subs_passive.txt
assetfinder --subs-only $TARGET >> subs_passive.txt
chaos -d $TARGET -silent >> subs_passive.txt   # ProjectDiscovery chaos
amass enum -passive -d $TARGET >> subs_passive.txt

# 2. Active DNS resolution (find live hosts)
cat subs_passive.txt | sort -u | dnsx -silent -a -resp -o subs_resolved.txt

# 3. HTTP probing (find live web services)
cat subs_resolved.txt | awk '{print $1}' | httpx -silent -mc 200,301,302,403,500 \
  -title -tech-detect -status-code -o live_web.txt

# 4. Screenshot all live targets
cat live_web.txt | awk '{print $1}' | gowitness file -f - -P screenshots/

# 5. Sort by interesting signals
cat live_web.txt | grep -E "admin|internal|staging|dev|api|test|mgmt|manage"

# 6. Run nuclei on all live targets
cat live_web.txt | awk '{print $1}' | nuclei -t cves/ -t exposures/ -t misconfigs/ -o nuclei_findings.txt
```

---

## Tool-by-Tool Reference

### subfinder
```bash
subfinder -d target.com -silent
subfinder -d target.com -silent -all           # all sources
subfinder -d target.com -sources chaos,virustotal,shodan
subfinder -dL domains.txt -silent -o output.txt
```

### amass
```bash
amass enum -passive -d target.com
amass enum -active -d target.com -ip            # active + IPs
amass enum -d target.com -config /path/config.ini  # with API keys
```

### assetfinder
```bash
assetfinder --subs-only target.com
assetfinder target.com | grep "\.target\.com$"
```

### dnsx
```bash
# Resolve + get A records
cat subs.txt | dnsx -a -resp
# Wildcard detection
dnsx -d target.com -wc-detection
# Brute force with wordlist
dnsx -d target.com -w /opt/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
```

### httpx
```bash
cat subs.txt | httpx -silent -mc 200,301,302,403
cat subs.txt | httpx -title -status-code -tech-detect -o results.txt
cat subs.txt | httpx -path /admin -mc 200  # test specific path
```

---

## Priority Subdomains to Look For

```
admin.*      internal.*    staging.*    dev.*
test.*       preprod.*     api.*        backend.*
vpn.*        mail.*        remote.*     mgmt.*
monitoring.* grafana.*     jenkins.*    gitlab.*
jira.*       confluence.*  kibana.*     elasticsearch.*
```

---

## Subdomain Takeover Detection

```bash
# nuclei has templates for this
nuclei -l live_hosts.txt -t takeovers/

# Or use subjack
subjack -w subs.txt -t 100 -timeout 30 -o potential_takeovers.txt -ssl

# Or subzy
subzy run --targets subs.txt

# Check manually: CNAME records pointing to:
# *.github.io, *.s3.amazonaws.com, *.azurewebsites.net, 
# *.shopify.com, *.herokuap.com, *.fastly.net, *.surge.sh
dig +short CNAME admin.target.com
# If CNAME points to unclaimed service → takeover possible
```

---

## URL Collection (Historical + Current)

```bash
# gau (historical URLs from multiple sources)
gau target.com --subs --providers wayback,commoncrawl,otx | tee urls.txt

# waybackurls
echo "target.com" | waybackurls | tee -a urls.txt

# katana (active crawl)
katana -u https://target.com -jc -d 5 -o katana_urls.txt

# Combine and dedupe
cat urls.txt katana_urls.txt | sort -u > all_urls.txt

# Filter interesting patterns
cat all_urls.txt | grep -E "(api|admin|upload|download|import|export|config|debug|token|key|secret)"
cat all_urls.txt | grep "=" | sort -u > params.txt
```

---

## Port Scanning

```bash
# nmap quick
nmap -iL resolved_ips.txt -p 80,443,8080,8443,3000,8000,9200,6379,27017 --open -oG port_results.txt

# naabu (fast)
naabu -list resolved_ips.txt -p 80,443,8080,8443 -silent | httpx -silent

# Full port
naabu -list resolved_ips.txt -p - -silent -o all_ports.txt
```

---

## 2025-2026 Notes

> [!info] New recon surface (2025-2026)
> - **chaos.projectdiscovery.io:** Updated daily — always include in passive enum
> - **GitHub search for subdomains:** `org:target-company "staging.target.com"` sometimes reveals undiscovered subdomains
> - **Cloud asset discovery:** `cloud_enum` tool finds S3 buckets, Azure blobs, GCP buckets by org name guessing
> - **Dependency confusion:** Check npm/pypi/rubygems for packages named `target-internal`, `target-core` — register them if unclaimed

---

## References

- ProjectDiscovery tools — https://github.com/projectdiscovery
- chaos.projectdiscovery.io — public bug bounty recon data
- SecLists DNS wordlists — https://github.com/danielmiessler/SecLists/tree/master/Discovery/DNS
