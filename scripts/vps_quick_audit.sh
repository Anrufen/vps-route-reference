#!/usr/bin/env bash
# Read-only VPS & Docker Security Quick Audit Script
# Companion to https://github.com/Anrufen/vps-route-reference
# Docs: https://www.vpsort.com/3354.html & https://www.vpsort.com/227.html

set -u

echo "============================================================"
echo "  VPShare Read-Only VPS & Docker Security Audit (2026)"
echo "============================================================"

echo -e "\n[1/5] CPU / Memory / Swap Check"
CPU_MODEL=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null | xargs)
CPU_CORES=$(nproc 2>/dev/null || echo "unknown")
echo "  CPU: ${CPU_MODEL:-unknown} (${CPU_CORES} vCPU)"
free -h | awk 'NR==1 || NR==2 || NR==3 {print "  " $0}'

MEM_MB=$(free -m | awk '/^Mem:/ {print $2}')
SWAP_MB=$(free -m | awk '/^Swap:/ {print $2}')
if [ -n "${MEM_MB:-}" ] && [ "$MEM_MB" -lt 3500 ]; then
  echo "  [WARN] Physical RAM < 3.5GB (${MEM_MB}MB): Claude Code / OpenClaw -browser may OOM without >= 2GB Swap."
fi
if [ -n "${SWAP_MB:-}" ] && [ "$SWAP_MB" -lt 1024 ]; then
  echo "  [INFO] Swap < 1GB (${SWAP_MB}MB): Consider adding 2G-4G swap on 2G-4G RAM hosts."
fi

echo -e "\n[2/5] Kernel & TCP Congestion Control (BBR)"
KERNEL=$(uname -r)
CC=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "unknown")
QDISC=$(sysctl -n net.core.default_qdisc 2>/dev/null || echo "unknown")
echo "  Kernel: $KERNEL | congestion_control=$CC | default_qdisc=$QDISC"
if [ "$CC" != "bbr" ]; then
  echo "  [TIP] BBR is not active. See https://www.vpsort.com/227.html to enable native BBR."
fi

echo -e "\n[3/5] Root vs Non-Root Execution Hygiene"
echo "  Current user: $(id -un) (uid=$(id -u))"
if [ "$(id -u)" -eq 0 ]; then
  echo "  [WARN] Running as root. Do NOT run Claude Code auto mode or OpenClaw directly under root."
fi

echo -e "\n[4/5] Docker Public Port Exposure Check (UFW Bypass Risk)"
if command -v docker >/dev/null 2>&1; then
  EXPOSED=$(docker ps --format '{{.Names}}\t{{.Ports}}' 2>/dev/null | grep -E '0\.0\.0\.0:|:::' || true)
  if [ -n "$EXPOSED" ]; then
    echo "  [ALERT] Containers bound to wildcard 0.0.0.0 / ::: (bypasses UFW!):"
    echo "$EXPOSED" | sed 's/^/    /'
    echo "  -> Bind internal gateways (e.g. 18789) to 127.0.0.1 and tunnel via Tailscale/SSH."
  else
    echo "  [OK] No wildcard-exposed Docker container ports found (or no containers running)."
  fi
else
  echo "  Docker not installed. Install guide: https://www.vpsort.com/3168.html"
fi

echo -e "\n[5/5] Next Diagnostic Commands (Manual Copy-Paste)"
echo "  IP Risk & Streaming Matrix (IPQuality): bash <(curl -sL https://Check.Place) -I"
echo "  Comprehensive Bench (GoECS):            curl -L https://raw.githubusercontent.com/oneclickvirt/ecs/master/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh"
echo "  More references: https://www.vpsort.com/vps-recommend"
echo "============================================================"
