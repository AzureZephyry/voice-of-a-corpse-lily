# Scene 02 gameplay and narrative

## Milestone 04.5 — lighting and projected shadows

The story Hallway now uses one scoped illumination controller plus one shared 1921×480 shadow-mask viewport. The original R/M environment laboratory remains unchanged and does not instantiate this lighting. No new native lights, clock, reality controller, source artwork or gameplay collision was introduced.

`hallway_lighting.gd` replaces the former tint-only responsibility: ambient 0.30 at night to 0.38 in daylight, open-rail diffuse fill up to 0.30, and direct daylight up to 0.28. Existing phase colors/boundaries are retained. A separate continuous fractional-time sun trajectory runs from 05:00 to 19:30; this is an artistic corridor projection, not geographic solar accuracy. Cast vectors travel inward (-Y) from the open front railing (+Y), moving from negative X in the morning to positive X in the afternoon. Cast length ratio varies smoothly from 2.4 near the horizon to 0.70 near midday. Color blending remains the shared seven-phase schedule; the sun is not held until a phase's final hour.

The ground background has its own receiver shader. Ground receiving bounds are x44..3842, y350..954; rear walls, doors and stair risers are above that floor band. Upright foreground sprites and actors use the same illumination field without receiving floor-shadow stamps. Direct coverage attenuates direct daylight, not the ambient/diffuse terms. Contacts use a separate green channel and 0.22 Normal / 0.16 Manifested opacity. Lighting is evaluated once per original sprite draw, below the existing glitch/dialogue/HUD layers. The former multiplicative tint/energy/shelter formula is replaced, not stacked on top.

Albert retains his original `ActorShadow2D`; the friends and shared ambient-student scene instance the same component. All 36 contribute feet contacts and current-frame alpha silhouette casts into the same mask. Main actor contacts are 32×8; ambient contacts 30×8. Hallway-local height scale is 0.85, ground depth 0.04, cast strength 0.80. Shared Classroom components and scripts are unchanged. Actors retain their positions, animation, flips and 5× scale. No shadow culling is applied to individual actors: the full-world mask includes offscreen contributors, while the existing crowd's 220px detailed-motion margin exceeds ordinary actor cast reach.

Provisional pillar proxies: centers (924.5,948), (2095.5,948), (3264.5,948); each footprint 100×16, height 240. Their bases are hidden by the lower artwork, so these are conservative inferred contacts, not measured physical geometry and not collisions. The initial weak railing envelope has been replaced by one alpha-only projection of the existing Normal railing PNG. Its native origin is (44,817), bottom anchor y954, height span137, projected height scale1.0 and coverage0.48. The genuine 26px bar rhythm/top rails are reused directly; no individual bar polygons or new image assets are created. It remains an approximate flattened visual-height projection, not a recovered physical guardrail model. Geometry is reprojected only when the sun slope changes sufficiently. Actor pose changes request a shared UPDATE_ONCE redraw; many requests in one frame do not mean many viewport renders.

The existing presentation_changed midpoint notification updates lighting and immediately refreshes current actor atlas regions. Manifested preserves the original art's exposure, retains contacts, and suppresses all ordinary actor/pillar/railing sunlight casts. Normal return samples current GameClock rather than restoring entry-time lighting. GameClock continues beneath manifestations; genuine pause freezes it. No new timing or narrative waits were added.

The second M04.5 refinement makes borrowed classroom-window light readable in the existing ground/background pass. The same six door-glass and six thin-window rectangles measured from Wayne's Normal PNG are retained. `window_spill_gain` is now 0.12 and independent `window_glass_gain` is 0.26. The former 0.07 gain multiplied nearly black glass by only 0.18, and its narrow upper-wall ellipse barely reached the floor; increasing that term alone did not communicate a lit opening. The bounded additive glass term now lifts the actual pane interiors, with a 2px edge feather preserving frames. Thin panes have 1.35 glass weighting but only 0.72 spill weighting. Door wall-fill radii remain 85×125; thin-pane radii are 150×130. A weaker aligned floor lobe centered at y375, gated into the y350 wall/floor junction, couples at 0.50 for door glass and 0.30 for thin windows. No beam, new texture or extra light/shadow source is introduced.

Both contributions follow the existing continuous diffuse daylight fraction, use bounded maxima across openings, and sample the original art for wall/floor lift. Color follows the established time tint with a quarter blend toward warm neutral. Evaluation is bounded to y<520 near the measured openings. Manifested and night suppress both terms; Normal restoration recomputes current GameClock state. Actor/foreground materials, ordinary atmospheric light, pillar/rail casts and protected UI are unchanged. Review outputs are under `milestone04_5_second_refinement`; the earlier reports remain historical baselines.

### Authored player-controlled traversal beats

After the entire friends' closing exchange and lingering look, `hallway_narrative.gd` enters Stage.FREE. Three one-shot leftward thresholds are authored in `traversal_x`: x3000, x2050 and x900. A threshold is eligible only while Albert is actually moving left, the earlier threshold has returned, and RealityPresentation is NORMAL. There is no key-press trigger or random timer. The cues are `hallway_walk_01` through `hallway_walk_03`; `traversal_holds` gives settled Manifested holds of 0.70, 0.90 and 0.75 seconds. Holds start only on the matching transition_finished notification. They stop during a genuine pause and request Normal when elapsed, even if Albert stops or turns around.

Movement remains fully enabled throughout the beats, including both glitches. No slowdown, new dialogue, new echo vocabulary or extra panel is added. HallwayPsychPresentation consumes these cues without drawing a phantom dialogue fracture. Existing world glitch, accepted-transition SFX, actor/HUD protection, midpoint presentation switching and contact-only Manifested lighting remain in charge. Original 0.48/0.42-second transitions (0.22 per direction reduced motion) and covered render checkpoints are unchanged. A configured beat is consumed only after its matching Normal completion; duplicate/busy requests are rejected, and backtracking does not replay it. Cancellation clears pending beat bookkeeping and uses the existing reality cancellation/restoration contract. The staircase checkpoint waits until no beat is active and Normal has settled before announcing Hallway completion.

The full Hallway now has **six manifested segments and twelve accepted directional transitions/SFX starts**: the original three conversation segments/six switches plus three walking segments/six switches. Source dialogue remains 24 Hallway entries plus seven Exterior entries, 31 total. Traversal events are recorded separately from source dialogue; `scene02_story.gd` retains their trace across its existing safe handoff. This is authored visual pacing, with no new screenplay line or story event.

For F6 review, open `scenes/story/scene02_story.tscn`, approach either friend and press E. Advance dialogue with E/Space/click, then walk left when prompted. Complete the friends' quiet exchange, then continue left through all three walking beats toward the staircase and existing Exterior continuation. `hallway_story.tscn` is the Hallway-only wrapper; `hallway_normal_playable.tscn` retains its original R/M laboratory controls and no story lighting. F5 still starts Classroom. There are no new shipping debug keys. Provisional structural geometry and final exposure/pacing require Project Lead visual review.

Graphical Normal/mixed-input, capture-free and reduced-motion full Scene02 runs each passed 109 independent source/order/integration checks. Capture-free UHD620 wall-frame measurements: Normal 59.94 FPS/P95 17.54ms; populated ordinary traversal 60.06/17.48; Manifested 60.03/17.53; transitions 60.08/17.74; walking beats (both directions plus hold) 60.06/17.54. These overlapping workload buckets are not GPU execution times. The existing Exterior walk remains 56.46/21.55, and covered setup had an 82.15ms maximum frame. All 36 shadow participants retained feet/animation synchronization during the runs. Full evidence, controlled lighting comparisons and boundary/integrity results are in the second-refinement review report.

## Milestone 04.4 — gameplay foundation (lighting superseded above)

Open `scenes/story/scene02_story.tscn` and press F6. Albert starts at (3557,610) with normal movement immediately available. Approach Jules or Liezel and use **E**. Space/click retain their dialogue reveal/advance roles after interaction, but do not start the encounter. The laboratory remains `scenes/gameplay/hallway_normal_playable.tscn`, with its original R/M controls and presentation; F5 still starts Classroom.

The initial automatic approach and automatic Hallway departure have been removed. The canonical 24-entry conversation starts only once through the nearest eligible friend. Its first line is always Jules’s. No teleport to a dialogue anchor occurs. The E press that starts it is isolated by the existing reveal/release guards.

Following Albert’s final line, player control returns. A prompt asks the player to walk left past the friends. A departure threshold is set to the smaller of x3390 and 120 pixels left of Albert’s current position. Reaching it briefly locks movement for the full source-exact friends’ quiet exchange, pause and lingering look. Control then returns for the entire leftward journey. A player who explores the staircase before talking cannot bypass the narrative checkpoint.

### Interaction and objectives

`hallway_friend_target.gd` extends the existing OverworldInteractable target’s distance/bounds interface without duplicating dialogue lines. `hallway_friend_interaction.gd` selects one nearest available target (fixed Jules-first tie order), displays the existing gold/shadow prompt style, accepts E and delegates to the narrative. It does not own typewriting or reality state. Both target entries become unavailable after the shared encounter starts.

`scene02_objectives.gd` uses the existing objective_panel.tscn checklist. One current objective is displayed, with scene-local completed IDs carried by the Scene 02 coordinator across the environment handoff:

| State | Objective |
|---|---|
| Initial exploration, conversation and required closing beats | Talk to Jules and Liezel |
| Friends’ final exchange/hold complete | Get some air |
| Free traversal reaches x1900 | Head outside |
| Exterior arrival/short source-authored walk | Find somewhere quiet |
| Quiet-corner composition reached | Take a moment |
| Final authored hold complete | Scene 02 complete |

The objective card occupies the upper left on layer 11. The existing TimeHUD is retained on layer 12, preferentially upper right; no new clock is created. The clock was already instantiated and live in M04.3, confirmed at alpha 1 during audit. The new layer overrides and objective obstacle registration keep it readable above psychological presentation. Dialogue stays on layer 10, world glitch on its established lower layer, and temporary location cover on layer 20. The psychological renderer explicitly protects both objective and interaction prompt bounds.

### Time-of-day presentation

`hallway_lighting.gd` samples fractional GameClock minutes through the existing DayPhase.sample function and its exact seven boundaries (06:30,12:00,15:00,18:00,19:30,21:00,05:00), with the existing final-hour quintic interpolation. Clock speed and autoloads are unchanged.

The new canvas-item shader grades only existing Hallway world sprites and actor sprites. A world-y-dependent covered-space factor reduces fill near the rear wall and relaxes toward the open foreground paving. This is a restrained 2D architectural approximation, not a new physical shadow model. No fullscreen grading pass, resampled artwork, light texture or new viewport is used. Actors share a lower-strength profile for readability. Cropped pillars/railing use original world coordinates, preventing lighting seams.

The lighting component binds the actual drawn material instances through node paths. Nested PackedScene localization can otherwise produce a different material instance from an exported resource reference. Crowd sprites are normalized to one shared crowd-instance material; the controller caches five actual materials, not a new material per frame/student.

The existing Hallway presenter emits a passive presentation_changed notification after its actual midpoint swap. The lighting listener reads the current clock then bypasses ordinary grading while Manifested artwork is active. Normal restoration reuses the current-time profile, with no saved pre-manifestation snapshot. The story-only railing shader retains Albert’s existing silhouette cutout and the same grading contract. The original laboratory material/shader is unchanged. RealityPresentation remains the only state authority; transition timing is unchanged.

### Corridor population

The story instances hallway_crowd.tscn: 33 editor-authored ambient students, 21 route walkers and 12 linger/idlers, distributed across the full 3842-pixel corridor. Only the five existing anonymous classmates are reused: female 01/02/03 and male 01/02. All have verified Normal/Manifested SpriteFrames. Jules and Liezel are never duplicated as ambient students. The two prior one-pass background actors were retired from the story wrapper; their reusable script and prior review evidence remain preserved.

All students retain 5× scale, the existing directional animation script and genuine source frames. Routes, initial waits, endpoint pauses, speed and idle facings are explicitly varied. No additional gesture/phone animation, name, dialogue, voice or hostile event is invented.

The population controller processes nearby actors in detail within viewport width plus a 220-pixel margin; distant movement advances in bounded .3-second steps and pauses sprite animation. Actors remain persistent and are never visibly spawned, wrapped or teleported. No full navigation/crowd framework is installed.

Ambient bodies use the same world collision mask with layer 0, so they cannot physically trap or push Albert. They proactively sidestep/yield to him and steer around opposing walkers/idlers; same-direction traffic may wait. This is soft priority avoidance rather than hard player-blocking physics or perfect dense-crowd simulation. Brief visual near-passes remain possible. Routes stay inside the existing physical perimeter. Tall pillar silhouettes still do not become obstacles.

Draw order remains background → y-sorted actors → railing → pillars. Only Albert drives the approved local pillar fade; the crowd does not globally fade architecture. The same NPC objects change to their mapped Manifested frame resources through the existing adapter, preserving position, route/wait state, animation/frame/progress and occupancy. There is no parallel manifested population or despawn after the conversation.

### Preservation and review

All 31 source entries, six directional Hallway transitions/SFX, three Exterior NO TRIGGER thoughts, the existing safe handoff and exactly-once scene completion are retained. No Classroom handoff or Scene 03 story is installed. The quiet-corner bench/scratches, literal face-drag gesture and dedicated crowd/laughter/phone/ending-note recordings remain human-authored production dependencies. The available Exterior continuation and reversible partial ending mix are preserved.

The temporary graphical evidence, source verifier, captures and review folder from M04.4 were removed during final housekeeping. This document retains the summarized historical results: Normal/reduced-motion/full rapid-input runs each passed 101 source/gameplay checks. Capture-free measurements: Normal 59.98 FPS/P95 18.38 ms; Manifested 59.98/17.70; transitions 59.42/19.10; traversal 60.06/18.22. Matched no-crowd/crowd/time-blend movement measured 60.04/60.06/60.05 FPS. A 43.38 ms startup frame and 87.64 ms covered Exterior setup frame remain measured limitations; Exterior movement measured 57.68 FPS. These are wall-frame intervals, not GPU timings, and are not a current validation run. Earlier sections below describe M04.3 and its measurements; the M04.4 opening, interaction, departure, population, objectives and lighting rules above supersede those earlier rules. Project Lead visual approval was pending in this snapshot.

---

# Milestone 04.3 reference and validation history

## Review entry points

Open `scenes/story/scene02_story.tscn` and press **F6** for the complete standalone Scene 02. F5 still starts the approved Classroom; no Classroom handoff or Scene 03 story is installed.

- `scenes/gameplay/hallway_normal_playable.tscn`: approved environment laboratory, R/M reality controls.
- `scenes/story/hallway_story.tscn`: Hallway-only narrative and intermediate endpoint.
- `scenes/story/scene02_exterior.tscn`: independently playable seven-entry continuation.

E, Space and supported left click reveal/advance the shared dialogue. Reveal-only input is silent. Enter remains unbound under the existing input map. Movement uses the existing movement controls. Following the friends’ final exchange, walk left to x320 or less. The complete entry covers the view, loads the quiet Exterior branch, then starts the continuation once. The final endpoint remains locked and visibly identifies the missing production assets; it does not load Scene 03.

## Source and responsibility

`docs/story/source/scene_02_the_hallway.docx` is authoritative and unchanged. `hallway_screenplay.gd` supplies 24 source-exact dialogue/thought entries and seven silent cues (paragraphs 3–16). `scene02_exterior_screenplay.gd` supplies seven entries and eight cues (paragraphs 18–30). The full order is 31 text entries and 15 cues.

Canonical origin, thought classification, displayed speaker, panel skin and required world reality are separate metadata. Hallway Heard thoughts retain Albert as origin and show ???. Exterior HEARD, NO TRIGGER thoughts show Albert in the white panel with restrained rose text. This distinction does not reveal another identity or imply a failed manifestation.

The existing quiz runner owns reveal/advance input, mandatory holds, same-frame/release gates, and matching reality-completion acknowledgments. Story subclasses supply data and local movement only. RealityPresentation remains the sole reality authority. The shared typewriter’s source-punctuation opt-in and story-local engine font fallback preserve Unicode without editing the original font or screenplay. The long Liezel offer retains the tested Standard layout; other lines use Compact.

## Revised Hallway manifestations (M04.3)

The previous Pair 4 black-panel/Normal-world mismatch came from its deliberate `reality: 0` metadata. The new direction changes that requirement to Manifested:

| Pair | Manifested thoughts | Composition | Restoration |
|---|---|---|---|
| 4 | Idiot. | One restrained IDIOT echo, 0.65-second minimum reading hold | Before Jules’s apology |
| 5 | Both Heard thoughts | Two existing crimson echoes in one segment | Before Jules’s joke |
| 6 | Both Heard thoughts | Four echoes and the existing major fracture profile | Before Jules’s standalone ellipsis |

At the M04.3 baseline there were **three conversation segments, six accepted directional transitions and six transition SFX starts**. The current walking-beat totals are documented above. Existing .48/.42-second entry/return choreography and .22-second reduced-motion choreography are unchanged, including covered source/destination render checkpoints. No redundant switch occurs between consecutive Heard lines.

The Hallway presenter swaps background, railing, all three pillars and the existing four cast frame resources together. It preserves animation/frame/progress, transforms, visibility and collisions. Passing students remain gone after leaving. Albert, friends, HUD and dialogue retain the established protection masks/rectangles. The laboratory leaves the optional cast bindings empty.

## Hallway staging and physical environment

Approved camera, nearest filtering, 5× Albert, collisions, walking band, local pillar fades and railing cutout remain unchanged. Albert starts (3557,425), approaches (3557,550), then makes a controlled departure to (3390,550). Jules remains (3475,495), Liezel (3650,495). Existing passers make one trip without invented dialogue. Friends finish their quiet exchange and pause, Liezel watches left, then free exploration resumes.

The Hallway-only `hallway_segment_completed` remains an intermediate signal, forwarded once at x320. It does not itself claim full Scene 02 completion.

## Exterior composition and production dependencies

The continuation instances the existing `school_exterior_room.tscn`, existing occlusion masks, lighting, sun shadows, player and footsteps. It does not instance the unrelated guard, janitor, objectives or interactions. Native environment placement and the existing 2× character/2× camera conventions are retained; camera limits are 0–1669 by 0–1683.

Albert follows the validated west courtyard walkway from (114.75,640) to (114.75,850), stops and faces right. `BenchArtPending` at (150,850) is an editor-only reservation, not a drawn bench. Final bench position/composition needs directorial approval after genuine artwork delivery. No source asset was altered or replaced.

The three NO TRIGGER thoughts remain Normal. The uncomfortable hold lasts 2.5 seconds, the unfinished-thought beat one second, and the final music hold two seconds. All seven source strings, including punctuation and the final murmur, remain verbatim. The phone stays in his pocket; no phone interface or invented message appears.

Missing human-authored material remains explicit:

- Quiet-corner bench with unreadable scratched initials; existing table/seat art is not substituted.
- Hand-down-face gesture/sitting depiction: current idle/orientation and silent beats only, no invented animation.
- Dedicated Hallway crowd/locker/laughter cues and friends’ laughter.
- Phone vibration recording.
- Authored sustained ending note/stem (and intentional transition from soundtrack).

Existing morning/night outdoor ambience supplies only a legitimate environmental bed. Its scene gain fades to −3 dB, beneath the existing Ambience bus and music; concrete footsteps retain calibrated gain and become relatively exposed. This does not pretend that a crowd recording exists. The ending applies only a gentle 3 dB Music-bus reduction over 1.8 seconds and a hold. It does not synthesize or claim a sustained note. The bus value is restored on cancellation/exit. The persistent soundtrack continues at completion.

## Safe location ownership and completion

`scene02_story.gd` owns the two location branches, not dialogue or reality. The Hallway completion callback verifies closed dialogue and Normal reality, records the trace, locks movement and schedules a deferred handoff. A .25-second black cover renders before the old branch leaves the tree. The preloaded Exterior is attached under the same root, a destination frame renders, and a .35-second uncover completes before its narrative starts. The camera and movement scales change only as part of this explicit location cut. Input during the cover is consumed, and the new runner requires release before accepting advancement.

The shared Time HUD now guards deferred blocker scans after leaving the tree. This fixes a script error reproduced during the first Scene 02 handoff, without changing layout behavior. It is not a fix for the deferred native Classroom hot-exit crash; that path remains untested and prohibited here.

GameClock and AudioDirector autoload instances survive the branch exchange. No clock initialization, hold, music restart or duplicate actor/manager is introduced. Exactly-once `scene_completed` requires accepted Hallway completion, successful Exterior entry, all seven Exterior entries, silent cues, final hold, inactive dialogue and Normal reality. The endpoint is stable and does not advance to another numbered scene.

Cancellation invalidates pending handoff generations, kills the cover tween, clears narrative/typewriter state, settles presentation using the existing authority, restores audio mix, releases control and emits no completion. Scene exit safely invalidates pending work. Reload starts fresh local story state without changing persistent time/music.

## Verification

The M04.3 verifier, graphical captures and temporary evidence directory were removed during final housekeeping. Earlier M04.2 results are historical and use the superseded four-transition policy. This document is not a current verifier; use Godot's present project checks when validating the game.

This build can complete the full narrative with available resources. It is **not artistically complete** until the missing bench, gesture and dedicated audio are supplied and approved. No source artwork, DOCX, character frames, clock rate, audio manager, Classroom or School Exterior implementation is redesigned.

### M04.3 graphical results — 2026-11-08

Normal, reduced-motion and rapid mixed-input complete runs passed 91 independent DOCX/state/count checks each: 31 exact ordered text entries, 46 events, six Hallway transitions/SFX, one handoff and one full completion. Held-key, reveal-only, pause, cover cancellation, loading-input, pending-transition reload and ending-mix cancellation checks passed. The existing Hallway laboratory and F5 Classroom quiz startup passed. The complete Scene 01 screenplay was not replayed.

Capture-free Forward+ repeat on Intel UHD 620: Normal 60.15 FPS/P95 18.34 ms; Manifested 60.00/17.98; transitions 60.16/18.10; Hallway traversal 60.06/18.54; short Exterior entry walk 55.67/22.48; quiet-corner sequence 59.63/18.04. Warm repeated Exterior movement measured 57.37 FPS/P95 21.23 ms. A 100.23 ms Exterior setup frame occurred under the black cover. The prior 51.34 ms echo hitch was not reproduced; first-use canvas pipeline compilation was observed, but its unique causal contribution is not established. These are wall-frame intervals, not GPU timings. No Roblox/OBS/ffmpeg process was detected; broader GPU contention was not exhaustively measured.

See the review report for exact source hashes, file scope, screenshots, complete regression results and remaining bench/gesture/audio dependencies. All changes remain unstaged/uncommitted.
