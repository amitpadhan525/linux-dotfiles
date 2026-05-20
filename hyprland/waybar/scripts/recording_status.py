#!/usr/bin/env python3
import os
import json
import time

def get_elapsed_time():
    pid_file = "/tmp/wf-recorder.pid"
    if not os.path.exists(pid_file):
        return None
    
    # Verify process is indeed running
    try:
        with open(pid_file, "r") as f:
            pid = f.read().strip()
        if not pid:
            return None
        # Check if pid is running
        os.kill(int(pid), 0)
    except (OSError, ValueError):
        return None
        
    try:
        mtime = os.path.getmtime(pid_file)
        elapsed = int(time.time() - mtime)
        return elapsed
    except Exception:
        return None

def main():
    elapsed = get_elapsed_time()
    if elapsed is None:
        # Output empty JSON when not recording to hide module completely
        print(json.dumps({"text": "", "class": "hidden"}))
        return

    mins = elapsed // 60
    secs = elapsed % 60
    time_str = f"{mins:02d}:{secs:02d}"
    
    # Pulse the red dot (even vs odd seconds)
    dot = "●" if elapsed % 2 == 0 else " "
    
    output = {
        "text": f"{dot}  REC  {time_str}",
        "class": "recording",
        "tooltip": f"Recording active for {time_str}. Click to Stop."
    }
    print(json.dumps(output))

if __name__ == "__main__":
    main()
