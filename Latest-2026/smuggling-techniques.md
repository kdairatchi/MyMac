# smuggling-techniques


## 2026-04-16

### Introducing HTTP Anomaly Rank
- **Tags:** `#web` `#api` `#smuggling`
- **Severity:** info · **Hunt:** 3/5 · **Score:** 3.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/introducing-http-anomaly-rank) · [2](https://portswigger.net/research/top-10-web-hacking-techniques-of-2024) · [3](https://portswigger.net/research/top-10-web-hacking-techniques-of-2025-nominations-open)

- Automated HTTP response ranking system that identifies anomalous responses based on length, status codes, and content patterns to replace manual sorting in tools like Burp Intruder.  
- Uses statistical deviation analysis to flag outliers from expected response behaviors, reducing false positives and accelerating vulnerability discovery.  
- Prioritizes responses with extreme length variations (indicative of desync/smuggling), unexpected headers, or suspicious content for manual review.  
- Integrates with Burp Suite to rank tens of thousands of responses in milliseconds, enabling efficient analysis of large-scale fuzzing campaigns.  

**Practical takeaways**:  
1. Implement anomaly detection in penetration testing to quickly identify non-standard responses that bypass traditional vulnerability scanners.  
2. Combine with desync/smuggling payloads to validate HTTP request smuggling primitives without manual response inspection.

---
*Clustered 3 sources for this item.*
