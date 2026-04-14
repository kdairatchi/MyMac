# Subdomain Enumeration

Passive → resolve → active brute → permutation → live probe.

## Passive

```bash
# Aggregators (no target packets)
subfinder -d target.com -all -recursive -silent -o sf.txt
amass enum -passive -d target.com -o am.txt
assetfinder --subs-only target.com > af.txt
findomain -t target.com -q > fd.txt

# CT logs directly
curl -s "https://crt.sh/?q=%25.target.com&output=json" \
  | jq -r '.[].name_value' | tr ',' '\n' | sort -u > crt.txt

# Wayback / CommonCrawl derived
gau --subs target.com | unfurl -u domains | sort -u > gau-domains.txt
waybackurls target.com | unfurl -u domains | sort -u > wb-domains.txt

# Chaos (PD's curated dataset — free with token)
chaos -d target.com -silent -o chaos.txt
```

Sources behind subfinder (review `~/.config/subfinder/provider-config.yaml`):
virustotal · securitytrails · shodan · censys · github · bevigil · fofa · binaryedge · dnsdumpster · hackertarget · anubis · threatbook · whoisxml · bufferover · passivetotal.

## Resolve

```bash
cat sf.txt am.txt af.txt fd.txt crt.txt chaos.txt | sort -u > all-raw.txt

# Wildcard-safe resolution
dnsx -l all-raw.txt -r resolvers.txt -wd target.com -a -resp-only -silent -o resolved.txt

# Massdns (faster for large lists)
massdns -r resolvers.txt -t A -o S -w massdns.out all-raw.txt
```

Fresh resolvers:
```bash
curl -s https://public-dns.info/nameservers-all.txt | \
  dnsvalidator --threads 50 -o resolvers.txt
```

## Active brute

```bash
# Short list first
shuffledns -d target.com -w subdomains-top1million-110000.txt \
  -r resolvers.txt -o brute.txt

# Permutations (altdns / gotator / ripgen)
gotator -sub resolved.txt -perm permutations.txt -depth 1 -numbers 3 -mindup \
  | shuffledns -d target.com -r resolvers.txt -o perms.txt
```

## HTTP probe

```bash
httpx -l resolved.txt -threads 100 -rate-limit 150 \
  -sc -title -tech-detect -cdn -location \
  -json -o httpx.json

jq -r '.url' httpx.json | sort -u > live.txt
```

## Takeover scan

```bash
subzy run --targets live.txt --hide_fails
nuclei -l live.txt -tags takeover -severity high,critical
```

## Output flow

- `resolved.txt` → next stage (content discovery)
- `httpx.json` → tech-sorted pivots (WordPress, Jenkins, Jira buckets)
- `takeover.txt` → submit immediately if confirmed

## References

- TrickestSec subdomain-enum playbook — https://github.com/trickest/resolvers
- ProjectDiscovery docs — https://docs.projectdiscovery.io
- SecLists subdomains — https://github.com/danielmiessler/SecLists
