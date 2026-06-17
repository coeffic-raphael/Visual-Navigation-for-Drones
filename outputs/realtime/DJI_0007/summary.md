# Realtime V7 Summary — DJI_0007

## Overall

- Frames processed: `520`
- Valid estimates: `465`
- No-estimate frames: `55`
- Coverage: `89.42%`

## Look-at / camera-center error

| Metric | Value |
| --- | ---: |
| Mean error | 70.57 m |
| Median error | 65.29 m |
| P90 error | 127.02 m |
| P95 error | 139.92 m |
| Max error | 401.13 m |
| % under 100 m | 74.19% |
| % under 50 m | 43.01% |
| % under 10 m | 11.40% |
| % under 5 m | 1.94% |

## Drone-position error

| Metric | Value |
| --- | ---: |
| Mean drone error | 46.98 m |
| Median drone error | 18.31 m |
| P90 drone error | 106.53 m |
| P95 drone error | 156.74 m |
| Max drone error | 414.00 m |
| Drone % under 100 m | 86.67% |
| Drone % under 50 m | 66.67% |
| Drone % under 10 m | 41.29% |
| Drone % under 5 m | 32.04% |

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
