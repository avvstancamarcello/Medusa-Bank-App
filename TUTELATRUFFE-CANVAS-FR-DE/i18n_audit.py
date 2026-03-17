import re
import sys
from pathlib import Path

default_path = r"c:\Users\Utente\BancheEuropa\TUTELATRUFFE-CANVAS-FR-DE\index.html"
p = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(default_path)
text = p.read_text(encoding="utf-8", errors="ignore")

used = set(re.findall(r'data-i18n\s*=\s*"([^"]+)"', text))
used_ph = set(re.findall(r'data-i18n-placeholder\s*=\s*"([^"]+)"', text))
used_all = used | used_ph

langs = {}
m = re.search(r"const\s+translations\s*=\s*\{", text)
if m:
    start = m.end() - 1
    brace = 0
    i = start
    end = len(text)
    while i < len(text):
        c = text[i]
        if c == "{":
            brace += 1
        elif c == "}":
            brace -= 1
            if brace == 0:
                end = i + 1
                break
        i += 1
    blob = text[start:end]

    for lm in re.finditer(r"\n\s*([A-Z]{2})\s*:\s*\{", blob):
        lang = lm.group(1)
        s = lm.end() - 1
        b = 0
        j = s
        e = len(blob)
        while j < len(blob):
            ch = blob[j]
            if ch == "{":
                b += 1
            elif ch == "}":
                b -= 1
                if b == 0:
                    e = j + 1
                    break
            j += 1
        body = blob[s:e]
        keys = set(re.findall(r"\n\s*([a-zA-Z0-9_]+)\s*:\s*", body))
        langs[lang] = keys

print("FILE", str(p))
print("USED_KEYS", len(used_all))
print("LANGS", ",".join(sorted(langs.keys())))
for lang in sorted(langs.keys()):
    miss = sorted(k for k in used_all if k not in langs[lang])
    print(f"{lang}_MISSING_COUNT", len(miss))
    if miss:
        print(f"{lang}_MISSING_KEYS", ",".join(miss[:120]))

# Hardcoded visible text candidates without i18n markers
cands = []
for mm in re.finditer(r"<(h1|h2|h3|h4|p|a|button|span|label|option|div)\\b([^>]*)>([^<][^<]{1,140})<", text, re.I):
    tag, attrs, val = mm.group(1), mm.group(2), mm.group(3).strip()
    if not val:
        continue
    if "data-i18n=" in attrs or "data-i18n-placeholder=" in attrs:
        continue
    if "id=\"emoji-" in attrs:
        continue
    if "class=\"emoji-floor-number\"" in attrs:
        continue
    if re.fullmatch(r"[\\W\\d_]+", val):
        continue
    if len(val) < 2:
        continue
    if val.lower().startswith("http"):
        continue
    cands.append((tag, val))

seen = set()
out = []
for t, v in cands:
    k = (t, v)
    if k in seen:
        continue
    seen.add(k)
    out.append(k)

print("HARD_CODED_CANDIDATES", len(out))
for t, v in out[:220]:
    print(f"{t}|{v}")
