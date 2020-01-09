GM.Name = "DarklandsFortwars"
GM.Author = "cody8295"
GM.Email = "N/A"
GM.Website = "N/A"


------------
--Maplist
------------
mapList = {

{"fw_2forttfc_v2"},
{"fw_2forttfc_v4"},
{"fw_2fort_night"},
{"fw_2sides"},
{"fw_3block"},
{"fw_3rooms"},
{"fw_3some3"},
{"fw_3some4"},
{"fw_3some7"},
{"fw_3stories"},
{"fw_3towers-3"},
{"fw_3towers2"},
{"fw_4team_balldrop"},
{"fw_4_platforms"},
{"fw_4_tunnel_v2"},
{"fw_adultswim_v2"},
{"fw_airgrid"},
{"fw_ambush"},
{"fw_ancient_towers"},
{"fw_ancient_towers_v1"},
{"fw_ancient_towers_v2"},
{"fw_arched2"},
{"fw_arches"},
{"fw_arena_v2"},
{"fw_aztec"},
{"fw_ball_room_blitz"},
{"fw_battlefield"},
{"fw_battleships3"},
{"fw_blockfort"},
{"fw_bounce"},
{"fw_box"},
{"fw_boxed"},
{"fw_boxed_rt"},
{"fw_breakable"},
{"fw_bunkers"},
{"fw_canada"},
{"fw_canals"},
{"fw_castles"},
{"fw_castle_v1"},
{"fw_chambers_final"},
{"fw_chasem2"},
{"fw_cheddar"},
{"fw_choices"},
{"fw_circlewarz"},
{"fw_cityblock"},
{"fw_city_v2"},
{"fw_climb"},
{"fw_climb2"},
{"fw_club_b1"},
{"fw_complex"},
{"fw_complexity_v2"},
{"fw_concrete"},
{"fw_confusion"},
{"fw_containment"},
{"fw_crocodile_a1"},
{"fw_cuba"},
{"fw_cuba_xfix"},
{"fw_curvature"},
{"fw_cycle"},
{"fw_darkest_v1"},
{"fw_darkland-football"},
{"fw_deathbox"},
{"fw_deathstar"},
{"fw_death_star"},
{"fw_delay"},
{"fw_demoneye_b2"},
{"fw_desertcamp"},
{"fw_desert_camp"},
{"fw_destruction"},
{"fw_devbox"},
{"fw_developer"},
{"fw_developers2"},
{"fw_devreversed_v2"},
{"fw_diarena"},
{"fw_ditch"},
{"fw_ditch_v2"},
{"fw_ditch_v3"},
{"fw_ditch_v4"},
{"fw_ditch_v5"},
{"fw_dock_b1"},
{"fw_earthlanding_b1"},
{"fw_earthlanding_b2"},
{"fw_earthlanding_b3"},
{"fw_edifice"},
{"fw_endoftime"},
{"fw_excellence"},
{"fw_excellence_fixed"},
{"fw_exhibition"},
{"fw_facingworlds"},
{"fw_factory"},
{"fw_faintlullaby"},
{"fw_fastkill"},
{"fw_fish"},
{"fw_football"},
{"fw_forest_zl"},
{"fw_fortress"},
{"fw_fourrooms"},
{"fw_fourrooms_vx"},
{"fw_funtime"},
{"fw_generic_b1"},
{"fw_goldengate_v3"},
{"fw_goldengate_v4"},
{"fw_goldengate_v5"},
{"fw_grand_hall"},
{"fw_greengrass"},
{"fw_greengrass_re_v31"},
{"fw_ground"},
{"fw_harbor"},
{"fw_heights"},
{"fw_hellhound_v6"},
{"fw_hill"},
{"fw_hill4th"},
{"fw_hulkcave_beta_d_d"},
{"fw_hulkskycastles"},
{"fw_hydro"},
{"fw_hydro_xfix"},
{"fw_iceworld"},
{"fw_industrial_being"},
{"fw_infinity"},
{"fw_islandwarfare"},
{"fw_italy"},
{"fw_jailbird"},
{"fw_japan"},
{"fw_jigga"},
{"fw_junglealtar"},
{"fw_killbox_v2"},
{"fw_lake_v2"},
{"fw_ledges"},
{"fw_lmsdeathbox_1"},
{"fw_longest_yard"},
{"fw_mayan"},
{"fw_mazin"},
{"fw_metalcomplex_final"},
{"fw_metalcomplex_final2"},
{"fw_mic_v2"},
{"fw_mid_v1"},
{"fw_minecraft"},
{"fw_mini"},
{"fw_miniV1"},
{"fw_moon"},
{"fw_municipal"},
{"fw_municipal_v2"},
{"fw_narrows"},
{"fw_ninjaownage"},
{"fw_noase"},
{"fw_no_mans_land"},
{"fw_no_where"},
{"fw_obsidian"},
{"fw_octagon_v2"},
{"fw_oct_2"},
{"fw_oct_4"},
{"fw_orig"},
{"fw_outpost_v2"},
{"fw_pacman"},
{"fw_pacman3"},
{"fw_paintball"},
{"fw_paintball2"},
{"fw_parkwar"},
{"fw_pipeline"},
{"fw_pipeline2"},
{"fw_pipeline3"},
{"fw_pipelinev2"},
{"fw_pit"},
{"fw_platforms"},
{"fw_pmg_ftw_v1"},
{"fw_polycourt_a1"},
{"fw_pool"},
{"fw_pool3"},
{"fw_pooltable"},
{"fw_pool_v2"},
{"fw_portal"},
{"fw_pumpkin_fight"},
{"fw_pumpkin_fight2"},
{"fw_quad"},
{"fw_quadroom_reloaded"},
{"fw_ramp"},
{"fw_ramp_n_tunnel"},
{"fw_rattletrap"},
{"fw_reboxed"},
{"fw_refinery21"},
{"fw_reset"},
{"fw_reset_V2"},
{"fw_reset_v4"},
{"fw_rogueball"},
{"fw_sanctuary2"},
{"fw_sectors_textured"},
{"fw_sharting_dragons_v1"},
{"fw_shelfs"},
{"fw_skyworld"},
{"fw_space"},
{"fw_spacestation_1"},
{"fw_spiral_v2"},
{"fw_stairs"},
{"fw_stepdown"},
{"fw_streetwars"},
{"fw_streetwars_v3"},
{"fw_stronghold2"},
{"fw_sunny_4"},
{"fw_swamp"},
{"fw_symmetry"},
{"fw_tactical"},
{"fw_teleport"},
{"fw_temple_v2"},
{"fw_tf2_2fortv2"},
{"fw_thebridge"},
{"fw_towerpower_v2"},
{"fw_towers"},
{"fw_train_station_v3"},
{"fw_trapped"},
{"fw_trenches3"},
{"fw_trimfortsv2"},
{"fw_trucksurf"},
{"fw_tubecastle"},
{"fw_turbulence_v2"},
{"fw_twbunk"},
{"fw_tworooms"},
{"fw_under-control"},
{"fw_under-control2"},
{"fw_uphill_madness"},
{"fw_valley_v2"},
{"fw_vietnam"},
{"fw_volcano_v2"},
{"fw_voodoo_a1"},
{"fw_wall"},
{"fw_war"},
{"fw_watchtower"},
{"fw_waterway"},
{"fw_waterway_a1"},
{"fw_weedlab"},
{"fw_xmas"}

}

for i,v in pairs(mapList) do
	mapList[i].votes = 0
end

function GM:Initialize()
end

NEO_JUMP_COST = 60
PRED_DRAIN_RATE = 15
SORCERER_MANA_COST = 100
ADVANCER_MANA_COST = 50
ASSASSIN_MANA_COST = 100

TEAM_BLUE = 1
TEAM_RED = 2
TEAM_GREEN = 3
TEAM_YELLOW = 4

team.SetUp(TEAM_BLUE, "Blue Team", Color(20,0,240,255))
team.SetUp(TEAM_RED, "Red Team", Color(255,0,0,255))
team.SetUp(TEAM_GREEN, "Green Team", Color(0,255,0,255))
team.SetUp(TEAM_YELLOW, "Yellow Team", Color(220,220,0,255))

Skills = {}
Skills[1] = { 
	NAME = "Speed", 
	COST = {[0] = 0, [1] = 5000, [2] = 10000, [3] = 15000, [4] = 20000, [5] = 25000, },
	LEVEL = {[0] = 0, [1] = 10, [2] = 20, [3] = 30, [4] = 40, [5] = 50, },
	DESCRIPTION = "This upgrade will increase your speed by 10 units per second to a maximum of 50 units per second.", 
}

Skills[2] = {
	NAME = "Health",
	COST = {[0] = 0, [1] = 6000, [2] = 12000, [3] = 18000, [4] = 24000, [5] = 30000, },
	LEVEL = {[0] = 0, [1] = 10, [2] = 20, [3] = 30, [4] = 40, [5] = 50, },
	DESCRIPTION = "This upgrade will give you 10 health points for each upgrade to a maximum of 50 health.",
}

Skills[3] = {
	NAME = "Max Energy",
	COST = {[0] = 0, [1] = 6000, [2] = 12000, [3] = 18000, [4] = 24000, [5] = 30000, },
	LEVEL = {[0] = 0, [1] = 5, [2] = 10, [3] = 15, [4] = 20, [5] = 25, },
	DESCRIPTION = "This upgrade will increase your maximum energy by 5 energy points up to a maximum of 25 points.",
}

Skills[4] = {
	NAME = "Energy Regen",
	COST = {[0] = 0, [1] = 5000, [2] = 10000, [3] = 15000, [4] = 20000, [5] = 25000, },
	LEVEL = {[0] = BASE_ENERGY_REGEN, [1] = 1.1, [2] = 1.2, [3] = 1.3, [4] = 1.4, [5] = 1.5, },
	DESCRIPTION = "This upgrade will increase your energy regeneration by 1 energy point per second to a maximum of +5",
}

Skills[5] = {
	NAME = "Fall Damage",
	COST = {[0] = 0, [1] = 5000, [2] = 10000, [3] = 15000, [4] = 20000, [5] = 25000, },
	LEVEL = {[0] = 5, [1] = 6, [2] = 7, [3] = 8, [4] = 9, [5] = 10, },
	DESCRIPTION = "This upgrade will reduce your fall damage",
}

Classes = {}
Classes[1] = {
    NAME = "Human",
    COST = 0,
    WEAPON = "human_gun",
    DESCRIPTION = "This is the default starting class armed with a glock. Play this class if you plan on saving for a more expensive class such as Ninja or Hitman.",
    SPECIALABILITY = "Right click to call hacks!",
    SPECIALABILITY_COST = 0,
    HEALTH = 100,
    SPEED = 250,
    MODEL = "models/player/Kleiner.mdl",
    JUMPOWER = 200
}
 
Classes[2] = {
    NAME = "Gunner",
    COST = 6000,
    WEAPON = "gunner_gun",
    DESCRIPTION = "This class is armed with a desert eagle, dealing significantly more damage per shot than the Human's pistol. This is a great class if you're just starting off and want to have some extra money in the bank.",
    SPECIALABILITY = "Allows you to deflect bullets, consuming  (amount of damage * 2) energy every time you deflect.  Your energy does not regenerate, so once depleted, you take bullet damage.  Bullet damage greater than your current energy will deplete it and do full damage.  Special only active while weilding the desert eagle.",
    SPECIALABILITY_COST = 30000,
    HEALTH = 100,
    SPEED = 170,
    MODEL = "models/player/Barney.mdl",
    JUMPOWER = 200
}
 
Classes[3] = {
    NAME = "Ninja",
    COST = 15000,
    WEAPON = "ninja_gun",
    DESCRIPTION = "This class is armed with a USP, able to jump high, run fast and take no fall damage. Ninja is a great budget option for ball control.",
    SPECIALABILITY = "Right click to perform a super jump for 100 energy.",
    SPECIALABILITY_COST = 25000,
    HEALTH = 80,
    SPEED = 300,
    MODEL = "models/player/mossman.mdl",
    JUMPOWER = 500
}
 
Classes[4] = {
    NAME = "Hitman",
    COST = 20000,
    WEAPON = "hitman_gun",
    DESCRIPTION = "This class is armed with a scout sniper rifle. With only one shot per magazine, you must use precision and accuracy to take down enemies from a distance.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 100,
    SPEED = 250,
    MODEL = "models/player/breen.mdl",
    JUMPOWER = 200
}
 
Classes[5] = {
    NAME = "Golem",
    COST = 25000,
    WEAPON = "golem_gun",
    DESCRIPTION = "This is a very tanky class armed with an M249 LMG holding 75 rounds.",
    SPECIALABILITY = "Reduce damage you take by 50% for  4 seconds at the cost of 100 energy.",
    SPECIALABILITY_COST = 45000,
    HEALTH = 150,
    SPEED = 150,
    MODEL = "models/player/monk.mdl",
    JUMPOWER = 200
}
 
Classes[6] = {
    NAME = "Predator",
    COST = 55000,
    WEAPON = "pred_gun",
    DESCRIPTION = "This class weilds a knife, able to kill any enemy with a backstab, and is able to cloak with right click. This class is best used in bases, whether it be defending your own base, or sneaking into an enemy base.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 120,
    SPEED = 250,
    MODEL = "models/player/gman_high.mdl",
    JUMPOWER = 200
}
 
Classes[7] = {
    NAME = "Juggernaught",
    COST = 60000,
    WEAPON = "jugg_gun",
    DESCRIPTION = "This class is the tankiest of them all, weilding an M3 pump shotgun. This defensive class is best used in close quarters, and is great for guarding a base.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 200,
    SPEED = 150,
    MODEL = "models/player/odessa.mdl",
    JUMPOWER = 200
}
 
Classes[8] = {
    NAME = "Bomber",
    COST = 70000,
    WEAPON = "bomber_gun",
    DESCRIPTION = "This class uses C4 to blow himself and surrounding enemies up. He is best in close quarters, and also deals significant damage to bases.",
	SPECIALABILITY = "Place a destroyable bomb on the ground that  detonates after 8 seconds. These small bombs deal heavy damage  to props. Consumes 100 energy.",
	SPECIALABILITY_COST = 40000, 
    HEALTH = 180,
    SPEED = 230,
    MODEL = "models/player/Eli.mdl",
    JUMPOWER = 200
}
 
Classes[9] = {
    NAME = "Swat",
    COST = 50000,
    WEAPON = "swat_gun",
    DESCRIPTION = "This class is armed with an M4A1, able to deal significant damage at medium distances. This class will generally do well on any map, and is best played offensively.",
    SPECIALABILITY = "Your M4A1 can now launch grenades at the cost of 100 energy.",
    SPECIALABILITY_COST = 45000,
    HEALTH = 100,
    SPEED = 230,
    MODEL = "models/player/Combine_Super_Soldier.mdl",
    JUMPOWER = 200
}
 
Classes[10] = {
    NAME = "Terrorist",
    COST = 55000,
    WEAPON = "terrorist_gun",
    DESCRIPTION = "This class carries an AK47, comparable to Swat's M4A1. In comparison to Swat, this class has slightly more damage, but less accuracy. Terrorist also has slightly more health.",
    SPECIALABILITY = "Continue firing after your magazine  has emptied at the cost of 20 energy per bullet.",
    SPECIALABILITY_COST = 35000,
    HEALTH = 120,
    SPEED = 220,
    MODEL = "models/player/Combine_Soldier_PrisonGuard.mdl",
    JUMPOWER = 200
}
 
Classes[11] = {
    NAME = "Sorcerer",
    COST = 50000,
    WEAPON = "sorcerer_gun",
    DESCRIPTION = "This mage type class uses energy to shoot bolts of lightning accurately at long distances. With good aim, this class can be deadly.",
	SPECIALABILITY = "Toggles seeking for a target that is 500 units  or closer, then casting chain lightning dealing 70 damage to  the first target hit, and 50% damage to a second target. Consumes 100 energy.",
	SPECIALABILITY_COST = 50000, 
    HEALTH = 80,
    SPEED = 230,
    MODEL = "models/player/soldier_stripped.mdl",
    JUMPOWER = 200
}
 
Classes[12] = {
    NAME = "Neo",
    COST = 70000,
    WEAPON = "neo_gun",
    DESCRIPTION = "This class is armed with rapid firing dual elites and the ability to use energy to jump far distances. Gravity is not Neo's friend, so be careful of high falls. This class is best used for ball control.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 90,
    SPEED = 230,
    MODEL = "models/player/charple.mdl",
    JUMPOWER = 200
}
 
Classes[13] = {
    NAME = "Assassin",
    COST = 60000,
    WEAPON = "assassin_gun",
    DESCRIPTION = "This class is similar to hitman, but has 3 bullets in his sniper's magazine, and is able to fire rapidly. Assassin is most effective in a high spot, or sniping from a distance.",
    SPECIALABILITY = "Enables a second level of zoom on your  sniper, also allows you to reload twice as fast for 100 energy.",
    SPECIALABILITY_COST = 35000, 
    HEALTH = 100,
    SPEED = 170,
    MODEL = "models/player/gman_high.mdl",
    JUMPOWER = 200
}
 
Classes[14] = {
    NAME = "Advancer",
    COST = 45000,
    WEAPON = "advancer_gun",
    DESCRIPTION = "This class is armed with a slow firing P90 and moves very slowly. Advancer's special ability is a must have, allowing this class to be one of the most agile, and is great for ball control.",
    SPECIALABILITY = "While crouched, double tap A or D to launch  you in that direction at the cost of 50 energy.",
    SPECIALABILITY_COST = 30000,
    HEALTH = 120,
    SPEED = 120,
    MODEL = "models/player/charple.mdl",
    JUMPOWER = 200
}
 
Classes[15] = {
    NAME = "RocketMan",
    COST = 60000,
    WEAPON = "arena_rocket",
    DESCRIPTION = "This class uses a rocket launcher, able to deal huge damage with a direct hit. Due to his rockets swaying in the wind, it isn't easy hitting players from a long distance. Bases are bigger though, so Rocketman is great at taking down bases with a barrage of rockets from a distance.",
	SPECIALABILITY = "Attach a laser pointer to your rocket launcher  allowing your next rocket to be laser-guided. Consumes 100 energy.",
	SPECIALABILITY_COST = 30000, 
    HEALTH = 160,
    SPEED = 120,
    MODEL = "models/player/odessa.mdl",
    JUMPOWER = 200
}
Classes[16] = {
    NAME = "Grenadier",
    COST = 60000,
    WEAPON = "grenade_gun",
    DESCRIPTION = "This class tosses grenades, able to deal lethal explosive damage in a small area around the grenade. This class is best used in close quarters with multiple targets to toss grenades at.",
	SPECIALABILITY = "Throw a grenade with extra velocity  that will explode on contact. Consumes 100 energy.",
	SPECIALABILITY_COST = 40000, 
    HEALTH = 80,
    SPEED = 120,
    MODEL = "models/player/odessa.mdl",
    JUMPOWER = 200
}
 
Classes[17] = {
    NAME = "Raider",
    COST = 10000,
    WEAPON = "raider_gun",
    DESCRIPTION = "This class is agile and weilds a MAC-10. Raider is a good budget offensive class.",
    SPECIALABILITY = "Increase running speed by 200%  for the cost of 25 energy per second.",
    SPECIALABILITY_COST = 40000,
    HEALTH = 80,
    SPEED = 250,
    MODEL = "models/player/Group03/male_03.mdl",
    JUMPOWER = 200
}
 
Classes[18] = {
    NAME = "Guardian",
    COST = 12000,
    WEAPON = "guardian_gun",
    DESCRIPTION = "This class has a double barrel shotgun and is able to deal devistating damage in close range, but has a slow reload time. This class is a good budget defensive class, and is great for guarding a base.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 130,
    SPEED = 150,
    MODEL = "models/player/police.mdl",
    JUMPOWER = 200
}

Classes[19] = {
    NAME = "PumpkinMan",
    COST = 75000,
    WEAPON = "pumpkinman_gun",
    DESCRIPTION = "Throw pumpkins that seek for enemys ! If it hits an enemy,  you will throw an additional pumpkin for 50 energy.",
    SPECIALABILITY = "You laugh out loud at your enemys...     how humiliating ! MUAHAHAHA !",
    SPECIALABILITY_COST = 25000,
    HEALTH = 60,
    SPEED = 200,
    MODEL = "models/player/monk.mdl",
    JUMPOWER = 200
}

buyableProps = {}
buyableProps[1] = 
{
  MODEL = Model("models/props_farm/stairs_wood001a.mdl"),
  NAME = "Stairs",
  PRICE = 40, 
  COST = 35000, 
  HEALTH = 1000, 
  FILENAME = "stairs"
}
buyableProps[2] = 
{
  MODEL = Model("models/props_trainyard/awning001.mdl"),
  NAME = "Awning",
  PRICE = 100, 
  COST = 60000, 
  HEALTH = 1200, 
  FILENAME = "awning"
}

PropList = {}
PropList[1] = {
	MODEL = "models/props_junk/wood_crate001a.mdl",
	NAME = "Wooden crate",
	PRICE = 5,
	HEALTH = 500
}
PropList[2] = {
	MODEL = "models/props_junk/wood_crate002a.mdl",
	NAME = "Large wooden crate",
	PRICE = 10,
	HEALTH = 500
}
PropList[3] = {
	MODEL = "models/props_junk/wood_pallet001a.mdl",
	NAME = "Wooden pallet",
	PRICE = 15,
	HEALTH = 700
}
PropList[4] = {
	MODEL = "models/props_wasteland/wood_fence01a.mdl",
	NAME = "Wooden fence",
	PRICE = 40,
	HEALTH = 800
}
PropList[5] = {
	MODEL = "models/props_wasteland/wood_fence02a.mdl",
	NAME = "Slim wooden fence",
	PRICE = 30,
	HEALTH = 900
}
PropList[6] = {
	MODEL = "models/props_pipes/concrete_pipe001a.mdl",
	NAME = "Concrete Pipe",
	PRICE = 50,
	HEALTH = 1000
}
PropList[7] = {
	MODEL = "models/props_docks/dock01_pole01a_128.mdl",
	NAME = "Wooden pole",
	PRICE = 30,
	HEALTH = 800
}
/*
PropList[8] = {
	MODEL = "models/props_wasteland/prison_celldoor001a.mdl",
	NAME = "Slim metal bars",
	PRICE = 35,
	HEALTH = 700
}

PropList[9] = {
	MODEL = "models/props_wasteland/prison_slidingdoor001a.mdl",
	NAME = "Metal bars",
	PRICE = 40,
	HEALTH = 800
}

--Buyable props

PropList[100] = {
	MODEL = "models/props_trainyard/awning001.mdl",
	NAME = "Awning",
	PRICE = 100,
	HEALTH = 1200
}
PropList[101] = {
	MODEL = "models/props_farm/stairs_wood001a.mdl",
	NAME = "Stairs",
	PRICE = 45,
	HEALTH = 800
}

PropList[102] = {
	MODEL = "models/props_phx/construct/metal_plate2x2.mdl",
	NAME = "Steel plates",
	PRICE = 125,
	HEALTH = 1750
}

PropList[103] = {
	MODEL = "models/props_phx/construct/glass/glass_plate1x2.mdl",
	NAME = "Glass plate",
	PRICE = 40,
	HEALTH = 700
}