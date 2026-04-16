# misc-techniques


## 2026-04-16

### Next.js Middleware Bypass (CVE-2025-29927) — `CVE-2025-29927`
- **Tags:** `#nextjs` `#web`
- **Severity:** unknown · **Hunt:** 4/5 · **Score:** 24.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://www.assetnote.io/resources/research/doing-the-due-diligence-analyzing-the-next-js-middleware-bypass-cve-2025-29927)

- Insight: Next.js middleware bypass vulnerability stems from improper URL rewriting logic, allowing attackers to access protected routes by manipulating request segments.
- Insight: Exploit chain involves crafting specially crafted request parameters that skip middleware execution, potentially exposing APIs, authentication systems, or internal endpoints.
- Insight: Vulnerable configurations typically use dynamic route segments (e.g., `[[...slug]]`) with improper middleware scope enforcement.
- Insight: Patch status remains unclear; affected versions likely include Next.js 13-15 due to middleware architecture changes.
- Takeaway: Audit all middleware definitions, especially wildcards and nested routes, for scope enforcement gaps.
- Takeaway: Test edge cases involving path normalization and URL rewriting in dev and preview environments.

---
### Enterprises power agentic workflows in Cloudflare Agent Cloud with OpenAI
- **Tags:** `#cloudflare` `#llm` `#api`
- **Severity:** unknown · **Hunt:** 1/5 · **Score:** 4.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://openai.com/index/cloudflare-openai-agent-cloud)

- Cloudflare's integration of GPT-5.4 and Codex into its edge network enables low-latency, autonomous AI agents that can execute real-world tasks for enterprises.
- The shift to "agentic workflows" expands the attack surface by giving AI models direct access to tools and APIs, moving the risk from prompt leakage to unauthorized actions (e.g., data exfiltration or modification).
- The use of Codex implies code-execution capabilities within the agent's environment, increasing the potential impact of prompt injection attacks leading to remote code execution or supply chain compromise.
- Securing these environments requires shifting focus from input filtering on the UI to strict validation and authorization checks on the *tool-calling* layer.
- **Practical Takeaway:** When testing enterprise deployments, identify the API endpoints exposed to agents and probe them for IDOR or privilege escalation, as agents often run with high privileges but may lack granular security controls.
- **Practical Takeaway:** Hunt for indirect prompt injection vectors in the data sources (e.g., web pages or emails) that these agents are designed to read and process.

---
### Shadow Repeater: AI-enhanced manual testing
- **Tags:** `#web` `#llm`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/shadow-repeater-ai-enhanced-manual-testing)

- Addresses the common issue of missing vulnerabilities due to minor, incorrect assumptions made during manual testing.
- Leverages Large Language Models (LLMs) to autonomously generate variations of requests sent via Burp Suite.
- Acts as a "shadow" tester, exploring alternative input vectors and edge cases in the background while the user focuses on primary test paths.
- Designed to augment human intuition rather than replace it, helping to overcome cognitive bias or tunnel vision.
- **Takeaway**: Integrate Shadow Repeater into Burp Suite workflows to automatically generate "what if" scenarios for every manual request.
- **Takeaway**: Review AI-suggested variations to identify logic flaws or parameter tampering opportunities that standard fuzzers might miss.

---
### Document My Pentest: AI-powered Burp extension for reporting
- **Tags:** `#web` `#llm`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/document-my-pentest)

- Introduces a new Burp AI extension designed to automate the creation of penetration test reports and audit trails directly from traffic.
- Leverages Large Language Models (LLMs) to interpret HTTP interactions and generate structured documentation, reducing manual effort.
- Aims to solve the "boring bits" of pentesting by transforming raw data into professional writeups in real-time.
- Integrates seamlessly into the Burp Suite workflow, allowing security testers to focus on exploitation rather than documentation.

**Practical Takeaways:**
- Adopt this extension to significantly reduce the time spent on report writing, allowing for faster delivery of assessments.
- Verify data privacy settings to ensure sensitive client traffic is handled appropriately when sent to the AI model.

---
### OpenAI Agents SDK native sandbox execution
- **Tags:** `#llm` `#mcp` `#web` `#api`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://openai.com/index/the-next-evolution-of-the-agents-sdk)

- Native sandbox execution provides isolation for agent operations, reducing blast radius but creating new attack surfaces for sandbox escape
- Model-native harness integration simplifies complex workflow development by removing manual orchestration layers
- Long-running agent support enables persistent automation across files and tools, increasing potential for privilege creep over time
- Sandbox boundaries should be tested for file system escape, network egress, and inter-process communication leaks
- MCP protocol integration may introduce supply chain risks if third-party tool providers are compromised

**Practical takeaways:**
- Audit sandbox configurations for restrictive filesystem and network policies before deployment
- Implement resource quotas and timeout limits to prevent runaway agent consumption

---
### Trusted access for the next era of cyber defense
- **Tags:** `#llm`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://openai.com/index/scaling-trusted-access-for-cyber-defense)

- OpenAI is launching GPT-5.4-Cyber, a specialized model variant explicitly designed for cybersecurity defense tasks.
- Access is gated through the "Trusted Access for Cyber" program, limiting availability to vetted security professionals to prevent misuse.
- This release indicates a shift from general-purpose LLMs to domain-specific models with enhanced safeguards for high-risk sectors.
- The integration suggests improved capabilities for malware analysis, threat intelligence processing, and defensive scripting at scale.

**Practical Takeaways:**
- Blue teams should prioritize enrollment in the Trusted Access program to utilize these tailored AI capabilities.
- Red teams should anticipate better-guarded models and may need to rely on alternative open-source LLMs for automated exploit generation.

---
### OpenAI Trusted Access for Cyber Program
- **Tags:** `#web` `#api` `#cloud`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 0.5 · **Status:** unknown · **Age:** 30d
- **Sources:** [1](https://openai.com/index/accelerating-cyber-defense-ecosystem)

- OpenAI launched a collaborative security program integrating GPT-5.4-Cyber with leading security firms and enterprises.  
- Provides $10M in API grants to accelerate defensive capabilities across global cyber operations.  
- Focuses on leveraging AI for enhanced threat detection, analysis, and response automation.  
- Demonstrates industry-wide shift toward AI-integrated defensive ecosystems and collaborative security models.  
- Signals maturation of LLMs as enterprise-grade security tools beyond offensive applications.  

**Practical takeaways:**  
- Organizations can integrate this program to augment SOC capabilities with AI-driven threat analysis, especially for novel attack patterns.  
- Highlights opportunity for security vendors to build complementary tools on OpenAI’s specialized cyber-defense APIs.

---
