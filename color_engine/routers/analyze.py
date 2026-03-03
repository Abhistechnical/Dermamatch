# color_engine/routers/analyze.py
"""
POST /analyze — Main skin analysis endpoint.
Orchestrates: face detection → lighting correction → undertone
classification → color conversion → shade recommendation.
"""
import io
import numpy as np
import cv2
from fastapi import APIRouter, File, HTTPException, UploadFile
from PIL import Image

from engine.face_detector import extract_skin_pixels
from engine.lighting_correction import correct_lighting, mean_rgb
from engine.undertone import classify_depth, classify_undertone
from engine.color_engine import rgb_to_hex, rgb_to_cmyk, rgb_to_ryb, compute_pigment_mix
from engine.shade_recommender import recommend_shades
from models.schemas import SkinAnalysisResult, RGBColor, CMYKColor, RYBColor, PigmentMix, RecommendedProduct, SkinMetrics
from database import supabase

router = APIRouter()


def hex_to_rgb(hex_str: str):
    hex_str = hex_str.lstrip('#')
    return [int(hex_str[i:i + 2], 16) for i in (0, 2, 4)]

def rgb_to_lab(rgb):
    # Convert RGB pixel to LAB color space
    pixel = np.uint8([[rgb]])
    lab = cv2.cvtColor(pixel, cv2.COLOR_RGB2LAB)
    return lab[0][0].astype(float)

def calculate_distance(rgb1, rgb2):
    # Use CIE76 color difference in LAB space, which represents human visual perception much better than RGB
    lab1 = rgb_to_lab(rgb1)
    lab2 = rgb_to_lab(rgb2)
    return np.sqrt(np.sum((lab1 - lab2)**2))


async def match_foundation_products(depth: str, undertone: str, target_hex: str):
    """
    Query Supabase for foundations matching depth + undertone and rank by proximity to hex.
    Uses 3-tier fallback: exact match → depth-only → global closest.
    """
    try:
        target_rgb = hex_to_rgb(target_hex)

        # Tier 1: Exact depth + undertone match
        response = supabase.table("foundation_products") \
            .select("*") \
            .eq("depth", depth) \
            .eq("undertone", undertone) \
            .execute()
        products = response.data or []

        # Tier 2: Fallback to depth-only if no exact match
        if not products:
            response = supabase.table("foundation_products") \
                .select("*") \
                .eq("depth", depth) \
                .execute()
            products = response.data or []

        # Tier 3: Fallback to ALL products, sorted by hex distance
        if not products:
            response = supabase.table("foundation_products") \
                .select("*") \
                .execute()
            products = response.data or []

        if not products:
            return []

        # Calculate LAB color distance for each product
        for p in products:
            p_rgb = hex_to_rgb(p['hex_reference'])
            p['distance'] = calculate_distance(target_rgb, p_rgb)

        # Sort by distance and return top 3
        sorted_products = sorted(products, key=lambda x: x['distance'])

        results = []
        for p in sorted_products[:3]:
            results.append(RecommendedProduct(
                id=str(p['id']),
                brand=p['brand'],
                shade_name=p['shade_name'],
                price_range=p['price_range'],
                affiliate_url=p['amazon_affiliate_url'],
                hex_reference=p['hex_reference']
            ))
        return results
    except Exception as e:
        print(f"ERROR in match_foundation_products: {e}")
        return []



@router.post("/analyze", response_model=SkinAnalysisResult, tags=["Analysis"])
async def analyze(file: UploadFile = File(...)):
    print(f"DEBUG: Incoming analysis request for file: {file.filename}")
    """
    Analyze a face photo and return complete skin color profile.
    """
    # ── 1. Decode image ────────────────────────────────────────────
    contents = await file.read()
    try:
        pil_img = Image.open(io.BytesIO(contents)).convert("RGB")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid image file")

    img_rgb = np.array(pil_img)
    img_bgr = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2BGR)

    # ── 2. Face detection & skin region extraction ─────────────────
    skin_pixels = extract_skin_pixels(img_bgr)
    if skin_pixels is None or len(skin_pixels) == 0:
        raise HTTPException(
            status_code=422,
            detail="No face detected. Please upload a clear front-facing photo.",
        )

    # Raw mean RGB (before correction)
    raw_r, raw_g, raw_b = mean_rgb(skin_pixels)

    # ── 3. Lighting correction ────────────────────────────────────
    corrected_bgr = correct_lighting(skin_pixels)
    cor_r, cor_g, cor_b = mean_rgb(corrected_bgr)

    # ── 4. Depth & undertone classification ───────────────────────
    depth = classify_depth(cor_r, cor_g, cor_b)
    undertone = classify_undertone(cor_r, cor_g, cor_b)

    # ── 5. Color conversions ──────────────────────────────────────
    hex_val = rgb_to_hex(cor_r, cor_g, cor_b)
    cmyk = rgb_to_cmyk(cor_r, cor_g, cor_b)
    ryb = rgb_to_ryb(cor_r, cor_g, cor_b)
    pigment = compute_pigment_mix(cor_r, cor_g, cor_b, depth, undertone)

    # ── 6. Shade recommendation ───────────────────────────────────
    shades = recommend_shades(cor_r, cor_g, cor_b, n=3)

    # ── 7. Affiliate Product Matching ────────────────────────────
    matched_products = await match_foundation_products(depth, undertone, hex_val)

    # ── 8. Skin Score & Metrics ───────────────────────────────────
    # Compute skin metrics based on pixel variance and color uniformity
    hsv_pixels = cv2.cvtColor(corrected_bgr.reshape(-1, 1, 3), cv2.COLOR_BGR2HSV)
    h_std = float(np.std(hsv_pixels[:, 0, 0]))
    s_std = float(np.std(hsv_pixels[:, 0, 1]))
    v_std = float(np.std(hsv_pixels[:, 0, 2]))
    v_mean = float(np.mean(hsv_pixels[:, 0, 2]))

    # Hydration: based on saturation variance (lower = more hydrated)
    hydration = max(0, min(100, int(100 - s_std * 2.5)))
    # Texture: based on value variance (lower = smoother)
    texture = max(0, min(100, int(100 - v_std * 1.8)))
    # Evenness: based on hue variance (lower = more even)
    evenness = max(0, min(100, int(100 - h_std * 3.0)))
    # Radiance: based on brightness mean
    radiance = max(0, min(100, int(v_mean * 0.5)))

    skin_score = int((hydration + texture + evenness + radiance) / 4)
    skin_metrics = SkinMetrics(
        hydration=hydration,
        texture=texture,
        evenness=evenness,
        radiance=radiance
    )

    return SkinAnalysisResult(
        depth=depth,
        undertone=undertone,
        raw_rgb=RGBColor(r=raw_r, g=raw_g, b=raw_b),
        corrected_rgb=RGBColor(r=cor_r, g=cor_g, b=cor_b),
        hex=hex_val,
        cmyk=CMYKColor(**cmyk),
        ryb=RYBColor(**ryb),
        pigment_mix=PigmentMix(**pigment),
        skin_score=skin_score,
        skin_metrics=skin_metrics,
        recommended_shades=shades,
        recommended_products=matched_products
    )
