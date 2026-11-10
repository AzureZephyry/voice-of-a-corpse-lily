extends RefCounted
## Exact Scene 04 entries; nonverbal staging remains cue metadata.
const STEPS: Array[Dictionary] = [
	{
		"id": "entry_medal",
		"source_paragraph": 2,
		"kind": "cue",
		"hold": 3.0,
		"direction": "Albert closes the door. The room is dim. The medal sits on the desk, catching what little light there is. He looks at it. He doesn’t touch it.",
		"reality": 0
	},
	{
		"id": "line_3_1",
		"source_paragraph": 3,
		"speaker": "Albert",
		"text": "...",
		"classification": "speech",
		"layout": 1,
		"reality": 0,
		"style": 0
	},
	{
		"id": "bag_bed_phone",
		"source_paragraph": 4,
		"kind": "cue",
		"hold": 1.5,
		"direction": "He drops his bag by the door and sits on the edge of the bed. His phone is in his hand. Mama’s message is still unread. He turns the screen face-down.",
		"reality": 0
	},
	{
		"id": "quiet_crying",
		"source_paragraph": 6,
		"kind": "cue",
		"hold": 16.0,
		"direction": "[SFX: Quiet crying. Nothing else.] (Play this straight. No cutaway, no joke. Let it run past the point where it feels like enough.)",
		"reality": 0
	},
	{
		"id": "line_7_1",
		"source_paragraph": 7,
		"speaker": "Albert",
		"text": "I was supposed to be good at this.",
		"classification": "HEARD, NO TRIGGER",
		"layout": 1,
		"reality": 0,
		"style": 0
	},
	{
		"id": "faint_wind",
		"source_paragraph": 8,
		"kind": "cue",
		"hold": 1.5,
		"direction": "[SFX: Faint wind. Closer now.]",
		"reality": 0
	},
	{
		"id": "line_9_1",
		"source_paragraph": 9,
		"speaker": "UNKNOWN VOICE",
		"text": "Shh.",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "line_9_2",
		"source_paragraph": 9,
		"speaker": "UNKNOWN VOICE",
		"text": "I know.",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "line_9_3",
		"source_paragraph": 9,
		"speaker": "UNKNOWN VOICE",
		"text": "I saw all of it.",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "voice_pause",
		"source_paragraph": 9,
		"kind": "cue",
		"hold": 1.5,
		"direction": "[LILY] UNKNOWN VOICE: “Shh.” UNKNOWN VOICE: “I know.” UNKNOWN VOICE: “I saw all of it.” Pause. UNKNOWN VOICE: “You’re not the Albert they clapped for.” UNKNOWN VOICE: “And I only ever loved that one.”",
		"reality": 1
	},
	{
		"id": "line_9_4",
		"source_paragraph": 9,
		"speaker": "UNKNOWN VOICE",
		"text": "You’re not the Albert they clapped for.",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "line_9_5",
		"source_paragraph": 9,
		"speaker": "UNKNOWN VOICE",
		"text": "And I only ever loved that one.",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "line_10_1",
		"source_paragraph": 10,
		"speaker": "Albert",
		"text": "Then what’s left?",
		"classification": "HEARD, NO TRIGGER",
		"layout": 1,
		"reality": 1,
		"style": 0
	},
	{
		"id": "line_11_1",
		"source_paragraph": 11,
		"speaker": "UNKNOWN VOICE",
		"text": "Nothing they’d want.",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "line_11_2",
		"source_paragraph": 11,
		"speaker": "UNKNOWN VOICE",
		"text": "So why keep carrying it?",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "line_11_3",
		"source_paragraph": 11,
		"speaker": "UNKNOWN VOICE",
		"text": "You don’t have to hold it anymore.",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "wipe_face",
		"source_paragraph": 12,
		"kind": "cue",
		"hold": 2.0,
		"direction": "Albert says nothing. He wipes his face with the back of his hand, and it doesn’t help.",
		"reality": 0
	},
	{
		"id": "lie_down",
		"source_paragraph": 13,
		"kind": "cue",
		"hold": 2.0,
		"direction": "He lies down. The Garden creeps in at the edges of the screen, thicker than before. Leaves press against the frame. The medal’s light fades.",
		"reality": 0
	},
	{
		"id": "sleep",
		"source_paragraph": 13,
		"kind": "cue",
		"hold": 1.8,
		"direction": "He lies down. The Garden creeps in at the edges of the screen, thicker than before. Leaves press against the frame. The medal’s light fades.",
		"reality": 0
	},
	{
		"id": "garden_emerges",
		"source_paragraph": 13,
		"kind": "cue",
		"hold": 5.5,
		"direction": "He lies down. The Garden creeps in at the edges of the screen, thicker than before. Leaves press against the frame. The medal’s light fades.",
		"reality": 0
	},
	{
		"id": "line_14_1",
		"source_paragraph": 14,
		"speaker": "Albert",
		"text": "I don’t want to be like this anymore.",
		"classification": "thought",
		"layout": 1,
		"reality": 1,
		"style": 0
	},
	{
		"id": "line_15_1",
		"source_paragraph": 15,
		"speaker": "UNKNOWN VOICE",
		"text": "Then come.",
		"classification": "speech",
		"layout": 1,
		"reality": 1,
		"style": 1,
		"source_marker": "[LILY]"
	},
	{
		"id": "music_fades",
		"source_paragraph": 16,
		"kind": "cue",
		"hold": 3.0,
		"direction": "[SFX: The ambient music loses clarity, then stops.] [VFX: Cut to black.]",
		"reality": 1
	}
]
