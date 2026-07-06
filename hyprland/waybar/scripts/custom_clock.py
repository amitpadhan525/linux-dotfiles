#!/usr/bin/env python3
import calendar
import datetime
import os
import sys
import subprocess
import json

STATE_FILE = "/tmp/waybar_custom_clock_state"

def get_state():
    try:
        with open(STATE_FILE, 'r') as f:
            return int(f.read().strip())
    except Exception:
        return 0

def set_state(state):
    try:
        with open(STATE_FILE, 'w') as f:
            f.write(str(state))
    except Exception:
        pass

def toggle_state():
    state = get_state()
    new_state = (state + 1) % 3
    set_state(new_state)
    # Signal waybar to refresh. Signal 9 corresponds to RTMIN+9.
    subprocess.run(["pkill", "-RTMIN+9", "waybar"])

def get_calendar_html(now):
    cal = calendar.TextCalendar(firstweekday=6) # Sunday start
    year = now.year
    month = now.month
    day = now.day
    
    month_name = now.strftime("%B %Y")
    header = f"<span color='#cba6f7'><b>{month_name:^20}</b></span>"
    
    weekdays = cal.formatweekheader(2).split()
    weekdays_styled = " ".join([f"<span color='#fde047'><b>{w}</b></span>" for w in weekdays])
    weekdays_styled += " <span color='#6c7086'><b>Wk</b></span>"
    
    month_weeks = cal.monthdayscalendar(year, month)
    weeks_lines = []
    for week in month_weeks:
        week_line = []
        non_zero_days = [d for d in week if d != 0]
        if non_zero_days:
            d = non_zero_days[0]
            dt = datetime.date(year, month, d)
            thursday_dt = dt + datetime.timedelta(days=(4 - week.index(d)))
            wk_num = thursday_dt.isocalendar()[1]
            wk_str = f"<span color='#6c7086'><b>{wk_num:2d}</b></span>"
        else:
            wk_str = "  "
            
        for d in week:
            if d == 0:
                week_line.append("  ")
            elif d == day:
                week_line.append(f"<span color='#00ffb3'><b><u>{d:2d}</u></b></span>")
            else:
                week_line.append(f"<span color='#cdd6f4'>{d:2d}</span>")
        weeks_lines.append(" ".join(week_line) + f" {wk_str}")
        
    return f"{header}\n{weekdays_styled}\n" + "\n".join(weeks_lines)

def get_clock_json():
    now = datetime.datetime.now()
    state = get_state()
    
    # Format according to state
    if state == 0:
        # Time:   {:%I:%M %p}
        text = now.strftime("  %I:%M %p")
    elif state == 1:
        # Date:   {:%d %m %Y}
        text = now.strftime("  %d %m %Y")
    else:
        # Day:   {:%A}
        text = now.strftime("  %A")
        
    # Tooltip: <span color='#cba6f7'><big>{:%A, %d %B %Y}</big></span>\n<tt><small>{calendar}</small></tt>
    tooltip_header = f"<span color='#cba6f7'><big>{now.strftime('%A, %d %B %Y')}</big></span>"
    cal_str = get_calendar_html(now)
    tooltip = f"{tooltip_header}\n<tt><small>{cal_str}</small></tt>"
    
    data = {
        "text": text,
        "tooltip": tooltip,
        "class": f"state-{state}"
    }
    return json.dumps(data)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--toggle":
        toggle_state()
    else:
        print(get_clock_json())
