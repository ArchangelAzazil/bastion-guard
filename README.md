# Bastion Guard: Automated Kernel Hardening & Telemetry Daemon

A lightweight, low-overhead, event-driven security daemon engineered on Hyper-V to secure Linux endpoints via `sysctl` kernel tweaks, absolute SSH identity lockdowns, and real-time `journalctl` log parsing with automated out-of-band alerts routed over the Telegram Bot API.

## Project Architecture
* **Kernel Network Optimization:** Disables IP source routing, ignores global ICMP echo sweeps, and implements strict Reverse Path Filtering (`rp_filter`) to drop spoofed packets.
* **Identity Governance:** Deprecates standard interactive password requirements in favor of mandatory asymmetric Ed25519 public keys.
* **Secrets Isolation:** Decouples API tokens entirely from the codebase, mapping them dynamically from a root-restricted environment profile (`chmod 600`).
* **Persistence Management:** Managed natively via a dedicated `systemd` background worker thread that survives unexpected system reboots.
