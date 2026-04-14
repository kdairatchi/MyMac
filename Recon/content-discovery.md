# Content Discovery

Directories, files, parameters. Right wordlist beats raw threads.

## Wordlists to keep handy

- `SecLists/Discovery/Web-Content/raft-large-{directories,files,words}.txt`
- `SecLists/Discovery/Web-Content/big.txt`
- `SecLists/Discovery/Web-Content/quickhits.txt`
- `SecLists/Fuzzing/LFI/LFI-Jhaddix.txt`
- `assetnote/wordlists` — technology-specific (cdx, bodhi, kiterunner).
- Custom: feed your own via `gau` / `katana` → extract paths → sort -u.

## ffuf (fast baseline)

```bash
ffuf -u https://target.com/FUZZ \
  -w raft-large-directories.txt \
  -mc 200,204,301,302,307,401,403 \
  -fc 404 \
  -recursion -recursion-depth 2 \
  -t 50 -rate 100 \
  -H "X-Bug-Bounty: kdairatchi" \
  -o ffuf.json -of json

# Filter size to hide soft-404 pages
ffuf -u https://target.com/FUZZ -w big.txt -fs 1234
```

## feroxbuster (recursive + auto-calibrate)

```bash
feroxbuster -u https://target.com \
  -w raft-large-words.txt \
  -x php,asp,aspx,js,json,bak,old,zip,sql \
  -t 50 -d 3 \
  --auto-tune \
  --scan-limit 10
```

## katana (crawl + JS-aware)

```bash
katana -u https://target.com \
  -d 5 -jc -kf all \
  -c 15 -rl 100 \
  -o katana.txt

# Headless for JS-rendered apps
katana -u https://target.com -headless -js-crawl -d 3 -o katana-hl.txt
```

## Parameter discovery

```bash
# arjun — active param mining
arjun -u https://target.com/api/endpoint -m GET,POST

# x8 — fast unguessable param brute
x8 -u https://target.com/page -w params.txt

# Harvest from historical URLs
gau --subs target.com | unfurl keys | sort -u > seen-params.txt
```

## API endpoint brute

```bash
# kiterunner — HTTP API-aware, uses method + body
kr scan https://target.com -w routes-large.kite -x 10 --ignore-length 1234
```

## Backup / archive fuzzing

```bash
# Try .bak .old .swp .~ variations of known paths
ffuf -u https://target.com/FUZZONE.FUZZTWO \
  -w known-paths.txt:FUZZONE \
  -w <(echo "bak\nold\nswp\n~\ntmp\nzip\ntar.gz") :FUZZTWO \
  -mc 200
```

## Output flow

- 200/301 → visit + feed to katana
- 401/403 → try `403 bypass` (Cheatsheets, header tricks, path normalization)
- `.git/`, `.env`, `.DS_Store`, `backup.zip`, `.sql`, `.swp` → immediate report
- `/debug/`, `/.well-known/`, `/actuator/`, `/swagger/` → dedicated playbooks

## References

- SecLists — https://github.com/danielmiessler/SecLists
- Assetnote wordlists — https://wordlists.assetnote.io
- ffuf — https://github.com/ffuf/ffuf
- feroxbuster — https://github.com/epi052/feroxbuster
- kiterunner — https://github.com/assetnote/kiterunner
