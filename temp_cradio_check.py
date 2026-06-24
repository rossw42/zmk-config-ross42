from pathlib import Path

keymap = Path("boards/shields/cradio/cradio.keymap").read_text().splitlines()
transform = Path("boards/shields/cradio/cradio.dtsi").read_text().splitlines()


def parse_layer(lines, layer_name):
    start = None
    for idx, line in enumerate(lines):
        if layer_name in line:
            start = idx
            break
    if start is None:
        raise ValueError(f"Layer {layer_name} not found")

    entries = []
    for line in lines[start + 1:]:
        if line.strip() in (">", ">;"):
            break
        code = line.split("//")[0]
        code = code.replace("<", " ").replace(">", " ")
        tokens = [tok for tok in code.strip().split() if tok and tok not in ("bindings", "=", "{", "}", "};", "{;")]
        entries.extend(tokens)

    grouped = []
    i = 0
    while i < len(entries):
        token = entries[i]
        if token.startswith("&") and i + 1 < len(entries) and not entries[i + 1].startswith("&"):
            grouped.append(token + " " + entries[i + 1])
            i += 2
        else:
            grouped.append(token)
            i += 1
    return grouped


def parse_transform(lines):
    in_map = False
    raws = []
    for line in lines:
        if "map = <" in line:
            in_map = True
            continue
        if in_map:
            if ">" in line:
                break
            for tok in line.strip().split():
                if tok.startswith("RC("):
                    raws.append(int(tok[3:-1].split(",")[1]))
    return raws

keys = parse_layer(keymap, "default_layer")
raws = parse_transform(transform)

print(f"default_layer parsed entries: {len(keys)}")
print(f"transform raw entries: {len(raws)}")
for idx, raw in enumerate(raws):
    if idx < len(keys):
        print(f"{idx:2d}: raw {raw:2d} -> {keys[idx]}")
    else:
        print(f"{idx:2d}: raw {raw:2d} -> ??")
