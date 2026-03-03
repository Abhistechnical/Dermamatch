# color_engine/engine/shade_recommender.py
"""
Foundation shade database and nearest-match lookup.
Uses Euclidean distance in CIE-LAB color space for perceptually
accurate matching.
"""
from typing import List, Tuple
import numpy as np
import cv2

# ──────────────────────────────────────────────
# Internal shade database (brand-agnostic naming)
# Entries: (name, R, G, B)
# ──────────────────────────────────────────────
SHADE_DB: List[Tuple[str, int, int, int]] = [
    # Fair
    ("Ivory Whisper",         255, 235, 215),
    ("Porcelain Dew",         252, 228, 208),
    ("Pearl Mist",            248, 220, 198),
    ("Alabaster Glow",        245, 215, 192),
    ("Soft Vanilla",          242, 210, 188),
    ("Bare Linen",            238, 205, 182),
    # Light-Fair
    ("Sand Drift",            235, 200, 175),
    ("Warm Nude",             232, 195, 170),
    ("Cashew Cream",          228, 190, 162),
    ("Golden Shell",          225, 185, 155),
    ("Peach Bisque",          220, 180, 150),
    ("Rose Petal",            216, 173, 148),
    # Light
    ("Natural Beige",         210, 165, 140),
    ("Honey Wheat",           205, 158, 132),
    ("Warm Almond",           200, 152, 124),
    ("Toasted Grain",         194, 146, 118),
    ("Spiced Latte",          188, 140, 112),
    ("Apricot Glow",          182, 134, 106),
    # Light-Medium
    ("Golden Sand",           176, 128, 100),
    ("Chai Blend",            170, 122, 94),
    ("Warm Sienna",           164, 116, 88),
    ("Honey Bronze",          158, 112, 82),
    ("Amber Glow",            152, 106, 76),
    ("Toasty Toffee",         146, 100, 70),
    # Medium
    ("Caramel Drizzle",       140, 94, 64),
    ("Rich Mocha",            134, 88, 58),
    ("Deep Toffee",           128, 84, 52),
    ("Warm Chestnut",         122, 80, 48),
    ("Roasted Pecan",         116, 74, 44),
    ("Cinnamon Toast",        110, 70, 40),
    # Tan
    ("Burnished Bronze",      104, 64, 36),
    ("Copper Sable",          98, 60, 32),
    ("Warm Cocoa",            92, 56, 28),
    ("Rich Espresso",         86, 52, 24),
    ("Deep Mahogany",         80, 48, 20),
    ("Sable Earth",           74, 44, 18),
    # Deep
    ("Dark Truffle",          68, 40, 16),
    ("Midnight Cocoa",        62, 36, 14),
    ("Obsidian Glow",         56, 32, 12),
    ("Deep Onyx",             50, 28, 10),
    ("Rich Ebony",            44, 24, 8),
    ("Luxe Shadow",           38, 20, 6),
    # Rich/Deep
    ("Velvet Noir",           32, 16, 5),
    ("Black Pearl",           26, 14, 4),
    ("Midnight Velvet",       20, 12, 4),
    # Cool-undertone specials
    ("Rose Ivory",            252, 225, 215),
    ("Pink Petal",            240, 205, 200),
    ("Mauve Dusk",            200, 160, 155),
    ("Berry Deep",            100, 60, 60),
    # Olive specials
    ("Olive Nude",            195, 165, 120),
    ("Sage Beige",            175, 150, 108),
    ("Earth Olive",           145, 120, 84),
]


def _bgr_to_lab_single(r: int, g: int, b: int) -> np.ndarray:
    """Convert a single RGB to LAB for distance computation."""
    pixel = np.array([[[b, g, r]]], dtype=np.uint8)
    lab = cv2.cvtColor(pixel, cv2.COLOR_BGR2LAB)
    return lab[0, 0].astype(np.float32)


def recommend_shades(r: int, g: int, b: int, n: int = 3) -> List[str]:
    """
    Find the n closest shades to the given RGB in LAB space.
    Returns a list of shade name strings.
    """
    target_lab = _bgr_to_lab_single(r, g, b)

    distances = []
    for (name, sr, sg, sb) in SHADE_DB:
        shade_lab = _bgr_to_lab_single(sr, sg, sb)
        dist = float(np.linalg.norm(target_lab - shade_lab))
        distances.append((dist, name))

    distances.sort(key=lambda x: x[0])
    return [name for _, name in distances[:n]]
