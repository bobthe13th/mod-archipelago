-- Testing-report ask: "Would it be possible to put an auctioneer in the
-- Barrens." Crossroads is the Barrens' main Horde hub (flight point, inn,
-- trainers) but has no Auction House NPC in base data, forcing early Horde
-- players questing there to travel to Orgrimmar/Thunder Bluff/Undercity just
-- to list/buy. This reuses the existing base creature_template entry 8673
-- 'Auctioneer Thathung' (data/sql/base/db_world/creature_template.sql:6543,
-- faction 29 == Thunder Bluff, npcflag 2097154 == UNIT_NPC_FLAG_AUCTIONEER |
-- UNIT_NPC_FLAG_QUESTGIVER) rather than defining a new custom NPC -- no new
-- creature_template/creature_template_model rows are needed, and the
-- Horde-aligned faction is already correct for a Barrens spawn.
--
-- Position: a few yards from Kilram, Crossroads' real blacksmithing trainer
-- (creature_template entry 11192, spawned per data/sql/base/db_world/
-- creature.sql:42063 at map 1, 6778.65,-4668.73,723.929,4.01426) -- offset
-- +4.0 on X and +3.0 on Y (matching npc_archipelago_cache_keeper's own
-- few-yards-off-a-verified-landmark precedent, rev_1787247438769110800.sql),
-- same Z (flat ground at Crossroads' town square), distinct orientation so
-- the two NPCs don't stand back-to-back facing the same way.
--
-- No explicit `guid` is assigned -- AUTO_INCREMENT allocates a safe,
-- collision-free value, same reasoning as the Holiday Herald migration
-- (2026_08_29_01_archipelago_wow_holiday_herald.sql). This checkout's live
-- `creature` table uses the single `id` entry column (not upstream's newer
-- id1/id2/id3), matching every other pending_db_world creature INSERT in
-- this module. Unlike Cache Keeper/Holiday Herald's own `DELETE FROM
-- creature WHERE id = <their own custom entry>` (safe there because they
-- exclusively own that entry's every spawn), entry 8673 is a shared
-- base-game template with a real spawn elsewhere (Thunder Bluff) that must
-- not be touched -- the idempotency DELETE below is instead scoped to this
-- exact new spawn's own map/position, so it only ever matches (and
-- re-deletes-then-reinserts) THIS row on a repeat apply, never the real
-- Thunder Bluff one.
DELETE FROM `creature` WHERE `id` = 8673 AND `map` = 1 AND `position_x` = 6782.65 AND `position_y` = -4665.73;
INSERT INTO `creature`
    (`id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`,
     `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `curhealth`, `curmana`, `MovementType`)
VALUES
    (8673, 1, 0, 0, 1, 1, 6782.65, -4665.73, 723.929, 1.55334, 300, 1, 0, 0);
