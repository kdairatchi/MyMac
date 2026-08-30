# Race Condition Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: — · Items: 0_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

_No CVE-assigned items yet. Items below are pre-CVE or class-level findings._

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

_No PoCs in items yet._

---

## Reproduction

_Step-by-step repro steps per CVE. Populated as items arrive with enough detail._
_pending enrichment_

---

## Defense

_Patch guidance and detection rules. Populated from vendor advisories._
_pending enrichment_

---

## References

_Populated by daily refresh-latest pipeline._

---

## Items

> Race conditions — exploiting concurrency windows to perform actions out of intended sequence, enabling double-spending, privilege escalation, or bypassing rate limits.

## Surface

- Balance/credit operations: withdraw, transfer, coupon redemption, gift card use
- Rate-limited features: login attempts, password reset, OTP verification
- One-time-use tokens: invite links, promo codes, file download tokens
- File operations: upload → virus scan → move (TOCTOU)
- Account state changes: role assignment, account activation, plan upgrades
- WebSocket message handlers — concurrent message processing without locks
- Database operations using read-then-write without atomic transactions

## Test Approach

1. **Identify target operations** — look for: "use once", "per-user limit", "balance check", "consume token"

2. **Single-packet attack** (HTTP/2) — all requests arrive at server simultaneously in one TCP packet, collapses the race window:
   - Use Turbo Intruder's `single-packet-attack` template
   - HTTP/2 required: `SETTINGS_MAX_CONCURRENT_STREAMS` allows multiple streams

3. **Last-byte sync** (HTTP/1.1) — send all but last byte, then fire all final bytes simultaneously:

   ```python
   # turbo-intruder script
   def queueRequests(target, wordlists):
       engine = RequestEngine(endpoint=target.endpoint,
           concurrentConnections=30, requestsPerConnection=1,
           pipeline=False)
       for i in range(30):
           engine.queue(target.req, gate='race1')
       engine.openGate('race1')
   ```

4. **Confirm with timing analysis** — look for any 200s among mostly 400/429s; even 1-2 successes in 30 concurrent attempts confirms race

5. **TOCTOU file operations** — upload file, race the virus scan window:

   ```
   # Upload malicious file, concurrently replace with clean one during scan
   # Then access the stored malicious version
   ```

6. **WebSocket race** — use Turbo Intruder with WebSocket support to send concurrent messages:
   - Maintains persistent WS connection
   - Send identical action messages at high throughput
   - Look for duplicate processing, double-credit, double-vote

7. **Limit override** — probe rate-limited endpoints (OTP, 2FA) with 20-50 concurrent requests before lockout triggers

## Tools

- **Turbo Intruder** (Burp) — single-packet attack, gate-based concurrent send
- **turbo-intruder WebSocket module** — concurrent WebSocket frame sending
- **ffuf** with `-c` concurrency — less precise but catches obvious race windows
- **custom Go/Python scripts** — goroutine/asyncio for microsecond-precision concurrency

## Payloads / Probes

```python
# Turbo Intruder - single packet attack
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
        concurrentConnections=1,
        engine=Engine.BURP2)
    for i in range(20):
        engine.queue(target.req, gate='race1')
    engine.openGate('race1')

def handleResponse(req, interesting):
    if '200' in req.status:
        table.add(req)
```

```http
# Target: coupon redemption (send 20 simultaneously)
POST /api/redeem HTTP/2
Host: target.com
Cookie: session=<token>
Content-Type: application/json

{"coupon": "FIRST50OFF"}
```

```
# Rate limit bypass - concurrent OTP attempts
# 30x concurrent POST /verify-otp with different codes
# window before lockout = 1 valid window
```

## Last-byte sync (HTTP/1.1)

When the target doesn't support HTTP/2:

1. Send all but the last byte of N requests (withhold final byte).
2. Send the last byte of all N requests back-to-back in rapid succession.
3. Server processes the queued requests nearly simultaneously.

Turbo Intruder `engine=Engine.THREADED` + `pipeline=True` implements this.

## Multi-endpoint chain races

Race two different endpoints that share state:

```
POST /transfer  +  POST /close-account   → transfer-then-close races
POST /email/verify  +  POST /email/change
POST /apply-coupon  +  POST /remove-coupon
```

Use `engine.queue(req1)` + `engine.queue(req2)` in the same gate to fire them simultaneously.

## Code pattern: what to look for

Bad — read-modify-write with no atomic check:

```python
if not user.has_claimed_bonus:
    give_bonus(user)
    user.has_claimed_bonus = True   # race window here
```

Good — atomic database update:

```sql
UPDATE users SET has_claimed_bonus = TRUE
WHERE id = $1 AND has_claimed_bonus = FALSE RETURNING id;
-- App checks if any row was returned
```

Or `SELECT ... FOR UPDATE` inside a transaction.

## Chain Opportunities

- **Race → double-spend** — apply coupon twice, transfer same balance twice
- **Race → privilege escalation** — role assignment race between read and write
- **Race → IDOR** — concurrent access to being-deleted resource before auth check clears
- **Race + TOCTOU → RCE** — race file replace during virus scan, execute malicious file
- **Race → account limit bypass** — create more resources than subscription allows

## Recent Intel

- **WebSocket Turbo Intruder** · WebSocket frames evade standard scanners; Turbo Intruder maintains persistent WS connection for concurrent race testing; also tests handshake for desync/cache poisoning · https://portswigger.net/research/websocket-turbo-intruder-unearthing-the-websocket-goldmine
- **Single-packet attack (PortSwigger 2023)** · HTTP/2 multiplexing eliminates network jitter, enabling reliable sub-millisecond race exploitation — collapsed the race window for Limit Overrun attacks previously dismissed as unexploitable
- **Parallels race (HackerOne 2024)** · Concurrent subscription API calls allowed 20x plan feature creation; read-modify-write without atomic transaction is the pattern — look in billing/plan management APIs


## 2026-04-19 — H1 disclosures

### Data race in Curl_dnscache_add_negative() corrupts shared DNS cache — heap corruption and double-free when using CURLOPT_SHARE with CURL_LOCK_DATA_DNS

- **2026-04-04** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3645361](https://hackerone.com/reports/3645361) · Reporter: [@intrax](https://hackerone.com/intrax) · Team: [curl](https://hackerone.com/curl)
- CWE: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition')

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---


## 2026-05-27 — H1 disclosures

### Memory Corruption via TOCTOU Race in SharedArrayBuffer UTF-8 Decode (`StringBytes::Encode`)

- **2026-05-23** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3752489](https://hackerone.com/reports/3752489) · Reporter: [@v1ct0rv0nd00m](https://hackerone.com/v1ct0rv0nd00m) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Time-of-check Time-of-use (TOCTOU) Race Condition

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### curl --skip-existing has a TOCTOU race that lets a post-check symlink redirect the later download write

- **2026-05-20** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3747959](https://hackerone.com/reports/3747959) · Reporter: [@sdjasj](https://hackerone.com/sdjasj) · Team: [curl](https://hackerone.com/curl)
- CWE: Time-of-check Time-of-use (TOCTOU) Race Condition

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---


## 2026-07-01 — H1 disclosures

### HTTP Response Queue Poisoning via TOCTOU Race Condition in `http.Agent`

- **2026-06-25** · sev: Low · bounty: undisclosed · cve: CVE-2026-48931
- Source: [hackerone.com/3582376](https://hackerone.com/reports/3582376) · Reporter: [@yushengchen](https://hackerone.com/yushengchen) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Time-of-check Time-of-use (TOCTOU) Race Condition

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-48931` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-48931.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---


## 2026-08-30 — H1 disclosures

### node:sqlite SQLTagStore Iterator Replay Lets Attacker Re-Execute Victim-Bound Writes Indefinitely

- **2026-08-28** · sev: Medium · bounty: undisclosed · cve: CVE-2026-58041
- Source: [hackerone.com/3795900](https://hackerone.com/reports/3795900) · Reporter: [@cantina-security](https://hackerone.com/cantina-security) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Time-of-check Time-of-use (TOCTOU) Race Condition

**What**

A flaw was discovered in the node:sqlite package for Node.js that allowed a stale StatementSyncIterator created through DatabaseSync#createTagStore() to continue executing a cached prepared statement after it had been reset and rebound with new parameters. The vulnerability was caused by the SQLTagStore feature resetting cached statements using sqlite3_reset() directly, bypassing the iterator invalidation mechanism introduced in recent releases. This issue affected Node.js versions 22.x, 24.x, and 26.x.

**PoC refs:** search `github.com/search?q=CVE-2026-58041` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-58041.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

###  curl_share TOCTOU > RCE via Curl_llist _dtor Function Pointer Hijack

- **2026-08-26** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3955945](https://hackerone.com/reports/3955945) · Reporter: [@k4rasu_s4ma](https://hackerone.com/k4rasu_s4ma) · Team: [curl](https://hackerone.com/curl)
- CWE: Time-of-check Time-of-use (TOCTOU) Race Condition

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### libcurl cache updates follow symlinks and truncate their targets

- **2026-08-14** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3938220](https://hackerone.com/reports/3938220) · Reporter: [@mr4bugs](https://hackerone.com/mr4bugs) · Team: [curl](https://hackerone.com/curl)
- CWE: Time-of-check Time-of-use (TOCTOU) Race Condition

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---
