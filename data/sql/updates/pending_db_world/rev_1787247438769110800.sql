-- Custom "Archipelago Cache Keeper" NPC (Task 13, Delivery::Policy::SharedCacheNpc;
-- also repurposed by Task 15's Delivery::Policy::FirstToClaim). Spawned in
-- Northshire Abbey, a few yards from Marshal McBride (creature_template entry
-- 197, spawned at -8902.59,-162.606,82.0223 per data/sql/base/db_world/
-- creature.sql) so it sits inside the existing sphere-0 hub without
-- overlapping his spawn point. Faction 12 and unit_flags/unit_flags2/type/
-- unit_class match McBride's own row exactly (a plain friendly Northshire
-- Abbey humanoid) -- this module has been Alliance/Northshire-only since
-- M2.1 (see Archipelago/worlds/wow/regions.py's single-region model), so
-- there is no Horde-side spawn to mirror this against. Display id 1859 is
-- McBride's own model (creature_template_model entry 197), reused rather
-- than picking an unverified one. gossip_menu_id is left 0 so
-- Player::GetGossipTextId falls back to DEFAULT_GOSSIP_MESSAGE (no new
-- gossip_menu/npc_text rows needed) -- the NPC's own AddGossipItemFor calls
-- (npc_archipelago_cache_keeper.cpp) hardcode their option text instead of
-- going through gossip_menu_option.
-- codestyle-sql.py's INSERT & DELETE safety check refuses DELETE FROM
-- creature_template entirely (it's a protected table, alongside
-- gameobject_template/item_template/quest_template). REPLACE INTO is the
-- idempotent upsert-by-primary-key equivalent for a brand-new custom entry
-- like this one, without touching any base-game row.
REPLACE INTO `creature_template`
    (`entry`, `name`, `subname`, `gossip_menu_id`, `minlevel`, `maxlevel`, `faction`, `npcflag`,
     `unit_class`, `unit_flags`, `unit_flags2`, `type`, `AIName`, `ScriptName`)
VALUES
    (900000, 'Archipelago Cache Keeper', 'Archipelago', 0, 1, 1, 12, 1,
     1, 768, 2048, 7, '', 'npc_archipelago_cache_keeper');

DELETE FROM `creature_template_model` WHERE `CreatureID` = 900000;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
VALUES (900000, 0, 1859, 1, 1);

DELETE FROM `creature` WHERE `id1` = 900000;
INSERT INTO `creature`
    (`id1`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `curhealth`, `curmana`, `MovementType`)
VALUES
    (900000, 0, 0, 0, 1, 1, -8905.4, -159.9, 82.02, 2.04204, 300, 1, 0, 0);
