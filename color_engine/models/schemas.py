# color_engine/models/schemas.py
from pydantic import BaseModel
from typing import List


class RGBColor(BaseModel):
    r: int
    g: int
    b: int


class CMYKColor(BaseModel):
    c: float
    m: float
    y: float
    k: float


class RYBColor(BaseModel):
    r: float
    y: float
    b: float


class PigmentMix(BaseModel):
    yellow: float
    red: float
    blue: float
    white: float
    black: float


class RecommendedProduct(BaseModel):
    id: str
    brand: str
    shade_name: str
    price_range: str
    affiliate_url: str
    hex_reference: str


class SkinAnalysisResult(BaseModel):
    depth: str
    undertone: str
    raw_rgb: RGBColor
    corrected_rgb: RGBColor
    hex: str
    cmyk: CMYKColor
    ryb: RYBColor
    pigment_mix: PigmentMix
    recommended_shades: List[str]
    recommended_products: List[RecommendedProduct] = []


class ClickTrackingRequest(BaseModel):
    product_id: str
    user_id: str
