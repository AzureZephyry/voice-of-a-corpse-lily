# Hallway — standalone reality-presentation test

Open `scenes/gameplay/hallway_normal_playable.tscn` and use **Run Current Scene (F6)**. F5 still launches the approved Classroom. Use the existing WASD/arrow controls. The spawn at `(480,610)` is development-only, not an authored Scene 02 entrance.

In debug builds, press **R** to switch reality and **M** to toggle reduced motion between transitions. Held-key echoes and requests during transitions are ignored. Disable `RealityDebug.enabled` or omit that node when integrating the screenplay; these are test controls, not narrative events. The retained scene filename is the approved Milestone 02 entry.

## Assets and rendering

The five Normal PNGs under `assets/environments/hallway/` are byte-for-byte copies of Wayne's validated Milestone 01 exports. Milestone 03 adds five validated Manifested exports, described below. Neither source KRA is modified. No dialogue, doorway triggers or scene handoff are included.

| Sprite | Canvas-space top-left | Native dimensions | Draw order |
|---|---|---|---|
| `hallway_normal_background.png` | `(0,0)` | 3842 × 960 | Background, z -10 |
| `foreground/hallway_normal_fg_railing.png` | `(44,817)` | 3798 × 137 | Above actors, effective z 11 |
| `foreground/hallway_normal_fg_pillar_01.png` | `(861,516)` | 127 × 443 | Above railing, effective z 12 |
| `foreground/hallway_normal_fg_pillar_02.png` | `(2032,516)` | 127 × 443 | Above railing, effective z 12 |
| `foreground/hallway_normal_fg_pillar_03.png` | `(3201,516)` | 127 × 443 | Above railing, effective z 12 |

All artwork is uncentered, scale 1, with the original top-left canvas origin. Imports use lossless compression, no mipmaps and no size limit. Both scene roots select nearest texture filtering.

`scenes/environments/hallway/hallway_normal_room.tscn` owns Background, Foreground and Geometry. `scenes/gameplay/hallway_normal_playable.tscn` instances that environment, the existing Player, FootstepAudio and TimeHUD, plus Camera2D and a local ForegroundVisibility component.

## Navigation and camera

Albert uses the existing movement controller and animation assets at scale 5. Only this scene overrides the feet collider to 24 × 14, centered seven pixels above the player origin. Movement speed remains the shared 150 pixels/second.

The provisional physical perimeter is a rear wall ending at y350, a front safety boundary starting at y800, and end walls at x80/x3786. With the feet collider, measured player-origin limits are approximately x92–3774 and y364–800. Vertical movement remains available within this band. The blue rear-floor strip is traversable.

The front boundary is deliberately inset from the railing: an earlier y920 candidate hid too much of Albert behind the rail. This is a gameplay visibility assumption awaiting visual approval, not a claim about an artist-specified collision anchor. The pillar bases are obscured outside the usable band; tall pillar sprite rectangles are not collision shapes. No speculative stair or door functionality is present.

The Camera2D uses zoom 1, fixed y480, no smoothing and limits `(0,0)` to `(3842,960)`. The host follows the player after player physics, clamps its center to x640–3202 at the 1280 × 960 viewport, and rounds camera positions to whole pixels.

## Foreground visibility

Faithful opaque foreground rendering completely hid Albert behind the first pillar. `scripts/hallway_foreground_visibility.gd` therefore fades only an actually overlapping pillar to 0.38 opacity, over 0.18 seconds, with an 0.08-second clear delay. The railing remains opaque.

Overlap uses cached foreground and actor-frame alpha bitmaps, not the actor's transparent texture rectangle. It is reevaluated when the actor transform, visible frame, flip or visibility changes. This scene uses fixed pillar transforms. Only three existing sprites are affected; no shader, extra viewport, texture regeneration or tween is added. Original opacity is restored on exit.

## Persistent systems

The host calls the existing idempotent `AudioDirector.ensure_gameplay_music()`. It creates no music player, resets no clock and changes no autoload. Footsteps use the existing interior surface and Footsteps bus. TimeHUD is the existing upper-right HUD. Genuine scene-tree pause stops movement and GameClock.

No Hallway-specific dynamic daylight, shadow receiver, ambient cue or reality presenter is introduced in this milestone. The artwork is displayed faithfully without a new lighting tint.

## Validation — Godot 4.7.2, 2026-11-07

Actual graphical Forward+ runs on Intel UHD 620, native viewport 1280 × 960, VSync enabled:

- Full traversal by movement input, all three pillars, both horizontal limits and both vertical bounds passed. Camera centers remained between x640 and x3202 with y480 fixed.
- Three runtime reconstruction captures, at camera x640, x1921 and x3202, matched their corresponding approved composite crops with **zero differing pixels**. Actor/HUD and local fading were disabled only for these diagnostic captures.
- All three pillars faded individually and restored. Alpha-only overlap tests confirmed transparent actor padding does not trigger fading.
- Three Hallway reloads retained 43 nodes, zero orphan nodes, the same clock/audio autoloads and continuing music position. Pause testing produced no clock or player movement during the pause.
- School Exterior and Classroom startup smoke checks passed. The complete Scene 01 screenplay was not replayed in this milestone.
- No Hallway parsing errors, runtime errors or warnings were recorded.

Three independent eight-second movement samples were measured without screenshots/recording during sampling:

| Sample | Average FPS | Mean frame time | P95 frame time | Worst frame |
|---|---:|---:|---:|---:|
| Left-to-middle, crossing pillar 1 | 60.21 | 16.61 ms | 17.34 ms | 20.00 ms |
| Right-to-middle, crossing pillar 3 | 60.07 | 16.65 ms | 17.74 ms | 31.99 ms |
| Final configuration, crossing pillar 1 | 60.21 | 16.61 ms | 17.66 ms | 21.04 ms |

These are wall-clock frame intervals, not GPU timings. They support approximately 60 FPS in the sampled runs, not a guarantee of hitch-free performance under all loads.

### Known independent hot-exit issue

A forced live scene change out of active Classroom dialogue is a confirmed native crash. On 2026-11-10 it reproduced from the current F5 route (Main Menu → Start → connected story), while the visible line was “Okay.” A forced direct change to `res://scenes/gameplay/school_exterior_playable.tscn` terminated Godot 4.7.2 with signal 11 at frame 1844. The native backtrace contains no symbols, so the cause remains unknown. This forced change is not the guarded connected-story handoff. No lifecycle rewrite was attempted during housekeeping.

## Review evidence and remaining scope

Temporary screenshots, source hashes and repository snapshots from this review were removed during final housekeeping. The final y800 boundary was accepted; the y920 railing placement was rejected. The measurements and decisions retained in this document are the available historical record.

The Normal scale, walking band and pillar fade were approved after Milestone 02. Screenplay entry/exit, NPC events and Scene 01/03 connections remain unimplemented by design.

## Milestone 03 — interchangeable Manifested presentation

The gameplay scene retains one environment, one Albert, one camera and one physical collision set. `HallwayRealityPresenter` swaps textures and local positions on the same five Sprite2D nodes. It saves the Normal texture/position bindings once; it never saves or restores clock time, player motion, camera state or audio position.

| Manifested sprite | Canvas-space top-left | Native dimensions |
|---|---|---|
| `hallway_manifested_background.png` | `(0,0)` | 3842 × 960 |
| `foreground/hallway_manifested_fg_pillar_01.png` | `(839,0)` | 175 × 960 |
| `foreground/hallway_manifested_fg_pillar_02.png` | `(2003,0)` | 194 × 960 |
| `foreground/hallway_manifested_fg_pillar_03.png` | `(3173,0)` | 174 × 959 |
| `foreground/hallway_manifested_fg_railing.png` | `(44,707)` | 3798 × 247 |

These are byte-identical copies of the color-correct validated exports. Native blend-layer appearance is baked into the approved PNGs; no Color/Overlay/Multiply treatment is reapplied at runtime. Draw order remains background → actors → railing → pillars. No Classroom window shader, furniture mask, lighting tint or new horror artwork is added.

### Authority, effect and protection

The scene instances the existing `reality_presentation.gd` and `scenes/components/reality_glitch.tscn` unchanged. The adapter implements only `can_present_manifested()`, `present_manifested()` and `present_normal()`. RealityPresentation remains the sole state authority; busy/redundant requests are rejected, the existing covered-frame checkpoint owns the midpoint swap, and completion follows stabilization. Entry/return settings remain .48/.42 seconds, reduced-motion .22 seconds, plus the established rendered-frame checkpoints. Actual wall time can extend under capture stalls.

The existing alpha-mask protection reads Albert's current animated atlas frame and canvas transform, including the scrolling camera. Both displaced samples and destination pixels are protected. The TimeHUD is above the effect and its frame is also bound to the existing HUD exclusion rectangle. No extra world viewport or permanent full-screen pass is introduced; the effect and back-buffer copy disable when settled.

`ForegroundVisibility.refresh_foregrounds()` restores old alphas, rebinds the three current pillar alpha masks and resolves overlap before the newly swapped presentation is uncovered. Normal fade settings remain .38 opacity, .18 seconds and .08-second clear delay. Only the affected pillar fades.

The raised Manifested rail obscures Albert near the approved y800 front bound. `RailingVisibility` therefore uses a local material on that rail only: its alpha becomes .38 over Albert's current protected silhouette, while all other railing pixels remain unchanged. This is a readability treatment, not new art or collision geometry. Normal restores its original material. Unlike fading the entire 3798-pixel rail, the treatment is limited to the actual silhouette overlap. The component disables processing in Normal.

### Accepted-transition sound

`TransitionAudio` listens only to `RealityPresentation.transition_started`. It uses Lawrence's three existing glitch WAVs with the established seeded no-adjacent-repeat shuffle bag, seek offsets .015/.650/.040 seconds, gains -12/-14/-12 dB and SFX bus routing. Two fixed scene-owned players permit a 40 ms retiring tail while the next accepted transition starts. Bound fades are canceled on slot reuse and exit. No new music manager, ambience cue, ducking or dialogue sound is added. Continuous AudioDirector music is independent of reality switching.

### Integration boundary

This is environment presentation only. Movement stays enabled during both visual transitions and settled realities. The shared physical geometry is unchanged. Future narrative code can call the same authority APIs and await `transition_finished`; it should remove/disable the isolated debug node. Do not introduce another reality state machine. The independent native Classroom hot-exit crash documented above remains a mandatory blocker before the real Scene 01 handoff; Milestone 03 does not exercise or resolve it.

### Milestone 03 graphical results — 2026-11-07

Both realities were checked at the two camera edges and all three pillars. Full-corridor traversal by movement input passed in both directions, with unchanged camera limits and all three local pillar overlaps observed. The rear feet limit remained y364.0065; the approved front limit remained y800. Stationary transitions preserved position and moving transitions kept the original controller running.

Six artwork-only runtime captures (three camera centers per reality) match the validated composites with zero differing pixels. A further Manifested capture with the rail material active and Albert hidden also matches exactly. Six moving glitch captures checked 3,425–3,900 opaque actor pixels each against their current source frames: none differed by more than one RGB level. This verifies the animated silhouette during camera movement, rather than only relying on shader uniforms.

Eight immediate busy requests per direction were rejected; accepted switches each emitted one glitch sound. Held R produced one switch, and four rapid presses during the reverse effect produced one reverse switch. A ten-second combined walking/transition run accepted 17 switches and played exactly 17 sounds, with all three variants used and no adjacent variant repetition. Configured durations remain unchanged; capture-free observed entry/return wall times were approximately .515/.449 seconds, including covered-frame checkpoints (one first entry was .533 seconds).

Pause froze player movement, fractional clock and transition progress. Paused R did not change reality or start audio. The music cursor settled within approximately one output buffer (11.6 ms) of the pause request. Resume completed the pending transition normally. Reduced-motion cycles took approximately .249–.251 seconds including checkpoints and preserved stationary position. Cancellation settled the accepted target once; a second cancel was rejected.

Three reloads while Hallway transitions were pending returned to a clean Normal scene, with consistent node counts, zero orphan nodes, unchanged persistent clock/audio instances and no additional music starts. No Classroom hot-exit test was run. No new project parsing errors, runtime errors or warnings were recorded.

Capture-free Forward+ measurements on Intel UHD 620, 1280 × 960, VSync enabled:

| Sample | Duration / frames | FPS | Mean ms | P95 ms | Worst ms |
|---|---|---:|---:|---:|---:|
| Normal full traversal | 25.21 s | 60.06 | 16.65 | 17.50 | 20.63 |
| Manifested full traversal | 25.21 s | 60.06 | 16.65 | 17.31 | 19.21 |
| Moving transitions | 479 transition frames | 60.11 | 16.64 | 17.73 | 25.61 |
| Manifested front rail overlap | 8 s | 60.06 | 16.65 | 17.28 | 18.83 |

These are wall-clock frame intervals, not GPU execution timings. Known Roblox/OBS/ffmpeg processes were absent; comprehensive system GPU contention telemetry was unavailable. No material regression from the approximately 60 FPS baseline was observed in these samples. The temporary review evidence and source-integrity files have since been removed; this summary preserves their measured results.
