-- Task 16 (design spec Sec7.2, "New characters"): archipelago_delivery_history
-- is an ordered, append-only log of every WoW item entry ever delivered to
-- this realm, written unconditionally by ArchipelagoPlayerScript.cpp's
-- DeliverArchipelagoItems regardless of Archipelago::Delivery::Policy --
-- catch-up needs to know what the realm has received no matter how it was
-- routed. archipelago_catchup_state tracks how many of that ordered history
-- each character has been caught up on so far (a prefix count, not a set of
-- specific entries -- catch-up always grants strictly in delivery order).
CREATE TABLE IF NOT EXISTS `archipelago_delivery_history` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `wow_item_entry` INT UNSIGNED NOT NULL,
  `delivered_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: full realm delivery history, all policies (Task 16)';
DELETE FROM `archipelago_delivery_history` WHERE 1=1;

CREATE TABLE IF NOT EXISTS `archipelago_catchup_state` (
  `character_guid` INT UNSIGNED NOT NULL,
  `items_granted_count` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`character_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: per-character new-character catch-up progress (Task 16)';
DELETE FROM `archipelago_catchup_state` WHERE 1=1;
