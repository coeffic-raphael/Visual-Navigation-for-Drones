# Realtime V7 Summary — DJI_0009

## Overall

- Frames processed: `229`
- Valid estimates: `217`
- No-estimate frames: `12`
- Coverage: `94.76%`

## Look-at / camera-center error

| Metric | Value |
| --- | ---: |
| Mean error | 28.64 m |
| Median error | 18.84 m |
| P90 error | 67.83 m |
| P95 error | 82.25 m |
| Max error | 176.43 m |
| % under 100 m | 98.16% |
| % under 50 m | 81.11% |
| % under 10 m | 23.50% |
| % under 5 m | 5.99% |

## Drone-position error

| Metric | Value |
| --- | ---: |
| Mean drone error | 22.89 m |
| Median drone error | 15.40 m |
| P90 drone error | 46.13 m |
| P95 drone error | 58.20 m |
| Max drone error | 176.04 m |
| Drone % under 100 m | 98.16% |
| Drone % under 50 m | 92.17% |
| Drone % under 10 m | 25.35% |
| Drone % under 5 m | 9.22% |

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
