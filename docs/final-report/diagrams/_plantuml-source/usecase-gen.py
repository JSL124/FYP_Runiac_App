import math, cairosvg

STROKE = "#2F4F6F"
TEXT   = "#1F1F1F"
FONT   = "Segoe UI, Helvetica, Arial, sans-serif"

BOX_L, BOX_R = 300, 830
OVAL_CX, OVAL_RX, OVAL_RY = 565, 172, 26
ROW_H = 66
BOX_TOP = 26
TITLE_H = 46
PAD_BOTTOM = 26
ACTOR_X = 100

def wrap(label, limit=27):
    words = label.split()
    lines, cur = [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if len(t) <= limit: cur = t
        else:
            if cur: lines.append(cur)
            cur = w
    if cur: lines.append(cur)
    return lines[:2] if len(lines) <= 2 else [" ".join(lines[:-1]), lines[-1]]

def actor_svg(x, cy, label):
    """Stick figure. Returns (svg, fan_origin)."""
    head_r = 12
    head_cy = cy - 34
    body_top = head_cy + head_r
    body_bot = cy + 6
    arm_y = cy - 12
    s = []
    s.append(f'<circle cx="{x}" cy="{head_cy}" r="{head_r}" fill="none" stroke="{STROKE}" stroke-width="1.6"/>')
    s.append(f'<line x1="{x}" y1="{body_top}" x2="{x}" y2="{body_bot}" stroke="{STROKE}" stroke-width="1.6"/>')
    s.append(f'<line x1="{x-22}" y1="{arm_y}" x2="{x+22}" y2="{arm_y}" stroke="{STROKE}" stroke-width="1.6"/>')
    s.append(f'<line x1="{x}" y1="{body_bot}" x2="{x-17}" y2="{body_bot+26}" stroke="{STROKE}" stroke-width="1.6"/>')
    s.append(f'<line x1="{x}" y1="{body_bot}" x2="{x+17}" y2="{body_bot+26}" stroke="{STROKE}" stroke-width="1.6"/>')
    ls = label.split("\n")
    ty = body_bot + 48
    wmax = max(len(l) for l in ls) * 9 + 16
    s.append(f'<rect x="{x - wmax/2}" y="{ty - 15}" width="{wmax}" height="{len(ls)*17 + 6}" fill="white"/>')
    for i, l in enumerate(ls):
        s.append(f'<text x="{x}" y="{ty + i*17}" font-family="{FONT}" font-size="16" font-weight="700" '
                 f'fill="{TEXT}" text-anchor="middle">{l}</text>')
    return "\n".join(s), (x + 22, arm_y)

def build(path, title, actors, cases):
    """actors: list of label. cases: list of (label, actor_index)."""
    n = len(cases)
    first_cy = BOX_TOP + TITLE_H + OVAL_RY + 12
    cys = [first_cy + i * ROW_H for i in range(n)]
    box_bot = cys[-1] + OVAL_RY + PAD_BOTTOM
    height = box_bot + 40
    width = BOX_R + 30

    parts = [f'<rect x="0" y="0" width="{width}" height="{height}" fill="white"/>']
    parts.append(f'<rect x="{BOX_L}" y="{BOX_TOP}" width="{BOX_R-BOX_L}" height="{box_bot-BOX_TOP}" '
                 f'fill="none" stroke="{STROKE}" stroke-width="1.6"/>')
    parts.append(f'<text x="{(BOX_L+BOX_R)/2}" y="{BOX_TOP+28}" font-family="{FONT}" font-size="16" '
                 f'font-weight="700" fill="{TEXT}" text-anchor="middle">{title}</text>')

    origins = []
    for ai, alabel in enumerate(actors):
        owned = [cys[i] for i, (_, o) in enumerate(cases) if o == ai]
        acy = sum(owned) / len(owned)
        origins.append(acy)
    if len(origins) == 2 and abs(origins[0] - origins[1]) < 140:
        mid = sum(origins) / 2
        origins = [mid - 70, mid + 70]

    fan = []; actor_parts = []
    for ai, alabel in enumerate(actors):
        svg, o = actor_svg(ACTOR_X, origins[ai], alabel)
        actor_parts.append(svg); fan.append(o)

    # straight connector lines, drawn before the ovals so the ovals sit on top
    for i, (label, ai) in enumerate(cases):
        ox, oy = fan[ai]
        parts.append(f'<line x1="{ox}" y1="{oy}" x2="{OVAL_CX-OVAL_RX}" y2="{cys[i]}" '
                     f'stroke="{STROKE}" stroke-width="1.2"/>')

    parts.extend(actor_parts)

    for i, (label, ai) in enumerate(cases):
        cy = cys[i]
        parts.append(f'<ellipse cx="{OVAL_CX}" cy="{cy}" rx="{OVAL_RX}" ry="{OVAL_RY}" '
                     f'fill="white" stroke="{STROKE}" stroke-width="1.4"/>')
        lines = wrap(label)
        if len(lines) == 1:
            parts.append(f'<text x="{OVAL_CX}" y="{cy+5}" font-family="{FONT}" font-size="16" '
                         f'fill="{TEXT}" text-anchor="middle">{lines[0]}</text>')
        else:
            for j, l in enumerate(lines):
                parts.append(f'<text x="{OVAL_CX}" y="{cy-3+j*17}" font-family="{FONT}" font-size="16" '
                             f'fill="{TEXT}" text-anchor="middle">{l}</text>')

    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
           f'viewBox="0 0 {width} {height}">' + "\n".join(parts) + '</svg>')
    open(path + ".svg", "w").write(svg)
    cairosvg.svg2png(bytestring=svg.encode(), write_to=path + ".png", scale=1.8, background_color="white")
    return width, height
