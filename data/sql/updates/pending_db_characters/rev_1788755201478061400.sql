-- M4.11.5.6: durable storage for the .ap leaderboard command's two real
-- breakdowns. archipelago_slot_totals is a realm-wide running counter, one
-- row per real AP slot id this realm's own client has observed an ItemSend
-- broadcast for (see ArchipelagoRealmState::RecordSlotItemSend) --
-- passively built from broadcasts this client already receives, never a new
-- AP-server query. archipelago_check_attribution is one row per real WoW
-- check this realm's own module has ever sent, recording which real WoW
-- character (by low GUID) triggered it (see
-- ArchipelagoRealmState::RecordLocationCheckAttribution) -- a strict subset
-- of archipelago_checks' own location_id set (every attributed check was
-- also durably recorded there), except the one real call site
-- (ArchipelagoWorldScript's own startup filler-location bootstrap) that has
-- no specific acting player and is deliberately never attributed.
CREATE TABLE IF NOT EXISTS `archipelago_slot_totals` (
  `slot_id` BIGINT NOT NULL,
  `total_count` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`slot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: per-slot running check-found totals, passively observed from ItemSend broadcasts (M4.11.5.6)';
DELETE FROM `archipelago_slot_totals` WHERE 1=1;

CREATE TABLE IF NOT EXISTS `archipelago_check_attribution` (
  `location_id` BIGINT UNSIGNED NOT NULL,
  `player_guid` INT UNSIGNED NOT NULL,
  `attributed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: which real WoW character triggered each of this realm own sent checks (M4.11.5.6)';
DELETE FROM `archipelago_check_attribution` WHERE 1=1;
