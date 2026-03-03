# color_engine/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import analyze, affiliate

app = FastAPI(
    title="DermaMatch AI - Color Engine",
    description="Skin tone analysis and color matching microservice",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(analyze.router)
app.include_router(affiliate.router, prefix="/affiliate")


@app.get("/health")
async def health():
    return {"status": "ok", "service": "DermaMatch AI Color Engine"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
