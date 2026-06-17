# Realtime V7 Summary — DJI_Test1_100m

## Overall

- Frames processed: `370`
- Valid estimates: `138`
- No-estimate frames: `232`
- Coverage: `37.30%`

## Look-at / camera-center error

| Metric | Value |
| --- | ---: |
| Mean error | 109.05 m |
| Median error | 103.04 m |
| P90 error | 202.80 m |
| P95 error | 204.18 m |
| Max error | 358.27 m |
| % under 100 m | 49.28% |
| % under 50 m | 26.81% |
| % under 10 m | 0.00% |
| % under 5 m | 0.00% |

## Drone-position error

| Metric | Value |
| --- | ---: |
| Mean drone error | 132.67 m |
| Median drone error | 88.00 m |
| P90 drone error | 300.71 m |
| P95 drone error | 308.83 m |
| Max drone error | 309.19 m |
| Drone % under 100 m | 54.35% |
| Drone % under 50 m | 30.43% |
| Drone % under 10 m | 2.17% |
| Drone % under 5 m | 0.72% |

## Metric notes

- Valid estimate frames are frames where the realtime localizer output an estimated coordinate. NO_ESTIMATE frames are intentionally skipped because the system was uncertain.
- Coverage is valid_estimate_frames divided by frames_processed.
- Mean error is the arithmetic average distance between the estimated look-at point and the SRT-derived ground-truth look-at point, in metres.
- Median error is the middle error value; half of evaluated estimates are below it and half are above it.
- P90 error means 90 percent of evaluated estimates have error less than or equal to this value.
- P95 error means 95 percent of evaluated estimates have error less than or equal to this value.
- % under 100m / 50m / 10m / 5m is the percentage of evaluated valid estimates whose error is less than or equal to that threshold. It is not divided by all frames, only by frames that have a valid estimate and ground truth.
- Drone-position error compares estimated drone GPS position to SRT drone GPS position. Look-at/camera-center error compares estimated camera-center ground coordinate to the SRT-derived camera-center ground coordinate.
- When no SRT/ground truth is available, accuracy metrics are N/A and only estimated paths are exported.
