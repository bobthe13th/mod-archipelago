-- Durable outbound-check and goal-complete persistence across disconnects (M4, closes defect #1):
-- Stores every sent location check durably in MySQL so a disconnect or server restart
-- never loses un-transmitted checks. Also persists the realm-wide goal-complete flag.
CREATE TABLE IF NOT EXISTS `archipelago_checks` (
  `location_id` BIGINT UNSIGNED NOT NULL,
  `sent_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: durably recorded sent location checks';
DELETE FROM `archipelago_checks` WHERE 1=1;

ALTER TABLE `archipelago_realm_state`
  ADD COLUMN `goal_complete` TINYINT UNSIGNED NOT NULL DEFAULT 0;
UPDATE `archipelago_realm_state` SET `goal_complete` = 0 WHERE `id` = 1;
