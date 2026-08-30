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


## 2026-04-19 — H1 disclosures

### BOLA/IDOR in Out-of-Office API allows any authenticated user to read other users' absence data

- **2026-04-14** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3382343](https://hackerone.com/reports/3382343) · Reporter: [@cyberjoker](https://hackerone.com/cyberjoker) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### IDOR on ██████ via direct photo URL leads to unauthorized access to deleted and other users' photos

- **2026-04-07** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3518758](https://hackerone.com/reports/3518758) · Reporter: [@shiva2550](https://hackerone.com/shiva2550) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Access to Deactivated LinkedIn Company Pages via Competitor Analytics API

- **2026-03-24** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3604288](https://hackerone.com/reports/3604288) · Reporter: [@riadalrashed](https://hackerone.com/riadalrashed) · Team: [LinkedIn](https://hackerone.com/linkedin)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was discovered in LinkedIn's Competitor Analytics API that permitted authenticated users to access analytics data for deactivated company pages.

**Hunt signal:** Collect IDs of soft-deleted/deactivated resources (from account history, cached pages, prior responses), then probe analytics/insights/reporting API endpoints with those IDs — check for 200 responses still returning data.
**Pass-if:** Analytics API validates resource `active`/`status` field before serving data.

---

### Add labels to arbitrary issues/prs & compromise github actions label checks

- **2026-03-19** · sev: Medium · bounty: undisclosed · cve: CVE-2026-3306
- Source: [hackerone.com/3527771](https://hackerone.com/reports/3527771) · Reporter: [@ahacker1](https://hackerone.com/ahacker1) · Team: [GitHub](https://hackerone.com/github)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was identified that allowed a user with read access to a repository and write access to a project to modify issue and pull request metadata through the project. When adding an item to a project that already existed, column value updates were applied without verifying the actor's repository write permissions.

**PoC refs:** search `github.com/search?q=CVE-2026-3306` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3306.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — target-specific GitHub Projects v2 permission boundary, no reusable probe.

---

### Unauthenticated access to private files on app.fizzy.do via Active Storage URLs leads to information disclosure

- **2026-03-16** · sev: Low · bounty: $100
- Source: [hackerone.com/3467641](https://hackerone.com/reports/3467641) · Reporter: [@perxibes](https://hackerone.com/perxibes) · Team: [Basecamp](https://hackerone.com/basecamp)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was discovered where unauthenticated users could access private files and file previews on the application through Active Storage URLs. This vulnerability allowed information disclosure, as the files and previews could be accessed without any authentication or authorization checks.

**Hunt signal:** Find Active Storage blob/representation URLs in page source or API responses (`/rails/active_storage/blobs/` or `/rails/active_storage/representations/`), then `curl -L 'https://<target>/rails/active_storage/blobs/<signed_id>/<filename>'` with no session cookie.
**Grep:** `rg -n 'active_storage/(blobs|representations)' app/ | rg -v 'before_action.*(auth|authenticate|verify)'`
**Nuclei:** `idor,rails`
**Pass-if:** Target isn't Ruby on Rails, or Active Storage routes are wrapped in `authenticate_user!` / `before_action` with auth checks.

---

### IDOR to make someone attend or leave an event

- **2026-03-06** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/1734639](https://hackerone.com/reports/1734639) · Reporter: [@safehacker_2715](https://hackerone.com/safehacker_2715) · Team: [LinkedIn](https://hackerone.com/linkedin)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

An Insecure Direct Object Reference (IDOR) vulnerability was discovered in LinkedIn's event attendance functionality. The vulnerability allowed an attacker to manipulate event attendance by modifying the fsd_profile parameter in POST requests to the voyagerScheduledcontentDashViewerStates API endpoint. This issue has been fixed.

**Hunt signal:** POST to event RSVP/attendance endpoints with the victim's profile/user ID swapped into the request body → verify victim's attendance state changed.
**Nuclei:** idor
**Pass-if:** API binds attendance state to the authenticated session token rather than a client-supplied profile parameter.

---


## 2026-05-27 — H1 disclosures

### Autotranslate DDP Method Exposes Private Messages Without Authentication or Room Access Check

- **2026-05-25** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3734326](https://hackerone.com/reports/3734326) · Reporter: [@deprrous](https://hackerone.com/deprrous) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Cross-repository IDOR in `/settings/security_analysis/bypass_reviewers` allows unauthorized delegated bypass reviewer modification

- **2026-05-19** · sev: Medium · bounty: undisclosed · cve: CVE-2026-3307
- Source: [hackerone.com/3560256](https://hackerone.com/reports/3560256) · Reporter: [@ahacker1](https://hackerone.com/ahacker1) · Team: [GitHub](https://hackerone.com/github)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was identified in GitHub Enterprise Server that allowed an attacker with admin access on one repository to modify the secret scanning push protection delegated bypass reviewer list on another repository. Authorization was verified against the repository in the URL, but the action was applied to a different repository specified in the request body. The vulnerability was limited to assigning existing trusted users as bypass reviewers and did not allow adding arbitrary external users. …

**PoC refs:** search `github.com/search?q=CVE-2026-3307` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3307.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### IDOR: autotranslate.translateMessage Full Message Content Leak

- **2026-05-18** · sev: Medium · bounty: undisclosed · cve: CVE-2026-32994
- Source: [hackerone.com/3713682](https://hackerone.com/reports/3713682) · Reporter: [@josan_george](https://hackerone.com/josan_george) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

The `/api/v1/autotranslate.translateMessage` endpoint allowed any authenticated user to retrieve the full content of any message from any room, including private groups, direct messages, and channels. The endpoint fetched the message without performing a room access check, returning the complete message object including the message text, sender information, room ID, timestamps, and markdown content.

**PoC refs:** search `github.com/search?q=CVE-2026-32994` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-32994.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Private circle can be added to another circle via API despite visibility restriction

- **2026-05-08** · sev: Low · bounty: $150 · cve: CVE-2026-45155
- Source: [hackerone.com/3511998](https://hackerone.com/reports/3511998) · Reporter: [@vidang04](https://hackerone.com/vidang04) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was discovered where private circles could be added to other circles via the API, despite visibility restrictions.

**PoC refs:** search `github.com/search?q=CVE-2026-45155` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-45155.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Files drop share links for end-to-end encrypted folders allowed to drop files into other folders of the share owner 

- **2026-05-08** · sev: Low · bounty: undisclosed · cve: CVE-2026-45159
- Source: [hackerone.com/3304830](https://hackerone.com/reports/3304830) · Reporter: [@0x0doteth](https://hackerone.com/0x0doteth) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

Files drop share links for end-to-end encrypted folders allowed to drop files into other folders of the share owner.

**PoC refs:** search `github.com/search?q=CVE-2026-45159` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-45159.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---


## 2026-07-01 — H1 disclosures

### Insecure Direct Object Reference (IDOR) allows creating folders.

- **2026-07-01** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3353057](https://hackerone.com/reports/3353057) · Reporter: [@bl4ck-](https://hackerone.com/bl4ck-) · Team: [SingleStore](https://hackerone.com/singlestore)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

An Insecure Direct Object Reference (IDOR) vulnerability was discovered in the backend API of a software product. The vulnerability allowed authenticated users with low privileges to create unauthorized folders and files in other users' workspaces within the same organization. The issue was reported, triaged, and resolved by the security team through the implementation of a patch to properly validate cluster ownership before allowing resource creation.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Delete any folder for any user within the organization

- **2026-07-01** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3353035](https://hackerone.com/reports/3353035) · Reporter: [@bl4ck-](https://hackerone.com/bl4ck-) · Team: [SingleStore](https://hackerone.com/singlestore)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability in the SingleStore backend API allowed low-privileged users to delete folders belonging to other users within the same organization by manipulating the folder_id parameter in DELETE requests. The vulnerability was rated CVSS 3.0 Low (3.8) due to high attack complexity requiring knowledge of two UUIDs, reported on September 22, 2025, triaged on October 2, 2025, and successfully patched by SingleStore on April 21, 2026.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Missing ownership validation allows cross‑manager tracker–campaign linking

- **2026-06-25** · sev: Medium · bounty: undisclosed · cve: CVE-2026-50739, CVE-2026-34913
- Source: [hackerone.com/3780709](https://hackerone.com/reports/3780709) · Reporter: [@hakuopi](https://hackerone.com/hakuopi) · Team: [Revive Adserver](https://hackerone.com/revive_adserver)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was reported in Revive Adserver version 6.0.7 and earlier that allowed a low-privileged user to link their trackers to campaigns owned by other managers on the same instance. This was due to a lack of proper ownership validation in the `tracker-campaigns.php` script, which handled the reverse operation of linking campaigns and trackers.

**PoC refs:** search `github.com/search?q=CVE-2026-50739` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-50739.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---


## 2026-08-30 — H1 disclosures

### **Unauthenticated IDOR allows modification of payment customer billing information**

- **2026-08-30** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3869124](https://hackerone.com/reports/3869124) · Reporter: [@visionx7](https://hackerone.com/visionx7) · Team: [Weblate](https://hackerone.com/weblate)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

The application contained an access control issue in the payment billing information edit functionality. An unauthenticated user was able to access the payment edit endpoint and modify the billing information associated with a payment without any authorization check. The issue occurred because the application allowed access to the edit page using only the payment identifier in the URL, and the server did not verify whether the requester was logged in or had permission to modify the customer information linked to that payment.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Hidden/restricted tags can be mutated through synonym ID paths without per-tag authorization

- **2026-08-26** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3689633](https://hackerone.com/reports/3689633) · Reporter: [@ahpuh](https://hackerone.com/ahpuh) · Team: [Discourse](https://hackerone.com/discourse)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was discovered in Discourse where a non-admin user with tag-editing permission could modify hidden or restricted tags by supplying their numeric IDs to the synonym creation and tag settings endpoints. Although the user could not view the hidden tags, the controller only authorized the visible target tag and did not re-check authorization for each synonym tag ID, allowing the non-admin user to update the synonym relationship of hidden tags.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Add labels to arbitrary issues/prs via Memex Bulk Update to compromise github actions label gating 

- **2026-08-25** · sev: Medium · bounty: undisclosed · cve: CVE-2026-3306
- Source: [hackerone.com/3527788](https://hackerone.com/reports/3527788) · Reporter: [@ahacker1](https://hackerone.com/ahacker1) · Team: [GitHub](https://hackerone.com/github)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was identified in GitHub Enterprise Server that allowed a user with read access to a repository and write access to a project to modify issue and pull request metadata through the project. When adding an item to a project that already existed, column value updates were applied without verifying the actor's repository write permissions.

**PoC refs:** search `github.com/search?q=CVE-2026-3306` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3306.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### TaskProcessing callback authorization bypass allows ex-members to post as Assistant Talk Bot

- **2026-08-14** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3799010](https://hackerone.com/reports/3799010) · Reporter: [@kuninogu](https://hackerone.com/kuninogu) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

An authenticated user could inject messages into Talk conversations they no longer had access to by scheduling a text processing task with a callback targeting the Assistant Talk Bot. The bot did not verify that the user still had access to the target conversation before posting messages under its trusted identity. The vulnerability was fixed in Assistant Talk Bot version 3.3.0 by limiting bot replies to active conversation participants only.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---
