# Final Report

## Assignment Objective

The yellow part of the assignment asks us to solve the following optical navigation problem:

Given a reference drone flight with video and telemetry, including GNSS, barometric height, and camera angle, preprocess the data so that a new real-time flight can estimate where the drone camera is looking without using GNSS during inference.

Our concrete output is the GPS coordinate of the center point of the video frame. During evaluation, we compare this estimated coordinate with the coordinate derived from the query flight SRT file.

## Data Used

Main benchmark:

| Role | Videos | Drone | Notes |
| --- | --- | --- | --- |
| Reference map | `v11`, `v12`, `v13` | DJI Mini 3 Pro | 1080p, 30 fps, about 119 m, 60 degree camera angle |
| Query/test | `v14` | DJI Mini 3 Pro | GNSS hidden from the algorithm, kept only for evaluation |

Sampling:

- Frames extracted at `1 fps`.
- SRT telemetry parsed for every video.
- Ground-truth video-center points computed geometrically from altitude, camera angle, and heading.

Additional validation data:

| Videos | Drone | Result |
| --- | --- | --- |
| DJI Air 3 `v1` and `v2` | 45 degree camera angle, gimbal metadata available | Useful for checking geometry, not retained as the main visual localization benchmark |

The Air 3 cross-video visual results were much worse than the Mini 3 Pro benchmark, probably because the two flights differ more strongly in path, scale, and scene coverage.

## Retained Pipeline

The final retained pipeline is:

1. **Parse telemetry**

   `src/telemetry_parser.py` converts DJI SRT files into structured CSV files with frame number, time, latitude, longitude, altitude, and camera metadata when available.

2. **Project the video center onto the ground**

   `src/project_ground_point.py` uses a geometric model:

   - drone GNSS position from SRT,
   - relative altitude,
   - camera angle,
   - heading estimated from the trajectory when yaw is unavailable.

   For the Mini 3 Pro flights, we use a fixed 60 degree camera angle and trajectory-derived heading.

3. **Build frame manifests**

   `src/build_frame_manifest.py` joins each extracted frame with its projected ground coordinate. This creates the reference map and the query/evaluation manifest.

4. **Retrieve candidates with frozen DINOv2**

   `src/frozen_dino_cross_retrieval.py` extracts frozen DINOv2 patch descriptors, mean-pools them into one global descriptor per image, and retrieves the nearest reference frames for each query frame.

5. **Verify candidates with LightGlue**

   `src/temporal_lightglue_rerank.py` runs SuperPoint + LightGlue on the DINOv2 top-k candidates and computes local matching quality.

6. **Select a coherent path with Motion Viterbi**

   `src/motion_viterbi_rerank.py` chooses one candidate per query frame while penalizing unrealistic jumps between consecutive estimated positions.

7. **Export visualization**

   `src/export_google_earth_kml.py` exports the drone path, ground-truth center path, and estimated center path to Google Earth.

## Why AnyLoc Is The Main Paper

The main paper we used is **AnyLoc: Towards Universal Visual Place Recognition**.

AnyLoc fits our problem because it proposes training-free visual place recognition with frozen foundation features, especially DINO/DINOv2. This was important for us because we did not want to train on the same drone videos that are later used for evaluation. In our project, the reference flights are a map/database, not a supervised training set.

We adapted the AnyLoc idea rather than copying the full AnyLoc repository:

- same philosophy: frozen visual features, no finetuning,
- same family of descriptors: DINOv2 features,
- same VPR framing: query image against reference database,
- extra assignment-specific layers: DJI SRT parsing, camera-center projection, LightGlue verification, temporal trajectory selection, KML export.

## Experiments

### 1. DINOv2 Global Retrieval Baseline

Reference: `v11 + v12 + v13`  
Query: `v14`  
Sampling: `1 fps`

| Metric | Value |
| --- | ---: |
| Queries | 115 |
| Mean error | 27.28 m |
| Median error | 20.04 m |
| P90 error | 57.63 m |
| Max error | 180.52 m |
| Oracle top-k mean | 16.65 m |
| Oracle top-k median | 12.90 m |

Interpretation: DINOv2 often places the correct or near-correct frame inside the candidate list, but the top-1 candidate is not always the best. That justifies reranking.

### 2. DINOv2 + LightGlue

LightGlue checks whether the query and candidate frame share local geometric evidence. This improves many cases where global descriptors retrieve visually similar but wrong places.

| Metric | Value |
| --- | ---: |
| Mean error | 19.15 m |
| Median error | 15.21 m |
| P90 error | 36.05 m |
| Max error | 72.53 m |

Interpretation: local matching is a strong improvement over raw DINOv2 retrieval.

### 3. DINOv2 + LightGlue + Motion Viterbi

This is the retained best version.

| Metric | Value |
| --- | ---: |
| Queries | 115 |
| Mean error | 18.83 m |
| Median error | 15.21 m |
| P90 error | 36.05 m |
| Max error | 72.53 m |
| Improved frames vs DINO | 61 |
| Worsened frames vs DINO | 29 |
| Unchanged frames vs DINO | 25 |

Configuration:

- DINO top-k candidates scored with LightGlue.
- Candidate limit: `6`.
- Maximum expected step: `20 m`.
- Transition weight: `4`.
- Acceleration weight: `0`.

This is the result we should present as the main implementation.

### 4. Air 3 Geometry And Cross-Video Validation

The DJI Air 3 data contains richer gimbal metadata, so it helped check the geometric projection step.

Geometry comparison using gimbal projection:

| Video | Mean shift vs trajectory-heading approximation | Median | P90 | Max |
| --- | ---: | ---: | ---: | ---: |
| Air 3 `v1` | 53.04 m | 38.89 m | 129.78 m | 198.33 m |
| Air 3 `v2` | 10.32 m | 5.65 m | 11.66 m | 84.06 m |

Cross-video visual localization was poor:

| Direction | Mean error | Median | P90 | Max |
| --- | ---: | ---: | ---: | ---: |
| `v1 -> v2` | 161.80 m | 130.60 m | 341.79 m | 446.40 m |
| `v2 -> v1` | 356.50 m | 419.70 m | 592.07 m | 780.14 m |

Interpretation: Air 3 is useful as a geometry sanity check, but not currently a good visual benchmark for our retained method.

## Rejected Or Non-Retained Attempts

We tested several ideas that did not become the official pipeline:

| Attempt | Outcome |
| --- | --- |
| EMA smoothing of estimated coordinates | Sometimes reduced mean slightly, but created delayed paths and was conceptually weaker than selecting a coherent path directly |
| 2 fps experiments | Added compute cost and complexity without improving the retained result |
| Rotating/cropping reference frames | Did not beat the current best result |
| Direction-change penalty | Did not improve the retained metrics enough to justify keeping it as default |
| DINOv2 VLAD aggregation | Improved raw candidate quality, but did not beat the retained final Motion-Viterbi result |

The repository has been cleaned so these attempts do not appear as the main path.

## Does This Answer The Assignment?

Yes, for the main yellow problem:

- We preprocess reference flight videos and telemetry.
- We build a visual reference database with known camera-center coordinates.
- For a new query video, the algorithm estimates the camera-center coordinate without using query GNSS as an input.
- We compare the estimated path to the captured SRT path for evaluation.
- We provide a KML file for visual inspection in Google Earth.

It also addresses the directions:

| Direction | Status |
| --- | --- |
| Literature review with open-source paper-with-code | Done in `docs/literature_review.md` |
| Complete preprocessing and navigation algorithm | Implemented in `src/` and described here |
| Suitable platform edited for suggested videos | AnyLoc-style DINOv2 + LightGlue VPR stack adapted to DJI SRT videos |
| Preliminary experiment with path comparison | Done on Mini 3 Pro `v14`, exported as CSV and KML |

## Limitations

The biggest limitation is viewpoint ambiguity. Drone frames from nearby places can look extremely similar. Trees, parking lots, roads, and buildings repeat across the campus, so raw image retrieval sometimes selects the wrong nearby location.

The geometry also depends on camera angle and heading. For Mini 3 Pro videos, yaw was not directly available in the SRT, so heading is estimated from the GNSS trajectory during preprocessing/evaluation. Better yaw or gimbal metadata would improve the projected center coordinate.

The current version is real-time compatible in structure, but the LightGlue step is the compute bottleneck. For real-time deployment, we would keep the reference descriptors precomputed, use a small DINO top-k, and run LightGlue only on a limited candidate set.

## Final Deliverables

| File | Purpose |
| --- | --- |
| `README.md` | Build and reproduction guide |
| `scripts/run_best_pipeline.sh` | One-command reproduction of the retained best pipeline |
| `docs/literature_review.md` | AnyLoc/DINOv2/LightGlue review |
| `outputs/anyloc/dji_mini3_cross_v11_v12_v13_to_v14_1fps_motion_viterbi_top6_acc0_results.csv` | Main numerical result |
| `outputs/maps/dji_mini3_v14_google_earth_best_motion_viterbi.kml` | Google Earth visualization |
| `outputs/debug/dji_mini3_v14_worst_retrieval_debug.html` | Debug page for the worst retrieval failures |

## Conclusion

The retained solution is not a trained drone-specific model. It is a clean visual localization pipeline inspired by AnyLoc: frozen DINOv2 descriptors for place recognition, LightGlue for local verification, and a temporal motion prior for navigation consistency. On the main Mini 3 Pro benchmark, it reduces the mean error from 27.28 m to 18.83 m and produces a complete estimated path that can be compared directly with the SRT-derived ground truth.
