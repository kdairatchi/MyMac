# Command and Control (C2) Interaction

This section covers the fundamental concepts and common commands associated with Command and Control (C2) frameworks, which are central to managing compromised systems during red team operations.

## General C2 Concepts

Command and Control (C2) is the communication channel between an attacker and a compromised system. Effective C2 infrastructure is crucial for maintaining access, executing commands, and exfiltrating data covertly.

*   **Beaconing:** The regular, periodic communication from the compromised host (beacon/agent) back to the C2 server. This communication is often designed to mimic legitimate network traffic to evade detection.

*   **Payloads:** The malicious code or executable deployed on the target system that establishes the connection back to the C2 server. Payloads can vary in format (e.g., executables, DLLs, scripts) and behavior (e.g., staged, stageless).

*   **Listeners:** Components on the C2 server that are configured to wait for and accept incoming connections from beacons/agents. Listeners define the protocol, port, and other parameters for communication.

*   **Profiles:** Also known as Malleable C2 profiles (in frameworks like Cobalt Strike), these are configuration files that define how the beacon communicates. They allow red teamers to customize network traffic patterns (e.g., HTTP headers, URI paths, jitter) to blend in with legitimate traffic and evade network-based detection.

## Example C2 Framework Commands (Conceptual)

While specific commands vary significantly between different C2 frameworks (e.g., Cobalt Strike, Mythic, Empire), the general workflow and types of interactions remain consistent. The following are conceptual examples of common commands:

*   **Generate Payload:** Create a beacon/agent payload that connects back to a specified listener.
    ```
    generate_payload --format exe --listener http_beacon --output /tmp/beacon.exe
    ```

*   **Start Listener:** Configure and start a listener on the C2 server to receive incoming connections.
    ```
    listener_start --name http_beacon --port 80 --profile default.profile
    ```

*   **Interact with Session:** Once a beacon connects, operators can interact with the compromised host to execute commands, upload/download files, and perform other post-exploitation activities.
    ```
    sessions -i 1
    shell whoami
    upload /local/path /remote/path
    download /remote/path /local/path
    screenshot
    ```

For more detailed information on C2 frameworks, refer to the `Tools/C2_Frameworks.md` documentation.

