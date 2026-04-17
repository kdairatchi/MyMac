# Defense Evasion - Snort IDS/IPS Rules and Usage

This section provides an overview of Snort, an open-source network intrusion detection system (IDS) and intrusion prevention system (IPS), and its rule structure. Understanding Snort can help red teamers develop evasion techniques and blue teamers improve their detection capabilities.

## Snort IDS/IPS Rules and Usage

Snort performs real-time traffic analysis and packet logging. It can be used in three main modes:

### Snort Modes

*   **Sniffer Mode:** Reads IP packets and displays them on the console. Useful for basic network traffic inspection.
    ```bash
    snort -v
    ```

*   **Packet Logger Mode:** Logs packets to disk. Useful for capturing network traffic for later analysis.
    ```bash
    snort -dev -l ./log
    ```

*   **NIDS (Network Intrusion Detection System) Mode:** Uses a set of rules to detect malicious activity and generate alerts. This is the primary mode for intrusion detection.
    ```bash
    snort -c /etc/snort/snort.conf -i eth0
    ```
    *   `-c`: Specify the path to the Snort configuration file.
    *   `-i`: Specify the network interface to listen on.

### Basic Snort Rule Structure

Snort rules are the core of its detection capabilities. A basic rule consists of a rule header and rule options.

```
alert tcp any any -> 192.168.1.10 80 (msg:"Web Exploit Attempt"; content:"cmd.exe"; sid:1000001; rev:1;)
```

*   **Action:** Defines what Snort does when a rule is triggered. Common actions include:
    *   `alert`: Generate an alert and log the packet.
    *   `log`: Log the packet without generating an alert.
    *   `pass`: Ignore the packet.
    *   `drop`: Block the packet (IPS mode).
    *   `reject`: Block the packet and send a TCP reset or ICMP unreachable message.
    *   `sdrop`: Drop the packet silently.

*   **Protocol:** The network protocol the rule applies to (`ip`, `icmp`, `tcp`, `udp`).

*   **Source/Destination IP:** The IP address(es) involved in the traffic. Can be `any`, a specific IP, or an IP range.

*   **Source/Destination Port:** The port(s) involved in the traffic. Can be `any`, a specific port, or a port range.

*   **Direction Operator:** Indicates the direction of the traffic:
    *   `->`: Unidirectional (source to destination).
    *   `<>`: Bidirectional (either direction).

*   **Rule Options (within parentheses):** Provide additional criteria for detection and information about the alert.
    *   `msg`: A descriptive message to display when the rule fires.
    *   `content`: Looks for specific content (byte sequence) in the packet payload.
    *   `sid`: Snort ID, a unique identifier for the rule. Custom rules should use SIDs above 1,000,000.
    *   `rev`: Revision number of the rule.
    *   `flow`: Defines the direction of the flow within a TCP session (e.g., `to_client`, `to_server`, `established`).
    *   `classtype`: Categorizes the type of attack (e.g., `web-application-attack`).

### Example Snort Rules

*   **Detecting a simple web attack (e.g., `cmd.exe` in URI):**
    ```snort
    alert tcp any any -> $HOME_NET $HTTP_PORTS (msg:"Attempted cmd.exe access in URI"; flow:to_server,established; uricontent:"cmd.exe"; sid:1000002; rev:1;)
    ```

*   **Detecting Nmap XMAS scan:**
    ```snort
    alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"NMAP XMAS Tree Scan"; flags:FPU; sid:1000003; rev:1;)
    ```

*   **Detecting SQL Injection attempt (basic):**
    ```snort
    alert tcp $EXTERNAL_NET any -> $HOME_NET $HTTP_PORTS (msg:"SQL Injection Attempt - Basic"; flow:to_server,established; content:"' OR 1=1"; nocase; sid:1000004; rev:1;)
    ```

Understanding and crafting Snort rules is essential for both detecting and evading network-based intrusion detection systems.

