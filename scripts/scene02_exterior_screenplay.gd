extends RefCounted
## Scene 02 continuation only. NO TRIGGER is explicit, separate from UI style.
const STEPS: Array[Dictionary] = [
	{"id": &"walkway_sound", "source_paragraph": 18, "kind": "cue", "hold": 0.6, "direction": "[SFX: Crowd noise fades. His footsteps get louder.]"},
	{"id": &"walk_without_choosing", "source_paragraph": 19, "kind": "cue", "hold": 999, "direction": "The walkway is nearly empty. Albert walks without choosing where. His feet stop at the bench near the quiet corner."},
	{"id": &"bench_composition", "source_paragraph": 20, "kind": "cue", "hold": 1.0, "direction": "A single panel: his flat sprite, the bench, the scratched initials he can’t read."},
	{"id": &"phone_in_pocket", "source_paragraph": 21, "kind": "cue", "hold": 0.5, "direction": "[SFX: A phone buzzes in his pocket. He doesn’t take it out.]"},
	{"id": &"valedictorian", "source_paragraph": 22, "origin": "Albert", "speaker": "Albert", "classification": "heard_no_trigger", "text": "Valedictorian.", "layout": 1, "reality": 0, "style": 0},
	{"id": &"uncomfortable_hold", "source_paragraph": 23, "kind": "cue", "hold": 2.5, "direction": "Hold. Longer than feels comfortable."},
	{"id": &"top_of_everything", "source_paragraph": 24, "origin": "Albert", "speaker": "Albert", "classification": "heard_no_trigger", "text": "Top of everything.", "layout": 1, "reality": 0, "style": 0},
	{"id": &"look_at_you", "source_paragraph": 24, "origin": "Albert", "speaker": "Albert", "classification": "heard_no_trigger", "text": "Look at you.", "layout": 1, "reality": 0, "style": 0},
	{"id": &"ugh", "source_paragraph": 25, "origin": "Albert", "speaker": "Albert", "classification": "speech", "text": "Ugh.", "layout": 1, "reality": 0, "style": 0},
	{"id": &"hand_down_face", "source_paragraph": 26, "kind": "cue", "hold": 0.8, "direction": "He drags a hand down his face."},
	{"id": &"one_quiz", "source_paragraph": 27, "origin": "Albert", "speaker": "Albert", "classification": "thought", "text": "It was one quiz.", "layout": 1, "reality": 0, "style": 0},
	{"id": &"cant_even", "source_paragraph": 27, "origin": "Albert", "speaker": "Albert", "classification": "thought", "text": "It was one quiz, and I can’t even...", "layout": 1, "reality": 0, "style": 0},
	{"id": &"unfinished_thought", "source_paragraph": 28, "kind": "cue", "hold": 1.0, "direction": "He doesn’t finish the thought."},
	{"id": &"badshet", "source_paragraph": 29, "origin": "Albert", "speaker": "Albert", "classification": "speech", "text": "...Badshet.", "layout": 1, "reality": 0, "style": 0, "delivery": "murmurs"},
	{"id": &"final_music_hold", "source_paragraph": 30, "kind": "cue", "hold": 2.0, "direction": "The ambient music thins to a single sustained note and holds."},
]
