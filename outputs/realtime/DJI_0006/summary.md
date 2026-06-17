# Realtime V7 Summary — DJI_0006

## Overall

- Frames processed: `1661`
- Valid estimates: `1288`
- No-estimate frames: `373`
- Coverage: `77.54%`

## Look-at / camera-center error

| Metric | Value |
| --- | ---: |
| Mean error | 74.48 m |
| Median error | 59.33 m |
| P90 error | 148.62 m |
| P95 error | 176.47 m |
| Max error | 787.84 m |
| % under 100 m | 75.16% |
| % under 50 m | 43.71% |
| % under 10 m | 7.14% |
| % under 5 m | 2.33% |

## Drone-position error

| Metric | Value |
| --- | ---: |
| Mean drone error | 82.51 m |
| Median drone error | 68.66 m |
| P90 drone error | 161.86 m |
| P95 drone error | 213.66 m |
| Max drone error | 826.22 m |
| Drone % under 100 m | 69.10% |
| Drone % under 50 m | 38.12% |
| Drone % under 10 m | 6.83% |
| Drone % under 5 m | 3.11% |

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
