# csrf-techniques


## 2026-04-16

### Bypassing __Host and __Secure cookie prefixes
- **Tags:** `#csrf` `#auth-bypass` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/cookie-chaos-how-to-bypass-host-and-secure-cookie-prefixes)

- Discrepancies between strict browser enforcement and lenient server-side cookie parsing allow attackers to bypass the security guarantees of `__Host-` and `__Secure-` prefixes.
- Browsers reject setting these cookies without specific attributes (Secure, Path=/, no Domain), but server libraries may accept malformed or spoofed variants delivered via raw headers.
- This creates a scenario where an attacker can inject a cookie that the server trusts as a protected prefix cookie, despite the browser blocking its creation under normal circumstances.
- The attack effectively undermines the protection against session fixation and cookie injection that these prefixes were designed to provide.

**Practical Takeaways:**
- When auditing session management, manually inject cookies with prefix names (e.g., `__Host-session=attacker`) via proxy tools to check if the backend validates the prefix or just trusts the name.
- Test for request smuggling or header injection bugs that might allow you to strip the `Secure` flag from a `Set-Cookie` header before it reaches the client, confusing the browser's state.

---
