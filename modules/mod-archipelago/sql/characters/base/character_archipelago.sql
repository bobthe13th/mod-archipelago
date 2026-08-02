-- Create base character tables for the Archipelago mod

CREATE TABLE IF NOT EXISTS `character_archipelago_checks` (
  `guid` INT UNSIGNED NOT NULL COMMENT 'Character Guid',
  `location_id` BIGINT NOT NULL COMMENT 'Archipelago location ID (or check ID)',
  `completed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When the check was completed',
  PRIMARY KEY (`guid`, `location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores completed Archipelago checks for each character';

CREATE TABLE IF NOT EXISTS `character_archipelago_received` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique sequence ID',
  `guid` INT UNSIGNED NOT NULL COMMENT 'Character Guid',
  `item_id` BIGINT NOT NULL COMMENT 'Archipelago item ID',
  `item_name` VARCHAR(255) NOT NULL COMMENT 'Descriptive name of the item',
  `index_received` INT NOT NULL COMMENT 'Index in the AP received queue',
  `processed` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0: pending delivery, 1: delivered in game',
  `processed_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'When the item was processed',
  PRIMARY KEY (`id`),
  KEY `idx_guid_processed` (`guid`, `processed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores items received from Archipelago for each character';

CREATE TABLE IF NOT EXISTS `character_archipelago_state` (
  `guid` INT UNSIGNED NOT NULL COMMENT 'Character Guid',
  `slot_name` VARCHAR(100) NOT NULL DEFAULT '' COMMENT 'Archipelago Slot Name',
  `level_cap` INT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'Active progressive level cap',
  `xp_multiplier` FLOAT NOT NULL DEFAULT 1.0 COMMENT 'Active progressive experience multiplier',
  `speed_multiplier` FLOAT NOT NULL DEFAULT 1.0 COMMENT 'Active movement speed multiplier',
  `unlocked_features` TEXT COMMENT 'JSON serialized list of account/character-wide unlocks',
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores progressive meta-state for each character';
