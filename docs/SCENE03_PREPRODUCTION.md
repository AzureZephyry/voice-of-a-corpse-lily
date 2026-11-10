# Scene 03 preproduction and exterior composition audit

M05.1, 2026-11-08. This report separates implemented notice-board composition from proposed Scene03 gameplay. Gate and Road remain two locations within SCENE03: THE GUARDHOUSE. No Scene03 narrative, handoff, new character art or Road gameplay was implemented.

## A. Project baseline

This preproduction snapshot recorded branch `main`, an empty index, Discord add-on deletions, modified SpriteFrames/shared scripts, and untracked Hallway/story/assets. The supplied Manifested KRA and Scene03 DOCX were found at that time. Temporary status snapshots and hashes in `.scene03-preproduction-review-2026-11-08/` were removed during final housekeeping; this note is the retained historical summary.

## B. Normal Exterior discovery

The original editable Normal Exterior master is absent from the searched repository, including ignored source/archive locations. Existing documents refer to a previous School delivery archive, but that archive/master is not present locally. Do not confuse the new reconstructed production ORA with Wayne's missing original.

`scenes/environments/school_exterior/school_exterior_room.tscn` renders the1455×1467 map at1.1475×, world extent1669.6125×1683.3825. `scenes/gameplay/school_exterior_playable.tscn` instances that room, Albert, MangArnel, a janitor, guard/board interactions, objectives and audio. Its camera zoom2, limits0/0/1669/1683 differ from Hallway; Albert and MangArnel have2× sprite display scale, further enlarged by the camera. Do not copy Hallway's5× sprite setting into this view. `school_exterior_story.tscn` is an older arrival wrapper. `scene02_exterior.tscn` also uses the shared room with its own source-faithful Scene02 continuation.

Original runtime reference: `assets/environments/school_exterior/composite/school_full_map.png`,1455×1467,16-bit RGBA. The asset manifest identifies it as delivered `School/Layers/fullschool.png`. Related full-canvas human-created exports: `ground/school_ground_paths_base.png`, `structures/school_buildings.png`, `props/school_placed_props_and_rear_boundary.png`, `foreground/school_trees_and_front_lamps.png`, plus `lighting/school_shadows_aligned.png`. These exports are not a recovered editable master. `docs/art/school_exterior_asset_manifest.tsv` inventories individual props and original archive member paths. Review/runtime_images.json lists every PNG dimension.

Rendering uses Map(z−10), OcclusionUnderlay(z−11), y-sorted Occluders containing cropped main-map regions, extra antenna masks/underlays, and independent lighting/fog/sun-shadow components. `school_background_mask.gdshader` discards masked foreground pixels; `school_foreground_mask.gdshader` draws them on the same map grid and can fade when covering Albert. Root `school_exterior_occlusion.gd` controls that local visibility. Full referenced texture paths are preserved in the scene resource, including all original lighting/vehicle/antenna dependencies.

## C. Wayne's Manifested Exterior

`art_source/environments/school_exterior/school_exterior_manifested.kra` is144,085,918bytes, a CRC-valid KRA archive saved by Krita5.2.9. Canvas1455×1467, RGBA16, sRGB-elle-V2-srgbtrc.icc, approximately300dpi. It contains27 paint layers and five groups. All groups and26 paint layers are visible; only `Paint Layer 1 Merged` is hidden. Complete UUID/visibility/opacity/blend inventory is in review/manifested_layer_inventory.json and the original maindoc XML snapshot.

Visible groups are plants+ and Clipping Groups1–4. Actual blend modes include Normal, Multiply, Color and Overlay, including partial opacities and inherited alpha. These are integration dependencies: raw isolation is not equivalent to the saved composite. The board exists as visible `school_notice_board.png`, UUID{cf95a0f1-e409-4989-bf96-8c7d037f3e3a}, inside Clipping Group3 alongside artist-created alteration layers. Preserve this treatment; no additional Normal board was inserted there.

The saved projection was extracted without modification to review/school_exterior_manifested_projection.png and visually inspected. It covers the same campus arrangement, with upper/lower gates, left courtyard/canteen, right buildings/parking and perimeter roadway. Major landmarks occupy the same apparent source coordinates: central drive x543..638; right upper building roof begins around(680,219); lower right roof aroundy598; southern gatehouse region(511,1229,33,47). These are visual alignment findings, not a pixel-exact foreground-separation certification. Tendrils, eyes, heavy grain, dark vegetation/parking corruption and edge contamination substantially alter silhouettes. It is a whole campus variant, not a complete long Road scene or a new sky.

Same canvas/origin supports a future presenter, but Normal's object masks and underlays cannot be assumed valid for all new tendrils/vegetation. Before runtime Manifested integration, export with original blend dependencies and validate foreground/background coverage, gates and actor occlusion. No fresh Krita export comparison or per-layer isolation was possible: the Krita bridge was unavailable. Saved projection/structure/CRC checks passed; native reopen/fresh export remains a validation dependency. No received KRA was saved, flattened, reorganized or promoted into gameplay.

## D. Implemented notice-board integration

Original world source `school_notice_board.kra` is48×64,8-bit RGBA, six visible editable layers. Inspection source `school_notice_board_inspection.kra` is480×340,8-bit RGBA,18 visible layers, including explicitly provisional section/room values. Both use the sRGB-elle profile. Both originals and their PNGs remain unchanged. Their prior authorship cannot be independently established from layer names; this task uses the Project Lead-approved supplied assets and adds no artwork.

A new editable OpenRaster production master, `art_source/environments/school_exterior/school_normal_production_composition.ora`, contains the original Normal map export and a separate supplied-board layer. It is explicitly reconstructed from exports, not Wayne's original master. The archive retains the original16-bit map PNG verbatim; its merged production PNG is16-bit RGBA. ORA is a standard editable Krita-compatible format, but native reopening could not be tested with the unavailable bridge.

The old independent board drew48×64 world pixels at x521,y1144 (feet anchor545,1204). The existing map scale is fractional, so exact native pixel registration required nearest-neighbor fitting to42×56 at native(454,997). New world extent is approximately(520.965,1144.0575),48.195×64.26: subpixel origin shift and less than0.3world-pixel extent change, without blur. This deliberate fitting is disclosed rather than claiming identical old/new board sampling. No surrounding artwork was rescaled. A16-bit lossless derivative `composite/school_normal_with_notice_board.png` becomes the room's main map; the original map stays intact.

`composite/school_notice_board_occlusion_mask.png` extends the original mask only at board-alpha pixels with objectID33. Main Map excludes those pixels; a cropped region of that SAME composition at Occluders/NoticeBoardComposition draws them using the established map coordinates, Y-sort and local fade. There is no separately authored board texture drawing independently at a Godot offset. A small NoticeBoardGroundUnderlay samples the unchanged original map beneath the board, preventing empty holes during fades. This is the existing background/foreground split applied to a composited object, not a second visible board.

The old `school_notice_board.tscn` Sprite2D is hidden. Its static body, collision, original feet anchor and inspection interaction remain. An actual E input near the board accepted that interaction in the graphical runtime. The sampled ordinary dialogue panel was hidden; this check does not claim the separate inspection flow was completed. The hidden source remains only as the existing nonvisual bounds/shadow reference; its ActorShadow component suppresses its hidden source, avoiding a duplicate shadow. Both existing playable/Scene02 wrappers use the new combined mask so foregroundID33 participates in their original fade controller. Lighting still grades the main-map region through the same materials and seven-phase clock; no lighting code changed.

Normal composition integration is implemented. Manifested already has its own board layer/design; it was preserved and not double-composited. End-to-end Manifested runtime compatibility remains pending a proper scene-specific export/mask validation, not silently declared complete.

## E. Complete screenplay inventory

Read the entire actual DOCX, including both locations, all actions and cues. There are13 Gate and10 Road spoken/thought entries,23 total. Count includes Albert's literal `...` thought and three UNKNOWN VOICE utterances; excludes Mama's message, stage directions, SFX and VFX. JSON entry inventory preserves exact punctuation, paragraph anchor, source/display identity, classification, metadata, associated source cues, proposed owner/input and approval status. Display speaker proposals are not implemented.

|#|Location / paragraph|Source speaker / classification|Exact text|
|---|---|---|---|
|1|School Gate p5|MANG ARNEL  / ordinary|Uy, Dimapilis.|
|2|School Gate p5|MANG ARNEL  / ordinary|Why the long face? Somebody die?|
|3|School Gate p7|ALBERT  / ordinary|Failed a quiz, po.|
|4|School Gate p7|ALBERT  / ordinary|Just kidding. It was... fine.|
|5|School Gate p9|MANG ARNEL  / CLEAN|Hah. Bad joke. Save it for after breakfast.|
|6|School Gate p9|ALBERT (thought) / HEARD|Even the guard thinks I’m not funny.|
|7|School Gate p9|ALBERT (thought) / HEARD|Even the guard thinks I’m nothing.|
|8|School Gate p10|MANG ARNEL  / ordinary|Go home and rest. Tomorrow’s another day.|
|9|School Gate p10|MANG ARNEL  / ordinary|We all have bad days, iho. Even me.|
|10|School Gate p12|MANG ARNEL  / CLEAN|We all have bad days.|
|11|School Gate p12|ALBERT (thought) / HEARD|He thinks this is small.|
|12|School Gate p12|ALBERT (thought) / HEARD|He doesn’t know what I was.|
|13|School Gate p13|ALBERT  / ordinary|Opo.|
|14|Road p19|ALBERT (thought) / HEARD, NO TRIGGER|Everyone saw.|
|15|Road p19|ALBERT (thought) / HEARD, NO TRIGGER|Everyone knows now.|
|16|Road p19|ALBERT (thought) / HEARD, NO TRIGGER|Jules knows. Liezel knows. Sir knows.|
|17|Road p19|ALBERT (thought) / HEARD, NO TRIGGER|By tomorrow, everybody.|
|18|Road p23|ALBERT (thought) / ordinary|What do I even say?|
|19|Road p23|ALBERT (thought) / ordinary|‘It went fine, Ma.’|
|20|Road p26|UNKNOWN VOICE  / ordinary|There you are.|
|21|Road p27|ALBERT (thought) / ordinary|...|
|22|Road p28|UNKNOWN VOICE  / ordinary|You’ve been so tired.|
|23|Road p28|UNKNOWN VOICE  / ordinary|Haven’t you?|

Paragraph9 is Pair7; paragraph12 is Pair8. The ordinary “We all have bad days, iho. Even me.” precedes the CLEAN “We all have bad days.” Both remain separate authored entries. The p19 HEARD, NO TRIGGER designation applies to all four consecutive road thoughts; it does not authorize a full-world manifestation or panel switch. P26 contains literal [LILY] metadata while the player-facing identity is UNKNOWN VOICE; p28 continues UNKNOWN VOICE. Do not expose the hidden identity, add appearance or assume voice acting.

Proposed ownership: GateConversation data drives accepted dialogue progression after one E interaction; GateDirector owns approach/pass-gate state. RoadSequence owns distance/authored cues, vignette and continuing movement. Four road thoughts remain Normal. Timing/acknowledgment rules, Pair7/8 reality treatment and unknown-voice presentation require approval. No screenplay punctuation was normalized. Full paragraph transcription below is the ordered authority for actions, pauses, phone text and sounds; the per-entry JSON links these cues explicitly.

### Ordered source paragraphs

- **p1** SCENE 03: THE GUARDHOUSE
- **p2** Location: School gate NPC: Mang Arnel
- **p3** [SFX: Traffic outside the gate. A radio plays softly.]
- **p4** Mang Arnel is on his stool with a newspaper and a small cup of coffee. He glances up as Albert approaches.
- **p5** MANG ARNEL: “Uy, Dimapilis.” MANG ARNEL: “Why the long face? Somebody die?”
- **p6** Albert tries to match the tone, the way he’d have done at the start of the semester. He doesn’t manage it.
- **p7** ALBERT: “Failed a quiz, po.” Pause. ALBERT: “Just kidding. It was... fine.”
- **p8** It lands wrong. Albert hears it land wrong.
- **p9** PAIR 7 [CLEAN] MANG ARNEL: “Hah. Bad joke. Save it for after breakfast.” (He teases everyone this way.) [HEARD] ALBERT (thought): “Even the guard thinks I’m not funny.” [HEARD] ALBERT (thought): “Even the guard thinks I’m nothing.”
- **p10** MANG ARNEL: “Go home and rest. Tomorrow’s another day.” MANG ARNEL: “We all have bad days, iho. Even me.”
- **p11** He’s already turning a page.
- **p12** PAIR 8 [CLEAN] MANG ARNEL: “We all have bad days.” [HEARD] ALBERT (thought): “He thinks this is small.” [HEARD] ALBERT (thought): “He doesn’t know what I was.”
- **p13** ALBERT: “Opo.”
- **p14** Albert walks through the gate. Mang Arnel doesn’t look up again, which is the most ordinary thing in the world.
- **p16** Location: Road
- **p17** [SFX: Traffic gets quieter with each step.] [VFX: The vignette creeps into the edges of the normal screen, no panel switch.]
- **p18** The road is long. A tricycle passes. A vendor calls out something Albert can’t make out. The sky has no clear light source.
- **p19** [HEARD, NO TRIGGER] ALBERT (thought): “Everyone saw.” ALBERT (thought): “Everyone knows now.” ALBERT (thought): “Jules knows. Liezel knows. Sir knows.” ALBERT (thought): “By tomorrow, everybody.”
- **p20** [SFX: Faint wind. No identifiable source.]
- **p21** Plants grow at the edge of the road, more than there should be. They lean toward him slightly.
- **p22** [SFX: Phone vibrates. Mama: How was your first quiz, nak? Proud of you! Text us after. He doesn’t open it.]
- **p23** ALBERT (thought): “What do I even say?” ALBERT (thought): “‘It went fine, Ma.’”
- **p24** He almost laughs. It comes out wrong.
- **p25** The music loses a little clarity.
- **p26** [LILY] UNKNOWN VOICE: “There you are.”
- **p27** ALBERT (thought): “...”
- **p28** UNKNOWN VOICE: “You’ve been so tired.” UNKNOWN VOICE: “Haven’t you?”
- **p29** Albert keeps walking. He doesn’t turn around. He also doesn’t speed up.

## F. Asset readiness inventory

Paths below are project-relative. “Present” means a verified local resource, not proof of an unsupplied bespoke action or new story implementation.

|Category / requirement|Status|Evidence and limitation|
|---|---|---|
|Normal campus|Present|Original composite/layer PNGs and room scene above; original KRA missing.|
|Manifested campus|Partially available|Wayne KRA verified; saved composite available for review, fresh exports/depth masks unverified.|
|World board|Present/integrated|48×64 source, new editable ORA and main-map derivative.|
|Board inspection|Present|480×340 source/PNG and scenes/UI/notice_board_inspection.tscn; provisional written room/section details remain.|
|Gates / guardhouses|Present|structures/guardhouse.png33×47; props/gate_closed.png37×31, gate_open.png4×50, barrier_arm.png89×20; baked into campus at both ends.|
|Road|Partially available|Top/bottom asphalt belongs to campus image; no complete long Road environment/scene/camera/collision/sky source found.|
|Foreground architecture|Present Normal / partial Manifested|Normal tree/building/car/antenna masks and underlays; new Manifested corruption needs separation audit.|
|Albert|Present|scenes/player.tscn, assets/characters/albert/, established five-direction idle/walk and feet/shadow convention.|
|Mang Arnel Normal|Present|assets/characters/mang_arnel/normal/mang_arnel_idle.png (94×122), mang_arnel_walk.png (94×123), and mang_arnel_frames.tres; scenes/characters/mang_arnel.tscn and npc_character.gd. 22×24 regions at 24px pitch, walking +1Y, four frames/five rows; 2× Exterior display.|
|Mang Arnel Manifested|Missing|Confirmed by Project Lead; no matching supplied resource found. No recolor/substitution created.|
|Seated newspaper/coffee performance|Missing dedicated assets|Normal guard sheets depict standing/walking, not a stool/newspaper page turn/coffee activity. No separate authored stool/newspaper/cup assets verified. Tiny guardhouse interior pixels cannot establish those actions.|
|Background NPCs|Partially available|Existing npc_001 janitor/roaming scene; not a verified vendor or Road crowd. No new cast required without source direction.|
|Tricycle/vendor|Missing|No specific sprite, vehicle animation or vendor recording found. Campus cars are not a tricycle substitute. Vendor source calls for indistinct audio; an on-screen NPC is not automatically required.|
|Plants|Partially available|foliage/tree.png30×96, potted_bush.png19×26, full-canvas campus foliage export. These are campus props, not approved Road-edge plants; no supplied leaning frames. Modest anchored transforms possible only after art suitability review.|
|Traffic/radio/wind/phone/tricycle/vendor/Unknown Voice recordings|Missing dedicated cues|Only existing school_morning/night and classroom ambience, footsteps, four Lawrence SFX and soundtrack found under assets/audio. A general ambience filename does not prove an identifiable traffic/radio cue. No audition/semantic validation of ambience was performed in this milestone.|
|Music|Present|assets/audio/music/soundtrack.ogg, persistent AudioDirector, explicit music continuity/loop handling.|
|Glitches / dialogue advance|Present|assets/audio/sfx/glitch_01.wav,02.wav,03.wav and dialogue_blip.wav; existing accepted-transition and completed-line advancement handlers. No typing audio.|
|Music clarity effect|Not implemented; feasible|default_bus_layout.tres has Music, Ambience, Footsteps, SFX, no filter effect. Existing Scene02 ending tween changes gain, not clarity. Later scoped reversible Music-bus low-pass could degrade clarity without modifying source audio or restarting music.|
|Interaction/objectives/clock/UI|Present reusable|OverworldInteractable/E prompt, DialoguePanel/TextType, scene02_objectives, time_hud, persistent GameClock. Objective wording/data must be Scene03-specific after approval.|
|Intrusive typography/world glitch|Present reusable, scene adapter needed|classroom/hallway_psych_presentation, RealityGlitch, RealityPresentation. No Scene03 event mapping exists.|
|Vignette|Missing dedicated Road effect|No existing dedicated vignette shader found. Later lightweight edge-mask shader below dialogue/HUD can remain entirely Normal and avoid a panel switch.|
|Scene/location handoff|Present contract, not Scene03 integration|scene02_story.gd covered settled-location handoff and exactly-once scene_completed. No approved Scene03 root/handoff implemented.|

All approved visual/audio source files were retained. No external assets, new art/audio, generated frames or production placeholders were added.

## G. Architecture and continuity assessment

Reuse player/input, animation, dialogue reveal/cancel/accepted advance, interaction prompt, clock/HUD, audio buses/director, actor shadows, objectives and reality authority. Use small Gate/Road directors plus source event data and scene-specific presentation/lighting adapters. Do not copy the large Classroom story controller or add another global scene/reality/audio manager.

The old school_guard_interaction.gd describes a branching first-year ID/course/directions encounter, starting “First year?”. Its comments naming Scene03 do not make it the supplied revised script. Preserve that laboratory behavior; the new canonical gate conversation must be separately authored data/controller with its own local once-only lifecycle, not the old school_arnel_intro_completed flag or choice branches.

School geography supports approach to the southern guardhouse near world(605.3,1396.5), with gatehouse contact around(605.3,1464.2) and barrier across the central drive. Existing walls/vehicle barriers/map bounds are physical blockers; passing the gate is not currently a functioning Road handoff. Review pedestrian route/barrier behavior before choosing collision edits. Do not infer a traversable Road from the strip of painted asphalt. North and south gate assets exist; the southern existing guard placement is the conservative candidate, requiring directorial confirmation.

Pair7/8 options for review: (1) Normal-world internal heard presentation, no sprite transformation required; (2) full Manifested campus with Normal guard unchanged, requiring explicit artistic approval; (3) full Manifested campus and manifested guard, blocked by missing Isabela sprite and environment export/depth validation. Clean/Heard labels alone do not choose among these. Both heard lines in each pair should share its segment if world manifestations are approved; no final transition count is assigned now.

Road vignette should be a scene-owned edge effect over Normal world, below existing panel/HUD, with no RealityPresentation request. Keep the specified panel stable. Plants need appropriate supplied art/contact anchors before gentle transforms. Preserve the ambiguous sky through approved art/exposure, not a newly painted sky or invented sun. Phone vibration/message can use a brief noninteractive authored notification or narrative presentation, with exact Mama text; Albert must not open the phone. The method requires review and missing phone SFX. UNKNOWN VOICE needs distinct display identity without revealing LILY or inventing voice acting.

A future reversible Music-bus filter must capture/restore its own prior effect state on cancellation/handoff, cooperate with persistent AudioDirector and the Scene02 ending mix, and avoid per-frame resource allocation, duplicate players or pumping. This is a proposal only.

Scene02 ends at the quiet-corner placeholder with player deliberately locked, dialogue closed, Normal reality and scene_completed emitted once. No automatic Scene03 entry exists. Future coordinator should wait for settled dialogue/typewriter/reality/effects and unwind the completion signal stack before removing the old location; preserve clock and AudioDirector, explicitly transfer movement ownership to the new scene. A controlled cover may bridge distant campus coordinates without presenting a false continuous walk. The general native Classroom hot-exit crash remains unresolved and was not exercised or investigated.

## H. Dependency-ordered roadmap

1. **M05.2 Gate foundation:** approve southern route/staging, supply or approve the guard's seated newspaper/coffee treatment; validate the revised Normal composition and build an isolated gate foundation only after authorization. Retain Exterior scale/camera/foreground conventions. No new global framework.
2. **M05.3 Guard conversation:** approve Pair7/8 treatment and player-facing heard styling. If full-character manifestation is required, obtain Isabela's asset; validate Wayne's blended exports/depth before enabling. Then source-exact13-entry conversation, E-once lifecycle, accepted-advance audio, pause/cancel/rapid-input checks.
3. **M05.4 Road foundation:** obtain approved Road artwork/layout, plant layers and traversal/camera geometry; settle gate passage/handoff. Identify/supply traffic, radio, wind, tricycle/vendor and phone recordings. Do not build a fabricated Road from campus tiles.
4. **M05.5 Road psychology:** source-exact10 entries plus separate Mama message; four NO TRIGGER thoughts, Normal creeping vignette/no panel switch, subdued reversible music clarity effect and reviewed UNKNOWN VOICE identity. Preserve unhurried walking/no turn/no speed-up ending.
5. **M05.6 Integration:** settled Gate→Road and Scene02→Scene03 lifecycle, one completion contract, shared clock/audio, source/order tests, full graphical narrative run, occlusion/lighting/reduced-motion/input/cancellation/performance checks and Project Lead review.

Technical preparation can proceed with Normal gate/character resources and reusable systems, but no canonical screenplay implementation should begin before the listed staging/art/presentation decisions. Road is art-blocked. No numeric Sanity system, new dialogue branch or new scene numbering is proposed.

## I. Validation and limitations

Graphical Godot4.7.2 launched the existing Exterior laboratory after integration. Checks passed: one visible composition-based board, hidden original sprite, retained interaction, object33 registered in fade controller, movement, valid seven-phase lighting, continuous music and clock. Noon and Night screenshots show established grading. Actor-behind-board capture confirms local fade with valid background beneath it. No duplicate silhouette or black hole was observed. Before/after entry screenshots and closer board views are in the review directory. Original-source composite dimensions are unchanged;8-bit comparison confines visible changes to board bbox(458,1003)-(492,1049). The final16-bit derivative retains original samples outside the edited board region by construction; original source PNG is retained in the ORA and unchanged on disk.

Scene02 Exterior independently loaded with the new map/mask and registered board; the full Hallway wrapper started with33 crowd actors,36 shadow participants, free opening movement and music. No full Scene01/Scene02 screenplay replay or new performance benchmark was performed in this preproduction task. No new Godot resource/runtime warnings or errors occurred. This does not resolve the deferred native crash. Manifested inspection is a genuine saved source projection, not a graphical runtime reality swap; runtime Manifested integration is not authorized here.

Krita bridge availability prevented native KRA opening/fresh export and ORA reopen tests. No manual unsaved Krita document was edited. KRA ZIP/XML/projection checks and standard lossless compositing were used. Original master absence and Manifested foreground/alignment validation remain clearly disclosed, not hidden behind a fake KRA. Artist sources are byte-preserved.

## J. Changed files, evidence and Git

Modified four existing scenes only: `scenes/environments/school_exterior/school_exterior_room.tscn`, `scenes/environments/school_exterior/school_notice_board.tscn`, `scenes/gameplay/school_exterior_playable.tscn`, `scenes/story/scene02_exterior.tscn`. Changes are limited to composition references, composition-region/underlay ownership, the hidden legacy sprite and mask references. No gameplay script or narrative changed.

Added `art_source/environments/school_exterior/school_normal_production_composition.ora`, `assets/environments/school_exterior/composite/school_normal_with_notice_board.png`, `school_notice_board_occlusion_mask.png` and their Godot-generated import files, plus this report. Review-only artifacts include initial/final hashes/status, exact source paragraphs/events, layer XML/inventory, runtime image inventory, comparison/check JSON and actual runtime screenshots.

Temporary screenshots, source inventory, cue-order, integrity and Git-status files from this review were removed during final housekeeping. Their summarized findings remain in this historical preproduction note and the current implementation guides; those original artifacts are no longer available here.

No staging, commit, push, reset, clean, remote/config change or Scene03 gameplay implementation occurred. Existing pending changes and source documents remain. Open the existing `scenes/gameplay/school_exterior_playable.tscn` with F6 to review the board; its old laboratory dialogue is preserved and must not be mistaken for the new screenplay. The Scene02 story entry remains separate and unchanged in behavior.
