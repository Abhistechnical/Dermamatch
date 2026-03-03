# Root Dockerfile for Mono-repo
FROM python:3.11-slim

# Install system dependencies for OpenCV and MediaPipe
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the backend requirements and install
COPY color_engine/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire backend folder content to the container root
COPY color_engine/ .

# Railway uses the PORT environment variable
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
