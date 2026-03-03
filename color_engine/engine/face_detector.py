# color_engine/engine/face_detector.py
"""
Detect face landmarks using MediaPipe FaceMesh and extract
forehead + cheek pixel regions for skin-tone sampling.
"""
import numpy as np
import cv2
from typing import Optional

# No longer using landmark indices as we switched to region-based cropping via OpenCV box



def extract_skin_pixels(image_bgr: np.ndarray) -> Optional[np.ndarray]:
    """
    Detect face using OpenCV Haar Cascades and return skin pixels.
    This replaces MediaPipe which is currently broken on Python 3.13.
    """
    # Load pre-trained Haar Cascade for face detection
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    
    gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.3, 5)

    if len(faces) == 0:
        return None

    # Use the largest face found
    x, y, w, h = sorted(faces, key=lambda f: f[2]*f[3], reverse=True)[0]
    
    # Define skin sampling regions relative to face box:
    # 1. Forehead: Top center (y + 15% to 30%, centered 40% width)
    # 2. Cheeks: Middle sides (y + 45% to 65%, sides 20% width)
    
    regions = [
        (int(y + 0.15*h), int(y + 0.30*h), int(x + 0.3*w), int(x + 0.7*w)),   # Forehead
        (int(y + 0.45*h), int(y + 0.65*h), int(x + 0.15*w), int(x + 0.35*w)), # Left Cheek
        (int(y + 0.45*h), int(y + 0.65*h), int(x + 0.65*w), int(x + 0.85*w)), # Right Cheek
    ]
    
    all_pixels = []
    for (y1, y2, x1, x2) in regions:
        # Clamp to image boundaries
        y1, y2 = max(0, y1), min(image_bgr.shape[0], y2)
        x1, x2 = max(0, x1), min(image_bgr.shape[1], x2)
        
        region_pixels = image_bgr[y1:y2, x1:x2].reshape(-1, 3)
        if len(region_pixels) > 0:
            all_pixels.append(region_pixels)

    if not all_pixels:
        return None

    combined = np.vstack(all_pixels)
    
    # Simple brightness filtering to remove shadows/highlights
    brightness = combined.mean(axis=1)
    mask_valid = (brightness > 40) & (brightness < 220)
    filtered = combined[mask_valid]
    
    return filtered if len(filtered) > 50 else combined
