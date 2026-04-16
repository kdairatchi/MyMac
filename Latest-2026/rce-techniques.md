# rce-techniques


## 2026-04-16

### Advisory: ShareFile Pre-Auth RCE — `CVE-2023-24489`
- **Tags:** `#rce` `#deserialization` `#citrix`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://www.assetnote.io/resources/research/advisory-sharefile-pre-auth-rce-cve-2023-24489) · [2](https://www.assetnote.io/resources/research/encrypted-doesnt-mean-authenticated-sharefile-rce-cve-2023-24489)

- **Vulnerable Entry Point**: The `UploadClientModule.asmx` endpoint processes unauthenticated SOAP requests without sufficient validation.
- **Root Cause**: The application utilizes unsafe .NET XML deserialization, parsing user-supplied XML directly into objects.
- **Exploitation Method**: Attackers can inject .NET gadget chains (e.g., `ObjectDataProvider`) within the XML payload to trigger arbitrary command execution.
- **Impact Scope**: Because the flaw is pre-authentication, it allows for immediate, unauthenticated RCE on the underlying ShareFile server.
- **Takeaway**: When auditing .NET applications, map out all endpoints accepting XML content and test for unsafe deserialization, not just XXE.
- **Takeaway**: Legacy file management modules often run with high privileges; prioritize auditing synchronization and upload handlers for logical flaws.

---
*Clustered 2 sources for this item.*

### Drag and Pwnd: Leverage ASCII characters to exploit VS Code
- **Tags:** `#rce` `#command-injection` `#data-exfil`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/drag-and-pwnd-leverage-ascii-characters-to-exploit-vs-code)

- Legacy ASCII control characters (SOH, STX, EOT, ETX) are often overlooked by modern sanitization but can still trigger commands in terminal emulators.
- VS Code's integrated terminal can be manipulated into executing commands based on the content of files being dragged or processed.
- The attack vector leverages the gap between the editor's UI handling and the terminal's interpretation of control sequences.
- This method bypasses standard input validation that focuses on printable characters, making it a stealthy injection technique.

**Practical Takeaways:**
- Audit file handling code to strip or escape non-printable control characters before passing data to shells or terminals.
- Test integrated development environments (IDEs) for command injection by embedding control sequences in filenames and file content.

---
### MOVEit Transfer RCE Part Two (CVE-2023-34362) — `CVE-2023-34362`
- **Tags:** `#rce` `#api` `#enterprise`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 27.0 · **Status:** poc · **Age:** 127d
- **Sources:** [1](https://www.assetnote.io/resources/research/moveit-transfer-rce-part-two-cve-2023-34362)

- Insight: Variant of CVE-2023-34362 with distinct RCE mechanism in MOVEit Transfer's file processing pipeline
- Insight: Exploitable via crafted file transfers triggering deserialization of untrusted input
- Insight: Affects version-specific endpoints handling large file payloads and metadata
- Insight: Allows authenticated user privilege escalation to SYSTEM-level compromise
- Insight: Demonstrates recurring flaw in MOVEit's input validation design patterns

Practical takeaways:
- Test file transfer endpoints with malicious payloads and metadata variations during pentests
- Prioritize MOVEit instances for patching; monitor for unusual file transfer activities as IOCs

---
### Bypass IIS Auth in Sitecore 9.3 - Three RCEs and Auth Bypasses
- **Tags:** `#rce` `#auth-bypass` `#iis` `#sitecore`
- **Severity:** critical · **Hunt:** 3/5 · **Score:** 26.55 · **Status:** theoretical · **Age:** 1d
- **Sources:** [1](https://www.assetnote.io/resources/research/bypass-iis-authorisation-with-this-one-weird-trick-three-rces-and-two-auth-bypasses-in-sitecore-9-3)

- **Insight 1:** The research demonstrates novel techniques to bypass IIS authorization mechanisms specifically in Sitecore 9.3, leveraging how the application handles authentication at the web server level.
- **Insight 2:** Multiple vulnerability vectors exist, including three distinct paths achieving Remote Code Execution, potentially through crafted requests that manipulate Sitecore's interaction with IIS security modules.
- **Insight 3:** Two authentication bypass methods allow attackers to access sensitive functionality without proper authentication, potentially compromising entire Sitecore environments.

**Takeaways:**
- Organizations running Sitecore 9.3 should immediately audit their IIS configuration and test for these specific authorization bypass techniques, especially if the application is exposed to the internet.
- Consider implementing additional authentication layers beyond IIS for critical Sitecore components, as the product's integration with IIS security creates unique attack surfaces not present in other web applications.

---
### Chaining Pre-Auth RCE in Metabase (CVE-2023-38646) — `CVE-2023-38646`
- **Tags:** `#rce` `#deserialization` `#command-injection` `#web`
- **Severity:** critical · **Hunt:** 2/5 · **Score:** 18.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://www.assetnote.io/resources/research/chaining-our-way-to-pre-auth-rce-in-metabase-cve-2023-38646) · [2](https://www.assetnote.io/resources/research/advisory-metabase-pre-auth-rce-cve-2023-38646)

- **Insight 1:** The vulnerability leverages the H2 database connection string's `INIT` parameter to execute arbitrary SQL commands during the connection validation phase on the `/api/setup/validate` endpoint.
- **Insight 2:** Attackers can abuse H2's `ALIAS` function to create custom functions that invoke arbitrary Java methods, effectively bridging the gap from SQL injection to native code execution.
- **Insight 3:** The issue stems from a lack of strict validation on JDBC connection strings in pre-authentication endpoints, allowing the database driver's feature set to be weaponized.
- **Insight 4:** Successful exploitation requires no prior authentication and works reliably on the default H2 in-memory database configurations often used during setup or testing.
- **Takeaway:** When auditing Java applications, pay close attention to unauthenticated endpoints that accept database connection details, specifically looking for dangerous JDBC parameters like `INIT`.
- **Takeaway:** Block or strictly sanitize JDBC URL schemes in user input, as database drivers often contain features (like script execution or classloading) that can lead to RCE.

---
*Clustered 2 sources for this item.*
