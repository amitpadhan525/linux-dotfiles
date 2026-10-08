#!/usr/bin/env bash
# ==============================================================================
# Comprehensive Linux Internet, Wi-Fi & USB Tethering Optimization Script
# Fixes:
# 1. TCP BBR Congestion Control + Fair Queuing (fq)
# 2. Dynamic Path MTU Probing (solves MTU Black Holes for Wi-Fi & USB Tethering)
# 3. Global Wi-Fi power-save disabling in NetworkManager
# 4. Realtek RTL8822CE PCIe ASPM latency fix
# 5. USB Tethering Optimization:
#    - Disables USB autosuspend on USB Network & Tethering devices (prevents dropouts)
#    - Sets lower route metric (100) so USB Tethering automatically takes priority over Wi-Fi
#    - Increases TX queue length on USB network interfaces
# 6. Fast DNS with systemd-resolved local caching
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo privileges."
    exit 1
fi

echo "==> 1. Configuring TCP & Network Stack Performance (sysctl)..."
cat << 'EOF' > /etc/sysctl.d/99-network-performance.conf
# TCP BBR Congestion Control & Fair Queuing (Wi-Fi + USB Tethering)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Dynamic Path MTU Probing (Prevents connection hangs/drops on hotspots & USB tethering)
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_no_pmtu_disc = 0

# TCP Fast Open (Client + Server)
net.ipv4.tcp_fastopen = 3

# Buffer & Scaling Optimizations
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_fack = 1
net.core.netdev_max_backlog = 16384
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# IPv6 Optimizations & Privacy
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2
EOF

# Load BBR module and apply sysctl
modprobe tcp_bbr 2>/dev/null || true
sysctl --system >/dev/null 2>&1 || true

echo "==> 2. Disabling Wi-Fi Power Saving Globally in NetworkManager..."
mkdir -p /etc/NetworkManager/conf.d
cat << 'EOF' > /etc/NetworkManager/conf.d/default-wifi-powersave.conf
[connection]
wifi.powersave = 2
EOF

echo "==> 3. Configuring USB Tethering & Ethernet Priority..."
cat << 'EOF' > /etc/NetworkManager/conf.d/default-ethernet-priority.conf
# Ensure USB Tethering and Ethernet automatically get high priority over Wi-Fi
[connection-ethernet-priority]
match-device=type:ethernet
ipv4.route-metric=100
ipv6.route-metric=100
EOF

echo "==> 4. Configuring USB Tethering Stability (Udev Rules)..."
mkdir -p /etc/udev/rules.d
cat << 'EOF' > /etc/udev/rules.d/99-usb-network-tethering.rules
# Disable USB autosuspend for USB Tethering & USB Ethernet adapters
# Matches: Android RNDIS, CDC-NCM, CDC-Ether, Apple iPhone (ipheth), Realtek USB
ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=~"02|e0|ff", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="net", DRIVERS=~"rndis_host|cdc_ether|cdc_ncm|cdc_mbim|ipheth|r8152|ax88179_178a", ATTR{tx_queue_len}="10000"
ACTION=="add", SUBSYSTEM=="net", KERNEL=="usb*|enp*u*|enx*", ATTR{tx_queue_len}="10000"
EOF

# Reload udev rules
udevadm control --reload-rules && udevadm trigger 2>/dev/null || true

echo "==> 5. Configuring Realtek RTL8822CE Driver Stability..."
mkdir -p /etc/modprobe.d
cat << 'EOF' > /etc/modprobe.d/rtw88.conf
options rtw88_pci disable_aspm=y
EOF

echo "==> 6. Configuring Fast DNS Resolvers (systemd-resolved)..."
mkdir -p /etc/systemd/resolved.conf.d
cat << 'EOF' > /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=1.1.1.1 8.8.8.8 2606:4700:4700::1111 2001:4860:4860::8888
FallbackDNS=9.9.9.9 149.112.112.112 2620:fe::fe
DNSSEC=allow-downgrade
DNSOverTLS=opportunistic
Cache=yes
EOF

systemctl enable --now systemd-resolved >/dev/null 2>&1 || true

if [ -f /run/systemd/resolve/stub-resolv.conf ]; then
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi

echo "==> 7. Reloading NetworkManager..."
systemctl reload NetworkManager || systemctl restart NetworkManager

echo "==> All Wi-Fi, Ethernet, and USB Tethering optimizations applied successfully!"
