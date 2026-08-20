-- Task 23 (design spec Sec5.4, InstanceClearMode: all_bosses): records every
-- boss ever recorded dead in a given instance_key, realm-wide (matching
-- archipelago_unlocked_instances' existing realm-wide-not-per-character
-- precedent, since one WoW realm is one AP slot) -- across however many raid
-- nights/players/attempts it takes to down the full roster. Only written to
-- when Archipelago.InstanceClearMode is all_bosses; ignored entirely by
-- final_boss_only mode, which behaves exactly as it did before this table
-- existed. See ArchipelagoInstanceScript.cpp's ArchipelagoInstanceKillScript
-- for the read/write logic.
CREATE TABLE IF NOT EXISTS `archipelago_boss_kills` (
  `instance_key` VARCHAR(64) NOT NULL,
  `boss_entry` INT UNSIGNED NOT NULL,
  `killed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`instance_key`, `boss_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: realm-wide boss-kill tracking for all_bosses InstanceClearMode (Task 23)';
DELETE FROM `archipelago_boss_kills` WHERE 1=1;
