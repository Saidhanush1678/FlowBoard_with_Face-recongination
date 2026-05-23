# Use a clean, stable Python base image
FROM python:3.11-slim-bookworm

# Install necessary C/C++ compilation tools and system dependencies for dlib / OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    gfortran \
    git \
    wget \
    curl \
    graphicsmagick \
    libgraphicsmagick1-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
    python3-dev \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory path
WORKDIR /workspace

# Copy dependencies list first to leverage Docker layer caching
COPY requirements.txt .

# Install dependencies via pip
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy over the remaining application directory context components
COPY . .

# Expose production port assigned by Render dynamically
EXPOSE 5050

# Execute server initialization via standard gunicorn threading matrix
CMD gunicorn -w 1 --threads 100 --bind 0.0.0.0:$PORT app:app
