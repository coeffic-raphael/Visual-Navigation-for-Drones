# Realtime V7 Summary — DJI_0008

## Overall

- Frames processed: `1661`
- Valid estimates: `1384`
- No-estimate frames: `277`
- Coverage: `83.32%`

## Look-at / camera-center error

| Metric | Value |
| --- | ---: |
| Mean error | 87.46 m |
| Median error | 56.14 m |
| P90 error | 155.33 m |
| P95 error | 195.20 m |
| Max error | 942.92 m |
| % under 100 m | 70.88% |
| % under 50 m | 45.01% |
| % under 10 m | 7.30% |
| % under 5 m | 0.87% |

## Drone-position error

| Metric | Value |
| --- | ---: |
| Mean drone error | 82.52 m |
| Median drone error | 51.11 m |
| P90 drone error | 165.19 m |
| P95 drone error | 227.24 m |
| Max drone error | 930.07 m |
| Drone % under 100 m | 76.66% |
| Drone % under 50 m | 49.06% |
| Drone % under 10 m | 19.44% |
| Drone % under 5 m | 9.25% |

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
