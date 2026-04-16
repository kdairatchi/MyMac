# data-exfil-techniques


## 2026-04-16

### Inline Style Exfiltration: leaking data with chained CSS conditionals
- **Tags:** `#data-exfil` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/inline-style-exfiltration) · [2](https://labs.watchtowr.com/stop-putting-your-passwords-into-random-websites-yes-seriously-you-are-the-problem/)

- Bypasses the traditional requirement for `<style>` blocks or external stylesheets by exploiting inline `style` attributes for data exfiltration.
- Utilizes chained CSS conditionals to sequentially guess attribute values (e.g., CSRF tokens) character by character.
- Triggers side-channel signals, such as HTTP requests for background images, only when a specific CSS condition evaluates to true.
- Demonstrates that restricted CSS injection contexts (attribute-only) are still viable for leaking sensitive data.
- **Practical Takeaway:** Re-evaluate input sanitization; allowing inline styles while blocking `<style>` tags is no longer safe from data theft.
- **Practical Takeaway:** When hunting for CSS injection, test attribute injection points for timing or network-based exfiltration vectors.

---
*Clustered 2 sources for this item.*
