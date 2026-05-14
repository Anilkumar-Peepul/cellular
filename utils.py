#!/usr/bin/env python3
import subprocess
import logging
import time
import os

# ====================== LOGGING SETUP ======================
# Get the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Log file will be created in the same folder as this script
log_file = os.path.join(script_dir, "ppp_monitor.log")

logging.basicConfig(
    filename=log_file,           # ← Logs will be saved here
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    filemode='a'                 # 'a' = append (recommended), use 'w' to overwrite
)

# Optional: Also show logs on console (very useful)
console = logging.StreamHandler()
console.setLevel(logging.INFO)
console.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))
logging.getLogger('').addHandler(console)

logging.info(f"Script started. Logging to: {log_file}")
# =========================================================

def run_command(cmd):
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True
        )
        return (
            result.stdout.strip(),
            result.stderr.strip(),
            result.returncode
        )
    except Exception as e:
        logging.error(f"Exception running command: {cmd} | Error: {e}")
        return "", str(e), -1

def ping_test(interface="ppp0", target="8.8.8.8"):
    cmd = f"ping -I {interface} -c 3 {target}"
    _, _, rc = run_command(cmd)
    if rc == 0:
        logging.info(f"Ping to {target} via {interface} → SUCCESS")
    else:
        logging.warning(f"Ping to {target} via {interface} → FAILED")
    return rc == 0

def restart_service(service):
    logging.info(f"Attempting to restart {service}...")
    cmd = f"systemctl restart {service}"
    _, err, rc = run_command(cmd)
    if rc == 0:
        logging.info(f"Successfully restarted {service}")
        return True
    else:
        logging.error(f"Failed to restart {service} | {err}")
        return False

def kill_process(name):
    logging.info(f"Killing processes matching: {name}")
    cmd = f"pkill -9 {name}"
    run_command(cmd)

def sleep_with_log(seconds):
    logging.info(f"Sleeping for {seconds} seconds...")
    time.sleep(seconds)
