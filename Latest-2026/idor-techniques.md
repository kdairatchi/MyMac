# idor-techniques


## 2026-04-16

### Repeater Strike: Manual testing, amplified
- **Tags:** `#idor` `#llm` `#web`
- **Severity:** info · **Hunt:** 4/5 · **Score:** 4.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/repeater-strike-manual-testing-amplified)

- Introduces "Repeater Strike," a Burp Suite extension that leverages LLMs to analyze requests within the Repeater tab and suggest mutations.
- Specifically targets IDOR (Insecure Direct Object Reference) flaws by interpreting the semantic context of parameters rather than relying solely on brute force.
- Reduces the tedium of manual parameter tampering by generating intelligent, context-aware payloads for access control testing.
- Enhances the detection of logical access control vulnerabilities that are often missed by traditional fuzzers due to a lack of pattern recognition.

**Practical Takeaways:**
- Integrate this extension into manual workflows to automate hypothesis generation for IDOR and access control bugs.
- Use the AI-suggested mutations to identify non-sequential or encoded identifiers that standard tools might overlook.

---
