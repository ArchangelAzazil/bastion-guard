# 🛡️ Bastion Guard: Automated Kernel Hardening & Telemetry Daemon

Welcome to **Bastion Guard**! This is a lightweight, low-overhead, event-driven security daemon I engineered completely from scratch inside my Hyper-V home lab (`testkitchen`). 

The mission? Transform a stock Linux endpoint into an absolute fortress by hardening the kernel, locking down SSH to zero-password cryptographic parameters, and building a real-time log-parsing telemetry engine that hits my personal Telegram channel the split-second a brute-force anomaly is detected.

No heavy, resource-hogging security agents. No massive third-party dependencies. Just pure, native Linux automation running at the lowest layer of the operating system.

---

## 🏗️ Project Architecture & How It Works

Here is exactly how this system secures the perimeter and processes telemetry under the hood:

### 1. Kernel Network Optimization (Blinding the Scanners)
I injected custom parameters directly into the kernel runtime namespace (`sysctl`) to alter how the networking stack evaluates traffic. The system drops all global inbound ICMP echo requests (making the machine completely blind to malicious network ping sweeps) and enforces strict **Reverse Path Filtering (`rp_filter`)** to drop spoofed packets right at the interface.

### 2. Zero-Password Identity Governance
Standard passwords are a massive liability. I completely deprecated interactive password challenges within OpenSSH, enforcing an absolute, mandatory **Asymmetric Ed25519 Elliptic-Curve Key Pair** policy. If an attacker tries to guess a password, the server terminates the handshake instantly at the pre-authentication (`[preauth]`) stage.

### 3. Bulletproof Secrets Isolation
No hardcoded API tokens or credentials here! Following enterprise best practices, all Telegram bot keys and environment variables are entirely decoupled from the codebase. They live in a root-restricted profile path protected by a strict `chmod 600` permission mask, keeping production secrets isolated from lower-privileged system processes.

### 4. Native Persistence & Telemetry Loop
The automation framework is offloaded directly to the system initialization layer as a native background service thread (`systemd`). Every 10 seconds, the daemon executes a highly optimized loop that tails `systemd-journald` via `journalctl`. It calculates unauthenticated drops within a rolling 60-second window, evaluates the math, and orchestrates an outbound SSL JSON payload to the Telegram API gateway the moment the anomaly threshold is breached.

---

## 🕹️ Live-Fire Testing (How I Verified It)

To prove the telemetry loop worked seamlessly across platforms, I simulated a real-world brute-force attack from my Windows workstation using a native PowerShell loop to hammer the VM's SSH daemon:

```powershell
1..5 | ForEach-Object { ssh admin@192.168.68.237 }


The result? The VM caught the automated probe, calculated that 5 failed attempts within the 60-second window, and instantly fired an alert straight to my phone. Mission accomplished.

## ⚙️ Tech Stack Stacked Deep

Core Language: Bash / Linux Shell Scripting
Log Aggregation: systemd-journald & journalctl
Network Tuning: Linux Kernel Namespace (sysctl)
API Gateways: Telegram Bot API via curl HTTPS POST
Hypervisor: Microsoft Hyper-V
