-- M4.10.7: the Archipelago Holiday Herald -- one gossip NPC per capital
-- city, real coordinates derived from this checkout's own live DB (see
-- this task's report for the query used and its output): each of the 10
-- capitals' canonical `game_tele` anchor point was cross-checked against a
-- real, nearby landmark NPC in `creature`/`creature_template` (a faction
-- leader or bank teller stationed in that capital), and that landmark's own
-- real spawn row was then offset a few yards on X so the new NPC doesn't
-- overlap it exactly. creature_template entry 900001, following
-- npc_archipelago_cache_keeper's real precedent (entry 900000, see
-- rev_1787247438769110800.sql) -- same REPLACE INTO shape (codestyle-sql.py's
-- INSERT & DELETE safety check refuses DELETE FROM creature_template, a
-- protected table, alongside gameobject_template/item_template/
-- quest_template), same minimal column set, same separate
-- creature_template_model row (without one the NPC has no display model).
-- faction 35, unit_flags/unit_flags2 768/2048, unit_class 1, type 7 match
-- Cache Keeper's own real, working values for "a plain friendly humanoid"
-- gossip-only NPC -- this NPC has the same basic shape, just spawned in 10
-- capitals instead of 1 Northshire Abbey location. Display id 1859 is
-- Cache Keeper's own already-verified-real display id (Marshal McBride's
-- model), reused here too rather than fabricating an unverified one.
--
-- NOTE: this checkout's live `creature` table schema has a single `id`
-- entry column (verified via DESCRIBE creature), not the newer upstream
-- `id1`/`id2`/`id3` multi-entry columns -- the creature INSERT below uses
-- `id`, matching both this schema and npc_archipelago_cache_keeper's own
-- real precedent.
REPLACE INTO `creature_template`
    (`entry`, `name`, `subname`, `gossip_menu_id`, `minlevel`, `maxlevel`, `faction`, `npcflag`,
     `unit_class`, `unit_flags`, `unit_flags2`, `type`, `AIName`, `ScriptName`)
VALUES
    (900001, 'Archipelago Holiday Herald', 'Toggle the Realm''s Holidays', 0, 80, 80, 35, 1,
     1, 768, 2048, 7, '', 'npc_archipelago_holiday_herald');

DELETE FROM `creature_template_model` WHERE `CreatureID` = 900001;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
VALUES (900001, 0, 1859, 1, 1);

-- 10 rows below: real coordinates transcribed from this task's own live DB
-- query output (landmark NPC per capital, offset +3.0 on X to avoid an
-- exact overlap with the landmark's own spawn point):
--   Stormwind      (map 0):   Olivia Burnside   (entry 2455,  Stormwind Bank teller)
--   Ironforge      (map 0):   Barnum Stonemantle(entry 2460,  Ironforge Bank teller)
--   Undercity      (map 0):   Randolph Montague (entry 2458,  Undercity Bank teller)
--   Darnassus      (map 1):   Idriana           (entry 4155,  Darnassus Bank teller)
--   Orgrimmar      (map 1):   Karus             (entry 3309,  Orgrimmar Bank teller)
--   Thunder Bluff  (map 1):   Torn              (entry 2996,  Thunder Bluff Bank teller)
--   Exodar         (map 530): Jaela             (entry 18350, Exodar Bank teller)
--   Silvermoon City(map 530): Ceera             (entry 17631, Silvermoon Bank teller)
--   Shattrath City (map 530): Mendorn           (entry 19034, Lower City Bank teller)
--   Dalaran        (map 571): Teller Rames      (entry 28675, Dalaran Bank teller)
-- Each landmark's real map/position/orientation was cross-verified against
-- this checkout's own `game_tele` table (canonical per-capital anchor
-- points) before use.
--
-- No explicit `guid` is assigned (unlike npc_archipelago_cache_keeper's
-- single-row precedent, which also omits it) -- `guid` is AUTO_INCREMENT,
-- so the 10 rows below get safe, collision-free real values allocated by
-- the server itself. This task's own live query confirmed the free range
-- (`SELECT MAX(guid) FROM creature` returned 5300679 at verification time,
-- well below wherever AUTO_INCREMENT will actually land by migration time),
-- and this sidesteps a `SET @variable := (SELECT MAX(...) ...)` construct
-- that would be a first-of-its-kind pattern in this repo's own
-- pending_db_world migrations (none use `SET @`) and risks tripping
-- codestyle-sql.py's backtick_check, whose per-line clause-content regex
-- would swallow an embedded `MAX(...)` call as unbacktick-able content.
DELETE FROM `creature` WHERE `id` = 900001;
INSERT INTO `creature`
    (`id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`,
     `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `curhealth`, `curmana`, `MovementType`)
VALUES
    (900001, 0,   0, 0, 1, 1, -8928.23,   605.801,   99.606,    0.488692, 300, 1, 0, 0), -- Stormwind
    (900001, 0,   0, 0, 1, 1, -4874.43,  -990.034,  504.024,    2.30383,  300, 1, 0, 0), -- Ironforge
    (900001, 0,   0, 0, 1, 1,  1602.96,   240.65,   -52.0596,   0.087266, 300, 1, 0, 0), -- Undercity
    (900001, 1,   0, 0, 1, 1,  9941.84,  2521.53,  1317.66,     4.38078,  300, 1, 0, 0), -- Darnassus
    (900001, 1,   0, 0, 1, 1,  1630.32, -4376.07,    12.0576,  3.4383,   300, 1, 0, 0), -- Orgrimmar
    (900001, 1,   0, 0, 1, 1, -1254.63,    19.5577, 128.27,    1.72788,  300, 1, 0, 0), -- Thunder Bluff
    (900001, 530, 0, 0, 1, 1, -3915.95,-11544.7,   -150.039,   4.58778,  300, 1, 0, 0), -- Exodar
    (900001, 530, 0, 0, 1, 1,  9528.23, -7221.82,    16.2139,  1.5708,   300, 1, 0, 0), -- Silvermoon City
    (900001, 530, 0, 0, 1, 1, -1717.86,  5489.87,   -9.71611, 0.366519,  300, 1, 0, 0), -- Shattrath City
    (900001, 571, 0, 0, 1, 1,  5990.35,   614.434,  651.223,  2.79253,   300, 1, 0, 0); -- Dalaran
