-- Task 15 (Delivery::Policy::FirstToClaim): a queue of individual delivered
-- items waiting to be claimed, one row per delivery (NOT deduped by item
-- type like archipelago_cache_items -- two deliveries of the same WoW item
-- entry before either is claimed are two separate races, each with its own
-- announcement). `id` (not `wow_item_entry`) is the primary key so repeat
-- entries are allowed. Whoever interacts with the Archipelago Cache Keeper
-- NPC first and picks the first-to-claim option drains every row currently
-- queued to themselves; ArchipelagoCacheKeeperScript.cpp deletes each row
-- as it's granted, which is what makes this "first come, first served"
-- rather than another shared cache.
CREATE TABLE IF NOT EXISTS `archipelago_first_to_claim_pending` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `wow_item_entry` INT UNSIGNED NOT NULL,
  `queued_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: first-to-claim delivery queue (Task 15)';
DELETE FROM `archipelago_first_to_claim_pending` WHERE 1=1;
