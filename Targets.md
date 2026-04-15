# Bug Bounty Program Index

Live feeds of public scopes from the major platforms. Source of truth is
[arkadiyt/bounty-targets-data](https://github.com/arkadiyt/bounty-targets-data)
— refreshed every 30 minutes. Mirror locally with:

```bash
git clone --depth 1 https://github.com/arkadiyt/bounty-targets-data ~/bounty-targets-data
cd ~/bounty-targets-data && git pull
```

## Raw feeds

| File | What it is |
|---|---|
| [domains.txt](https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/domains.txt) | flat list of in-scope domains (no wildcards) |
| [wildcards.txt](https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/wildcards.txt) | wildcard scopes — always re-check per-program out-of-scope |
| [hackerone_data.json](https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/hackerone_data.json) | HackerOne programs + targets + response metrics |
| [bugcrowd_data.json](https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/bugcrowd_data.json) | Bugcrowd programs + scope + max payout |
| [intigriti_data.json](https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/intigriti_data.json) | Intigriti programs + min/max bounty |
| [yeswehack_data.json](https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/yeswehack_data.json) | YesWeHack programs |
| [federacy_data.json](https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/federacy_data.json) | Federacy programs |

## Platform search / discovery

- HackerOne directory — <https://hackerone.com/directory/programs?asset_type=URL>
- Bugcrowd programs — <https://bugcrowd.com/engagements>
- Intigriti programs — <https://app.intigriti.com/programs>
- YesWeHack programs — <https://yeswehack.com/programs>
- Hackenproof — <https://hackenproof.com/programs>
- Federacy — <https://www.federacy.com/programs>
- Open Bug Bounty — <https://www.openbugbounty.org/>
- Immunefi (web3) — <https://immunefi.com/explore/>
- Code4rena (web3) — <https://code4rena.com/audits>

## Aggregators / dashboards

- BBRadar — <https://bbradar.io/>
- Firebounty — <https://firebounty.com/>
- Disclose.io — <https://disclose.io/>
- Chaos (subdomains by program) — <https://chaos.projectdiscovery.io/>

## VDPs & government

- CISA VDP platform — <https://vdp-platform.cisa.gov/>
- /dev/null (HackerOne) gov list — <https://hackerone.com/directory/programs?government_only=true>

## Scope intake — one-shot pulls

```bash
# fresh domains only
curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/domains.txt > domains.txt

# wildcards for subdomain enum
curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/wildcards.txt > wildcards.txt

# grep HackerOne programs that pay bounties
jq -r '.[] | select(.offers_bounties==true) | "\(.handle)\t\(.name)"' \
  hackerone_data.json | sort

# Bugcrowd programs with max_payout >= 5000
jq -r '.[] | select(.max_payout>=5000) | "\(.max_payout)\t\(.name)\t\(.url)"' \
  bugcrowd_data.json | sort -rn

# Intigriti programs with min bounty >= 500 USD
jq -r '.[] | select(.min_bounty.value>=500 and .min_bounty.currency=="USD")
  | "\(.min_bounty.value)-\(.max_bounty.value)\t\(.name)\t\(.url)"' \
  intigriti_data.json | sort -rn
```

## Notes

- Wildcards do **not** imply every subdomain is in-scope. Always read the
  exclusions in the program policy before submitting or even aggressively
  scanning.
- `offers_bounties=false` on HackerOne means VDP — still worth a report for
  reputation, but no payout.
- Managed programs respond faster; unmanaged can sit for months.
