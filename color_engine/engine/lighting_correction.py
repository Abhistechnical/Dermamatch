# color_engine/engine/lighting_correction.py
"""
Remove lighting bias (shadows, highlights) from a pixel array.
Uses LAB color space and IQR-based outlier trimming.
"""
import numpy as np
import cv2


def correct_lighting(pixels_bgr: np.ndarray) -> np.ndarray:
    """
    Given an (N, 3) BGR pixel array, remove lighting bias and
    return a corrected (N, 3) BGR array.

    Steps:
    1. Convert to LAB
    2. Trim luminance outliers (shadows < Q10 and highlights > Q90)
    3. Convert back to BGR
    """
    if pixels_bgr.ndim == 1:
        pixels_bgr = pixels_bgr.reshape(1, -1)

    # Reshape to (1, N, 3) for OpenCV color conversion
    strip = pixels_bgr.reshape(1, -1, 3).astype(np.uint8)
    lab = cv2.cvtColor(strip, cv2.COLOR_BGR2LAB)
    lab_flat = lab.reshape(-1, 3)  # (N, 3)

    L = lab_flat[:, 0].astype(np.float32)
    lo, hi = np.percentile(L, 10), np.percentile(L, 90)
    keep = (L >= lo) & (L <= hi)

    # If trimming removes too many pixels, keep all
    trimmed = lab_flat[keep] if keep.sum() > 30 else lab_flat

    # Compute mean after trimming -> our corrected color
    mean_lab = trimmed.mean(axis=0).astype(np.uint8)

    # Return as single corrected pixel for downstream averaging
    single = mean_lab.reshape(1, 1, 3)
    corrected_bgr = cv2.cvtColor(single, cv2.COLOR_LAB2BGR)
    return corrected_bgr.reshape(1, 3).astype(np.uint8)


def mean_rgb(pixels_bgr: np.ndarray) -> tuple[int, int, int]:
    """Compute mean BGR then return as (R, G, B)."""
    mean = pixels_bgr.mean(axis=0).astype(int)
    if mean.ndim == 0:
        b, g, r = int(mean[0]), int(mean[1]), int(mean[2])
    else:
        b, g, r = int(mean[0]), int(mean[1]), int(mean[2])
    return r, g, b
