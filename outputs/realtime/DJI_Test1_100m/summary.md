# Realtime V7 Summary — DJI_Test1_100m

## Overall

- Frames processed: `739`
- Valid estimates: `444`
- No-estimate frames: `295`
- Coverage: `60.08%`

## Look-at / camera-center error

| Metric | Value |
| --- | ---: |
| Mean error | 97.66 m |
| Median error | 72.46 m |
| P90 error | 195.05 m |
| P95 error | 240.01 m |
| Max error | 397.82 m |
| % under 100 m | 61.26% |
| % under 50 m | 33.11% |
| % under 10 m | 1.35% |
| % under 5 m | 0.00% |

## Drone-position error

| Metric | Value |
| --- | ---: |
| Mean drone error | 130.38 m |
| Median drone error | 94.47 m |
| P90 drone error | 303.20 m |
| P95 drone error | 308.91 m |
| Max drone error | 430.84 m |
| Drone % under 100 m | 52.03% |
| Drone % under 50 m | 33.56% |
| Drone % under 10 m | 2.48% |
| Drone % under 5 m | 0.68% |

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
