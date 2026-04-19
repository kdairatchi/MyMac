# IDOR Techniques

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

> Insecure Direct Object Reference — when a server exposes internal object identifiers that can be substituted to access data belonging to other users or objects.

## Surface

- Sequential integer IDs in URL paths: `/api/invoices/1042`, `/users/profile/5519`
- GUIDs or UUIDs in request bodies or query params: `{"orderId": "3fa85f64-..."}`
- Indirect references in API params: `?report=monthly_summary` mapping to a file path
- Numeric IDs in cookies or JWT claims: `{"sub": "44821"}`
- Batch/export endpoints: `/export?ids[]=1&ids[]=2`
- Predictable filenames in download endpoints: `/downloads/invoice_2024_1042.pdf`

## Test Approach

1. **Map all object identifiers** — spider the app, note every param that looks like a reference to a server-side object
2. **Create two accounts** (A and B), record B's object IDs, attempt access from A's session
3. **Test horizontal then vertical** — same privilege level first, then escalate (user → admin object IDs)
4. **Try GUID enumeration** — check if GUIDs are UUIDv1 (time-based, enumerable) with `python3 -c "import uuid; print([str(uuid.uuid1()) for _ in range(5)])"`
5. **Check indirect refs** — fuzz string-based params with known filenames (`/etc/passwd`, `../config`, peer usernames)
6. **Automate ID sweeps** with ffuf:

   ```
   ffuf -u https://target.com/api/users/FUZZ/profile \
     -w /usr/share/seclists/Fuzzing/4-digits-0000-9999.txt \
     -H "Cookie: session=<your_token>" \
     -mc 200 -t 50
   ```

7. **Confirm with Autorize** — Burp extension that auto-replays every request under a lower-privileged session; flag 200s where you'd expect 403s

## Tools

- **Autorize** (Burp) — replays all requests with a second session cookie; green=allowed, red=blocked, yellow=needs review
- **Astra** — automated IDOR scanner with multi-account context; `astra scan --target https://target.com`
- **ffuf** — fuzz numeric/UUID ID spaces in path/query params
- **ParamMiner** (Burp) — uncover hidden params that may expose ID-based access paths

## Payloads / Probes

```
# Swap integer ID (your ID 9000, target 9001)
GET /api/v1/documents/9001 HTTP/1.1
Cookie: session=<account_A_token>

# UUID in JSON body
POST /api/export HTTP/1.1
{"userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"}

# Array-based batch IDOR
GET /api/messages?ids[]=101&ids[]=102&ids[]=103

# Indirect ref via filename
GET /reports/download?file=user_9001_statement.pdf
```

## Chain Opportunities

- **IDOR → PII leak** — access another user's profile, DOB, SSN, address
- **IDOR + weak auth → ATO** — read email/reset token of target user, complete account takeover
- **IDOR → privilege escalation** — swap user ID for admin object ID, gain elevated data or actions
- **IDOR + SSRF** — if object ref is a URL, swap to internal IP
- **Vertical IDOR → admin API** — `/api/admin/users/FUZZ` with user-level session

## Recent Intel

- **CVE-2023-24489** · Citrix ShareFile pre-auth IDOR/RCE · `UploadClientModule.asmx` object ID exposed without auth check · https://www.assetnote.io/resources/research/advisory-sharefile-pre-auth-rce-cve-2023-24489
- **Repeater Strike** · Burp extension using LLM context to generate IDOR-targeted mutations on Repeater requests · https://portswigger.net/research/repeater-strike-manual-testing-amplified
- **HackerOne reports (2024)** · IDOR in REST batch endpoints (`/api/v2/bulk`) consistently high-signal; check `X-User-ID` header overrides in internal APIs
