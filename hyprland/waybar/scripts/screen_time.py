#!/usr/bin/env python3
import subprocess
import datetime
import re
import os

def get_screen_time():
    # Get total uptime seconds from /proc/uptime for sanity check or fallback? 
    # screen time can be > uptime.
    
    today = datetime.datetime.now()
    # "Fri Feb 13"
    today_str = today.strftime("%a %b %e").replace("  ", " ")
    
    current_user = os.environ.get("USER")
    if not current_user:
        try:
            current_user = subprocess.check_output("whoami", shell=True).decode().strip()
        except:
            return "?"

    try:
        # Get login history. 
        # -R: no hostname. 
        # We also might want to check full wtmp if needed, but default is fine.
        output = subprocess.check_output("last -R", shell=True).decode()
    except:
        return "?"

    total_seconds = 0
    # Regex for duration (days+HH:MM) or (HH:MM)
    dur_regex = re.compile(r'\((\d+)\+(\d{2}):(\d{2})\)|\((\d{2}):(\d{2})\)')
    
    # Track calculated sessions to avoid overlap? 
    # Simple "last" usually doesn't show overlaps for the same TTY.
    # But if user has tty1 and tty2... we sum them.
    # To be safe, we only allow tty entries (physical sessions) or known display managers.
    # We explicitly exclude 'pts' which are terminal windows.
    
    lines = output.splitlines()
    for line in lines:
        if not line.strip(): continue
        if line.startswith("reboot"): continue
        if line.startswith("wtmp begins"): continue
        
        # Must match user
        if not line.startswith(current_user):
            continue

        # Must be today
        if today_str not in line:
            continue
            
        # Exclude pseudo-terminals (pts) to avoid double counting window usage
        # e.g. "pts/0"
        parts = line.split()
        if len(parts) > 1 and "pts/" in parts[1]:
            continue

        # If we are here, it's likely a real session (tty or dm)
        
        is_active = "still logged in" in line
        if is_active:
            # Parse start time
            # Line: user tty1 Fri Feb 13 15:24 still logged in
            # Find the time 15:24. It is usually the 4th/5th token.
            # But let's look for HH:MM pattern after the date components
            # "Fri", "Feb", "13"
            # next token is time.
            
            try:
                # Find the token with colon
                time_token = None
                for token in parts:
                    if ":" in token and len(token) == 5 and token[2] == ":":
                        # exclude (HH:MM) duration format which has parens
                        if "(" not in token and ")" not in token:
                            time_token = token
                            break
                            
                if time_token:
                    h, m = map(int, time_token.split(":"))
                    start_dt = today.replace(hour=h, minute=m, second=0, microsecond=0)
                    if start_dt > today:
                         # Clock skew or wrong day parsed?
                         # If date is today, and start > now, impossible unless clock changed.
                         pass
                    else:
                        total_seconds += (today - start_dt).total_seconds()
            except:
                pass

        else:
            # Finished session, has duration
            match = dur_regex.search(line)
            if match:
                if match.group(1): # Days+HH:MM
                    d, h, m = map(int, [match.group(1), match.group(2), match.group(3)])
                    total_seconds += d*86400 + h*3600 + m*60
                elif match.group(4): # HH:MM
                    h, m = map(int, [match.group(4), match.group(5)])
                    total_seconds += h*3600 + m*60

    hours = int(total_seconds // 3600)
    minutes = int((total_seconds % 3600) // 60)
    
    return f"{hours}h {minutes}m"

if __name__ == "__main__":
    print(get_screen_time())
