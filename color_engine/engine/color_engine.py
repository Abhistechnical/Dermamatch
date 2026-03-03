# color_engine/engine/color_engine.py
"""
Convert corrected RGB to HEX, CMYK, RYB, and pigment mixing formula.
All logic is pure Python/NumPy — no external APIs required.
"""
from typing import Tuple
import numpy as np

# ──────────────────────────────────────────────
# 1. RGB → HEX
# ──────────────────────────────────────────────

def rgb_to_hex(r: int, g: int, b: int) -> str:
    return "#{:02X}{:02X}{:02X}".format(r, g, b)


# ──────────────────────────────────────────────
# 2. RGB → CMYK
# ──────────────────────────────────────────────

def rgb_to_cmyk(r: int, g: int, b: int) -> dict:
    """
    Returns C, M, Y, K as percentages (0–100).
    """
    if r == 0 and g == 0 and b == 0:
        return {"c": 0.0, "m": 0.0, "y": 0.0, "k": 100.0}

    r_, g_, b_ = r / 255.0, g / 255.0, b / 255.0
    k = 1 - max(r_, g_, b_)
    if k == 1:
        return {"c": 0.0, "m": 0.0, "y": 0.0, "k": 100.0}

    c = (1 - r_ - k) / (1 - k)
    m = (1 - g_ - k) / (1 - k)
    y = (1 - b_ - k) / (1 - k)

    return {
        "c": round(c * 100, 1),
        "m": round(m * 100, 1),
        "y": round(y * 100, 1),
        "k": round(k * 100, 1),
    }


# ──────────────────────────────────────────────
# 3. RGB → RYB (Approximate)
# ──────────────────────────────────────────────

def rgb_to_ryb(r: int, g: int, b: int) -> dict:
    """
    Approximate RGB → RYB conversion.
    Based on Nathan Gossett & Baoquan Chen's algorithm.
    Scaled to 0–255 range.
    """
    r_, g_, b_ = r / 255.0, g / 255.0, b / 255.0

    # Remove white
    white = min(r_, g_, b_)
    r_ -= white; g_ -= white; b_ -= white

    max_g = max(r_, g_, b_)

    # Shift yellow out of green
    yellow = min(r_, g_)
    r_ -= yellow; g_ -= yellow

    # If blue & red mix to magenta, shift to RYB blue
    if b_ > 0 and g_ > 0:
        b_ /= 2.0; g_ /= 2.0

    yellow += g_; b_ += g_

    # Normalize
    max_ryb = max(r_, yellow, b_)
    if max_ryb > 0 and max_g > 0:
        factor = max_g / max_ryb
        r_ *= factor; yellow *= factor; b_ *= factor

    # Add white back
    r_ += white; yellow += white; b_ += white

    return {
        "r": round(r_ * 255),
        "y": round(yellow * 255),
        "b": round(b_ * 255),
    }


# ──────────────────────────────────────────────
# 4. Pigment Mixing Formula
# ──────────────────────────────────────────────

def compute_pigment_mix(
    r: int, g: int, b: int,
    depth: str,
    undertone: str,
) -> dict:
    """
    Compute pigment mixing ratios (Yellow, Red, Blue, White, Black)
    summing to exactly 100%.

    Rules:
    - Undertone drives hue channel ratios (Yellow / Red / Blue)
    - Depth drives white (lightening) or black (deepening)
    """
    # --- Step 1: Hue base from undertone ---
    # All units are "parts" before normalisation
    parts = {"yellow": 0.0, "red": 0.0, "blue": 0.0, "white": 0.0, "black": 0.0}

    undertone_profiles = {
        "Warm":    {"yellow": 50, "red": 35, "blue": 5},
        "Cool":    {"yellow": 20, "red": 20, "blue": 50},
        "Neutral": {"yellow": 35, "red": 30, "blue": 20},
        "Olive":   {"yellow": 45, "red": 20, "blue": 25},
    }
    profile = undertone_profiles.get(undertone, undertone_profiles["Neutral"])
    for k, v in profile.items():
        parts[k] = float(v)

    hue_total = parts["yellow"] + parts["red"] + parts["blue"]  # e.g. 90

    # --- Step 2: Depth adjusts white/black budget ---
    depth_budget = {
        "Fair":   {"white": 55, "black": 0},
        "Light":  {"white": 40, "black": 0},
        "Medium": {"white": 20, "black": 5},
        "Tan":    {"white": 5,  "black": 15},
        "Deep":   {"white": 0,  "black": 25},
        "Rich":   {"white": 0,  "black": 35},
    }
    budget = depth_budget.get(depth, {"white": 10, "black": 10})
    wb_total = budget["white"] + budget["black"]

    # --- Step 3: Scale hue parts to fill (100 - wb_total) ---
    hue_target = 100.0 - wb_total
    scale = hue_target / hue_total if hue_total > 0 else 1.0

    parts["yellow"] *= scale
    parts["red"] *= scale
    parts["blue"] *= scale
    parts["white"] = float(budget["white"])
    parts["black"] = float(budget["black"])

    # --- Step 4: Fine RGB correction (micro-adjustment) ---
    # Use relative channel strength to tweak within 5% window
    total_rgb = r + g + b
    if total_rgb > 0:
        y_boost = (r + g) / total_rgb  # warm channels → yellow
        b_boost = b / total_rgb

        parts["yellow"] = parts["yellow"] * (0.85 + 0.15 * y_boost)
        parts["blue"] = parts["blue"] * (0.85 + 0.15 * b_boost)

    # --- Step 5: Normalise to exactly 100% ---
    total = sum(parts.values())
    if total > 0:
        parts = {k: round(v / total * 100, 1) for k, v in parts.items()}

    # Fix floating point drift: adjust yellow
    remainder = round(100.0 - sum(parts.values()), 1)
    parts["yellow"] = round(parts["yellow"] + remainder, 1)

    return parts
