# Android Testing Checklist

## APK acquisition

```bash
# From Play Store via apkeep / gplaydl
apkeep -a com.target.app -d APK_MIRROR .

# From device (rooted or debuggable)
adb shell pm path com.target.app
adb pull /data/app/com.target.app/base.apk
```

## Static

```bash
# Decompile
apktool d base.apk -o app/
jadx -d jadx-out base.apk

# Quick wins
grep -rniE 'http[s]?://|api.key|secret|password|token|aws|firebase' jadx-out/ | head -50

# MobSF for structured report
docker run -it --rm -p 8000:8000 opensecurity/mobile-security-framework-mobsf
```

Look for:

- Hardcoded secrets, API keys, Firebase DBs (`*.firebaseio.com` without auth).
- Exported components in `AndroidManifest.xml` (`android:exported="true"` on activities/services/receivers).
- Backup allowed (`android:allowBackup="true"`).
- Debuggable flag (`android:debuggable="true"`).
- Weak crypto (ECB, hardcoded IVs, MD5/SHA1 for auth).

## Deep links

```xml
<intent-filter android:autoVerify="true">
  <data android:scheme="target" android:host="open"/>
</intent-filter>
```

Test:

```bash
adb shell am start -W -a android.intent.action.VIEW -d "target://open?url=https://evil.com"
```

Open redirect / injection in deep link handlers → WebView XSS, token theft.

## WebView

- `setJavaScriptEnabled(true)` + user-controlled URL → XSS with native bridge.
- `addJavascriptInterface` pre-API-17 → RCE via `getClass().forName(...)`.
- `setAllowUniversalAccessFromFileURLs(true)` → local file read from `file://`.

## Dynamic — Frida

```bash
frida -U -f com.target.app -l bypass-ssl.js --no-pause

# SSL pinning bypass (common)
frida -U -f com.target.app -l frida-ssl-pinning-bypass.js
```

Use [frida-tools](https://frida.re/docs/android/) + [objection](https://github.com/sensepost/objection):

```bash
objection -g com.target.app explore
# then:
android sslpinning disable
android hooking list activities
```

## Network capture

- Install Burp CA as system cert (rooted) or use apk-mitm to patch network security config.
- Proxy via Burp → replay API traffic → back to `Checklists/API/rest.md`.

## References

- OWASP MASTG — https://mas.owasp.org/MASTG/
- hacktricks — https://book.hacktricks.xyz/mobile-pentesting/android-app-pentesting
- frida codeshare — https://codeshare.frida.re/
