# Scene 01 reality presentation

Scene 01, "Time Called", runs from classroom opening through the concluding quiz-paper narration. It contains 19 unidentified-voice lines in 16 Manifested segments and 32 directional reality transitions. These totals describe the current screenplay, not controller limits. Scene 02 is implemented in the connected-story host.

## Ownership and transition contract

`ClassroomOpening/RealityPresentation` is the only reality authority. Its states are NORMAL, GLITCH_IN, MANIFESTED and GLITCH_OUT. Public requests `request_manifestation(cue)` and `request_normal(cue)` return whether a request was accepted. Busy and redundant requests are rejected rather than queued. Signals are `state_changed`, `transition_started(from,toward,cue)` and `transition_finished(state,cue)`.

`ClassroomRealityPresenter` handles assets, collision enable states and lighting; it never owns dialogue. `RealityGlitch` is passive visual presentation. The authority holds the distortion midpoint until a covered source frame has rendered, swaps presentation, then renders the covered destination before stabilization. Only the final completion releases dialogue. Cancellation settles the authorized target exactly once; scene exit disables presentation without late completions. Scenes without an effect use a generation-guarded deferred swap.

Normal and Manifested artwork are exclusive siblings under `Foundation/Classroom/Presentation`. The Foundation and Classroom inherited paths remain editable in the story scene so the local Manifested child survives scene packing. No scene reload is used.

## Narrative and input

The shared quiz renderer, inherited by dismissal and Professor conversation, keeps `speaker`, panel `style` and required `reality` separate. Unidentified perceived speech uses ??? and the black panel. Named ordinary thoughts/dialogue use the light panel. A speaker string does not decide world state.

The renderer interrupts and clears the old reveal, hides dialogue and stores one pending authored step during a transition. Text, cues and mandatory reading intervals begin only after matching completion. Consecutive Manifested lines share one segment. Ordinary cues and sequence handoffs restore Normal first. Inputs during transitions/mandatory holds are discarded; held keys/clicks and same-frame repeats cannot advance twice. Typewriter completion alone never advances a line or restores reality.

`text_type.gd` supports `arm_interruption(character_count,event_id)`, `authored_interruption_reached` and `interrupt_reveal`. Counts refer to normalized displayed text. Reveal-all respects an armed boundary; revision checks prevent canceled or reentrant callbacks from appending old characters to replacement text. Current Professor pairs are authored after completed clean passages, not at invented character positions.

The local screenplay reference is `docs/story/source/scene_01_time_called.docx` (team source, separately maintained). Runtime dialogue resides in the story controllers and does not load the DOCX. Source ellipses and curved apostrophes use existing display substitutions for missing font glyphs.

## Manifestation inventory

| Host | Segment IDs | Voice lines |
|---|---|---:|
| Quiz | did_you, losing_race, slow, excuses + answer_paper, die, times_up, fraud, imposter | 9 |
| Dismissal | is_it, just_excuses | 2 |
| Professor opening | embarrassing, didnt_have_to | 2 |
| Professor pairs | pair_one, pair_two, pair_three | 5 |
| Closing | asshole | 1 |

The Professor sequence keeps actual speech separate from Albert's perception:

1. Professor: "It's a very common mistake." -> Pair 1 / ???: "Common, Like everyone else." then "That's all you'll ever be." -> Normal.
2. Professor: "You'll get it, don't worry." -> Pair 2 / ???: "You should've gotten it already." -> Normal.
3. Professor: "And Albert, come to me earlier next time. Don't wait until after the quiz." -> Pair 3 / ???: "Too f*cking late." then "You waited too long." -> Normal.
4. Albert: "....Thank you, sir." Professor: "Anytime." Final ??? thought: "A**hole." -> Normal paper narration.

The clean excerpt "Come to me earlier next time" identifies the preceding full advice; it is not delivered twice. Pair metadata records ID, clean reference, trigger, heard passages, speaker/style and return reference. Started-pair guards prevent reentry. No identity is revealed for ???.

The concluding source staging appears as nameless light-panel narration: Albert picks up his paper, focuses on its red mark, and tightens his hand around the edge. No new paper illustration or unapproved hand animation is required.

## Completion boundary

After the final reading and hold, the conversation clears dialogue, settles Normal, completes the instructor objective and emits `conversation_finished`. The root emits `scene_completed` exactly once and shows "Scene 01 complete". Movement remains deliberately locked at this endpoint; input does not replay the ending. GameClock and music continue. A standalone Scene 01 run remains at this endpoint; `connected_story.gd` consumes completion and advances the connected run to Scene 02.

## Character continuity and depth

The adapter accepts locked narrative segments and rejects free exploration or active opening/dismissal blackouts. It swaps SpriteFrames only on currently visible cast members, preserving animation name, frame, progress, play/pause and flip. Dismissed classmates remain hidden. Albert's sprite, scale and position are never replaced.

| Existing NPC | Manifested PNG stem | SpriteFrames resource |
|---|---|---|
| Jules | jules_manifested_idle / walk | jules_manifested_frames.tres |
| Liezel | liezel_manifested_idle / walk | liezel_manifested_frames.tres |
| ClassmateMale01 | classmate_male_manifested_01_idle / walk | classmate_male_01_manifested_frames.tres |
| ClassmateMale02 | classmate_male_manifested_02_idle / walk | classmate_male_02_manifested_frames.tres |
| ClassmateFemale01 | classmate_female_manifested_01_idle / walk | classmate_female_01_manifested_frames.tres |
| ClassmateFemale02 | classmate_female_manifested_02_idle / walk | classmate_female_02_manifested_frames.tres |
| ClassmateFemale03 | classmate_female_manifested_03_idle / walk | classmate_female_03_manifested_frames.tres |
| Professor | professor_manifested_idle / walk | professor_manifested_frames.tres (existing) |

All paths in the table are under assets/characters/classroom/manifested/. The adapter saves only visible NPC resources and never writes actor visibility. Return carries their current breathing/step phase rather than rewinding to the entry pose. No instances are created.

Delivered sheets use four columns and five directional rows (S, SE, E, NE, N), 22x24 extraction regions on a 24px pitch, walking Y offset +1 and existing 5x scale. Normal furniture collisions are disabled during locked Manifested presentation and restored with their original enable states. No speculative corrupted-furniture collision geometry is used.

The three manifested foreground overlays remain aligned to the 1280x960 base. Desk and chair use independent ground anchors y783/y713 and negative artwork offsets. Wall equipment is background to nearby actors at z=-5; the base is z=-10. A full-canvas sprite's center is not its object's physical sorting anchor. See the foreground asset README and manifest for layer provenance.

Missing artist-authored partitions remain: per-student-chair overlap masks; foreground/background branches of combined tendrils; and desk front-edge/top/side depth partitions for arbitrary side approaches. Existing displaced chairs intersect some fixed seats. A single flattened image cannot provide physically accurate occlusion or cast shadows for those regions. Manifested movement remains locked.

## Lighting, shadows and clock

Scene 01 initializes at 6:30 AM once, advances one in-game minute per real second using fractional delta, and continues through dialogue/cinematics. Genuine pause freezes simulation. Explicit overrides remain available. Normal sunlight samples current fractional time; all four ceiling lamps remain on with independent controls and rare flicker.

Manifested presentation selects a branch in the existing lighting shader, not a second full-world pass. Exposure is .36, highlight retention .12, contact strength .16 and tint (.96,.98,1). Mild desaturation preserves the artwork's grain. Existing bright eye pixels in the verified pane interiors retain slightly more exposure; no new eyes, exterior scenery or daylight are painted into black panes.

Normal window recoloring, static furniture casters, ceiling masks and fixture graphics are excluded while Manifested. The same 640x480 mask and ActorShadow2D protocol provide actor/desk/chair contacts. Normal sunlight cast strength/length are zero in this profile; no unsupported cast geometry is claimed. Return restores visibility/collision states and invalidates Normal masks at the CURRENT GameClock time, not an entry snapshot. Normal time/source state continues updating underneath.

Albert protection binds his current original atlas region, alpha, frame transform and flip. The world glitch checks both destination and displaced source samples to prevent ghost copies. A one-screen-pixel edge guard handles raster rounding. The lighting pass additionally checks visible pixel ownership to avoid leaving bright environmental halos or lifting actors above furniture.

## World glitch and render order

World glitch tuning: entry .48s, return .42s, reduced .22s; horizontal displacement 18px, vertical 2px, band height 8px, fragment width 64px and deterministic seed 113. Covered-frame fences add about two rendered frames. Reduced motion uses a world-only dim/resolve without displacement, shutters or noise. Normal movement locks do not pause it; genuine scene-tree pause does.

Render order is world -> lighting1 -> copied-world glitch2 -> dialogue4 -> local panel fracture5 -> intrusive typography6 -> blackout10 -> TimeHUD11. The explicit BackBufferCopy samples the lit world. No additional world viewport or frame readback is used for these effects. Settled passes stop unnecessary processing.

## Dialogue artwork and local fracture

Both Compact panels are 1120x172 at (80,708) with an 80px bottom margin. Standard layouts remain independent. Black Compact reuses original `dialogue_dream_world.png` regions: black body/borders, a 264x72 original tab at (92,6), and floral clusters redistributed beside the tab/body. The label remains 244x56 at 40px. Left/right flowers use uniform 1.5x/1.25x scaling, not vertical flattening. The artwork has a small horizontal overhang but stays within the same 172px height. Source PNGs are unchanged; `manifestation_compact_art.gd` shares this geometry with the transition strips.

PsychPresentation consumes existing transition signals without changing authority or readiness. Irregular entry snaps use 16px horizontal amplitude (20px for major Professor pairs) and up to 6px vertical movement. Return uses 10/14px horizontal and up to 4px vertical. Local strip tearing is 10/16px. The fracture overlaps world transition timing; .14s aftershocks overlap live typing without delaying input. Rest is derived from current anchors/layout, preventing accumulated offsets. Reduced motion suppresses displacement/tearing and uses a short alpha settle.

## Intrusive typography

Twelve pooled controls render only after matching Manifested completion and clear on transition start/exit. Authored event IDs select 5 early fragments, 7 mid-sequence, 10 Professor/final-thought fragments, and 12 for pair_three. Consecutive lines do not reset a segment. Vocabulary is drawn from existing screenplay accusations: DID YOU, LOSING THE RACE, COMMON, IMPOSTER, EXCUSES, FRAUD and TOO LATE. They are visual echoes, not new dialogue or state.

Bounded placements crowd toward the center later in the scene. Typography may cover scenery and NPCs; shader exclusions preserve Albert, current dialogue/nameplate, TimeHUD, objective and prompt. Colors are muted scarlet #C65362, crimson #A32F40, rose #BA747C, dried-blood #8A2234 and pale #D2ADB4, with varied peak alpha .76-.94. Font sizes begin at 68/82/96px by intensity and fit within each authored region. Existing font variations, jagged baselines, per-character scaling/angle, overlapping ink and narrow shader breaks create distress without new glyph assets.

Fragments stagger, fade in over .14s, persist up to 4/5/6s and fade out over .55s unless the narrative returns sooner. Sparse local bursts have .13s recovery and horizontal jolts of 9/13/17px. They do not use repeated alpha strobing. Reduced motion retains static distress/fades but removes positional bursts and animated ink changes. Cue guards reject stale/duplicate completions; no unbounded nodes, timers or animation callbacks are created.

## Validation

For changes, run F5 from the black opening through the final paper narration. Verify all 19 voice lines, 16 segments, 32 directional transitions, three pairs, named/unknown panel styling, accepted-input gates, dismissal occupancy and exactly-once completion. Test held/rapid E, Space and click, typewriter cancellation, repeated cycles, exit during a transition and reduced motion. Confirm current-time lighting restoration, both panel layouts, no residue, continuous music and correct SFX counts. See AUDIO_PLAYBACK.md for audio behavior.

Measure uncaptured frame times with the full cast and maximum typography. A reference Intel UHD620 / Vulkan Forward+ / 1280x960 run measured Normal 60.07 FPS/P95 17.41ms, Manifested 60.05/P95 17.71ms and transitions 58.74/P95 18.24ms. These are reference measurements rather than a hardware guarantee. Compare visual output as well as numerical results; flattened-art depth limitations require artist review.
