# Literature Review

## Scope

The assignment asks for recent algorithms and tools for low-altitude drone visual navigation, with emphasis on open-source "paper with code" methods. Our implementation focuses on the part of the problem where a new GNSS-denied video frame must be localized against a preprocessed reference flight.

For that reason, the most relevant family of methods is visual place recognition (VPR): build a database of reference images with known positions, then retrieve the closest visual match for each query image.

## Main Paper: AnyLoc

The main paper used in this project is **AnyLoc: Towards Universal Visual Place Recognition** by Keetha et al. The paper and code are available from:

- Paper: https://anyloc.github.io/assets/AnyLoc.pdf
- Repository: https://github.com/AnyLoc/AnyLoc

AnyLoc is relevant because it addresses the exact type of decision we faced: should we train a place-recognition model on our own drone data, or should we use frozen general-purpose visual features? AnyLoc argues for the second option. It uses features extracted from large self-supervised foundation models, especially DINO/DINOv2, without task-specific VPR finetuning. The paper evaluates across many environments, including aerial data, and shows that frozen foundation features combined with unsupervised aggregation can be competitive and more general than methods trained for a specific VPR dataset.

The conceptual AnyLoc pipeline is:

1. Extract dense ViT patch features from a frozen foundation model.
2. Aggregate those local features into a global image descriptor.
3. Compare query descriptors with database descriptors.
4. Retrieve the most visually similar reference images.

AnyLoc studies aggregation methods such as global average pooling, GeM, and VLAD. The paper's key lesson for us is that training on our own SRT-labelled video is not necessary and would be suspicious for evaluation if the same area is used for both reference and test. A frozen model makes the experiment cleaner: the reference flight is a map, not a training set.

## How We Used AnyLoc

We did not integrate the full AnyLoc repository as-is. Instead, we implemented an AnyLoc-style pipeline that fits the assignment:

- Frozen DINOv2 descriptors from drone frames.
- A reference database built from `v11`, `v12`, and `v13`.
- A query flight `v14`, evaluated only after matching.
- No supervised training or finetuning on our drone videos.
- A coordinate output, not just a retrieved image ID.

Our final retained descriptor is DINOv2 mean pooling over patch tokens. We also tested more AnyLoc-like VLAD aggregation. VLAD improved the raw candidate pool but did not improve the final temporally selected trajectory in our current setup, so it is described as an experiment rather than the official pipeline.

## DINOv2

DINOv2 is the frozen visual backbone used by our pipeline:

- Paper/code: https://github.com/facebookresearch/dinov2

DINOv2 is useful here because it provides strong self-supervised features without training on the target task. For each frame, we extract ViT patch tokens and aggregate them into one descriptor. This descriptor becomes the visual signature used for large-scale retrieval.

Advantages:

- No GNSS labels are needed to train the model.
- No domain-specific finetuning is required.
- It is robust enough to retrieve visually similar drone viewpoints.

Limitations:

- A single global descriptor can confuse nearby places with similar texture, roads, trees, or buildings.
- It is not a geometric method by itself; it says "this looks similar", not "this pose is physically consistent".

## LightGlue And SuperPoint

The second important open-source method is LightGlue:

- Paper/code: https://github.com/cvg/LightGlue

LightGlue performs local feature matching efficiently. In our pipeline, DINOv2 proposes a small top-k list of candidate reference frames. LightGlue then verifies whether the query and candidate share enough local keypoint correspondences. This helps reject some false positives from global DINO retrieval.

We use SuperPoint keypoints with LightGlue. The local matching score is summarized with:

- number of matches,
- RANSAC inliers,
- inlier ratio.

These values are used in reranking and temporal path selection.

## Temporal Motion Prior

The assignment is about a flight sequence, not isolated images. Consecutive frames should not jump randomly across the map. We therefore add a temporal Viterbi selector over the DINOv2 + LightGlue candidates.

This stage is not a learned model. It is a sequence optimizer:

- visual score rewards high DINO similarity and good LightGlue matching,
- transition score penalizes implausibly large jumps between consecutive estimated positions,
- the selected path is the minimum-cost sequence through the candidate graph.

This is what turns independent frame retrieval into a navigation trajectory.

## Relation To The Assignment

The assignment asks for a platform for drone optical navigation and an edited solution for the suggested videos. In this project, the "platform" is an adapted open-source VPR stack:

- DINOv2 as the frozen foundation feature extractor,
- AnyLoc as the methodological basis for training-free place recognition,
- LightGlue as local geometric verification,
- our SRT parser, camera-center projection, and trajectory selector around those components.

The output is not only a classification or retrieval score. The final CSV and KML estimate the GPS coordinate of the point at the center of each query video frame.

## Why We Did Not Train A Model

Training a model on the same site would risk overfitting to the assignment data and would make the evaluation less meaningful. AnyLoc explicitly motivates training-free VPR using pretrained foundation features. We follow that philosophy: the reference videos are used as a map/database, not as supervised training data.

## Limitations And Future Work

Our retained implementation uses mean-pooled DINOv2 patch descriptors, which are simpler than the strongest AnyLoc settings. We tested VLAD-style aggregation and found better raw retrieval candidates, but the final trajectory did not improve yet. A future improvement would be to revisit VLAD with better vocabulary selection, tune candidate fusion, and use camera yaw/gimbal metadata when available.

The remaining weak point is viewpoint ambiguity. Drone images from nearby locations often share the same visual elements from slightly different angles, so the correct candidate may be visually close but not ranked first. This is why the debug page remains important: it shows query frames, top candidates, LightGlue scores, and the local map position of the retrieved matches.
