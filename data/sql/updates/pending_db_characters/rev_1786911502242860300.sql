-- Realm-wide Archipelago core-loop progression state (M2.1): the current
-- level cap and which instances/portals have been unlocked via received
-- items. One realm = one AP slot, so this is server-wide, not per-character.
CREATE TABLE IF NOT EXISTS `archipelago_realm_state` (
  `id` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `level_cap` INT UNSIGNED NOT NULL DEFAULT 10,
  `dark_portal_unlocked` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `northrend_passage_unlocked` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module realm-wide core-loop state';
DELETE FROM `archipelago_realm_state` WHERE `id` = 1;
INSERT INTO `archipelago_realm_state` (`id`, `level_cap`, `dark_portal_unlocked`, `northrend_passage_unlocked`) VALUES (1, 10, 0, 0);

CREATE TABLE IF NOT EXISTS `archipelago_unlocked_instances` (
  `instance_key` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`instance_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: realm-wide unlocked instance keys';
DELETE FROM `archipelago_unlocked_instances` WHERE 1=1;
