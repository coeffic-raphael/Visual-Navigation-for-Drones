#!/usr/bin/env bash
# setup.sh — Preprocess all raw DJI Mini 3 Pro videos for the navigation pipeline.
#
# Run this once after cloning the repo and placing the .mp4 files in data/raw/.
# After this script completes, run:  ./scripts/run_best_pipeline.sh
#
# Requirements:
#   - ffmpeg installed (brew install ffmpeg)
#   - Python venv activated: source .venv-anyloc/bin/activate
#
# Expected raw files in data/raw/:
#   DJI_v11.mp4  DJI_v11.SRT
#   DJI_v12.mp4  DJI_v12.SRT
#   DJI_v13.mp4  DJI_v13.SRT
#   DJI_v14.mp4  DJI_v14.SRT

set -euo pipefail

PYTHON_BIN="${PYTHON_BIN:-.venv-anyloc/bin/python}"
CAMERA_ANGLE=60
HEADING_SOURCE=trajectory

# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

if ! command -v ffmpeg &>/dev/null; then
  echo "ERROR: ffmpeg not found. Install it with: brew install ffmpeg"
  exit 1
fi

if ! "${PYTHON_BIN}" -c "import torch" &>/dev/null; then
  echo "ERROR: Python venv not set up. Run:"
  echo "  python3 -m venv .venv-anyloc"
  echo "  source .venv-anyloc/bin/activate"
  echo "  pip install -r requirements-anyloc.txt"
  exit 1
fi

for v in v11 v12 v13 v14; do
  mp4="data/raw/DJI_${v}.mp4"
  srt="data/raw/DJI_${v}.SRT"
  if [[ ! -f "$mp4" ]]; then
    echo "ERROR: Missing $mp4 — place the raw video files in data/raw/ first."
    exit 1
  fi
  if [[ ! -f "$srt" ]]; then
    echo "ERROR: Missing $srt — SRT telemetry file not found."
    exit 1
  fi
done

echo "=== All checks passed. Starting preprocessing... ==="
echo ""

mkdir -p data/processed

# ---------------------------------------------------------------------------
# Helper: preprocess one video
# ---------------------------------------------------------------------------

preprocess_video() {
  local version="$1"       # e.g. v11
  local mp4="data/raw/DJI_${version}.mp4"
  local srt="data/raw/DJI_${version}.SRT"
  local frames_dir="data/processed/frames_${version}_1fps"
  local telemetry_csv="data/processed/DJI_${version}_telemetry.csv"
  local projection_csv="data/processed/DJI_${version}_ground_projection_${CAMERA_ANGLE}deg.csv"
  local manifest_csv="data/processed/DJI_${version}_frame_manifest_1fps.csv"

  echo "--- [$version] Extracting frames at 1 fps ---"
  mkdir -p "$frames_dir"
  if [[ -z "$(ls -A "$frames_dir" 2>/dev/null)" ]]; then
    ffmpeg -i "$mp4" -vf fps=1 "${frames_dir}/frame_%06d.jpg" -loglevel warning
    echo "    $(ls "$frames_dir" | wc -l | tr -d ' ') frames extracted."
  else
    echo "    Already extracted ($(ls "$frames_dir" | wc -l | tr -d ' ') frames), skipping."
  fi

  echo "--- [$version] Parsing SRT telemetry ---"
  "${PYTHON_BIN}" src/telemetry_parser.py "$srt" "$telemetry_csv"

  echo "--- [$version] Projecting ground center (${CAMERA_ANGLE}° fixed, heading=${HEADING_SOURCE}) ---"
  "${PYTHON_BIN}" src/project_ground_point.py \
    "$telemetry_csv" \
    "$projection_csv" \
    --camera-angle-deg "$CAMERA_ANGLE" \
    --camera-angle-source fixed \
    --heading-source "$HEADING_SOURCE"

  echo "--- [$version] Building frame manifest ---"
  "${PYTHON_BIN}" src/build_frame_manifest.py \
    "$frames_dir" \
    "$projection_csv" \
    "$manifest_csv" \
    --fps 1

  echo "    Done: $manifest_csv ($(wc -l < "$manifest_csv") rows)"
  echo ""
}

# ---------------------------------------------------------------------------
# Preprocess all four videos
# ---------------------------------------------------------------------------

preprocess_video v11
preprocess_video v12
preprocess_video v13
preprocess_video v14

# ---------------------------------------------------------------------------
# DINOv2 third-party checkout
# ---------------------------------------------------------------------------

if [[ ! -d "third_party/dinov2/.git" ]]; then
  echo "--- Cloning DINOv2 ---"
  mkdir -p third_party
  git clone --depth 1 https://github.com/facebookresearch/dinov2.git third_party/dinov2
  echo "    Done."
  echo ""
else
  echo "--- DINOv2 already cloned, skipping. ---"
  echo ""
fi

echo "=== Setup complete! ==="
echo ""
echo "Model weights will be downloaded automatically on first run."
echo "Now run the full pipeline:"
echo ""
echo "    ./scripts/run_best_pipeline.sh"
echo ""
