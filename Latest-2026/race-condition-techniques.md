# race-condition-techniques


## 2026-04-16

### WebSocket Turbo Intruder: Unearthing the WebSocket Goldmine
- **Tags:** `#race-condition` `#web` `#desync` `#cache-poisoning`
- **Severity:** unknown · **Hunt:** 3/5 · **Score:** 12.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/websocket-turbo-intruder-unearthing-the-websocket-goldmine)

*   WebSockets often evade standard scanning because tools drop the connection after the HTTP Upgrade handshake, leaving the communication channel unaudited.
*   The WebSocket handshake is a standard HTTP request, making it susceptible to HTTP-level attacks like Request Smuggling (Desync), Cache Poisoning, and Header injection.
*   Turbo Intruder enables high-throughput testing of WebSocket messages, revealing race conditions and logic flaws (e.g., IDOR, double-spending) that occur during rapid state changes.
*   Unlike standard fuzzers, Turbo Intruder maintains the persistent WebSocket connection and allows precise control over byte-level message crafting.
*   Attacks can be mounted against the handshake (to confuse front-end servers) or the message stream (to confuse the backend application).

**Takeaways:**
*   Don't stop at the handshake; replay captured WebSocket frames using Turbo Intruder to probe for race conditions and access control bypasses.
*   Manually inject headers into the HTTP Upgrade request to check for desync or cache poisoning vulnerabilities before the connection switches protocols.

---
