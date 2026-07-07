# Default Credentials

## Fingerprint the Technology

- [ ] Identify CMS / software version from headers, `X-Powered-By`, HTML comments, `/robots.txt`, error pages
- [ ] Check login page URL patterns: `/admin`, `/wp-admin`, `/manager/html`, `/console`, `/login`, `/_admin`
- [ ] Run `whatweb` or `wappalyzer` against target to auto-detect stack

  ```bash
  whatweb https://target.com
  ```

## Look Up Default Credentials

- [ ] Search [DefaultCreds-cheat-sheet](https://github.com/ihebski/DefaultCreds-cheat-sheet):

  ```bash
  python3 creds.py search grafana
  python3 creds.py search jenkins
  ```

- [ ] Search [many-passwords](https://github.com/many-passwords/many-passwords) for the product
- [ ] Check vendor documentation for factory defaults
- [ ] Common universal fallbacks to try:

  ```
  admin:admin
  admin:password
  admin:1234
  admin:(blank)
  root:root
  root:toor
  guest:guest
  test:test
  ```

## Test Login

- [ ] Try default creds manually on the login form — watch for 200 vs 302 response
- [ ] Check if the account is still default after login (password change prompt = confirmed default)
- [ ] Try default creds on SSH, FTP, SNMP if in scope

  ```bash
  # SSH
  ssh admin@target.com
  # FTP
  ftp target.com
  # SNMP community string
  snmpwalk -v2c -c public target.com
  ```

## Escalation Checks

- [ ] Can default admin account create new users?
- [ ] Can default account read/export sensitive data?
- [ ] Is there a second admin account also using defaults?

## References

- [OWASP Testing Guide 04.02](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/04-Authentication_Testing/02-Testing_for_Default_Credentials)
- [HackerOne #398797](https://hackerone.com/reports/398797)
