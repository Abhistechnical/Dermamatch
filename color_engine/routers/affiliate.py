# color_engine/routers/affiliate.py
from fastapi import APIRouter, HTTPException
from models.schemas import ClickTrackingRequest
from database import supabase

router = APIRouter()

@router.post("/track-click", tags=["Affiliate"])
async def track_click(request: ClickTrackingRequest):
    """
    Log an affiliate link click to Supabase.
    """
    try:
        response = supabase.table("affiliate_clicks")\
            .insert({
                "product_id": request.product_id,
                "user_id": request.user_id
            })\
            .execute()
        return {"status": "success", "message": "Click tracked"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to track click: {e}")
