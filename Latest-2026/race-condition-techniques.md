# Race Condition Techniques

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
