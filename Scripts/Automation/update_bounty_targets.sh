#!/usr/bin/env bash

# ---------------------------
#     CONFIGURATION
# ---------------------------
WORKTREE_DIR="/Users/anom/tools/bounty-targets-data"
OUTPUT_DIR="/Users/anom/BugBounty"
SLACK_WEBHOOK_URL=""  # Replace with your Slack webhook URL

# Ensure the output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR" || { echo "[-] Failed to create output directory: $OUTPUT_DIR"; exit 1; }
fi

DOMAINS_FILE="${WORKTREE_DIR}/data/domains.txt"
LIVE_DOMAINS_OUTPUT="${OUTPUT_DIR}/livedomains-$(date +%F-%H%M%S).txt"
SUBZY_OUTPUT="${OUTPUT_DIR}/subzy-output-$(date +%F-%H%M%S).txt"
SUBFINDER_RESULTS="${OUTPUT_DIR}/subfinder-results-$(date +%F-%H%M%S).txt"
NUCLEI_OUTPUT="${OUTPUT_DIR}/nuclei-results-$(date +%F-%H%M%S).txt"
GF_SQLI_OUTPUT="${OUTPUT_DIR}/gf-sqli-$(date +%F-%H%M%S).txt"
GF_XSS_OUTPUT="${OUTPUT_DIR}/gf-xss-$(date +%F-%H%M%S).txt"
CLEANED_URLS="${OUTPUT_DIR}/cleaned-urls-$(date +%F-%H%M%S).txt"
EXTRACTED_URLS="${OUTPUT_DIR}/extracted-urls-$(date +%F-%H%M%S).txt"

# ---------------------------
#     FUNCTIONS
# ---------------------------
send_slack_notification() {
  local message="$1"
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL" || echo "[-] Failed to send Slack notification"
}

send_slack_file() {
  local filepath="$1"
  local filename=$(basename "$filepath")
  curl -F "file=@$filepath" -F "initial_comment=Here is the report: $filename" -F "channels=#general" -H "Authorization: Bearer YOUR_SLACK_TOKEN" https://slack.com/api/files.upload
}

generate_summary() {
  echo "[+] Generating summary..."
  local summary_file="${OUTPUT_DIR}/summary-$(date +%F-%H%M%S).txt"
  {
    echo "### Bug Bounty Automation Report - $(date)"
    echo "#### Subfinder Results"
    cat "$SUBFINDER_RESULTS"
    echo ""
    echo "#### Cleaned URLs"
    cat "$CLEANED_URLS"
    echo ""
    echo "#### Live Domains (httpx)"
    cat "$LIVE_DOMAINS_OUTPUT"
    echo ""
    echo "#### Subdomain Takeover Results (subzy)"
    cat "$SUBZY_OUTPUT"
    echo ""
    echo "#### Nuclei Results"
    cat "$NUCLEI_OUTPUT"
    echo ""
    echo "#### GF SQLi Results"
    cat "$GF_SQLI_OUTPUT"
    echo ""
    echo "#### GF XSS Results"
    cat "$GF_XSS_OUTPUT"
    echo ""
    echo "#### Extracted URLs"
    cat "$EXTRACTED_URLS"
  } > "$summary_file"

  echo "[+] Summary saved to $summary_file"
  send_slack_file "$summary_file"
}

run_subfinder() {
  echo "[+] Discovering subdomains with subfinder..."
  subfinder -dL "${DOMAINS_FILE}" -o "${SUBFINDER_RESULTS}" 2>&1 || {
    echo "[-] Subfinder failed. Check input and output paths."
    send_slack_notification "Subfinder failed. Please check logs."
    return 1
  }
  echo "[+] Subfinder results saved to ${SUBFINDER_RESULTS}"
}

clean_urls() {
  echo "[+] Cleaning URLs from subfinder results..."
  awk '{print $1}' "${SUBFINDER_RESULTS}" | sort -u > "${CLEANED_URLS}" || {
    echo "[-] URL cleaning failed."
    send_slack_notification "URL cleaning failed during subfinder post-processing."
    return 1
  }
  echo "[+] Cleaned URLs saved to ${CLEANED_URLS}"
}

run_httpx() {
  echo "[+] Running httpx on cleaned URLs..."
  cat "${CLEANED_URLS}" | httpx -silent -threads 50 -title -tech-detect -status-code -o "${LIVE_DOMAINS_OUTPUT}" || {
    echo "[-] httpx failed. Check the command or input file."
    send_slack_notification "httpx scan failed. Please check logs."
    return 1
  }
  echo "[+] Live domains saved to ${LIVE_DOMAINS_OUTPUT}"
}

run_subzy() {
  echo "[+] Running subzy to detect subdomain takeovers..."
  subzy run --targets "${CLEANED_URLS}" --hide_fails --vuln >> "${SUBZY_OUTPUT}" || {
    echo "[-] Subzy failed. Check your installation."
    send_slack_notification "Subzy scan failed. Please check logs."
    return 1
  }
  echo "[+] Subzy results saved to ${SUBZY_OUTPUT}"
}

run_nuclei() {
  echo "[+] Running nuclei for vulnerability scanning..."
  nuclei -l "${LIVE_DOMAINS_OUTPUT}" -t /Users/anom/Library/CloudStorage/OneDrive-SNHU/bb/BugBounty/wordlist/nuclei-templates/Custom-Nuclei-Templates/ -o "${NUCLEI_OUTPUT}" || {
    echo "[-] Nuclei failed. Check the templates or input file."
    send_slack_notification "Nuclei scan failed. Please check logs."
    return 1
  }
  echo "[+] Nuclei results saved to ${NUCLEI_OUTPUT}"
}

extract_sensitive_data() {
  echo "[+] Extracting sensitive data using gf..."
  cat "${LIVE_DOMAINS_OUTPUT}" | gf sqli > "${GF_SQLI_OUTPUT}" || echo "[-] GF SQLi extraction failed."
  cat "${LIVE_DOMAINS_OUTPUT}" | gf xss > "${GF_XSS_OUTPUT}" || echo "[-] GF XSS extraction failed."
}

extract_urls() {
  echo "[+] Extracting URLs from all scan outputs..."
  awk '{print $1}' "${OUTPUT_DIR}"/*.txt | sort -u > "${EXTRACTED_URLS}" || {
    echo "[-] Failed to extract URLs."
    send_slack_notification "URL extraction failed."
    return 1
  }
  echo "[+] Extracted URLs saved to ${EXTRACTED_URLS}"
}

# ---------------------------
#     MAIN LOGIC
# ---------------------------

while true; do
  echo "--------------------------"
  echo "[+] Starting update process: $(date)"
  echo "--------------------------"

  # Step 1: Pull latest changes from GitHub
  cd "${WORKTREE_DIR}" || { echo "[-] Failed to access worktree directory."; exit 1; }
  echo "[+] Fetching and pulling latest changes from GitHub..."
  git pull origin main || { echo "[-] Git pull failed."; send_slack_notification "Git pull failed."; exit 1; }

  # Step 2: Run all tools
  run_subfinder || continue
  clean_urls || continue
  run_httpx || continue
  run_subzy || continue
  run_nuclei || continue
  extract_sensitive_data || continue
  extract_urls || continue

  # Step 3: Generate and send summary
  generate_summary

  echo "[+] Completed this iteration. Sleeping for 1 hours..."
  sleep 1h
done
