# Gameplay soundtrack and mix

Scene 01 and direct School Exterior entry call AudioDirector.ensure_gameplay_music(). It starts Lawrence's existing assets/audio/music/soundtrack.ogg once, including during the Classroom black opening. AudioDirector is the existing autoload, not a new manager. Subsequent ensure calls do not restart playback or replace an explicitly requested music cue. Scene ambience release never owns/stops music. The Scene 01 completion endpoint leaves it playing.

Two fixed Music-bus players (Music and MusicB) alternate for loop overlaps and explicit cue crossfades; normally only one plays. No runtime players are spawned. The 47.643s source has no authored BPM/loop markers; its import remains loop=false. A 2s complementary linear overlap plays the original tail under the next original beginning without a hard EOF cut. Weights sum to one, including correlated material. No recordings are trimmed, normalized, converted or overwritten. This is a technical continuity treatment, not a claim of a musically seamless or beat-matched loop. Final headphones/speaker listening must approve the quiet outro/intro relationship.

API:
- ensure_gameplay_music(): idempotent continuous gameplay entry, 1.5s fade-in.
- play_music(owner, fade_seconds, stream, looping): deliberate cue; defaults to the existing soundtrack as a one-shot for compatibility. A different explicitly requested stream crossfades; requests during overlap retain only the latest pending cue. No future story cues are activated.
- stop_music(seconds): explicit global music fade/stop, separate from release(scene_ambience_owner).
- set_bus_level(): existing Music/Ambience/Footsteps attenuation controls remain available.

Music follows genuine SceneTree pause, including playback cursor, crossfade and fade envelopes. Ordinary movement locks, dialogue, manifestation, glitch, scene release and time overrides never pause or duck it. Existing ambience pause/lifecycle behavior is unchanged. No dialogue-driven music ducking or new compressor/limiter is added.

## Initial calibration

| Bus | Gain | Notes |
|---|---:|---|
| Master | 0 dB | Existing routing/defaults preserved |
| Music | 0 dB | Player envelope reaches -10 dB; source previously measured approximately +0.2dB true peak |
| Ambience | -10 dB | Existing scene gain and gentle whisper duck retained |
| Footsteps | -5 dB | Existing per-surface compensation remains -8/-4/-14dB for interior/concrete/grass |

Classroom populated/empty/conversation gains remain +9/+1/-1dB before bus attenuation (effective -1/-9/-11dB before whisper duck). The quiet Classroom source previously measured about -46.6 LUFS. Source levels are not equalized to an arbitrary peak; Music reserves headroom, ambience is reduced independently, and the louder grass source retains its own compensation. Lawrence's glitch and advancement recordings route through the SFX bus at -6dB. No spoken voice recordings are currently routed, so no empty Dialogue bus is added. The unassigned clock hook remains silent. Future recordings need their own measured cue gain before assignment.

## Lawrence glitch and accepted-advance SFX

Four original stereo PCM16 WAV deliveries are reused without modification:

| File under assets/audio/sfx/ | Rate | Duration | Source sample peak | Whole-file RMS | Leading/trailing quiet below -45dBFS |
|---|---:|---:|---:|---:|---:|
| glitch_01.wav | 48kHz | 2.424s | 0dBFS | -16.04dBFS | .023/.001s |
| glitch_02.wav | 44.1kHz | 3.0563s | 0dBFS | -19.11dBFS | .662/1.853s |
| glitch_03.wav | 48kHz | 3.120s | 0dBFS | -19.20dBFS | .049/.017s |
| dialogue_blip.wav | 44.1kHz | 1.000s | -14.68dBFS | -38.92dBFS | .130/.660s |

These are sample/RMS measurements, not LUFS. Whole-file RMS includes quiet padding. Glitch01 has a sustained early body and decaying tail, Glitch02 a delayed concentrated impact with long quiet padding, Glitch03 an early body with a much quieter second half. Original full-scale samples: 17/117/39 respectively; gain attenuation cannot undo existing source saturation. Selection uses measurable envelopes rather than an assumed emotional role based on filename order.

Selection is a deterministic three-item Fisher-Yates shuffle bag, selection_seed=1031 on ClassroomAudio. Each bag uses every variant once. The next bag swaps its first selected item if it would repeat the previous variant. All 32 directional switches use this same variation policy, including Professor pairs, rather than assigning emotional roles from filenames. No pitch variation or layered three-sample playback is used.

The existing ClassroomAudio observes RealityPresentation.transition_started only. Rejected/busy requests produce no audio. It starts one selected variant in that same process frame; device/output-buffer latency still applies. Seek offsets .015/.650/.040 seconds remove measured quiet lead-in non-destructively. Gains are -12/-14/-12dB; Glitch02's concentrated active body gets extra attenuation. SFX bus is -6dB to Master. Visual/dialogue duration is never delayed for samples. Natural tails are allowed; if another switch arrives, the old voice fades out over 40ms while the new one starts immediately. Two fixed scene-owned glitch players bound this overlap. Reused slots kill old fade callbacks. Scene exit frees players and their bound tweens; canceling a visual transition emits no additional audio start. Genuine pause pauses the scene-owned players and fades.

DialoguePanel exposes accepted_line_advanced through notify_accepted_advance(has_following_line). Narrative hosts call it only AFTER their existing input/hold/repeat/typewriter gates accept progression from a complete line. It checks active/visible/non-typing state and rejects same-frame duplication. The shared Quiz base covers quiz, dismissal and Professor dialogue; the Professor override knows about pair/return continuation. Opening uses the same panel hook. Future hosts may opt in at their accepted progression boundary rather than connecting to character or line_revealed signals. Closing without another authored line remains silent, including dismissal-to-exploration and the final hand narration.

ClassroomAudio consumes that one shared signal. dialogue_blip.wav plays at .120s, gain -4dB through SFX(-6dB), on one fixed voice with no accumulating polyphony. It is NOT a typewriter effect: no character_revealed, automatic reveal-completion or reveal-only input is wired to audio. A completed-line advance leading into a reality transition produces one quiet advance impact plus one selected glitch; neither event replays the other. Existing soundtrack, ambience and footstep logic/gains are unchanged; no music ducking, rewind, restart, added compressor or audio-driven narrative delay is introduced.

## Validation and limitations

Run graphical F5 from the opening to the paper narration. Confirm 19 voice lines, 16 Manifested segments, 32 transitions and exactly one scene_completed event. Audio should report 32 glitch starts and 54 accepted-advance sounds for the current complete flow. The seeded 32-switch sequence uses variants 01/02/03 11/10/11 times without adjacent repeats. Test automatic reveal, reveal-only presses, held/rapid inputs and closure-without-next-line for unwanted advancement audio.

Test rejected requests, cancellation, pause/resume and scene exit. Scene-owned SFX should stop on exit with no orphaned nodes; persistent music should continue. Repeated ensure calls must not restart music. Exercise both natural soundtrack loops and a seek near EOF, checking complementary overlap gains and settlement to one active music voice. Explicit future cues should crossfade; stop/restart should remain deterministic. School Exterior day/night changes must affect ambience without resetting music.

Reference full-scene sampled peaks: Music -9.84dBFS, SFX -15.88, Ambience -29.94, Footsteps -27.89, Master -8.10. No output clipping, zero-active-music gap, non-loop restart or unbounded voice growth was detected in the reference run. Peak measurements are not integrated loudness or a guarantee for future mixes. Validate new recordings independently, especially when adding voiced narrative cues.

The original glitches contain full-scale samples; gain attenuation cannot undo source saturation. The soundtrack has a quiet ending and no authored musical loop points. Device-specific balance and the loop seam require listening when mix settings or assets change. No additional scenes or automatic future soundtrack cues are implemented.
