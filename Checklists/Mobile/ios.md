# iOS Testing Checklist

## IPA acquisition

- Jailbroken device: `frida-ios-dump` or `bagbak` to pull decrypted IPA.
- AppStore encrypted IPA is useless for static analysis — must decrypt first.

```bash
# bagbak (requires jailbreak)
bagbak com.target.app
```

## Static

```bash
# Unzip IPA
unzip app.ipa -d app/
ls app/Payload/Target.app/

# Binary analysis
class-dump -H app/Payload/Target.app/Target -o headers/
otool -l Target | grep -A5 LC_ENCRYPTION_INFO   # 0 = decrypted
rabin2 -z Target | grep -iE 'http|api|key|secret|token'

# Plist
plutil -p app/Payload/Target.app/Info.plist
```

Look for:
- `NSAllowsArbitraryLoads: true` in ATS config (cleartext HTTP allowed).
- URL schemes in `CFBundleURLTypes`.
- Universal links in `com.apple.developer.associated-domains`.
- Hardcoded secrets in binary strings or bundled JSON.

## Keychain

- `kSecAttrAccessibleAlwaysThisDeviceOnly` vs `kSecAttrAccessibleWhenUnlocked` — stored while device locked?
- Secrets that should be in keychain stored in `NSUserDefaults` / plist instead → file read = creds.

```bash
# Dump keychain on jailbroken device
objection -g com.target.app explore
ios keychain dump
```

## URL schemes / Universal links

```bash
# Trigger scheme
xcrun simctl openurl booted "target://open?next=https://evil.com"
```

Test handlers for open redirect, deep link injection, auth bypass (token in URL).

## WKWebView

- `javaScriptEnabled` + user URL → XSS.
- `WKScriptMessageHandler` bridging native → web injection path.
- Missing `allowsContentJavaScript` gating per origin.

## Dynamic — Frida / objection (jailbroken)

```bash
objection -g com.target.app explore

# SSL pinning bypass
ios sslpinning disable

# Jailbreak detection bypass
ios jailbreak disable

# File system
ios bundle list_files
ios nsuserdefaults get
```

## Network capture

- Install Burp CA, trust as root cert under Profiles.
- Tunnel simulator traffic through Burp via system proxy.
- For device: USB proxy via [ssl-kill-switch2](https://github.com/nabla-c0d3/ssl-kill-switch2) or objection to disable pinning.

## References

- OWASP MASTG iOS — https://mas.owasp.org/MASTG/iOS/
- hacktricks iOS — https://book.hacktricks.xyz/mobile-pentesting/ios-pentesting
- objection — https://github.com/sensepost/objection
