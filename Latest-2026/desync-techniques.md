# desync-techniques


## 2026-04-16

### HTTP/1.1 must die: the desync endgame
- **Tags:** `#desync` `#smuggling` `#web` `#cache-poisoning`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/http1-must-die)

- HTTP/1.1 remains fundamentally vulnerable to desynchronization attacks due to parsing ambiguities that persist despite six years of mitigation attempts.
- Existing defenses have failed to resolve the underlying protocol issues, leaving millions of websites exposed to potential hostile takeover.
- The research posits that the only definitive fix is the deprecation of HTTP/1.1 in favor of unambiguous protocols like HTTP/2 or HTTP/3.
- **Practical Takeaway:** Continue hunting for CL.TE and TE.CL discrepancies even on systems believed to be patched, as standard mitigations are bypassable.
- **Practical Takeaway:** Prioritize testing for request smuggling in infrastructure stacks that have not fully migrated to HTTP/2/3.

---
