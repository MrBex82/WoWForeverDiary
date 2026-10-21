"""Renders the stains of the worn parchment: blood, sweat and tears, as one 512x512 picture with alpha.

Usage: python tools/gen_stains.py WoWForeverDiary/Media/stains.tga [preview.png]

Four cells of 256x256 (read in Lua as quarters of the picture):
  top left     a blood splatter with spray and a drip
  top right    a second blood splash, smaller, with a trail
  bottom left  sweat: salty tide rings, uneven and broken
  bottom right tears: three small rings with a paler middle
The pictures are white-balanced for the parchment (dark red / tan / cream) and carry their shape in the
alpha channel; dried liquid is darker at its rim, as a drop dries from the outside in.
Needs numpy and Pillow.
"""
import sys

import numpy as np
from PIL import Image

C = 256
rng = np.random.default_rng(1021)
YY, XX = np.mgrid[0:C, 0:C].astype(float)


def smooth_noise(cells, seed):
    r = np.random.default_rng(seed)
    g = r.random((cells + 1, cells + 1))
    img = Image.fromarray((g * 255).astype(np.uint8)).resize((C, C), Image.BICUBIC)
    return np.asarray(img, dtype=float) / 255.0


def fbm(seed, base=4, octaves=4):
    total, amp, norm = np.zeros((C, C)), 0.5, 0.0
    for o in range(octaves):
        total += amp * smooth_noise(base * 2 ** o, seed + o * 17)
        norm += amp
        amp *= 0.5
    return total / norm


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)


def blob(cx, cy, radius, wobble, seed, stretch=(1.0, 1.0), angle=0.0):
    """signed distance of an irregular blob: > 0 inside; stretch and angle make it an ellipse"""
    ca, sa = np.cos(angle), np.sin(angle)
    dx, dy = XX - cx, YY - cy
    u = (dx * ca + dy * sa) / stretch[0]
    v = (-dx * sa + dy * ca) / stretch[1]
    dist = np.sqrt(u * u + v * v)
    n = fbm(seed, 4, 5) - 0.5
    return radius * (1 + wobble * n * 2) - dist


def wet(sd, soft=1.6):
    return smoothstep(-soft * 0.5, soft, sd)


def paint(layers, shape_alpha, colour, centre_alpha, rim_alpha, sd, rim_w=4.0):
    """a dried drop: alpha from the shape, darker at the rim"""
    inside = np.clip(sd / 14.0, 0, 1)                      # 0 at the edge, 1 deep inside
    rim = np.exp(-np.clip(sd, 0, None) / rim_w)            # strongest right at the edge
    a = shape_alpha * (centre_alpha * (0.55 + 0.45 * inside) + (rim_alpha - centre_alpha) * rim * 0.9)
    layers.append((np.clip(a, 0, 1), colour))


def compose(layers):
    """layers of (alpha, rgb) into one rgba picture"""
    out_a = np.zeros((C, C))
    out_c = np.zeros((C, C, 3))
    for a, col in layers:
        col = np.array(col, dtype=float)
        new_a = a + out_a * (1 - a)
        with np.errstate(invalid="ignore", divide="ignore"):
            w = np.where(new_a > 0, a / new_a, 0)
        out_c = out_c * (1 - w[..., None]) + col[None, None, :] * w[..., None]
        out_a = new_a
    return out_a, out_c


def splatter(seed, spray_dir, size):
    r = np.random.default_rng(seed)
    layers = []
    cx, cy = C / 2 + r.uniform(-8, 8), C / 2 + r.uniform(-14, -4)
    main = blob(cx, cy, size, 0.75, seed + 1)
    paint(layers, wet(main), (0.32, 0.02, 0.02), 0.74, 0.95, main)
    # a thicker pool in the middle
    core = blob(cx + r.uniform(-4, 4), cy + r.uniform(-4, 4), size * 0.5, 0.8, seed + 2)
    paint(layers, wet(core), (0.22, 0.012, 0.01), 0.40, 0.0, core)
    # fingers of blood reaching out of the pool: stretched, pointing away from the middle
    for i in range(7):
        ang = spray_dir + r.normal(0, 1.1)
        reach = size * r.uniform(1.0, 1.5)
        d = blob(cx + np.cos(ang) * size * 0.8, cy + np.sin(ang) * size * 0.8, reach * 0.42, 0.5, seed + 30 + i,
                 stretch=(1.9, 0.55), angle=ang)
        paint(layers, wet(d, 1.2), (0.32, 0.02, 0.02), 0.72, 0.93, d, 2.5)
    # spray: droplets thrown out along one direction, stretched along their flight, thinning with distance
    for i in range(34):
        ang = spray_dir + r.normal(0, 0.65)
        dist = size * r.uniform(1.5, 3.4) * (0.55 + 0.7 * r.random())
        px, py = cx + np.cos(ang) * dist, cy + np.sin(ang) * dist
        rad = max(1.1, r.uniform(1.2, 6.5) * (1.25 - dist / (size * 4.2)))
        st = (1.0 + r.uniform(0.3, 1.8), 1.0)
        d = blob(px, py, rad, 0.5, seed + 50 + i, stretch=st, angle=ang)
        paint(layers, wet(d, 1.0), (0.32, 0.02, 0.02), 0.78, 0.96, d, 2.0)
    # a drip running down from the pool: a tongue ending in a bulb
    dx = cx + r.uniform(-size * 0.5, size * 0.5)
    length = r.uniform(34, 62)
    y_start = cy + size * 0.55
    for k in range(int(length)):
        t = k / length
        width = 5.6 * (1 - 0.45 * t) + 0.8
        d = blob(dx + np.sin(k * 0.10) * 1.2, y_start + k, width, 0.08, seed + 200 + k % 5)
        paint(layers, wet(d, 0.8) * (0.95 - 0.2 * t), (0.30, 0.02, 0.015), 0.72, 0.90, d, 1.8)
    bulb = blob(dx, y_start + length, 7.5, 0.25, seed + 300)
    paint(layers, wet(bulb, 1.2), (0.30, 0.02, 0.015), 0.78, 0.96, bulb, 3.0)
    return compose(layers)


def sweat(seed):
    r = np.random.default_rng(seed)
    layers = []
    cx, cy = C / 2, C / 2
    n1, n2, n3 = fbm(seed, 3, 4) - 0.5, fbm(seed + 9, 5, 3), fbm(seed + 21, 6, 3)
    ang = np.arctan2(YY - cy, XX - cx)
    dist = np.sqrt((XX - cx) ** 2 + (YY - cy) ** 2)
    outer = 88 * (1 + 0.20 * n1 * 2)
    fill = 1 - smoothstep(outer - 6, outer + 2, dist)
    # the damp patch: faint, slightly darker in the middle
    layers.append((fill * (0.10 + 0.05 * n2), (0.62, 0.46, 0.20)))
    # tide marks: where the salt dried, several rings drawn closer and closer together, broken by gaps
    for k, f in enumerate((1.0, 0.86, 0.70, 0.52)):
        rr = outer * f * (1 + 0.05 * (fbm(seed + 40 + k, 4, 3) - 0.5) * 2)
        ring = np.exp(-((dist - rr) ** 2) / (2 * (2.2 - 0.3 * k) ** 2))
        gap = smoothstep(0.38, 0.62, fbm(seed + 70 + k, 7, 3))
        layers.append((ring * gap * (0.46 - 0.07 * k), (0.52, 0.36, 0.14)))
    # crystals of salt: a few tiny pale flecks
    for _ in range(40):
        a = r.uniform(0, 2 * np.pi)
        rr = 88 * r.uniform(0.2, 1.0)
        px, py = cx + np.cos(a) * rr, cy + np.sin(a) * rr
        d = blob(px, py, r.uniform(1.0, 2.2), 0.3, seed + 500 + int(rr))
        layers.append((wet(d, 0.8) * 0.35, (1.0, 0.96, 0.82)))
    return compose(layers)


def tears(seed):
    r = np.random.default_rng(seed)
    layers = []
    for i, (px, py, rad) in enumerate(((C * 0.30, C * 0.34, 30), (C * 0.66, C * 0.52, 22), (C * 0.40, C * 0.74, 17))):
        sd = blob(px, py, rad, 0.55, seed + i * 11)
        dist_in = np.clip(sd, 0, None)
        rim = np.exp(-dist_in / 2.6) * smoothstep(-1.0, 1.2, sd)
        gap = smoothstep(0.38, 0.52, fbm(seed + 90 + i, 6, 3))       # the ring breaks where it dried unevenly
        layers.append((wet(sd, 1.2) * 0.13, (1.0, 0.95, 0.80)))        # the middle is a little paler
        layers.append((rim * (0.10 + 0.36 * gap), (0.46, 0.30, 0.12)))  # the dried rim
        # a faint outer halo
        halo = np.exp(-np.clip(-sd, 0, None) / 5.0) * (sd < 0)
        layers.append((halo * 0.10, (0.50, 0.34, 0.14)))
    return compose(layers)


def to_cell(rgba):
    a, c = rgba
    return np.dstack([np.clip(c * 255 + 0.5, 0, 255), np.clip(a * 255 + 0.5, 0, 255)]).astype(np.uint8)


def write_tga(path, img):
    h, w, _ = img.shape
    with open(path, "wb") as f:
        f.write(bytes([0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, w % 256, w // 256, h % 256, h // 256, 32, 0x28]))
        bgra = img[..., [2, 1, 0, 3]]
        f.write(bgra.tobytes())


def main():
    cells = [
        to_cell(splatter(11, np.pi * 0.15, 36)),
        to_cell(splatter(23, np.pi * 0.85, 24)),
        to_cell(sweat(31)),
        to_cell(tears(41)),
    ]
    atlas = np.zeros((2 * C, 2 * C, 4), np.uint8)
    atlas[0:C, 0:C] = cells[0]
    atlas[0:C, C:2 * C] = cells[1]
    atlas[C:2 * C, 0:C] = cells[2]
    atlas[C:2 * C, C:2 * C] = cells[3]
    # transparent pixels keep the colour of their neighbours, so a filtered edge does not turn dark
    mask = atlas[..., 3] == 0
    atlas[mask, :3] = (150, 100, 50)
    write_tga(sys.argv[1], atlas)
    if len(sys.argv) > 2:
        bg = Image.new("RGBA", (2 * C, 2 * C), (226, 198, 146, 255))
        bg.alpha_composite(Image.fromarray(atlas, "RGBA"))
        bg.save(sys.argv[2])
    print("wrote", sys.argv[1])


if __name__ == "__main__":
    main()
