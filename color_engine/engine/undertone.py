# color_engine/engine/undertone.py
"""
Classify skin depth and undertone from corrected RGB values.
"""


def classify_depth(r: int, g: int, b: int) -> str:
    """
    Use HSV Value channel (brightness) to classify skin depth.
    V = max(R, G, B) / 255
    """
    v = max(r, g, b) / 255.0
    if v > 0.72:
        return "Fair"
    elif v > 0.55:
        return "Light"
    elif v > 0.40:
        return "Medium"
    elif v > 0.28:
        return "Tan"
    elif v > 0.16:
        return "Deep"
    else:
        return "Rich"


def classify_undertone(r: int, g: int, b: int) -> str:
    """
    Detect undertone from corrected skin RGB.

    Rules (per spec + olive extension):
      R - B > 15  → Warm
      B - R > 15  → Cool
      G > R and G > B by > 8 → Olive
      Else        → Neutral
    """
    diff_rb = r - b
    diff_br = b - r

    # Check olive first: green channel noticeably dominant
    if g > r and g > b and (g - r) > 8 and (g - b) > 8:
        return "Olive"

    if diff_rb > 15:
        return "Warm"
    elif diff_br > 15:
        return "Cool"
    else:
        return "Neutral"
