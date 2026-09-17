-- Durable received-item history for the AP unlocks drawer (M6.2.4): every
-- distinct (item_id, from_player_id) pair this realm's own AP slot has ever
-- received, with an accumulated count. archipelago_delivery_history (Task
-- 16) only stores the WoW item entry actually mailed and cannot answer this
-- -- many AP items (realm-state-only unlocks, flag-only Gates/Holidaysanity
-- items) never produce a wow_item_entry at all. Grouped by
-- (item_id, from_player_id), not item_id alone: two different senders
-- sending the same real AP item id are logically distinct rows (see this
-- milestone's plan Global Constraints).
CREATE TABLE IF NOT EXISTS `archipelago_items_received` (
  `item_id` BIGINT NOT NULL,
  `from_player_id` BIGINT NOT NULL,
  `count` INT UNSIGNED NOT NULL DEFAULT 0,
  `flags` INT NOT NULL DEFAULT 0,
  `first_received_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`, `from_player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: durable received-item history for the AP unlocks drawer (M6.2.4)';
