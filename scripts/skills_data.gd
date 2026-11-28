class_name SkillData
extends RefCounted

const ALL_SKILLS: Array[Dictionary] = [
	{
		"id": "wick_and_flint",
		"name": "Wick and Flint",
		"branch": "Pyromancy",
		"desc": "+4 Power\n-15% Cast Speed"
	},
	{
		"id": "murmur",
		"name": "Murmur",
		"branch": "Grimoire Mastery",
		"desc": "+25% Cast Speed\n+20% Recharge Time"
	},
	{
		"id": "guideness_of_light",
		"name": "Guideness Of Light",
		"branch": "Lantern & Soul",
		"desc": "+40% Light Radius\n-20 Movement Speed"
	},
	{
		"id": "quire",
		"name": "Quire",
		"branch": "Deep Tome",
		"desc": "+2 Max Charges &\nrefills your book\n+25% Recharge Time"
	},
	{
		"id": "swift",
		"name": "Swift",
		"branch": "Shadow Step",
		"desc": "+40 Movement Speed\n-15% Light Radius"
	},
	{
		"id": "grit_of_blood",
		"name": "Grit Of Blood",
		"branch": "Blood & Vitality",
		"desc": "+1 Max Heart &\nheals 1 Heart\n-15% XP Gained"
	},
	{
		"id": "krakens_gamble",
		"name": "Kraken's Gamble",
		"branch": "Abyssal Pact",
		"desc": "60% chance for 1.60x dmg,\n40% chance for 0.70x dmg"
	}
]


static func get_random_skills(count: int) -> Array[Dictionary]:
	var pool: Array[Dictionary] = ALL_SKILLS.duplicate()
	pool.shuffle()
	var chosen: Array[Dictionary] = []
	for i in range(min(count, pool.size())):
		chosen.append(pool[i])
	return chosen
