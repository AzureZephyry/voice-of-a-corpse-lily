# Approved Milestone 1 baseline

Independent Month of Horror 2 project. The official title was undecided when this
baseline was written; the project is now titled Withering Away.

Milestone 1 — Normal Classroom Foundation is approved. Open `project.godot` with Godot 4.7.2 Stable. The existing main scene remains unchanged.

- Foundation: `scenes/gameplay/classroom_normal.tscn`.
- Development movement preview: `scenes/gameplay/classroom_normal_preview.tscn`; run with F6 and use the existing arrow/WASD controls.
- Albert starts at (754, 628), facing right, at a Classroom-only 5x sprite scale. Camera: fixed (640, 480), zoom 1x, viewport 1280 x 960, nearest filtering.
- Student seats and supports are solid. The four uppermost backrest footprints allow the cabinet-side horizontal pathway; their visual backs still sort in front of Albert.
- Instructor table and television are solid. Instructor standing position (1122, 572) and seat anchor (1154, 620) remain approachable without a staff-side exclusion.
- Foregrounds use transparent silhouettes derived from Wayne's unchanged layered source; floor remains below Albert. Source/export provenance is in `assets/environments/classroom/foreground/source_manifest.json`.
- Existing character resources, movement, and reusable game systems are included. Local editor caches and iteration artifacts are excluded from Git.

This baseline does not implement instructor NPCs, Classroom dialogue/cinematics, manifestations, or Milestone 2.
