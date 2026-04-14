# Triage Playbook

Before reporting, decide: severity, impact statement, reproducibility.

## Severity via CVSS 3.1 (fast pass)

| Metric | Question |
|--------|----------|
| AV     | Network / Adjacent / Local / Physical |
| AC     | Low (no prereqs) / High (race, MITM, user-agent) |
| PR     | None / Low (any user) / High (admin) |
| UI     | None / Required (click, visit) |
| S      | Unchanged / Changed (crosses security boundary) |
| C/I/A  | None / Low / High |

Cheatsheet:
- **Critical (9–10)** — pre-auth RCE, unauth SQLi w/ dump, auth bypass to admin.
- **High (7–8.9)** — auth RCE, stored XSS in admin context, SSRF to cloud metadata, IDOR across tenants.
- **Medium (4–6.9)** — reflected XSS, CSRF on sensitive action, limited IDOR, open redirect in OAuth flow.
- **Low (0.1–3.9)** — self-XSS w/ delivery, info leak (non-sensitive), missing headers w/ demonstrated impact.

## Impact statement formula

> As **`<role>`**, an attacker can **`<action>`** on **`<target>`** resulting in **`<business impact>`**.

Example: "As an unauthenticated user, an attacker can trigger SSRF against `api.target.com` to read AWS IMDSv1 credentials, resulting in full AWS account compromise (IAM role: `prod-ec2-role`)."

## Reproducibility bar

- [ ] PoC reproduces in a fresh browser / curl from clean IP
- [ ] HTTP request + response captured (Burp .req/.res or curl `-v`)
- [ ] Screencast / screenshots with timestamps visible
- [ ] Account email(s) used noted in report
- [ ] No sensitive data beyond minimum PoC (stop at "can read" — don't dump)

## When to chain

Single low-sev → chain with another for medium+.

Common chains:
- Open redirect + OAuth → account takeover
- Self-XSS + CSRF login → stored XSS
- IDOR (read) + IDOR (write) → full account overwrite
- SSRF + metadata → credential theft → S3 dump

## Report minimum viable structure

1. Title — `<vuln class> in <endpoint> leads to <impact>`
2. Summary (2–4 lines)
3. Steps to reproduce (numbered, copy-paste)
4. PoC (request/response, screenshot, video)
5. Impact (using formula above)
6. Remediation suggestion (specific, not "sanitize input")
7. References (CWE, OWASP, similar writeups)

## Anti-patterns that get NA'd

- "Might lead to" — prove it or don't submit
- CVSS calculator without justifying metrics
- Scanner output pasted as-is (nuclei/nikto/acunetix)
- Missing steps ("inject payload here")
- Same report on 10 programs (template spam)

## References

- FIRST CVSS calculator — https://www.first.org/cvss/calculator/3.1
- Bugcrowd VRT — https://bugcrowd.com/vulnerability-rating-taxonomy
- HackerOne disclosure-quality rubric — https://docs.hackerone.com/hackers/submitting-reports.html
