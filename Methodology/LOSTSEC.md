# **LOSTSEC / COFFINXP — Bug Bounty Hunting Playbook**

**Research scope:** Lostsec (@lostsec\_ / CoffinXP), including publicly indexed Medium articles, X posts, YouTube videos, and associated GitHub resources.

The playbook will distinguish three things:

1. **Original methodology:** techniques and workflows attributable to Lostsec.
2. **Operational implementation:** commands, pipelines, parameters, and validation procedures.
3. **Hunter adaptation:** how to apply the techniques against authorized HackerOne, Bugcrowd, and Intigriti programs.

The objective is to turn the material into a repeatable hunting methodology, not simply a collection of scanner commands.

# **1. Source inventory — Lostsec / CoffinXP**

**Lostsec**

CoffinXP · @lostsec\_ · GitHub coffinxp

Verified account links

Public research

These are the source identities used to assemble the playbook:

| Platform | Source                                                                         |
| -------- | ------------------------------------------------------------------------------ |
| X        | [@lostsec\_](https://x.com/lostsec_?utm_source=chatgpt.com)                    |
| Medium   | [Lostsec](https://lostsec.medium.com/?utm_source=chatgpt.com)                  |
| YouTube  | [Lostsec channel](https://www.youtube.com/@lostsec_ftw?utm_source=chatgpt.com) |
| GitHub   | [coffinxp repositories](https://github.com/coffinxp?utm_source=chatgpt.com)    |

The current X identity is `@lostsec_`. The account identifies `@coffinxp7` as its previous username; do not confuse it with another account using that old handle.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://ww1.twstalker.com\&sz=32)

TwStalker+1



## **A. Medium articles identified**

Chronological research inventory · 2024–2026

| Date     | Article / research                               | Main techniques                                    |
| -------- | ------------------------------------------------ | -------------------------------------------------- |
| Dec 2024 | How to Find XSS Vulnerabilities in 2 Minutes     | GAU, GF, Gxss, kxss                                |
| Dec 2024 | JS-Recon                                         | JavaScript secrets, endpoints, credentials         |
| Jan 2025 | PDF.js CVE-2024-4367                             | PDF rendering, JavaScript execution                |
| Jan 2025 | Unlock the Full Potential of the Wayback Machine | Historical endpoint discovery                      |
| Jan 2025 | SQL Injection in Sri Lanka Electricity Board     | Origin IP, SQLi                                    |
| Feb 2025 | FFUF Mastery                                     | Directory, parameter, vhost fuzzing                |
| Mar 2025 | LostFuzzer                                       | Passive URL fuzzing, Nuclei DAST                   |
| Mar 2025 | XML-RPC Attacks                                  | WordPress XML-RPC, pingback, SSRF                  |
| May 2025 | Mastering SQL Injection Recon                    | SQLi discovery, header-based testing               |
| May 2025 | Master CRLF Injection                            | HTTP response splitting                            |
| Jul 2025 | Recon to Master                                  | Complete reconnaissance workflow                   |
| Aug 2025 | Mastering WordPress Bug Hunting                  | Plugins, themes, CMS security                      |
| Sep 2025 | My 5-Minute Workflow                             | Shodan, OTX, URLScan, VirusTotal, automation       |
| Dec 2025 | Authentication and Session Management            | Session invalidation, authentication weaknesses    |
| Dec 2025 | React2Shell                                      | CVE-2025-55182                                     |
| Dec 2025 | Mass Assignment                                  | Hidden registration fields, privilege manipulation |
| Dec 2025 | Certificate Transparency Monitoring              | Real-time subdomain discovery                      |
| Jan 2026 | SQLMap and Ghauri                                | SQLi automation, WAF testing                       |
| Feb 2026 | Microsoft IIS Recon and Fuzzing                  | IIS fingerprinting, shortnames, fuzzing            |
| Mar 2026 | Practical Fuzzing and Scanning                   | CHAOS, HTTPX, Naabu, Nmap, Nuclei, FFUF            |
| May 2026 | Exposed Google API Keys                          | Gemini, Google API capabilities                    |
| Aug 2026 | Claude Code Bug Bounty Setup                     | MCP, custom skills, agents, Burp integration       |
| Oct 2026 | Ultimate SSRF Guide                              | Discovery, OAST, filter testing, impact validation |

Sources:&#x20;

[image](https://www.google.com/s2/favicons?domain=https://lostsec.medium.com\&sz=32)

lostsec.medium.com+14



## **B. YouTube research inventory**

[Medium](https://images.openai.com/static-rsc-4/lBwOv6aZbtkW3qtbCO-SIAcJ7PmLWuBYJgQ3gwNkc5yZZBe4ew_Hyg8R-tM-vlcTHufCHL1mgrxns1gyllkQZVzawZxx1i51uZ5fSvA1NQVqMU0D3tE1V1Ov41lKlqTvBDbw4e452ROylfXhvaEpWQAfW69bBbSs0EAXl7ahCRU?purpose=inline)

**1. Recon to Master: The Complete Bug Bounty Checklist**

July 10, 2025

[Watch video](https://www.youtube.com/watch?v=7hf-WQ0Idhg\&utm_source=chatgpt.com)

- Full reconnaissance workflow.
- Asset discovery and vulnerability identification.

[JavaScript Analysis Masterclass - Part 1](https://images.openai.com/static-rsc-4/fjjyjX6MdTZb8fZb3QMVVrprd9Jle6Tgw5wCUDOh1bMQsz0z7KQvCP7eM4Tn3rrR5V3ORhPVguQDQrr97SCfVCI_KyzAnHVkytKwTD_pDDIHXaSLerwJMczlkWayvfB3zyKo9MuATk6JCG6CgoIZKngMBDeN3CbvFEH2JjSD8NU?purpose=inline)

**2. JavaScript Recon Masterclass**

December 23, 2024

[Watch video](https://www.youtube.com/watch?v=FWPXWBh4EFw\&utm_source=chatgpt.com)

- JavaScript analysis.
- Hidden endpoints and application intelligence.

[Mastering Origin IP Discovery Behind WAF: 11+ Methods Explained | Galaxy.ai](https://images.openai.com/static-rsc-4/8Uhr-b11kToTbidAmAI8GTM6_aMI_YyVK2yDRJOnedKhkm7mDwMzAK8gixjM7kTrpkwokM-1SNt0Nw9P0Qsa_iBpnjbp7RBcV1tAjC3XVXoULaFannI7TcnDgIGL_fwADh0ggqe6JVIaNbjGFUTZY9P1JDItKR51FEYlw9bx4dE?purpose=inline)

**3. Mastering Origin IP Discovery Behind WAF**

December 8, 2024

[Watch video](https://www.youtube.com/watch?v=R3hmZpkvCmc\&utm_source=chatgpt.com)

- DNS history.
- Certificate and infrastructure correlation.
- Origin discovery.

[Ben Sadeghipour (@NahamSec) on X](https://images.openai.com/static-rsc-4/eHyB5IeZDMREt6BKw98ZZKSO_uNBkSKasVDE9pr8DaepUibsNWz0Xuof00sMgI9JppvknM3Atd4rZhojGhf8v5OqyMgexrCmuxKnqAc9oTPizbPOA2_WMNrLyru59FVDjcQTx9-3IQMdbjpYl0U6byFz7PkOZ1KSFC81IaJ0BOE?purpose=inline)

**4. Don't Use ParamSpider Blindly — LostFuzzer**

March 7, 2025

[Watch video](https://www.youtube.com/watch?v=aMA7gWhGNaE\&utm_source=chatgpt.com)

- Valid parameter preservation.
- Passive URL discovery.
- Nuclei DAST automation.

[- YouTube](https://images.openai.com/static-rsc-4/eYk0BCr8QzKPypdSpNTbZi3BuMk37jLemWZTU_WCuYJpQozbXC3WprwmHutZihvllAumhGLUvgT2kBx0FzPMCdLm-Ma-wrM-me8Cnl6H7g8dmAuaIcBGCuJEETRZtnfGTfDyRw3QGq-ZYYjVzg2Kd2wNYZdjn2BRdXE7ko0u-Bo?purpose=inline)

**5. Finally We Made a Best Bug Hunting Tool**

September 5, 2024

[Watch video](https://www.youtube.com/watch?v=6wtwUp5Zx48\&utm_source=chatgpt.com)

- Security tool workflow.
- XSS, JavaScript recon and origin discovery resources.

[How Penligent AI Enhances VAPT with AI-Driven Security Testing | Rakesh Joshi posted on the topic | LinkedIn](https://images.openai.com/static-rsc-4/tIjpALXnpSzt3EE8wJVNZe46G--cPYQTfESF-Ch28Qiq7Qic3FZo65WmF0V65CvnleVeql7dgutyZWjM2PG4wwl4HHZkMlygRTHrNFvdWpnxzwkv5U5Jr4s0r7dqen0efqzx68L9j1QPZTNPdCu6qr1a74Mo2SeC1yRLY4ThYrg?purpose=inline)

**6. Penligent AI: Next-Gen Tool for Pentesting**

February 22, 2026

[Watch video](https://www.youtube.com/watch?v=qpvPArc7Za0\&utm_source=chatgpt.com)

- AI-assisted testing.
- Automated security workflows.

[Penligent:An autonomous penetration testing platform combining vulnerability detection, exploit automation, and intelligent red teaming in a unified security ecosystem. - MOGE](https://images.openai.com/static-rsc-4/VOsNPDdItkdH_fAzyUubKI-DWBhVrdlmzAQe8kQkUeeG8fspCQfxKGRA_83N5-RY53F1oDcr3YagBdlI-92GieQcC4rqXjyRFMbssMEMTAMbOjvhDXLsc-0HGXyxxMHPL2pMaLLKUlo9xQ6Pw3kPgaNJrRXyYnGK0P-63JmYOIs?purpose=inline)

**7. Testing Penligent AI on Live Bug Bounty Targets**

May 18, 2026

[Watch video](https://www.youtube.com/watch?v=VIx7B9YxVrI\&utm_source=chatgpt.com)

- Practical AI-assisted hunting.
- Live target testing.

Additional video topics explicitly linked by Lostsec include:

- How to Access 404 Files of Any Server.
- The Best XSS Methodology for Bug Bounty Hunters.
- How to Approach a Target in Bug Bounty Programs.
- Extended Target Approach, Part 2.

The available indexed material identifies these videos, but does not provide complete searchable transcripts for every one. I will not invent their exact spoken commands or attribute unrelated techniques to him.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.youtube.com\&sz=32)

YouTube+3



## **C. X methodology**

The most useful directly indexed X technique is his XSS pipeline:

```
echo https://example.com | gau | gf xss | uro | Gxss | kxss | tee xss_output.txt
```

The idea:

1. Retrieve historical URLs.
2. Identify XSS-relevant parameters.
3. Deduplicate.
4. Detect reflected parameters.
5. Identify characters that remain insufficiently filtered.
6. Manually validate the actual browser execution context.

Lostsec also emphasizes that generic AI and scanner output will not replace creative, deeper security research.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.sotwe.com\&sz=32)

Sotwe+1



# **2. Lostsec GitHub arsenal**

These are particularly useful because they turn the articles into repeatable workflows.

[Wix.com Computer Software Jimdo Internet Content management system, Wix, angle, marine Mammal png | PNGEgg](https://images.openai.com/static-rsc-4/Y6t7LfHPGzfvL61LHbcrEqzL--YLVJUDVBtSBgCIdlm8igDiP6kVRA1ZQvFXgkEZiPKVLS4o3_wf_ccsVGIESx9wOYpfme2dn_2YOBB07RtbWfZSiO7fxAJkN6JovfAqZDMhI6SIXxdxgSRPws5xFfgZUKEQLcY937ICe40Z_Gs?purpose=inline)

**LOXS — Multi-vulnerability scanner**

[coffinxp/loxs](https://github.com/coffinxp/loxs?utm_source=chatgpt.com)

SQLi, XSS, LFI, open redirects and CRLF. Supports customizable payloads, concurrency, result saving and HTML reporting.

Core tool

[Coffin (@coffinxp7) on X](https://images.openai.com/static-rsc-4/5RhoAykzwf3xi1KI_cAzw8tnRUSQeYh5BqDH8qDI8OQ1CPfb3TS7Mly-PHg5RBW9uRQHe7qX64gCHTYvQlmedVTUghRmy8NHz35Btixuobw2pv3D6OdObCsA1au4AluLFRvr5Vs5zeoGic5gizou75tGxBoB9ciZprnuW7SWXrU?purpose=inline)

**Payload collection**

[coffinxp/payloads](https://github.com/coffinxp/payloads?utm_source=chatgpt.com)

Wordlists and payload collections for SQLi, XSS, LFI, SSRF, IIS, JWT, PHP, WordPress, XML, fuzzing and more.

[GitHub - 1ndianl33t/Gf-Patterns: GF Paterns For (ssrf,RCE,Lfi,sqli,ssti,idor,url redirection,debug_logic, interesting Subs) parameters grep](https://images.openai.com/static-rsc-4/Ml9nG9sQSZoEDTn64mKej4aHDYQxRhbSik49dMpqEAC_WzR40OONEVKetBVnBJjKIWDvx_KLCa1MQFoMPeRiFkf0J7jFBCi6SNRfhXLduIeXTfFuBsodbiqBFCWJv9yNB34Zp7vVBql0robbX1VQh3oXnaZYqtbqaybM6auG3yU?purpose=inline)

**GFpattren**

[coffinxp/GFpattren](https://github.com/coffinxp/GFpattren?utm_source=chatgpt.com)

Pattern-based URL classification for vulnerability hunting.

[GitHub - coffinxp/nuclei-templates](https://images.openai.com/static-rsc-4/elPrwvseWdumYjdZJGNYcB0JCH0-6QRpVWVIb62QI_cdHICm6FB9paRP8H4TYxWsBR0AithPUNHPCu0dQVzR16jpEYfHyw4acZE6amfz8UFj_cUNp76ZQrsdLK57To2DZQw6LT9lg9ktlTRDg16bdBS7jLmUWgt44sjoNUEn2k4?purpose=inline)

**Custom Nuclei templates**

[coffinxp/nuclei-templates](https://github.com/coffinxp/nuclei-templates?utm_source=chatgpt.com)

Includes CVE-2025-29927, IIS, CORS, CRLF, SSRF, GraphQL, credential disclosure, exposed backups and takeover detection.

[Continuous Integration | OSS-Fuzz](https://images.openai.com/static-rsc-4/yD1QMOHjPtNRPkGsT-XIwBajRq80humwckaZ7CpJKJQinVnwrDmCRbdtYHX6fFHyHVrSCGVCluVjpbFB3dgVgMreNGRwNXeK53X1K-gFFC3S_vw6nvMKTJlE_OB1vpZYwleO3ZLYy9wp-bT2xF3hj95tO1502a9WqUoKgzrJ1Tc?purpose=inline)

**LostFuzzer**

[coffinxp/lostfuzzer](https://github.com/coffinxp/lostfuzzer?utm_source=chatgpt.com)

GAU → valid parameter filtering → HTTPX → Nuclei DAST.

[GitHub - Myudi422/Bypass-cerminx · GitHub](https://images.openai.com/static-rsc-4/CFYqVLPyB-tTbqG9BS4C23A5oL4jGKDecsYQL7lqGrymYTFTxuBp1nk-_1t2a9reKODjracd9vzqyQWnTG33VMRbrLaiCh-XutxONjeqIjr7FtJdahjnFyZuoO2m8BAEsBWhcHEWM6KO6cTHEEgXu3Bw-YSp6DtaYp_67lgGZt8?purpose=inline)

**CRTMon**

[coffinxp/crtmon](https://github.com/coffinxp/crtmon/blob/main/README.md?utm_source=chatgpt.com)

Continuous Certificate Transparency monitoring with Discord and Telegram notifications.

[31 bite-sized tips, techniques, and bug bounty resources to kick off 2026!](https://images.openai.com/static-rsc-4/KSa9rnr6nOAsaoTzYqKrUf4jWxNT0GLZ35wOqXH-4skO0i_6HBxpwuu3sX3gHvTlMfGujuzEmRe5sTJUc_f8DU9wHxh70tmlzlzqPVud7QPIAuHCfF-WR8nLxzdTkUwGvprLvUUdQ7yfpwgYrX2CCVZMwywXda8pedfyCk90PzI?purpose=inline)

**PDF exploits**

[coffinxp/pdFExploits](https://github.com/coffinxp/pdFExploits?utm_source=chatgpt.com)

PDF.js research and proof-of-concept resources.

[Reconnaissance: How GitDorks can power up your recon! | by Kieran W | Medium](https://images.openai.com/static-rsc-4/jfk3g5F8ZHcq-noFS0LiIFTle3Sx-OP4inwNk2ZBZHLGUzCxHomaK3z8xFljXLbka-eSiVSdr_Tfkbxp_7z0O-Z5VjUaDt3eQBzJwR8PBn5dJD1--3e0XgoXoMz_W4Pt9nQbwFpMx4VZyll-DXJqnYNm7jehItvyygYLCpcb5C0?purpose=inline)

**Google API Key Scanner**

[coffinxp/Google-api-key-scanner](https://github.com/coffinxp/Google-api-key-scanner?utm_source=chatgpt.com)

Tests discovered Google API keys against 21 service endpoints.

[Coffin (@coffinxp7) on X](https://images.openai.com/static-rsc-4/XvoeH2z_gSeFctf9hFai99C327TXimkCnTVRk04eD3P__lXIS6rymRBuYKxtPf3HtAa1aFgOE8LmDVD5RanItqBCG-U18Fb6SmmbIsgFBM2DMpRD_XR6UlVajRUenHhTwd8ijUUf0cs7XyOW6cg1MamGmxohiMKI1Ng6WHC4cvM?purpose=inline)

**Image payloads**

[coffinxp/img-payloads](https://github.com/coffinxp/img-payloads?utm_source=chatgpt.com)

Image-related security testing resources.

[I discovered 40+ live AI API keys on GitHub Gists. Here’s what I found. | by kevinMEH | Medium](https://images.openai.com/static-rsc-4/C2QYnHG9KVFfMaDBY8luYwkWdhjreiKiiUZM71kLBj90uTNR7EdVEPZgnYsbU7LRtCmc8NJ3micgSPzU6AVITKvZ8sj50P2pgVfP-6t-5IlE4ZX6BaJxYLAhqaOZFQfnWoVXmqKvVkhllw2BBjGnqNtjkbqbrCEO0T7TNVM6VaM?purpose=inline)

**Gemini API Key Hunter**

[coffinxp/Gemini-api-key-hunter](https://github.com/coffinxp/Gemini-api-key-hunter?utm_source=chatgpt.com)

Key discovery and capability validation workflow.

Other repositories to inspect:

- [Scripts](https://github.com/coffinxp/scripts?utm_source=chatgpt.com)
- [All public repositories](https://github.com/coffinxp?tab=repositories\&utm_source=chatgpt.com)

The payload repository explicitly contains material from both Lostsec and other public/community sources. Not every payload should be attributed as his original invention.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://github.com\&sz=32)

GitHub+8



# **3. Complete reconnaissance methodology**

This is the foundation of the Lostsec approach: gather assets from multiple sources, consolidate them, fingerprint them, discover historical endpoints, then prioritize vulnerability-specific testing.

## **3.1 Environment and workspace**

Use a separate directory per program.

```
export DOMAIN="example.com"
export OUT="$HOME/bugbounty/$DOMAIN"

mkdir -p "$OUT"/{recon,urls,js,scans,fuzz,evidence,reports}
```

Maintain separate files:

```
program/
├── scope.txt
├── excluded.txt
├── recon/
│   ├── subfinder.txt
│   ├── amass.txt
│   ├── crt.txt
│   ├── resolved.txt
│   ├── alive.txt
│   ├── ports.txt
│   └── screenshots/
├── urls/
│   ├── passive.txt
│   ├── active.txt
│   ├── all.txt
│   ├── parameters.txt
│   └── sensitive-files.txt
├── js/
│   ├── js-files.txt
│   ├── endpoints.txt
│   └── findings.txt
├── scans/
├── fuzz/
├── evidence/
└── reports/
```

**Important:** All active commands below must use verified in-scope hostnames. A parent domain being in scope does not automatically authorize every related IP, third-party service, or subdomain.

## **3.2 Subdomain enumeration**

### **Method 1 — Subfinder**

```
subfinder -d "$DOMAIN" -all -recursive -silent \
  -o "$OUT/recon/subfinder.txt"
```

### **Method 2 — Assetfinder**

```
assetfinder --subs-only "$DOMAIN" \
  > "$OUT/recon/assetfinder.txt"
```

### **Method 3 — Amass**

```
amass enum -passive -d "$DOMAIN" \
  -o "$OUT/recon/amass.txt"
```

### **Method 4 — Certificate Transparency**

```
curl -s "https://crt.sh/?q=%25.${DOMAIN}&output=json" |
jq -r '.[].name_value' |
sed 's/^\*\.//' |
sort -u > "$OUT/recon/crt.txt"
```

### **Method 5 — Consolidate everything**

```
cat "$OUT"/recon/*.txt |
sort -u > "$OUT/recon/all-subdomains.txt"
```

### **Method 6 — Resolve discovered assets**

```
dnsx -l "$OUT/recon/all-subdomains.txt" -silent \
  -o "$OUT/recon/resolved.txt"
```

### **Method 7 — Discover organization infrastructure**

Tools:

- `asnmap`
- `amass intel`
- Shodan
- Censys
- VirusTotal
- AlienVault OTX
- urlscan.io
- SecurityTrails

Examples:

```
asnmap -d "$DOMAIN" | tee "$OUT/recon/asn.txt"
```

```
amass intel -d "$DOMAIN" \
  -whois -o "$OUT/recon/amass-intel.txt"
```

Shodan query:

```
ssl.cert.subject.CN:"example.com"
```

Use organization and ASN information to identify potentially related assets, then independently verify ownership and program scope.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

infosecwriteups.com+2

## **3.3 Live host discovery and fingerprinting**

```
httpx-toolkit \
  -l "$OUT/recon/resolved.txt" \
  -ports 80,443,8080,8000,8888 \
  -status-code -title -tech-detect -silent \
  -rl 5 \
  -o "$OUT/recon/alive.txt"
```

Capture additional information:

```
cat "$OUT/recon/alive.txt" |
httpx-toolkit -status-code -title -tech-detect \
  -web-server -ip -cdn -silent \
  > "$OUT/recon/fingerprints.txt"
```

### **Visual reconnaissance**

```
cat "$OUT/recon/alive.txt" |
aquatone -ports 80,443,8080,8443
```

Look for:

- Login portals.
- Development dashboards.
- API documentation.
- Legacy applications.
- Admin interfaces.
- Unusual application versions.
- Different frontend implementations.
- Forgotten staging environments.

### **Port discovery**

Where the program permits infrastructure scanning:

```
naabu -list "$OUT/recon/resolved.txt" \
  -top-ports 1000 -rate 50 \
  -o "$OUT/recon/ports.txt"
```

Follow up only on authorized IPs and ports.

## **3.4 URL discovery — passive and active**

This is one of the most reusable Lostsec methodologies.

### **Passive URL collection**

```
cat "$OUT/recon/alive.txt" |
gau --threads 5 |
uro |
sort -u > "$OUT/urls/passive.txt"
```

### **Wayback Machine**

```
waybackurls "$DOMAIN" |
sort -u > "$OUT/urls/wayback.txt"
```

### **Katana active crawling**

```
katana \
  -list "$OUT/recon/alive.txt" \
  -d 3 \
  -jc -kf \
  -rl 5 \
  -silent \
  -o "$OUT/urls/active.txt"
```

### **Combine all sources**

```
cat "$OUT"/urls/*.txt |
sort -u > "$OUT/urls/all.txt"
```

### **Extract parameterized URLs**

```
grep '=' "$OUT/urls/all.txt" |
uro > "$OUT/urls/parameters.txt"
```

### **Extract server-side application routes**

```
grep -Ei '\.(php|asp|aspx|jsp|jspx|cfm|cgi)(\?|$)' \
  "$OUT/urls/all.txt" |
sort -u > "$OUT/urls/server-routes.txt"
```

### **Sensitive file candidates**

```
grep -Ei '\.(env|log|bak|backup|sql|db|json|yaml|yml|zip|tar|gz|config|conf|ini|pem|key|xml|txt)$' \
  "$OUT/urls/all.txt" |
sort -u > "$OUT/urls/sensitive-files.txt"
```

These are candidate URLs, not proof of exposed information. Verify responses carefully without downloading unrelated customer data.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+2

## **3.5 GF pattern hunting**

This is one of the strongest reusable parts of the methodology.

```
cat "$OUT/urls/all.txt" | gf xss | uro > "$OUT/urls/xss.txt"

cat "$OUT/urls/all.txt" | gf sqli | uro > "$OUT/urls/sqli.txt"

cat "$OUT/urls/all.txt" | gf ssrf | uro > "$OUT/urls/ssrf.txt"

cat "$OUT/urls/all.txt" | gf lfi | uro > "$OUT/urls/lfi.txt"

cat "$OUT/urls/all.txt" | gf redirect | uro > "$OUT/urls/redirect.txt"

cat "$OUT/urls/all.txt" | gf idor | uro > "$OUT/urls/idor.txt"
```

The `idor` pattern depends on the installed custom pattern collection.

**Priority parameter names**

| Vulnerability | Interesting parameters                       |
| ------------- | -------------------------------------------- |
| XSS           | `q`, `search`, `name`, `message`, `html`     |
| SQLi          | `id`, `user`, `filter`, `sort`, `query`      |
| SSRF          | `url`, `uri`, `src`, `image`, `callback`     |
| LFI           | `file`, `path`, `page`, `template`           |
| Redirect      | `next`, `return`, `redirect`, `continue`     |
| IDOR          | `id`, `user_id`, `account_id`, `document_id` |
| Authorization | `role`, `permission`, `tenant`, `owner`      |

### **Hidden parameter discovery**

```
arjun -u "https://$DOMAIN/api/endpoint" \
  -m GET,POST --stable
```

Use Arjun against individually verified endpoints, not every URL at once.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

infosecwriteups.com+1

## **3.6 Directory and file fuzzing**

### **FFUF directory discovery**

```
ffuf \
  -u "https://$DOMAIN/FUZZ" \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -mc 200,204,301,302,307,401,403 \
  -rate 5 -t 5 \
  -ac \
  -of json \
  -o "$OUT/fuzz/directories.json"
```

### **Extension fuzzing**

```
ffuf \
  -u "https://$DOMAIN/indexFUZZ" \
  -w /usr/share/seclists/Discovery/Web-Content/web-extensions.txt \
  -rate 5 -t 5 \
  -ac
```

### **Virtual-host discovery**

```
ffuf \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  -u "https://$DOMAIN/" \
  -H "Host: FUZZ.$DOMAIN" \
  -rate 5 -t 5 \
  -ac
```

Only test virtual hosts that are within the authorized program boundary.

### **Parameter-name fuzzing**

```
ffuf \
  -u "https://$DOMAIN/api/endpoint?FUZZ=test" \
  -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
  -rate 5 -t 5 \
  -ac
```

### **Fuzzing modes to master**

| Mode            | Application                                           |
| --------------- | ----------------------------------------------------- |
| Directory       | Hidden paths                                          |
| Extension       | Backup and alternate file extensions                  |
| Subdomain       | Hidden hostnames                                      |
| VHost           | Host-header routing                                   |
| GET parameters  | Undocumented query inputs                             |
| POST parameters | Hidden body fields                                    |
| Clusterbomb     | Controlled combinations of multiple variables         |
| Pitchfork       | Corresponding values from multiple wordlists          |
| Raw request     | Headers, cookies, JSON, multipart and custom requests |
| Recursive       | Nested paths and directories                          |

For authenticated testing, import your own captured request and use your own test account. Do not turn these modes into password spraying or uncontrolled login attempts.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+1

## **3.7 Nuclei scanning**

Lostsec's own templates are a useful starting collection.

```
nuclei \
  -l "$OUT/recon/alive.txt" \
  -t ~/nuclei-templates/ \
  -rl 5 -c 5 \
  -exclude-tags dos,fuzz \
  -o "$OUT/scans/nuclei.txt"
```

### **Specific template categories**

| Category  | What to investigate              |
| --------- | -------------------------------- |
| CVE       | Known vulnerable versions        |
| Exposure  | Sensitive files and credentials  |
| CORS      | Origin policy                    |
| SSRF      | Server-side URL handling         |
| IIS       | IIS fingerprinting               |
| GraphQL   | API exposure                     |
| Takeover  | Dangling DNS                     |
| CRLF      | Header injection                 |
| Backup    | Exposed backups                  |
| WordPress | Setup and configuration exposure |
| Redirect  | Unvalidated redirect handling    |
| Next.js   | Middleware and cache behavior    |

The Lostsec collection includes individual templates such as:

```
CVE-2025-29927.yaml
next-js.yaml
nextjs-middleware-cache.yaml
cors.yaml
cRlf.yaml
response-ssrf.yaml
iis.yaml
graphql_get.yaml
credentials-disclosure-all.yaml
detect-all-takeovers.yaml
php-backup-files.yaml
zip-backup-files.yaml
aws-access-secret-key.yaml
```

Do not treat a Nuclei match as a confirmed vulnerability. Validate the affected version, vulnerable behavior, exploitability and impact manually.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://github.com\&sz=32)

coffinxp/nuclei-templates · GitHub+1



# **4. Vulnerability-specific hunting playbook**

## **4.1 XSS — reflected, stored, DOM and blind**

High-priority methodology

Lostsec's XSS methodology is especially useful because it combines multiple filters rather than immediately launching an XSS scanner.

[How I was able to find 4 Cross-site scripting (XSS) on vulnerability disclosure program ? | by DrakenKun | Medium](https://images.openai.com/static-rsc-4/tTG2sae9ERMFX_-Bj1bWsjPwsbpqQwgpCQWadd_54JvHuFrMO6VG7Y_SCJxzJ23s-0kORiGzGzys65G6tNzE8YA1qn0vimiEJ_0aKyySfUKCYyp3H7gI0Hvta83EbFRzkkyNiB-9n4Lb3bWuOTpvqodr0CAkkjpSI_xA2afQIHQ?purpose=inline)

### **Main pipeline**

```
echo "$DOMAIN" |
gau |
gf xss |
uro |
Gxss -p Rxss |
kxss |
tee "$OUT/scans/xss-reflections.txt"
```

### **Pipeline explanation**

| Tool   | Purpose                              |
| ------ | ------------------------------------ |
| GAU    | Historical URLs                      |
| GF     | XSS candidate filtering              |
| URO    | Deduplication                        |
| Gxss   | Reflected parameter discovery        |
| kxss   | Special-character filtering analysis |
| Dalfox | Further XSS validation               |

### **Follow-up with Dalfox**

```
cat "$OUT/urls/xss.txt" |
dalfox pipe --silence
```

Keep its request volume within program limits.

### **XSS methodology checklist**

- Reflected query parameters.
- Stored profile fields.
- User-generated comments.
- Search history.
- Contact forms.
- File names.
- SVG and image metadata.
- HTML email templates.
- Admin-facing moderation interfaces.
- DOM sources and sinks.
- `postMessage` handlers.
- JSON responses rendered into HTML.
- Different content types.
- CSP and output encoding.
- Delayed or blind execution.

### **DOM XSS review**

```
rg -n -i \
'document\.write|innerHTML|outerHTML|eval\(|location\.hash|location\.search|postMessage' \
"$OUT/js/"
```

This identifies code requiring source-to-sink review. It does not prove XSS.

### **Blind XSS**

Use an OAST endpoint you control.

Prioritize fields that may later be viewed by:

- Support staff.
- Moderators.
- Administrators.
- Internal operations teams.
- Customer success personnel.

Use unique callbacks per test and never inject into unrelated users' data.

**Validation standard:** prove execution in the correct origin and context using your own test account or an approved test workflow.

[image](https://www.google.com/s2/favicons?domain=https://www.sotwe.com\&sz=32)

Sotwe+3

## **4.2 JavaScript reconnaissance — JS-Recon**

High-priority methodology

JavaScript is not just a source of leaked API keys. It is an application architecture map.

[Extract Hidden Endpoints from JavaScript Files with Katana | ProjectDiscovery posted on the topic | LinkedIn](https://images.openai.com/static-rsc-4/h1nTQ0ua4NoMItSqDzFwS7dHl-Gg698jpbhtlgcZ8EKnFJHQwKCRo-SxSrVJDWSEcMq8BpFy7l4iI7l8vnh8TkR5dBtya7I5CT1-FTutrXCJHyWzjkRt3rl8_XPKTVSj2OUdhXTgcDMBdjeUdI5SYodBogbA0CnbSEETrLbHemU?purpose=inline)

### **Extract JavaScript files**

```
grep -Ei '\.js([?#]|$)' "$OUT/urls/all.txt" |
uro |
httpx-toolkit -mc 200 -silent \
> "$OUT/js/js-files.txt"
```

### **Discover endpoints with LinkFinder**

```
cat "$OUT/js/js-files.txt" |
xargs -I@ -P5 bash -c \
'python3 linkfinder.py -i "$1" -o cli 2>/dev/null' _ @ |
tee "$OUT/js/endpoints.txt"
```

### **Search for sensitive references**

```
rg -n -i \
'api[_-]?key|client_secret|access_token|authorization|password|secret|firebase|swagger|graphql|admin|internal' \
"$OUT/js/" \
> "$OUT/js/findings.txt"
```

### **SecretFinder**

```
cat "$OUT/js/js-files.txt" |
xargs -I@ -P3 \
python3 SecretFinder.py -i @ -o cli \
> "$OUT/js/secret-candidates.txt"
```

### **Additional targets**

Look for:

- `.map` source maps.
- OpenAPI and Swagger references.
- GraphQL operation names.
- REST endpoints.
- Internal service hostnames.
- Feature flags.
- API version numbers.
- Debug routes.
- Deprecated endpoints.
- Authorization conditions.
- Hidden frontend functionality.
- Environment-specific configurations.

### **The important next step**

Do not stop at discovering an endpoint.

For each endpoint, record:

```
Endpoint:
HTTP method:
Request format:
Required authentication:
Observed role:
Required permissions:
Response fields:
Associated frontend feature:
Associated API operation:
```

Then test the endpoint with authorized identities.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

infosecwriteups.com+2

## **4.3 SSRF — server-side request forgery**

Major research priority

The October 2026 SSRF article is one of the most substantial recent Lostsec resources.

[How I Turned a Low Blind SSRF Into a Critical Vulnerability With Strategic Impact Escalation | by DrakenKun | Medium](https://images.openai.com/static-rsc-4/x1mEYxSapt7PzoWU9hnZf8zqR09xVeBkZdlA68B8d6Ie7lWgB97VB-Y4fwF2bY5OUfxMBW6ixW2n6BZ6Q4UGIcT3w3YGK4RzhWjjtwakSpUH0hFFpcZqk2R4lHA6oZY_mLoddMoSu7apCeLJ5AyrdogiNVyw4Q5mas0pxzBgMeA?purpose=inline)

### **Where to look**

| Feature             | Why investigate                            |
| ------------------- | ------------------------------------------ |
| URL previews        | Backend retrieves supplied URLs            |
| PDF generators      | Rendering engines fetch external resources |
| Image processing    | Remote image retrieval                     |
| Webhooks            | Server-initiated callbacks                 |
| Import by URL       | Backend download                           |
| Avatar retrieval    | Remote image processing                    |
| Video processing    | FFmpeg and media parsers                   |
| Link unfurling      | Background URL fetching                    |
| Document conversion | Headless browser rendering                 |
| Integrations        | External API connections                   |

### **Find SSRF candidates**

```
cat "$OUT/urls/all.txt" |
gf ssrf |
uro > "$OUT/urls/ssrf-candidates.txt"
```

### **OAST validation**

```
export OAST="YOUR-OWN-COLLABORATOR-DOMAIN"

cat "$OUT/urls/ssrf-candidates.txt" |
qsreplace "https://$OAST/lostsec-test" |
tee "$OUT/scans/ssrf-test-requests.txt"
```

Replay the resulting requests against the in-scope endpoints through your proxy or controlled testing client.

### **Investigate validation boundaries**

Test these concepts with controlled external callbacks:

- Scheme validation.
- Hostname validation.
- DNS resolution behavior.
- Redirect following.
- IPv4 versus IPv6 parsing.
- URL encoding and decoding.
- Multiple URL parsing stages.
- Allowed-host restrictions.
- DNS rebinding resistance.
- Redirect chains.

### **SSRF impact validation**

Establish:

1. The application made the request.
2. The request originated from the target infrastructure.
3. The request reached the intended controlled endpoint.
4. The server exposed a meaningful security boundary.
5. The finding has demonstrated impact.

Do not proceed to internal network scanning, cloud credential extraction, Redis manipulation, file writing or RCE payloads unless the program explicitly authorizes that level of testing. An OAST callback is often enough to establish the underlying behavior without accessing sensitive systems.

[image](https://www.google.com/s2/favicons?domain=https://lostsec.medium.com\&sz=32)

Medium+1

## **4.4 SQL injection — SQLi and Ghauri**

[SQLMAP tutorial. In this quest, we are going to use the… | by Omar Pineda | Medium](https://images.openai.com/static-rsc-4/S9U48b8FRQdt-1MCWaiAnabL2l1jZ0eQL_8KmGFCbEJj6Xf7gTxES8-8y6UQAImFf8cosXOV7v9JvVZ5jf2LJ3IMn63AfVf-ld2Qnum_UsGauOHpsPZNxTK6JaF-sE0L9qAO1xtRugGSHdEXw0WoxIa3txOTW_Z2391zmbYRArE?purpose=inline)

### **Discover likely SQLi parameters**

```
cat "$OUT/urls/all.txt" |
gf sqli |
uro > "$OUT/urls/sqli-candidates.txt"
```

### **Identify application technologies**

```
subfinder -d "$DOMAIN" -all -silent |
httpx-toolkit -td -sc -silent |
grep -Ei 'asp|php|jsp|jspx|aspx'
```

### **Header-based testing**

Lostsec specifically discusses testing reflected input in:

- `User-Agent`
- `Referer`
- `X-Forwarded-For`

Investigate whether these values enter database queries. Use controlled differential tests and avoid repeated time-delay tests that could affect production.

### **Controlled SQLMap validation**

Capture your own request in Burp:

```
sqlmap \
  -r request.txt \
  --batch \
  --risk=1 \
  --level=1 \
  --technique=BEU \
  --threads=1 \
  --delay=1 \
  --timeout=10 \
  --retries=0
```

Do not use database dumping or extraction options in a bounty proof of concept.

### **LOXS**

```
git clone https://github.com/coffinxp/loxs.git
cd loxs
pip3 install -r requirements.txt
python3 loxs.py
```

Use it to prioritize SQLi candidates and inspect its detection criteria before trusting results.

### **High-value SQLi targets**

- Search and filtering.
- Report generation.
- Sorting and pagination.
- Export functions.
- Legacy PHP endpoints.
- API query parameters.
- Administrative search.
- Header-derived database inputs.
- Multi-tenant filtering.
- Numeric and string identifiers.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

infosecwriteups.com+3

## **4.5 LFI and path traversal**

### **Candidate extraction**

```
cat "$OUT/urls/all.txt" |
gf lfi |
uro > "$OUT/urls/lfi-candidates.txt"
```

### **Fuzzing**

Use the Lostsec payload collection:

```
payloads/
├── lfi.txt
├── directory_traversal_unix.txt
├── directory_traversal_win.txt
├── env.txt
├── config.txt
└── backup_files_only.txt
```

### **Hunting methodology**

- Identify file parameters.
- Examine download and export features.
- Check document preview handlers.
- Investigate archive extraction.
- Test path normalization.
- Test extension validation.
- Examine absolute versus relative paths.
- Check whether authorization is enforced on file identifiers.
- Use a harmless test file or controlled canary where possible.

Stop when a vulnerability is established. Do not extract configuration files, credentials or unrelated customer information.

[image](https://www.google.com/s2/favicons?domain=https://github.com\&sz=32)

coffinxp/payloads · GitHub+1

## **4.6 Open redirect**

### **Discover candidates**

```
cat "$OUT/urls/all.txt" |
gf redirect |
uro > "$OUT/urls/redirect-candidates.txt"
```

Look for:

```
next=
return=
return_url=
redirect=
redirect_uri=
continue=
destination=
callback=
target=
```

### **Test**

Use a domain you control as a destination and inspect the HTTP `Location` response.

Test:

- Absolute URL acceptance.
- Relative URL handling.
- Scheme validation.
- URL encoding.
- Nested redirects.
- Redirect chains.
- OAuth callback interactions.
- Hostname allowlists.

The actual objective is not merely an external redirect. Investigate whether it creates an authentication, trust or authorization impact.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+1

## **4.7 CORS**

### **Initial check**

```
curl -sS -D- -o /dev/null \
  -H "Origin: https://attacker.invalid" \
  "https://$DOMAIN/"
```

Inspect:

```
Access-Control-Allow-Origin
Access-Control-Allow-Credentials
Access-Control-Allow-Methods
Access-Control-Allow-Headers
Vary: Origin
```

### **Test cases**

| Test             | Expected investigation            |
| ---------------- | --------------------------------- |
| Arbitrary origin | Origin reflection                 |
| Null origin      | Null trust                        |
| Subdomain origin | Unsafe suffix matching            |
| Credentials      | Credentialed cross-origin access  |
| API endpoints    | Sensitive authenticated responses |
| OPTIONS          | Preflight behavior                |
| Error responses  | Inconsistent CORS policy          |

### **Automation**

```
python3 CORScanner.py -u "https://$DOMAIN" -d -t 5
```

### **Impact requirement**

A missing CORS header is not automatically a vulnerability. Demonstrate that an untrusted origin can read sensitive information belonging to your test account.

## **4.8 CRLF injection**

Frequently overlooked

CRLF can create response splitting and cache-related issues when an application incorrectly processes carriage return and line feed characters.

### **Basic harmless probe**

```
curl -skD- --path-as-is \
"https://$DOMAIN/%0d%0aX-Lostsec-Probe%3A%20test"
```

Look for an unexpected response header:

```
X-Lostsec-Probe: test
```

### **Follow-up**

- Test path-based reflection.
- Test redirect parameters.
- Inspect `Location`.
- Compare response headers.
- Check whether cache behavior changes.
- Check whether injected headers persist across requests.

Do not inject session cookies or poison shared production caches as a proof of concept.

### **LOXS**

CRLF detection is one of the five core vulnerability classes in the LOXS project.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+1

# **5. Infrastructure and specialized hunting**

## **5.1 Origin IP discovery behind WAF**

Lostsec's video covers more than 11 origin discovery methods.

[What Is Cloudflare and How Does It Work? Beginner's Guide](https://images.openai.com/static-rsc-4/7Hc3_gJhwgglvmRmVBjPEGZWAdtgk1f6a1RPWgaKofXs1YYbZ-DwVjndlP0JulwJ6g-S8hLHV_POBmX34Dzyz2ZML_XFXe1t70E0lV-YRUzxNC6Z8r6YTOm2A7NBTAW8VpsUV0Rwl5_I9k4V1oA8-sCwK8q__dQaYpmWbr0ZlQc?purpose=inline)

### **Sources to correlate**

| Source         | Investigation                        |
| -------------- | ------------------------------------ |
| crt.sh         | Historical certificates              |
| Shodan         | Certificate and service fingerprints |
| Censys         | Host and certificate history         |
| SecurityTrails | Historical DNS                       |
| ViewDNS        | Historical IP records                |
| DNSRecon       | DNS records                          |
| SPF records    | Mail infrastructure references       |
| Favicon hash   | Matching service fingerprints        |
| FOFA           | Infrastructure search                |
| urlscan.io     | Historical host references           |
| Public DNS     | Old A and AAAA records               |

### **Example commands**

```
dnsrecon -d "$DOMAIN"
```

```
dig A "$DOMAIN" +short
dig AAAA "$DOMAIN" +short
dig MX "$DOMAIN" +short
dig TXT "$DOMAIN" +short
```

### **Verification**

A candidate origin IP is not automatically the target's origin.

Correlate:

- TLS certificate.
- Hostname routing.
- HTTP response fingerprints.
- DNS history.
- Ownership.
- CDN configuration.

Only conduct direct testing if that IP is explicitly in scope or the program permits it. Discovering an origin address does not authorize bypassing the program's infrastructure restrictions.

[image](https://www.google.com/s2/favicons?domain=https://www.youtube.com\&sz=32)

11+ method - YouTube+2

## **5.2 Certificate Transparency monitoring**

Fresh-asset advantage

This is one of the best techniques for reducing competition.

Instead of discovering assets only during a scheduled recon session, continuously watch for new certificates.

### **Install**

```
go install github.com/coffinxp/crtmon@latest
```

### **Monitor a target**

```
crtmon -target "$DOMAIN"
```

### **Multiple targets**

```
cat programs.txt | crtmon -target - -notify both
```

### **Persistent monitoring**

```
nohup crtmon -target "$DOMAIN" \
  > "$OUT/recon/crtmon.log" 2>&1 &
```

### **Workflow**

```
New certificate
      |
      v
New hostname
      |
      v
Scope verification
      |
      v
DNS resolution
      |
      v
HTTP fingerprint
      |
      v
Technology identification
      |
      v
Feature discovery
      |
      v
Manual vulnerability testing
```

Look particularly for:

- Newly deployed API hosts.
- Preview environments.
- Authentication subdomains.
- New regional deployments.
- Integration services.
- Development dashboards.

A new certificate is a discovery signal, not evidence of a vulnerability or permission to test an asset.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+1

## **5.3 IIS hunting**

[Deploying Windows Containers with Azure Container Instances (ACI) Connector for Kubernetes](https://images.openai.com/static-rsc-4/_qfIM4x4XhxUDkInwEdyaXnWdaqyH04V11q9K-N2H3QRtezXx8-74avMW2XfV4PipjrPSFiWfS2CqFKZRhEmDnS4cWUCEf56emjp0uGwhBfnxHtHBicQN_XeSAElrqeCcT2qifVRNoq82yVT8dKhib9K_jc9H5uHnxVm9EMfqU4?purpose=inline)

Lostsec's IIS methodology focuses on identifying IIS infrastructure and then investigating its unique behavior.

### **Google dorks**

```
intitle:"IIS Windows Server" site:*.example.com
```

```
intext:"IIS Windows Server" site:*.example.com
```

### **Identify**

- IIS version.
- Windows Server fingerprints.
- ASP.NET applications.
- `.aspx` endpoints.
- Hidden virtual hosts.
- Shortname disclosure.
- Backup files.
- Legacy application routes.

### **FFUF extension testing**

```
ffuf \
  -u "https://$DOMAIN/indexFUZZ" \
  -w /usr/share/seclists/Discovery/Web-Content/web-extensions.txt \
  -rate 5 -t 5 -ac
```

### **IIS 8.3 shortname investigation**

Shortname disclosure is particularly interesting when directory and filename aliases can be inferred from the server response.

Use an IIS-specific shortname detection tool, then manually establish whether discovered aliases reveal otherwise inaccessible application structure.

Do not confuse filename disclosure with actual file access.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+1

## **5.4 WordPress**

[WordFence Review : Is this the best WordPress Security Plugin? - GalussoThemes](https://images.openai.com/static-rsc-4/psPzjkywmFPthSp3HxosfCQ6HRQlQZWEMgunhu1Ob9gMmZq8Q0DvK0fM1HDQsiSvNf34gn0KVMa1ra1QaMP-TRZzP9W-YWoQuaO5_WzdGV594S26_nhjWrl_b8YkLXVHyq_JD27Nr_WliI4fUq37EUsRNpYUl8Q7zvGANy_gou8?purpose=inline)

### **Enumerate**

```
wpscan \
  --url "https://$DOMAIN" \
  --api-token "$WPSCAN_API_TOKEN" \
  -e ap -e at -e u \
  --plugins-detection passive
```

### **Investigate**

| Component  | Hunting targets                      |
| ---------- | ------------------------------------ |
| Core       | Version-specific weaknesses          |
| Plugins    | Authorization and input validation   |
| Themes     | Stored XSS and unsafe templates      |
| REST API   | Exposed routes and permissions       |
| XML-RPC    | Authentication and pingback behavior |
| Uploads    | File validation and access control   |
| wp-admin   | Authorization inconsistencies        |
| wp-content | Backup and configuration exposure    |
| Multisite  | Tenant and site separation           |

### **XML-RPC**

Check whether:

```
/xmlrpc.php
```

is enabled and what functionality it exposes.

Potential research areas include:

- `system.listMethods`.
- `system.multicall`.
- `wp.getUsersBlogs`.
- Pingback handling.
- Request authentication.
- API-level access restrictions.

Lostsec discusses XML-RPC brute force, pingback abuse and DDoS. For bounty testing, restrict yourself to safe method discovery and a controlled callback test where explicitly allowed. Do not execute password spraying or denial-of-service testing.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+1

## **5.5 Exposed API keys**

Specialized 2026 methodology

Lostsec's May 2026 research focuses on exposed Google API keys, especially their potential access to Gemini and other Google services.

### **Discovery locations**

- JavaScript bundles.
- Source maps.
- Public repositories.
- HTML source.
- Configuration files.
- Archived JavaScript.
- Build artifacts.

### **Search locally collected source**

```
rg -n -i \
'AIza[0-9A-Za-z_-]{30,}|api[_-]?key|client_secret|AIza' \
"$OUT/js/"
```

### **Dedicated tool**

```
git clone https://github.com/coffinxp/Google-api-key-scanner.git
cd Google-api-key-scanner
pip install requests urllib3
```

```
python3 keyhunt.py -k YOUR_AUTHORIZED_TEST_KEY
```

The repository documents checks across 21 Google service endpoints.

### **What matters for a valid finding**

- Is the key genuinely exposed?
- Is it associated with the target?
- Are restrictions absent or insufficient?
- Can an unauthorized party use a protected service?
- Does it enable sensitive access or create demonstrable financial impact?

Do not generate billable content, upload files, or consume a target's service quota to demonstrate impact. API-key exposure alone does not establish critical severity.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+2

## **5.6 PDF.js and document processing**

Lostsec's PDF.js CVE-2024-4367 research is a useful specialized research path.

Investigate:

- PDF.js versions.
- Bundled copies of PDF.js.
- `pdfjs-dist`.
- React PDF wrappers.
- Document previewers.
- PDF conversion services.
- Electron-based PDF viewers.
- Whether untrusted PDFs reach vulnerable rendering code.

The key distinction is between identifying a vulnerable dependency and proving that the vulnerable code path is reachable.

For safe bounty validation, use a controlled test PDF and an application you are authorized to assess. Do not turn a browser-rendering issue into unauthorized access to a victim's account or machine.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+1

## **5.7 Next.js and React security**

Two important research themes in Lostsec's material:

| Research                | Vulnerability               |
| ----------------------- | --------------------------- |
| Next.js middleware      | CVE-2025-29927              |
| React Server Components | CVE-2025-55182, React2Shell |

### **Test methodology**

1. Fingerprint React and Next.js.
2. Identify application version.
3. Determine whether Server Components are used.
4. Map middleware-protected routes.
5. Compare middleware protection with direct backend authorization.
6. Review cache and prefetch behavior.
7. Validate using an authorized non-destructive test.

### **Available custom templates**

```
nuclei -l "$OUT/recon/alive.txt" \
  -t ~/coffinxp/nuclei-templates/CVE-2025-29927.yaml \
  -rl 2 -c 2
```

```
nuclei -l "$OUT/recon/alive.txt" \
  -t ~/coffinxp/nuclei-templates/next-js.yaml \
  -rl 2 -c 2
```

A vulnerable version is not sufficient proof. Demonstrate that the intended authorization boundary actually fails.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+2

# **6. Authentication and session management**

High-impact hunting category

Lostsec's December 2025 article specifically covers session management vulnerabilities.

The central test is whether an application consistently recognizes authentication state and invalidates old credentials when security-sensitive events occur.

## **6.1 Session invalidation**

Use two browsers with accounts you own.

[Basic Web Security Testing - Sessions | by Team Merlin | Government Digital Products, Singapore | Medium](https://images.openai.com/static-rsc-4/oQdkvfIfL-03lTFD6Qjp6a8-ufh7YZckCpJbnjD3hnNpQPM2-rJzdgkR9ySXOi4Duu0Eoc2B4Nwa37IBnW8j133ZSnnYcYJMoRJgSNV4qq5MADMqaDXMnFQ27KTnbIjHqmaWYESwWg47rGaNUilasQJHj3BoIh-HBODu4f9NOEE?purpose=inline)

| Test               | Expected secure behavior                     |
| ------------------ | -------------------------------------------- |
| Change password    | Old sessions invalidated according to policy |
| Reset password     | Previously issued reset token unusable       |
| Logout             | Session no longer accepted                   |
| Logout all devices | Other sessions revoked                       |
| Change email       | Reauthentication or verification enforced    |
| Enable MFA         | MFA enforced on subsequent authentication    |
| Disable MFA        | Strong verification required                 |
| Change role        | Old authorization state updated              |
| Refresh token      | Rotation and revocation enforced             |
| Delete account     | Associated sessions revoked                  |

### **Practical procedure**

1. Log into Account A in Browser 1.
2. Log into the same account in Browser 2.
3. Change the password in Browser 1.
4. Replay the previous session in Browser 2.
5. Check whether protected functionality remains available.
6. Record the exact endpoint and response.
7. Repeat with logout, reset and revocation.

A session remaining active is not automatically a vulnerability in every product; evaluate the intended session policy and security impact.

## **6.2 JWT testing**

Investigate:

- Algorithm handling.
- Signature verification.
- Issuer validation.
- Audience validation.
- Expiration.
- Not-before.
- Key selection.
- Token revocation.
- Refresh-token rotation.
- Role and permission claims.

Never assume that a decoded JWT is a valid or forgeable token.

Use your own token and verify whether unauthorized claim changes are rejected.

## **6.3 OAuth and SSO**

Test:

- Redirect URI validation.
- State parameter handling.
- PKCE enforcement.
- Account linking.
- Identity-provider mismatch.
- Email verification assumptions.
- Token audience and issuer.
- SAML assertion validation.
- Session establishment.
- Logout consistency.

## **6.4 MFA and recovery**

Look for inconsistent enforcement between:

- Web login.
- Mobile login.
- Password reset.
- API authentication.
- SSO login.
- Account recovery.
- Email-change flows.
- Backup-code use.

## **6.5 Rate limiting**

Check whether controls are consistently enforced on login, reset and verification workflows.

Use a small number of requests and your own account. Do not perform brute-force attacks.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups

# **7. Mass assignment and invisible privileges**

Particularly valuable API research

Lostsec's November 2025 article focuses on hidden JSON fields in registration flows.

The idea is straightforward: an application may accept fields that the frontend never exposes.

Example normal request:

```
POST /api/register
Content-Type: application/json

{
  "email": "researcher@example.com",
  "password": "ExamplePassword123"
}
```

Fields worth investigating in your own test account:

```
{
  "role": "user",
  "isAdmin": false,
  "verified": false,
  "plan": "free",
  "permissions": [],
  "tenantId": "YOUR_TEST_TENANT",
  "ownerId": "YOUR_TEST_ACCOUNT"
}
```

### **Methodology**

1. Capture the registration request.
2. Review the response schema.
3. Compare frontend fields against backend accepted fields.
4. Introduce one additional field at a time.
5. Observe whether the backend accepts or rejects it.
6. Re-fetch your own account.
7. Compare actual server-side privileges.
8. Confirm whether the change affects protected functionality.

### **High-value endpoints**

- `/api/register`
- `/api/users`
- `/api/profile`
- `/api/account`
- `/api/organizations`
- `/api/invitations`
- `/api/members`
- `/api/settings`
- `/api/subscriptions`

### **Important distinction**

An accepted field is not proof of a vulnerability.

A meaningful finding requires an unauthorized change to a security-sensitive property and a demonstrable impact.

[image](https://www.google.com/s2/favicons?domain=https://lostsec.medium.com\&sz=32)

Medium

# **8. The 5-minute workflow and LostFuzzer**

This is the part of Lostsec's approach that combines automation with fast target understanding.

[A Real-World Recon Workflow — One Command, Clean Results | by ghostyjoe | Bug Bounty Hunting: A Comprehensive Guide in English and french | Feb, 2026 | Medium](https://images.openai.com/static-rsc-4/ftiXUkB9RJ4lqp4cFZA64KxxhibQFpEppkYbkuXqLX4AqCWaAhpcjfOyIB4di7Ne88TtRdhjSdkibuTqN-MdVlCqBl1QD52l8G_D7gG5f6EzGJs4B5va5UfZSZaPqqBgf0JZi049ZARoiV5sONuPtn5zXZfZtnO_PSxOwAQwmRc?purpose=inline)

## **8.1 Shodan + CVE discovery**

Method:

1. Select a technology or recently disclosed CVE.
2. Search Shodan for matching fingerprints.
3. Examine certificate and product information.
4. Identify potentially relevant assets.
5. Check program scope.
6. Validate affected versions.
7. Use a suitable detection template.

Do not mass-test arbitrary Shodan results.

## **8.2 AlienVault OTX**

The original workflow uses a custom script:

```
./alienvault.sh "$DOMAIN"
```

Use it to expand historical URL discovery, then feed results into GF.

## **8.3 URLScan**

```
python3 urlscan.py -d "$DOMAIN" --mode urls
```

```
python3 urlscan.py -d "$DOMAIN" --mode subdomains
```

## **8.4 VirusTotal**

```
./virustotal.sh "$DOMAIN"
```

Investigate historical public observations for:

- Exposed API references.
- Old JavaScript.
- Configuration artifacts.
- Sensitive URL references.
- Historical endpoints.

Do not attempt to use discovered passwords, tokens or reset links to access accounts.

## **8.5 GF filtering**

```
cat all_urls.txt | gf xss | uro
```

```
cat all_urls.txt | gf sqli | uro
```

```
cat all_urls.txt | gf idor | uro
```

```
cat all_urls.txt | gf ssrf | uro
```

```
cat all_urls.txt | gf redirect | uro
```

## **8.6 LostFuzzer**

```
git clone https://github.com/coffinxp/lostfuzzer.git
cd lostfuzzer
chmod +x lostfuzzer.sh
./lostfuzzer.sh
```

Its documented workflow is:

**GAU — Passive URLs**

**Valid parameter filtering — URO**

**HTTPX — Live URL verification**

**Nuclei — DAST**

**filtered_urls.txt**

Manual hunting queue

**nuclei_results.txt**

Scanner findings to validate

The important innovation is preserving valid query structures rather than generating malformed multi-parameter FUZZ URLs.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+2

# **9. How to compete against established bug bounty researchers**

This is where I would take the collected methodology further.

Lostsec provides a strong discovery and automation foundation. To compete against experienced researchers, use that foundation to identify security boundaries that scanners cannot understand.

## **9.1 Fresh asset advantage**

Instead of repeatedly scanning the same popular endpoints:

1. Monitor CT logs.
2. Detect new subdomains.
3. Compare newly discovered hosts against previous inventory.
4. Identify new technologies.
5. Discover new endpoints.
6. Investigate newly deployed functionality.
7. Prioritize assets with little historical coverage.

The advantage is finding new functionality before it becomes common knowledge.

## **9.2 Feature-first hunting**

Do not organize your entire hunt around vulnerability names.

Organize it around application features.

| Feature             | What to investigate                            |
| ------------------- | ---------------------------------------------- |
| Registration        | Mass assignment, account creation              |
| Invitations         | Cross-tenant access, privilege assignment      |
| Billing             | Price manipulation, subscription authorization |
| File uploads        | Storage, parsing, access controls              |
| Exports             | Unauthorized report downloads                  |
| Webhooks            | SSRF, secret exposure                          |
| Integrations        | Token scope and permissions                    |
| SSO                 | Authentication and identity mapping            |
| Admin panels        | Function-level authorization                   |
| API keys            | Restrictions and service capabilities          |
| Search              | SQLi, information disclosure                   |
| Notifications       | Stored XSS, cross-user data                    |
| Imports             | SSRF, path handling                            |
| AI features         | Prompt injection, tool authorization           |
| Document conversion | SSRF, parser vulnerabilities                   |

## **9.3 Cross-identity testing**

Create two or three accounts you control.

## **Identity differential matrix**

**Account A**

Owner

**Account B**

Restricted

**Anonymous**

No session

**Compare the same operation**

- GET resource
- POST resource
- PATCH resource
- DELETE resource
- Export resource
- Change resource permissions
- Retrieve asynchronous job results

  Use only test-owned resources and permitted accounts.

Look for:

- Anonymous access to protected operations.
- Restricted accounts performing owner-only operations.
- Different enforcement across API versions.
- Different enforcement across mobile and web.
- Inconsistent REST and GraphQL permissions.
- Backend authorization missing despite frontend restrictions.

## **9.4 Cross-interface endpoint hunting**

An endpoint discovered in JavaScript may have a different authorization policy when accessed through another interface.

Map the same business operation across:

```
Web application
       |
       +---- REST API
       |
       +---- GraphQL
       |
       +---- RPC
       |
       +---- Mobile API
       |
       +---- Background job
       |
       +---- Export/download service
```

Compare authentication, permission requirements, response fields and object ownership.

## **9.5 Historical endpoint resurrection**

Combine three Lostsec techniques:

- Wayback historical URLs.
- JavaScript endpoint extraction.
- Passive URL discovery.

Then compare old endpoints with current functionality.

Look for:

- Removed frontend functionality with an active backend route.
- Deprecated API versions.
- Old administrative operations.
- Forgotten export endpoints.
- Unlinked file handlers.
- Legacy authentication routes.
- Old parameters that remain accepted.

An endpoint returning 404 is not a finding. Investigate whether an alternate authorized route or application version still exposes the underlying operation.

## **9.6 Edge-case testing matrix**

| Layer              | Variations                           |
| ------------------ | ------------------------------------ |
| HTTP method        | GET, POST, PUT, PATCH, DELETE        |
| Content type       | JSON, form, multipart                |
| Parameter handling | Duplicate, missing, null, empty      |
| Encoding           | URL encoding, Unicode, case          |
| Authentication     | Anonymous, restricted, owner         |
| Session            | Old, expired, revoked                |
| API version        | Legacy, current                      |
| Routing            | Trailing slash, normalization        |
| Headers            | Host, Origin, forwarded headers      |
| State              | Created, pending, completed, deleted |
| Cache              | Authenticated versus anonymous       |
| Files              | Upload, preview, download, export    |

Change one variable at a time and record the response difference.

## **9.7 AI-assisted research**

Lostsec's August 2026 Claude Code material covers:

- Custom skills.
- MCP servers.
- Burp integration.
- Security research agents.
- Automated workflows.
- Recon and HTTP analysis.

The useful model is:

```
Recon Agent
    |
    v
Endpoint Mapper
    |
    v
Technology Analyst
    |
    v
Vulnerability Hypothesis Agent
    |
    v
Manual Validation
    |
    v
Evidence Collection
    |
    v
Report Generation
```

AI should generate hypotheses and organize evidence. It should not decide that a vulnerability exists based solely on a scanner result.

[image](https://www.google.com/s2/favicons?domain=https://infosecwriteups.com\&sz=32)

InfoSec Write-ups+1

# **10. Consolidated Lostsec-style one-liner collection**

These are the commands worth keeping together in your operator cheatsheet. They combine published workflows with scope-conscious operational adaptations.

## **Recon**

```
subfinder -d "$DOMAIN" -all -recursive -silent | tee subs.txt
```

```
assetfinder --subs-only "$DOMAIN" | sort -u
```

```
amass enum -passive -d "$DOMAIN" -o amass.txt
```

```
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' | sort -u
```

```
cat subs.txt | dnsx -silent | tee resolved.txt
```

```
cat resolved.txt | httpx-toolkit -sc -title -td -silent | tee alive.txt
```

```
naabu -list resolved.txt -top-ports 1000 -rate 50 -o ports.txt
```

```
cat alive.txt | aquatone -ports 80,443,8080,8443
```

## **URL collection**

```
cat alive.txt | gau | uro | sort -u | tee urls.txt
```

```
waybackurls "$DOMAIN" | sort -u | tee wayback.txt
```

```
katana -u "https://$DOMAIN" -d 3 -jc -kf -rl 5 -silent -o katana.txt
```

```
cat urls.txt katana.txt wayback.txt | sort -u > allurls.txt
```

## **GF filtering**

```
cat allurls.txt | gf xss | uro > xss.txt
```

```
cat allurls.txt | gf sqli | uro > sqli.txt
```

```
cat allurls.txt | gf ssrf | uro > ssrf.txt
```

```
cat allurls.txt | gf lfi | uro > lfi.txt
```

```
cat allurls.txt | gf redirect | uro > redirect.txt
```

```
cat allurls.txt | gf idor | uro > idor.txt
```

## **JavaScript**

```
cat allurls.txt | grep -Ei '\.js([?#]|$)' | uro > js.txt
```

```
cat js.txt | httpx-toolkit -mc 200 -silent -content-type | tee js-live.txt
```

```
cat js.txt | nuclei -t ~/coffinxp/nuclei-templates/credentials-disclosure-all.yaml -rl 5
```

```
rg -n -i 'api_key|apikey|secret|token|password|authorization|client_secret' ./js/
```

```
cat js.txt | xargs -I@ -P5 python3 SecretFinder.py -i @ -o cli
```

## **XSS**

```
echo "$DOMAIN" | gau | gf xss | uro | Gxss -p Rxss | kxss | tee xss.txt
```

```
cat xss.txt | dalfox pipe --silence
```

```
cat allurls.txt | grep -Ei 'search|comment|profile|message|name' | uro
```

## **SQL injection**

```
cat allurls.txt | gf sqli | uro | tee sqli-candidates.txt
```

```
python3 loxs.py
```

```
sqlmap -r request.txt --batch --risk=1 --level=1 --technique=BEU --threads=1 --delay=1
```

## **SSRF**

```
cat allurls.txt | gf ssrf | uro | tee ssrf-candidates.txt
```

```
cat ssrf-candidates.txt | qsreplace "https://YOUR-CONTROLLED-OAST-DOMAIN/test" | tee ssrf-probes.txt
```

## **LFI**

```
cat allurls.txt | gf lfi | uro | tee lfi-candidates.txt
```

```
cat lfi-candidates.txt | nuclei -tags lfi -rl 3
```

## **CORS**

```
curl -sS -D- -o /dev/null -H "Origin: https://attacker.invalid" "https://$DOMAIN/"
```

## **CRLF**

```
curl -skD- --path-as-is "https://$DOMAIN/%0d%0aX-Test%3A%20probe"
```

## **Open redirect**

```
cat allurls.txt | gf redirect | uro | tee redirect-candidates.txt
```

## **Subdomain takeover**

```
subzy run --targets subs.txt --concurrency 5 --hide_fails --verify_ssl
```

## **WordPress**

```
wpscan --url "https://$DOMAIN" --api-token "$WPSCAN_API_TOKEN" -e ap -e at -e u
```

## **Nuclei**

```
nuclei -l alive.txt -t ~/coffinxp/nuclei-templates/ -rl 5 -c 5 -exclude-tags dos,fuzz -o nuclei.txt
```

## **CT monitoring**

```
crtmon -target "$DOMAIN" -notify both
```

## **LostFuzzer**

```
git clone https://github.com/coffinxp/lostfuzzer.git && cd lostfuzzer && chmod +x lostfuzzer.sh && ./lostfuzzer.sh
```

**Operational correction:** The original published commands use different HTTPX variants and some older flag names. Check `-h` for your installed version. For current ProjectDiscovery HTTPX, `-td` is the technology-detection option. Never assume that a historical command works unchanged with a newer release.

# **11. Platform-specific operating rules**

The same methodology can be used across all three platforms, but the individual program's rules determine what you can test.

| Platform  | What to check before hunting                                             |
| --------- | ------------------------------------------------------------------------ |
| HackerOne | Security page, asset scope, exclusions, disclosure rules, safe harbor    |
| Bugcrowd  | Bounty Brief, target eligibility, testing restrictions, disclosure rules |
| Intigriti | Program scope, testing requirements, automation rate limits, safe harbor |

Official references:

- [HackerOne Vulnerability Disclosure Guidelines](https://www.hackerone.com/terms/disclosure-guidelines?utm_source=chatgpt.com)
- [HackerOne Code of Conduct](https://www.hackerone.com/policies/code-of-conduct?utm_source=chatgpt.com)
- [Bugcrowd Code of Conduct](https://www.bugcrowd.com/resources/hacker-resources/code-of-conduct/?utm_source=chatgpt.com)
- [Intigriti Program Details](https://kb.intigriti.com/en/articles/6899431-program-details?utm_source=chatgpt.com)

Three important requirements:

1. Stop testing when you encounter unrelated sensitive customer information.
2. Do not conduct DoS, destructive exploitation or uncontrolled credential testing.
3. Submit reproducible findings with demonstrated impact, not scanner screenshots alone.

[image](https://www.google.com/s2/favicons?domain=https://www.hackerone.com\&sz=32)

HackerOne+3

# **12. Final hunting and reporting checklist**

**Hunting progress**

# **0%**

0 / 41 completed

**1. Reconnaissance**

0/10 completed

Program scope verified

Subdomains enumerated

CT logs checked

DNS and infrastructure mapped

Live hosts fingerprinted

Ports checked where permitted

Historical URLs collected

Active crawling completed

JavaScript collected

Endpoints classified

**2. Vulnerability testing**

0/14 completed

XSS candidates reviewed

SQLi candidates reviewed

SSRF candidates reviewed

LFI and traversal candidates reviewed

CORS tested

Open redirects tested

CRLF investigated

WordPress components reviewed

IIS and legacy routes investigated

API keys and secrets reviewed

Authentication and sessions tested

Mass assignment tested

Cross-identity authorization compared

Relevant CVEs checked

**3. Validation**

0/8 completed

False positives eliminated

Vulnerable behavior reproduced

Test accounts used

Security boundary identified

Impact demonstrated

Scope reconfirmed

Evidence saved

Duplicate research performed

**4. Submission**

0/9 completed

Clear vulnerability title

Affected asset and endpoint

Prerequisites documented

Exact reproduction steps

Request and response evidence

Impact explained

Minimal proof of concept

Remediation recommendation

No unrelated sensitive data included

Reset checklist

# **13. Primary research library**

These are the resources worth keeping bookmarked alongside the playbook.

| Resource           | Link                                                                                      |
| ------------------ | ----------------------------------------------------------------------------------------- |
| Lostsec Medium     | [Articles](https://lostsec.medium.com/?utm_source=chatgpt.com)                            |
| Lostsec X          | [Posts](https://x.com/lostsec_?utm_source=chatgpt.com)                                    |
| Lostsec YouTube    | [Videos](https://www.youtube.com/@lostsec_ftw?utm_source=chatgpt.com)                     |
| GitHub             | [Repositories](https://github.com/coffinxp?utm_source=chatgpt.com)                        |
| LOXS               | [Scanner](https://github.com/coffinxp/loxs?utm_source=chatgpt.com)                        |
| Payloads           | [Wordlists](https://github.com/coffinxp/payloads?utm_source=chatgpt.com)                  |
| GF patterns        | [Patterns](https://github.com/coffinxp/GFpattren?utm_source=chatgpt.com)                  |
| Nuclei             | [Templates](https://github.com/coffinxp/nuclei-templates?utm_source=chatgpt.com)          |
| LostFuzzer         | [DAST](https://github.com/coffinxp/lostfuzzer?utm_source=chatgpt.com)                     |
| CRTMon             | [Monitoring](https://github.com/coffinxp/crtmon?utm_source=chatgpt.com)                   |
| PDF exploits       | [Research](https://github.com/coffinxp/pdFExploits?utm_source=chatgpt.com)                |
| Google key scanner | [API research](https://github.com/coffinxp/Google-api-key-scanner?utm_source=chatgpt.com) |

**Research coverage qualification:** This is a consolidated playbook from the publicly indexed Lostsec material and associated repositories identified in this research. It is not an independently verified transcript of every X post or every YouTube video; some video transcripts and member-only article sections were not publicly indexed. Commands and methods are attributed only where the available sources support that attribution.

**Core takeaway:** Recon discovers the attack surface. GF and fuzzing narrow the possibilities. JavaScript reveals hidden functionality. Authentication and authorization testing reveal security-boundary failures. Manual validation turns those observations into reportable vulnerabilities.
