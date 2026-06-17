These are some of the debugging outputs that we had while experimenting with the offline approach

The pipeline then was roughly this:

    SRT parsing + reference frame extraction
    → visual retrieval
    → geometric verification
    → strict gating
    → multiscale retrieval for height/zoom mismatch
    → LightGlue verification
    → temporal consensus
    → local/context reruns
    → fixed grid regions
    → path consistency / candidate upgrade
    → final full-path KML

These are ideas that were implemented and tested in an offline manner and may be somehow implemented in a realtime fashion:

## Strict gating ##

We stop accepting weak matches just because they had some visual similarity.

We add checks like:

    minimum matches
    minimum RANSAC inliers
    minimum inlier ratio
    projected center must be plausible
    homography geometry must not be bad
    temporal jumps must not be impossible

Goal:

Reduce wrong accepted matches.

*But it could also reject many correct refrences with weak matches.*

##DINO / AnyLoc retrieval##

This replaced weaker visual retrieval with stronger global descriptors.

Pipeline idea:

    query frame
    → DINOv2 / AnyLoc descriptor
    → retrieve top-k visually similar reference frames

This helped because DINO features are much stronger than simple ORB/color retrieval for aerial scenes.

## Multiscale retrieval ##

This was added to try and tackle the dron height difference issue where DINOv2 and AnyLoc would treat the images as if they are 
at the same height.

A lower drone sees buildings/trees larger. A higher reference flight sees them smaller.

Additionally the viewable area by the 30m height drone is much smaller then the one of a 119m height drone, so only a small 
section of the refrence image should be refrenced and not hte whole image.  

So we tried query scales like:

1.0
0.8
0.6
0.5
0.4
0.3
0.2

Goal:

Make a query frame from one altitude look more like a reference frame from another altitude.

This is one of the main things that helped us improve our query to refrence matching.

## LightGlue multiscale verification ##

After DINO/AnyLoc retrieved candidates, LightGlue checked whether the query/reference pair actually matched geometrically.

Pipeline:

DINO/AnyLoc top-k candidates
→ SuperPoint/LightGlue feature matching
→ RANSAC / homography scoring
→ choose best verified candidate

This was much stronger than raw retrieval alone.

## Debug cluster / inlier-spread filtering ##

This stage looked at where the LightGlue/RANSAC inliers landed.

The idea was:

A good match should have enough inliers,
and those inliers should form a plausible spatial pattern.

It tried to reject cases where:

matches were technically found,
but the geometry looked suspicious.

This is related to our later V7 spread-consistency idea.

## Temporal consensus ##

Instead of trusting each frame independently, we start finding reliable anchor frames and grouping them into stable regions.

It did something like:

find high-confidence accepted frames
→ cluster them into GPS regions
→ detect jumps/gaps/bad frames
→ prepare reruns for suspicious frames

This is one of the main reasons the old KML became visually cleaner.

It used the fact that nearby frames should usually stay in the same area.

## Temporal context rerun ##

After testing we tried to improve the reruns.

Instead of rerunning a bad frame in the region it originally guessed, it used nearby stable anchors to decide where it should search.

So a bad frame could be rerun using candidate regions from:

previous trusted anchors
next trusted anchors
globally common stable regions

This is very important: it means the pipeline used future context.

That makes it offline/post-processing and not realtime.

## Fixed grid regions ##

We changed the region system to fixed map grid cells.

Instead of arbitrary clusters, it used stable geographic grid regions.

Goal:

Make local reruns more stable and prevent the search region from drifting.

This helped with cases where the path started in the wrong area or jumped to a visually similar wrong area.

## Path consistency overlay/filter ##

This stage rejected isolated jumps.

Example:

correct area
→ one frame jumps far away
→ next frame returns to correct area

We would say:

that middle point is probably a false match

and either reject or fill/interpolate it.

## Candidate upgrade top25 metricfix full path ##

We cheapend our regularrun by lowering to around top 8 and increaced our rerun frames to do top25.

meaning we spent less time in the start with the idea that obvious matched will happen either way,

and dedicated that time to the reruns because they were more problamatic.

That way we might optimize dedicating more time to bad frames and less time to easy ones.




## In short what we had was ##

    Offline AnyLoc/DINO + multiscale retrieval + LightGlue verification
    + strict geometric gating
    + temporal consensus
    + local fixed-grid reruns
    + path consistency / candidate upgrade

    It was designed mainly on:

    DJI_0010
    DJI_0011

