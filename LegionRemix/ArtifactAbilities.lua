-- LegionRemix/ArtifactAbilities.lua

local addon, ns = ...
local Hekili = _G[ addon ]

local class, state = Hekili.Class, Hekili.State
local all = Hekili.Class.specs[ 0 ]


all:RegisterAbilities( {
	call_of_the_forest = {
		id = 1233577,
		cast = 0,
		cooldown = 90,
		gcd = "spell",

		toggle = "cooldowns",

		startsCombat = true,
		texture = 4667415
	},
	twisted_crusade = {
		id = 1237711,
		cast = 0,
		cooldown = 90,
		gcd = "spell",

		toggle = "cooldowns",

		startsCombat = true,
		texture = 1413862
	},
	narans_everdisc = {
		id = 1233775,
		cast = 0,
		cooldown = 60,
		gcd = "spell",

		toggle = "cooldowns",

		startsCombat = true,
		texture = 6891023
	},
	tempest_wrath = {
		id = 1233181,
		cast = 0,
		cooldown = 60,
		gcd = "spell",

		toggle = "cooldowns",

		startsCombat = true,
		texture = 839979
	},
	vindicators_judgement = {
		id = 1251045,
		cast = 0,
		cooldown = 90,
		gcd = "spell",

		toggle = "cooldowns",

		startsCombat = true,
		texture = 1360764
	},
	remix_time = {
		id = 1236723,
		channeled = true,
		cast = 3,
		cooldown = 120,
		gcd = "spell",

		toggle = "cooldowns",

		startsCombat = false,
		texture = 5228749
		
	}
} )