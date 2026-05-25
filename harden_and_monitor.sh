#!/usr/bin/env bash
# ==============================================================================
# L3 Infrastructure Lab - Automated Kernel Hardening & Telemetry Daemon
# Target: Debian / Arch Linux Environments
# ==============================================================================

set -euo pipefail

ENV_FILE="/etc/bastion/alerts.env"

# --- SECURELY SOURCE ENVIRONMENT VARIABLES ---
if [[ -f "$ENV_FILE" ]]; then
    # Source the file securely
    # shellcheck disable=SC1090
    source "$ENV_FILE"
else
    echo "[ERROR] Security Environment configuration missing at $ENV_FILE" >&2
    exit 1
fi

# Verify variables were actually loaded into the environment
if [[ -z "${TELEGRAM_TOKEN:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
    echo "[ERROR] Missing critical Telegram API telemetry environment keys." >&2
    exit 1
fi

send_alert() {
    local message="$1"
    echo "[!] Alerting Telegram Channel..."
    # Access keys safely from environmental memory
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=🚨 BASTION GUARD: ${message}" > /dev/null
}

echo "=== [1/3] OPTIMIZING NETWORK KERNEL STACK (SYSCTL) ==="
cat << 'EOF' > /etc/sysctl.d/99-bastion-hardening.conf
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
EOF

sysctl --system

echo "=== [2/3] ENFORCING SECURE SSH DAEMON PROFILE ==="
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

cat << 'EOF' >> /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
MaxAuthTries 3
X11Forwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

if systemctl is-active --quiet sshd; then
    systemctl restart sshd
elif systemctl is-active --quiet ssh; then
    systemctl restart ssh
fi

echo "=== [3/3] SPINNING UP AUTHENTICATION FORENSIC TELEMETRY ==="
THRESHOLD=3

send_alert "Bastion Guard Activated on Hyper-V. Env variables loaded securely."

while true; do
    FAILED_SPIKE=$(journalctl --since "1 minute ago" _SYSTEMD_UNIT=ssh.service _SYSTEMD_UNIT=sshd.service 2>/dev/null | grep -c -E "Failed|Connection closed|preauth" || true)
    
    if [ "$FAILED_SPIKE" -ge "$THRESHOLD" ]; then
        send_alert "Brute-force anomaly detected! $FAILED_SPIKE failed login attempts registered within the last 60 seconds."
        sleep 60 
    fi
    sleep 10
done
