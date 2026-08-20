-- Task 13 (Delivery::Policy::SharedCacheNpc): a realm-wide catalog of every
-- distinct WoW item entry ever granted by an AP delivery under this policy
-- (archipelago_cache_items, a set of item TYPES, not a count -- see
-- APDelivery.cpp's INSERT IGNORE comment), plus which character has already
-- claimed which entry (archipelago_cache_claims). npc_archipelago_cache_keeper
-- (ArchipelagoCacheKeeperScript.cpp) is the only reader/writer of the claims
-- table; APDelivery.cpp is the only writer of the items table.
CREATE TABLE IF NOT EXISTS `archipelago_cache_items` (
  `wow_item_entry` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`wow_item_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: realm-wide shared-cache item catalog (Task 13)';
DELETE FROM `archipelago_cache_items` WHERE 1=1;

CREATE TABLE IF NOT EXISTS `archipelago_cache_claims` (
  `character_guid` INT UNSIGNED NOT NULL,
  `wow_item_entry` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`character_guid`, `wow_item_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: per-character shared-cache claims (Task 13)';
DELETE FROM `archipelago_cache_claims` WHERE 1=1;

-- Design spec Sec7.1's "Optional variant: single realm-wide pile, first come
-- first served (opt-in, clearly labeled)" -- a second, distinct gossip
-- option on the same NPC (not a silent default). Once an entry is claimed
-- through that option it is gone for the whole realm, including anyone's
-- future per-player copy via archipelago_cache_claims above, so this table
-- is checked by (and excluded from) both gossip options.
CREATE TABLE IF NOT EXISTS `archipelago_cache_realm_claimed` (
  `wow_item_entry` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`wow_item_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: shared-cache entries claimed from the realm-wide first-come-first-served pile (Task 13)';
DELETE FROM `archipelago_cache_realm_claimed` WHERE 1=1;
