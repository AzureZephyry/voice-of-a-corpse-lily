# Scene 03 — Guardhouse and Road

Current standalone entry: `scenes/story/scene03_story.tscn` (F6). Connected F5/F6 entry: `scenes/story/connected_story.tscn`, Scene01 → Scene02 → Scene03. Standalone entry remains available. The connected wrapper continues to Scene04 only after canonical Scene03 completion. Source: unchanged `docs/story/source/scene_03_the_guardhouse.docx`.

## Source coverage

The original13Gate and10Road dialogue/thought entries remain exact, ordered and independently checked against the DOCX. Mama’s message is a separate message event, not one of those23entries. There are38ordered events:23original entries,14nonverbal cues and one incoming message.

|#|Source paragraph|Speaker / classification|Exact text|
|---|---:|---|---|
|1|5|MANG ARNEL / speech|Uy, Dimapilis.|
|2|5|MANG ARNEL / speech|Why the long face? Somebody die?|
|3|7|ALBERT / speech|Failed a quiz, po.|
|4|7|ALBERT / speech|Just kidding. It was... fine.|
|5|9|MANG ARNEL / CLEAN|Hah. Bad joke. Save it for after breakfast.|
|6|9|ALBERT / HEARD|Even the guard thinks I’m not funny.|
|7|9|ALBERT / HEARD|Even the guard thinks I’m nothing.|
|8|10|MANG ARNEL / speech|Go home and rest. Tomorrow’s another day.|
|9|10|MANG ARNEL / speech|We all have bad days, iho. Even me.|
|10|12|MANG ARNEL / CLEAN|We all have bad days.|
|11|12|ALBERT / HEARD|He thinks this is small.|
|12|12|ALBERT / HEARD|He doesn’t know what I was.|
|13|13|ALBERT / speech|Opo.|
|14|19|ALBERT / HEARD, NO TRIGGER|Everyone saw.|
|15|19|ALBERT / HEARD, NO TRIGGER|Everyone knows now.|
|16|19|ALBERT / HEARD, NO TRIGGER|Jules knows. Liezel knows. Sir knows.|
|17|19|ALBERT / HEARD, NO TRIGGER|By tomorrow, everybody.|
|18|23|ALBERT / thought|What do I even say?|
|19|23|ALBERT / thought|‘It went fine, Ma.’|
|20|26|UNKNOWN VOICE / speech|There you are.|
|21|27|ALBERT / thought|...|
|22|28|UNKNOWN VOICE / speech|You’ve been so tired.|
|23|28|UNKNOWN VOICE / speech|Haven’t you?|

## UI and progression

E/Space/click reveal or advance through the existing floral dialogue panel and shared input/typewriter/accepted-advancement-sound runner. Mama’s incoming message uses the white panel, header `Mama (message)`, exact text `How was your first quiz, nak? Proud of you! Text us after.`, and player acknowledgment. No phone interface is opened. “Phone vibrates.”/“He doesn’t open it.” and all other SFX/VFX stage directions remain cue metadata, never floating captions. The temporary `StoryLayer/Message` label is removed.

The guard prompt uses the existing Pixel handwriting_regular.ttf,40px, warm color, nearest filtering and measured placement above both actors. Existing board inspection keeps its established pixel-font overlay. No player-facing diagnostic/completion banner is rendered.

Objectives are one-way: `Talk to Mang Arnel` → complete canonical exchange → `Head through the school gate` → the full outside-sidewalk region at y1490 → `Continue down the road`. The broad Area2D and global-position fallback cover lateral movement along the sidewalk; neither requires hitting the former narrow x568/y1526 detector. Only Albert after the canonical encounter can latch the crossing. The original progression collider then closes behind him without restricting the outside Road.

Road presentation is geographic, not a monologue launched at the gate. Five ordered beat boundaries retain the original38events: initial atmosphere/four NO TRIGGER thoughts; environmental unease; Mama’s message; Albert’s following thoughts/music cue; UNKNOWN VOICE and final walk. The first horizontal movement chooses a direction. Rightward route anchors are approximately x620/800/980/1100/1280 from the gate. Leftward anchors scale to the shorter existing Road, approximately x540/448/355/294/201. Each new beat requires genuine travel; Albert stops during dialogue, cues and transitions, then regains control for the next interval. The final scripted walk resumes only after Normal restoration. No dialogue or source order changes.

## Movement and population

Classroom and Hallway use `player_movement.gd` with SPEED150world px/s and1×cameras. Production Scene02Exterior and Scene03 reuse camera-normalized movement:150 / camera.zoom.x =75world px/s under their2×cameras, yielding the same150screen px/s. The standalone Exterior laboratory retains its earlier controller. No Road-only modifier remains. Diagonal input is normalized, stopping takes one physics tick and animation playback uses actual displacement with speed_scale1. Classroom/Hallway retain5×sprites; Exterior/Scene03 retain2×sprites. Artwork, cameras and shared movement constants were not rescaled.

Thirty-two scene-authored outdoor students reuse the existing outdoor NPC body, feet, actor-shadow component, animation controller and waypoint roaming. Eight walk bounded campus/parking/garden routes; twenty-four idle in campus/parking and outside-sidewalk spaces. Five genuine appearance pairs are reused: female01/02/03 and male01/02. All are2×, matching Exterior Albert, collision_layer2/mask1; Albert’s mask includes layer2. They avoid architecture and remain unpushable. All eight routes completed loops in testing. Two idle placements initially intersected existing architecture and were relocated before the final run. Offscreen animation and shadow updates pause outside a128px viewport margin, preserving pose and resuming before visibility. The shared existing sun receiver provides grounding/casts. No new navigation framework, individual lights, art or audio.

## Reality and endpoint

Pair7’s two HEARD thoughts, Pair8’s two HEARD thoughts and paragraphs26–28’s UNKNOWN VOICE passage each require the genuine Manifested exterior. There are three segments/six directional switches and six accepted-transition glitch sounds. The actual `SchoolExterior/Map.texture` path is verified as `school_manifested_saved_composite.png` on every manifested entry; the Normal composite is verified elsewhere. Sprite variants swap at the same authority-controlled midpoint, preserving animation/frame/progress/position. Mang Arnel now swaps his genuine delivered Normal/Manifested SpriteFrames at the same presentation midpoint, preserving animation, frame and progress.

The four Road HEARD, NO TRIGGER thoughts remain Normal; the0.28creeping world-only vignette stays independent. UNKNOWN VOICE uses the black panel and preserves [LILY] only as metadata, including Albert’s intervening thought in the same manifestation. The final walking cue waits for Normal restoration and then holds the last direction for2seconds at normal speed before restoring free control. Normal lighting always samples current GameClock time. Scene completion emits once, closes dialogue and hides the finished objective; no banner; the connected wrapper consumes completion and safely enters Scene04.

Clock/music persist, existing Road ambience recedes with distance, and the scene-local Music low-pass gradually reaches6.5kHz at its authored cue. Reduced motion uses the existing nonmoving0.22s world transition and disables text displacement. Cancellation disables the runner before settling/restoring reality, clears effects/filter/sounds and waits for settled presentation before supported replay.

## Asset limitations and validation

Three independently instantiated identical potted bushes were placeholders from M05.3, not baked Wayne artwork. They are removed, including their fade/rotation behavior. Original baked vegetation is preserved; natural Road vegetation suitable for the authored leaning performance is still missing. No bright Normal-only shrubs remain over Manifested art. Missing phone-vibration, isolated traffic/radio/tricycle/vendor/wind recordings and guard newspaper/coffee staging remain honest production dependencies. Their source cues and order are retained without printed instructions, substituted recordings or invented performances.

Earlier graphical runs, source checks, movement samples and captures were stored in `.scene03-preproduction-review-2026-11-08/consolidated_final/`; that temporary review directory was removed during final housekeeping. Earlier M05.3 reports are superseded where they describe provisional Normal Guardhouse pairs, raw cue captions or repeated plants. A forced live scene change from visible Classroom dialogue to `school_exterior_playable.tscn` was reproduced on 2026-11-10 via Main Menu → Start → connected story and caused Godot 4.7.2 to terminate with signal 11 at frame 1844; its native cause remains unknown. Original KRA/DOCX files remain unchanged; the shared actor-collision and interaction corrections are documented below.

## Connected gameplay corrections — 2026-11-09

Scene01 completion now requires interaction with its unlocked south-right classroom exit after the Professor exchange. The existing objective/marker style shows `Exit the classroom`. Scene02 begins at the corresponding rightmost Hallway door, feet(3570,405), facing out. Room numbering is not supplied by the artwork; this is the explicit spatial correspondence used by the story.

E/Space/click world activation shares `interaction_activation.gd`; bounded object/prompt clicks use canvas-transformed target bounds. Existing dialogue runners retain input ownership and reveal/advance guards. Scene02 departure shows `Walk left past your friends` in the objective HUD, with no floating duplicate. Its final Exterior monologue unlocks free walking with `Go to the main gate`; only physical arrival in the inside gate approach completes Scene02. Scene03 inherits that actual position instead of teleporting to a fixed spawn. Production Exterior free walking reuses the camera-normalized controller; the separate environment laboratory remains unchanged.

Player/NPC top-down bodies explicitly use floating motion and no moving-platform carry. Ambient actors occupy layer 2; idle actors do not perform penetration recovery into Albert, and roamers stop before approaching him. The 33 Hallway students retain their existing yielding behavior. Source assets are unchanged. The temporary gameplay-correction evidence folder was removed during final housekeeping; this paragraph preserves the implementation summary.
