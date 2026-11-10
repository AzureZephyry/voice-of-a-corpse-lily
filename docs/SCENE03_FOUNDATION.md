> M05.3 correction: F8 is removed because Godot reserves it for Stop. Use the separate exploration F6 entry or its Inspector development_exploration option. The canonical story entry is scenes/story/scene03_story.tscn; production gate access comes from completing the conversation.

# Scene 03 continuous exterior foundation

M05.2 — 2026-11-08. The Normal guardhouse-to-road foundation is playable in one existing campus environment. A developer-only Manifested presentation uses Wayne's authentic saved projection, shared architectural occlusion and source-derived board alpha. Final depth for added corruption remains an artistic validation dependency. Scene03's23-entry screenplay, Pairs7/8 and production handoffs are not implemented.

## A. Baseline and preservation

This milestone note records work continued on `main` from the preproduction snapshot. The temporary `initial.json` and review directory were removed during final housekeeping; the file-count/Git snapshot is not available as a separate artifact. Earlier Hallway, Exterior and story implementation details remain documented in the project sources.

The M05.1 Normal master remains explicitly reconstructed: `art_source/environments/school_exterior/school_normal_production_composition.ora`. It is not Wayne's missing original Normal KRA. Its components,16-bit Normal derivative and notice-board integration were preserved. M05.1's concern about a complete separate Road should not be read as an art requirement: the existing southern road is sufficient for this playable foundation. No new Road background is requested or created.

## B. Verified geography and continuous route

The same1455×1467 artwork uses the established1.1475 map scale, world extent1669.6125×1683.3825. The southern gate is around source x475..638,y1226..1310. Its existing guardhouse occupies source(511,1229,33,47), world contact around(605.306,1464.21). Mang Arnel is at(605.30625,1396.5074). The vehicle barrier remains across the central vehicle lane, around world(679.89375,1451.5875).

There is a real pedestrian passage west of that gatehouse, between the open gatepost and guardhouse. Albert can walk at x565..568 through it; the existing vehicle barrier and all shared physical architecture remain intact. A new foundation-only progression collider at(568,1470),37×16, closes this pedestrian passage while the canonical encounter is unimplemented. E does not disable it. Explicit development exploration or a future successful canonical conversation can disable it.

The painted southern asphalt begins below the campus frontage around world y1503. The logical road zone starts at y1512. Safe Road traversal was tested through the existing full-width strip, approximately x32..1637, with feet restricted below y1665 by one foundation-only bottom boundary. The original side/campus/vehicle collisions remain. No opaque artwork rectangle was used as a new collider. A practical walk is spawn(655,1340), approach the guard, move to x565 above the frontage, then down through the pedestrian gap and along the existing road. Both directions and side/bottom boundaries passed actual input testing without teleporting during the route test.

Camera remains player-following, zoom2, no smoothing, limits0/0/1669/1683. Maximum center is(1349,1443); these limits stay inside the scaled art. No new load, second Albert, camera switch, scene change or unseen geographic connector is used between Gate and Road. Physical map edges safely end current exploration without pretending the authored story has completed.

## C. Manifested source and export

Original source: `art_source/environments/school_exterior/school_exterior_manifested.kra`,144,085,918bytes,1455×1467, RGBA16, sRGB-elle-V2-srgbtrc.icc,27 paint layers/five groups. KRA CRC validation passed. Source SHA256: `c6b0135fbcb44f4822f07d16c455434195650db68a290d7592a7488c211b03b7`. Krita bridge was retried and unavailable; no native reopen or fresh Krita export is claimed.

`art_source/environments/school_exterior/export_manifested_exterior.py` copies the KRA's saved `mergedimage.png` byte for byte into `assets/environments/school_exterior/composite/school_manifested_saved_composite.png`. It is the artist's embedded8-bit RGBA saved projection, not a recreated blend or fresh export from the16-bit source. Export SHA256: `9d40d56bbc690d9735e3adcbe93b84901e2c92c756845c154bfc2c1f07eb6ea3`. The full canvas, colors, origin and artist-composited Multiply/Overlay/Color appearance are retained. Both textures are losslessly imported, nearest filtered through the existing scene, without mipmaps.

The helper verifies the board layer UUID/name slot, tile version/size/format, LZF payload lengths and source preservation. It decodes only the genuine planar alpha from the existing8-bit `school_notice_board.png` layer18, UUID{cf95a0f1-e409-4989-bf96-8c7d037f3e3a}. Its bounds are(455,1006)-(507,1052),52×46: Wayne tilted the board, so reusing the Normal42×56 rectangle was incorrect. The derived mask is technical occlusion data, not generated artwork. Source KRA structure/bytes are never written.

Runtime contract: `composite/school_manifested_export_contract.json`; mask: `composite/school_manifested_occlusion_mask.png`. Other architectural IDs reuse the established Normal physical/foreground geometry because the major campus/gate/road layout corresponds visually. The special Normal rotated-car correction is removed from the Manifested mask and its Normal-only overlay is hidden, preserving Wayne's composite instead of rotating its contents again.

### Depth limitation

The existing architectural partitions remain foreground/Y-sorted, rather than flattening all foreground into a background sprite. The board has its verified variant-specific alpha/region. This is a conservative developer depth partition, not a certification of all new tendril/vegetation depth. Added corruption without verified contact/foreground ownership remains in the artwork plane. Final foreground designation and background coverage require a trustworthy native/layer export review; no missing backgrounds were painted.

Normal underlays cannot be shown through transformed foregrounds safely. They are hidden in Manifested, and foreground fading is disabled there so no Normal pixels or duplicated baked object is exposed. Hard occlusion remains; Albert can be briefly hidden at some foreground objects. Normal local fading restores normally. A faithful Manifested background/foreground separation is an artistic-fidelity blocker before treating this as final production manifestation depth, not evidence that new Road scenery must be drawn.

## D. Notice board

Normal board remains in the M05.1 main composition with cropped map-region rendering, not an independent floating board asset. The legacy Sprite2D stays hidden, with its collision and inspection hotspot retained. Normal E inspection opened successfully in the new foundation. The shared original Exterior implementation is unchanged except material isolation described below.

Manifested uses Wayne's already-treated tilted board directly from the full composite, with genuine source alpha for objectID33 and its own52×46 region. No Normal board was pasted over it. Underlying logical collider/hotspot stays at the approved Normal feet anchor; its physical accuracy under the tilted silhouette remains conservative. The existing inspection close-up is Normal artwork, so inspection is explicitly suspended during developer Manifested tests rather than implying an authored Manifested inspection. Normal return restores it. Comparable final_normal_board/final_manifested_board captures show the two presentations and no duplicate legacy sprite.

## E. Mang Arnel and interaction

Uses `scenes/characters/mang_arnel.tscn` and Normal runtime resources under `assets/characters/mang_arnel/normal/` (`mang_arnel_frames.tres`, `mang_arnel_idle.png`, and `mang_arnel_walk.png`), with Manifested counterparts under `assets/characters/mang_arnel/manifested/`. The Normal sheet uses 22×24 extraction at 24px pitch, walking +1Y, four columns/five directions, 2× Exterior sprite scale and feet anchoring. Default idle_down is technical staging facing the gate/road; the authored seated/newspaper/coffee performance is not claimed. No supplied seated pose or dedicated stool/newspaper/cup performance was verified.

The prompt is `[E] Talk to Mang Arnel` within64 world pixels. No automatic encounter begins. One accepted E emits `encounter_requested`, sets local pending state and displays a development diagnostic. It does not type invented dialogue, tick the objective, open the gate, lock movement or emit scene completion. Held/rapid E cannot repeat the pending request. `resolve_encounter(false)` cancels/rearms; `resolve_encounter(true)` is reserved for a future canonical conversation controller and opens progression exactly once. Current runtime never calls the success hook from E or debug exploration.

The existing board handler used to consume unclaimed E. A scene-local `scene03_board_interaction.gd` adapter delegates its original behavior only when appropriate, allowing the guard hook to receive E. No shared dialogue/typewriter or old branching guard script was rewritten. The old first-year guard encounter remains in its original laboratory and is not substituted for the supplied Scene03 script.

## F. Foundation ownership and entry points

- `scenes/gameplay/scene03_exterior_foundation.tscn`: one existing room, Albert, Normal guard, retained board hotspot, progression collider/bottom boundary, inert markers, objective/HUD, audio, one reality authority, passive adapter and existing world glitch.
- `scenes/gameplay/scene03_exterior_exploration.tscn`: inherited explicit development-road-access variant; the canonical conversation remains incomplete.
- `scripts/scene03_exterior_foundation.gd`: extends the existing school occlusion controller, owns local encounter/permission/zone hooks and the shared objective panel. No screenplay entries are installed.
- `scripts/scene03_exterior_presenter.gd`: swaps source textures/masks/regions and lighting only at the authority's accepted midpoint.
- `scripts/scene03_board_interaction.gd`: narrow input adapter for the established board interaction.

`encounter_requested`, `gate_conversation_completed` and `zone_changed` are local future integration hooks. Zone changes do not trigger dialogue or reality. Objective is Talk to Mang Arnel; only a real future success can change it to Head home. Debug access retains the incomplete objective and explicit diagnostic. No Scene03 completion signal is emitted and no Scene02/Scene04 handoff is connected.

Planning markers, all inert: RoadEntry(568,1540), TrafficFade(650,1590), VignetteOnset(760,1590), PlantReview(950,1590), PhoneMoment(1120,1590), UnknownVoice(1370,1590), CurrentPlayableEnd(1600,1590). Eastward spacing is a review proposal, not approved final screenplay timing. No Area2D calls Road thoughts, vignette, Mama, plants, tricycle/vendor, audio filters or UNKNOWN VOICE. The four Road HEARD, NO TRIGGER thoughts remain unimplemented and cannot invoke a world swap.

## G. Reality, lighting, shadows and persistence

One unchanged RealityPresentation instance owns NORMAL/GLITCH_IN/MANIFESTED/GLITCH_OUT. Existing RealityGlitch retains0.48s entry,0.42s return and0.22 reduced-motion directions, accepted-transition SFX and dynamic Albert/HUD screen-mask protection under the moving2× camera. No second state machine or extra full-world viewport was introduced. R tests accepted transitions only; rapid/busy requests do not stack sounds.

Normal keeps the original seven-phase Exterior lighting, ambient modulation, lamps/windows, fog and shared sun/actor-shadow receiver. In Manifested the adapter stops ordinary grading/light/fog presentation, hides Normal repair underlays, displays Wayne's exposure, sets ordinary sun opacity to zero and retains grounding contacts. Mang Arnel intentionally remains Normal art in this labelled environment test; this does not choose the canonical Pair7/8 policy. Normal return restarts the existing lighting owner and samples CURRENT GameClock, with original sun strength/fog/lights restored.

The only pre-existing file changed is `scenes/environments/school_exterior/school_exterior_room.tscn`:37 ShaderMaterial resources now have resource_local_to_scene=true. This isolates per-instance runtime presentation uniforms, preventing a Manifested test/reload from contaminating a later Normal room. No existing scene geometry, texture assignment, lighting parameter or gameplay script was otherwise changed. The receiver/lighting caches get their local materials from instantiation before ready, not from per-transition cloning.

GameClock, TimeHUD and persistent AudioDirector are reused; no reset/duplicate clock or music manager. Real scene reload during a pending transition passed with continued clock/music starts unchanged, one receiver/HUD and a fresh Normal mask. Normal source textures/camera/actor frames are restored without node recreation. Existing surface-aware footsteps remain; the original classifier returns silence for unclassified asphalt, so Road footstep cue mapping is still a production choice, not a fabricated sound.

## H. Validation

Actual graphical Godot4.7.2, Vulkan Forward+, UHD620,1280×960. Final GDScript diagnostics are empty. Initial import timing and a typed-array startup issue were corrected; subsequent graphical runs produced no new parsing/resource/runtime warnings or errors.

Final route checks pass: immediate control, guard held-once/cancel/retry, no fake completion, closed story gate, explicit debug permission, continuous pedestrian passage, walking during Manifested/Normal return, both Road ends, bottom boundary, feet-contact alignment and one receiver. Separate tests pass Normal board inspection, variant board regions, hidden legacy board, real pause of clock/player, reduced-motion both ways, current Night restoration and accepted-only SFX. Foundation reload during active GLITCH_OUT passed; this is not a resolution of the deferred unsafe Classroom dialogue hot-exit crash.

A captured road view with actors/UI/contacts temporarily hidden for identity testing matched all1,228,800 rendered pixels to the artist's saved composite at the actual camera transform: maximum difference0. This establishes faithful pixels in that view, not universal foreground-depth proof. Normal architectural/shadow overlays were deliberately excluded from this identity capture. Actual ordinary runtime retains contacts.

Regression launches passed existing Exterior laboratory and Scene02 Exterior (Normal map, valid lighting, one receiver/music), Hallway startup (33 crowd,36 participants, free control/music), and safe F5 Classroom startup (four lamps, ambient0.28/music). Full previous screenplay runs were not repeated. No forced Classroom dialogue exit was exercised.

### Capture-free performance

Each final bucket has240 wall-frame samples after frame_post_draw, while moving by the actual input controller. These are not GPU execution times or a claim of exclusive hardware use. No screenshot/recording was taken in these intervals. Measurement fixtures repositioned between sampled regions; separate route tests prove continuous traversal.

|Workload|Average FPS|P95 ms|Worst ms|
|---|---:|---:|---:|
|Normal Exterior movement|58.98|19.27|33.45|
|Gate / guardhouse|59.90|17.43|28.14|
|Road traversal|59.86|17.42|30.43|
|Manifested Road|59.86|17.71|29.31|
|Restored Normal Road|59.85|17.34|30.11|

Normal campus remains slightly below a guaranteed60FPS; Road/gate/Manifested run near60. The earlier repeat measured57.46FPS/P9520.73ms for Normal movement; final repeat58.98/19.27. Variability and occasional28–33ms frames remain disclosed. The prior Scene02 Exterior movement was also below60; no disproportionate new pass/cost was added. No benchmark proves a universal60FPS budget.

## I. Production dependencies and next milestone

- **Directorial decision:** Pair7/8 world/character/panel policy remains unset. Do not use development R tests as narrative approval. Confirm southern gate staging and Road direction/anchor pacing before scripting.
- **Artistic fidelity blocker:** verify native/layer exports and new corruption foreground/background coverage before final production Manifested occlusion/fades. Current common architectural partition and source-board alpha are conservative and usable for developer review. This need not require newly painted scenery.
- **Conditional character blocker:** Isabela's Manifested guard art is required if the approved policy transforms him. Normal-in-Manifested is currently a diagnostic choice only. Stool/newspaper/coffee pose/activity remain separate fidelity dependencies.
- **Specific remaining art/audio:** tricycle, suitable Road-edge plant layers/leaning support and vendor representation if visually needed are unverified/missing. Existing cars/potted campus plants are not automatically final substitutes. No new Road background is needed for this foundation. Dedicated traffic/radio/wind/phone/tricycle/vendor cues remain unverified or absent; general school ambience is not proof of an isolated required cue. Unknown Voice recording is not supplied and must not be invented.
- **Later implementation:** Normal creeping vignette/no panel switch, four NO TRIGGER thoughts, exact phone message without opening phone, reversible music-clarity filter, UNKNOWN VOICE display/[LILY] metadata and authored ending remain wholly deferred. Existing Music bus has no clarity filter installed here.
- **Optional polish:** camera/prompt placement and any source-approved roadside motion after the narrative/art policy is settled.

Recommend M05.3 as the source-faithful13-entry guard conversation and approved Pair7/8 treatment, first resolving the listed presentation/character/depth decisions. Retain continuous geography; later Road sequence can use the same scene and inert markers without a loading screen. Add settled exactly-once lifecycle/handoff only after the canonical conversation exists. Scene03 is not story-complete.

## J. Review evidence and F6 controls

Earlier Godot captures covered the listed spawn, prompt, board, gate, road, night, inspection and reduced-motion states. Their temporary review directory was removed during final housekeeping, so the image files are no longer available in this repository. The written results distinguish boundary fixtures/repositioned comparisons from uninterrupted route-input tests.

Open `scenes/gameplay/scene03_exterior_foundation.tscn` and F6. Move toward Mang Arnel and E; a development diagnostic confirms the request. The separate exploration F6 entry enables development Road access; take the left pedestrian gap beside the guardhouse, then walk down and along the road. R toggles environment only when settled; M toggles reduced motion when settled. Development keys require OS.is_debug_build and the exported development_tools_enabled setting. The inherited exploration scene starts with explicit debug permission already set. Neither mode marks the canonical encounter complete. No source dialogue is presented by the guard hook. Normal board E inspection remains available; Manifested inspection is intentionally suspended.

## K. Files and preservation

New runtime files: two gameplay scenes, three scene-local GDScripts and their UID files, authentic Manifested composite/import, technical Manifested mask/import and export-contract JSON. Added source export helper and this documentation. Review-only snapshots, extracted source crop, checks, measurements and captures remain in the existing review hierarchy.

The one existing scene modification is material isolation described above. Wayne's KRAs, the reconstructed Normal ORA, every DOCX, existing character/audio assets, GameClock/AudioDirector, Classroom/Hallway scripts and prior Scene02 narrative remain byte-preserved. Initial/final hashes and exact new/modified file lists are in final_integrity.json; final_git_status.txt preserves the complete pending-tree listing. Branch/HEAD unchanged; staging empty. No stage, commit, push, reset, clean, rebase, remote/config change or canceled experimental artwork reuse occurred.
