# Wireless Attacks

This section covers various techniques used in wireless network attacks, including Wi-Fi cracking, Evil Twin attacks, and Bluetooth reconnaissance.

## Wi-Fi Cracking (WPA/WPA2-PSK)

Cracking WPA/WPA2-PSK (Pre-Shared Key) networks typically involves capturing the 4-way handshake and then using a brute-force or dictionary attack against it.

*   **Monitor Mode:** To capture wireless traffic, your wireless adapter must be put into monitor mode.
    ```bash
    airmon-ng start wlan0
    ```
    *Replace `wlan0` with your wireless interface name.*

*   **Capture Handshake:** Use `airodump-ng` to scan for access points and capture the WPA/WPA2 handshake when a client connects or re-authenticates.
    ```bash
    airodump-ng -c <channel> --bssid <AP_MAC> -w <output_file> wlan0mon
    ```
    *   `-c`: Specify the channel of the target AP.
    *   `--bssid`: Specify the BSSID (MAC address) of the target AP.
    *   `-w`: Write captured packets to a file.
    *   `wlan0mon`: Your wireless interface in monitor mode.

*   **Deauthentication Attack:** This attack disconnects clients from an access point, forcing them to re-authenticate and thus generating a new 4-way handshake that can be captured.
    ```bash
    aireplay-ng --deauth 0 -a <AP_MAC> -c <Client_MAC> wlan0mon
    ```
    *   `--deauth 0`: Send continuous deauthentication frames.
    *   `-a`: BSSID of the access point.
    *   `-c`: MAC address of a connected client (optional, but helps target specific clients).

*   **Crack Handshake:** Use `aircrack-ng` with a wordlist to crack the captured handshake.
    ```bash
    aircrack-ng -w /path/to/wordlist.txt <output_file>.cap
    ```
    *   `-w`: Specify the path to your wordlist.
    *   `<output_file>.cap`: The `.cap` file captured by `airodump-ng`.

## Evil Twin Attack (Conceptual)

An Evil Twin attack involves setting up a rogue Wi-Fi access point that mimics a legitimate one to trick users into connecting to it, allowing the attacker to intercept traffic or capture credentials.

*   **Setup Fake AP:** Tools like `hostapd` (for creating the AP) and `dnsmasq` (for DHCP and DNS services) are commonly used to set up a rogue access point with the same SSID as a legitimate one.

*   **Deauthenticate Legitimate Clients:** Similar to Wi-Fi cracking, deauthentication attacks can be used to force clients from the legitimate AP to connect to your fake AP.

*   **Capture Credentials:** Once clients connect to the fake AP, traffic can be redirected through the attacker's machine, allowing for the capture of credentials (e.g., through a captive portal or by sniffing unencrypted traffic).

## Bluetooth Reconnaissance

Bluetooth reconnaissance involves discovering and enumerating nearby Bluetooth devices, which can reveal information about potential targets or vulnerabilities.

*   **Scan for Devices:** Use `hcitool` to scan for discoverable Bluetooth devices.
    ```bash
    hcitool scan
    ```

*   **Bluetooth Low Energy (BLE) Scan:** For BLE devices, `bluetoothctl` can be used.
    ```bash
    bluetoothctl scan on
    ```

These wireless attack techniques highlight the importance of securing wireless networks and being aware of potential threats in the radio frequency spectrum.

