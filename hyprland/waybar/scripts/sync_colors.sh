#!/usr/bin/env bash
# Sync dynamic theme colors from ~/.config/hypr/colors.sh to Waybar, Rofi, and Mako

COLORS_SH="$HOME/.config/hypr/colors.sh"
if [ -f "$COLORS_SH" ]; then
    # shellcheck source=/dev/null
    source "$COLORS_SH"
fi

ACCENT="${accent:-#34d399}"
ACCENT_TWO="${accent_two:-#6ee7b7}"
BG_COLOR="${bg_color:-#020e0a}"
TEXT_COLOR="${text_color:-#ffffff}"
SECONDARY_TEXT="${secondary_text:-#a7f3d0}"
CHECK_COLOR="${check_color:-#10b981}"
FAIL_COLOR="${fail_color:-#f87171}"

# 1. Waybar colors.css
cat > "$HOME/.config/waybar/colors.css" <<EOF
/* Auto-generated from ~/.config/hypr/colors.sh */
@define-color accent ${ACCENT};
@define-color accent_two ${ACCENT_TWO};
@define-color bg_color ${BG_COLOR};
@define-color text_color ${TEXT_COLOR};
@define-color secondary_text ${SECONDARY_TEXT};
@define-color check_color ${CHECK_COLOR};
@define-color fail_color ${FAIL_COLOR};
EOF

# 2. Rofi colors.rasi
mkdir -p "$HOME/.config/rofi"
cat > "$HOME/.config/rofi/colors.rasi" <<EOF
/* Auto-generated from ~/.config/hypr/colors.sh */
* {
    bg-base:             ${BG_COLOR}a6;
    bg-base-solid:       ${BG_COLOR}d9;
    bg-alt:              #ffffff14;
    fg-main:             ${TEXT_COLOR}ff;
    fg-dim:              ${SECONDARY_TEXT}99;
    accent:              ${ACCENT}ff;
    accent-two:          ${ACCENT_TWO}ff;
    accent-dim:          ${ACCENT}12;
    accent-mid:          ${ACCENT}b3;
    accent-soft:         ${ACCENT}4d;
    accent-hover:        ${ACCENT}80;
    border-subtle:       ${ACCENT}33;
    urgent:              ${FAIL_COLOR}ff;
    selected-fg:         ${BG_COLOR}ff;
}
EOF

# 3. Mako config color sync (preserves structure, updates dynamic palette values)
MAKO_CONF="$HOME/.config/mako/config"
if [ -f "$MAKO_CONF" ]; then
    python3 - "$MAKO_CONF" "$ACCENT" "$SECONDARY_TEXT" "$BG_COLOR" "$TEXT_COLOR" "$FAIL_COLOR" <<'PY'
import re, sys

path, accent, sec, bg, fg, fail = sys.argv[1:7]
with open(path, "r") as f:
    text = f.read()

# Sync global and app-specific emerald/bg tokens cleanly
text = re.sub(r"^background-color=#[0-9a-fA-F]{6}a6$", f"background-color={bg}a6", text, flags=re.M)
text = re.sub(r"^background-color=#[0-9a-fA-F]{6}bf$", f"background-color={bg}bf", text, flags=re.M)
text = re.sub(r"^text-color=#[0-9a-fA-F]{6}$", f"text-color={fg}", text, flags=re.M)
text = re.sub(r"^border-color=#[0-9a-fA-F]{6}66$", f"border-color={accent}66", text, flags=re.M)
text = re.sub(r"^border-color=#[0-9a-fA-F]{6}88$", f"border-color={accent}88", text, flags=re.M)
text = re.sub(r"^border-color=#[0-9a-fA-F]{6}cc$", f"border-color={fail}cc", text, flags=re.M)
text = re.sub(r"^progress-color=source #[0-9a-fA-F]{6}$", f"progress-color=source {accent}", text, flags=re.M)

with open(path, "w") as f:
    f.write(text)
PY
    if pgrep -x mako >/dev/null 2>&1; then
        makoctl reload >/dev/null 2>&1 || true
    fi
fi
