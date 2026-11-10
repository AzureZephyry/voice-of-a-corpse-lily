# Manifested Classroom foreground assets

These overlays preserve Wayne's manifested Classroom composition while allowing independent object sorting. All are full-canvas 1280x960 RGBA images aligned to origin (0,0).

| File | KRA layer | Alpha bounds (exclusive) | Scene anchor |
|---|---|---|---|
| classroom_manifested_fg_instructor_desk.png | Paint Layer 7 | (954,465)-(1090,784) | y783, actor Y-sort |
| classroom_manifested_fg_instructor_chair.png | Paint Layer 13 | (1107,645)-(1243,714) | y713, actor Y-sort |
| classroom_manifested_fg_wall_equipment.png | Paint Layer 6 | (1207,382)-(1235,679) | y678, background z=-5 |

Native nonzero layer alpha supplies binary coverage. Covered pixels are copied from the final manifested base, preserving its blended colors and grain rather than raw isolated-layer RGB. Empty pixels are transparent. Recomposition over the base is pixel-identical. The images are baked appearance patches, not separate relightable materials. `foreground_manifest.json` records source layer UUIDs, bounds, pixel counts and base hash.

Place artwork with its top-left at (0,0). The scene uses independent object anchors and corresponding negative artwork offsets. Do not use one permanently topmost overlay group: actors in front must remain in front. A centered full-canvas Sprite2D's default sort position is not the object's feet.

## Remaining depth dependencies

- Layer 17 combines wall/ceiling/floor tendrils and right-side corruption at different depths. It needs artist-authored foreground/background partitions before branches can safely cross actors.
- Layer 8 Merged contains multiple displaced student chairs. Per-chair and overlapping-cluster masks with ground anchors are needed for broader seating occlusion.
- The long instructor desk needs front-edge/top/side partitions for reliable arbitrary side approaches.

Window eyes, roots, books and other unpartitioned details remain in the base. No missing depth geometry is invented. Manifested player movement stays locked; the current foregrounds do not imply free-navigation support.
