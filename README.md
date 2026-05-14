# cellular
In production systems, the PPP connection process is usually handled by:  Boot-time service startup Automatic modem detection SIM/network checking PPP dial-up Connection monitoring Auto-reconnect on failure Interface health monitoring Cloud connectivity validation (AWS/EMQX) Failover/retry logic
# Cellular PPP Installer

## Installation

```bash
git clone <repo-url>
cd cellular-installer
sudo bash install.sh
```

## Logs

```bash
journalctl -u quectel-ppp.service -f
```

## Restart Service

```bash
sudo systemctl restart quectel-ppp.service
```

## Check PPP

```bash
ifconfig ppp0
```
