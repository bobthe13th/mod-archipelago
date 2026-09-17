-- M6.2.7: Add archipelago_admin_queries table for recording when admins query
-- REQ_LOGIC and REQ_STUCK via the spoiler & logic viewer addon (see
-- ArchipelagoRealmState::RecordAdminQuery, Task 4's real committed C++ implementation).
-- One row per query attempt that was not cooldown-suppressed (a real
-- per-player 5000ms cooldown, added after this table's own introduction,
-- gates this write -- see ArchipelagoRealmState::RecordAdminQuery's own
-- call sites in APAdminQueriesBroadcast.cpp), regardless of whether the
-- (non-suppressed) query was granted, recording the account, character,
-- query type (REQ_LOGIC/REQ_STUCK), query target (e.g. location_id), and
-- whether the query was granted or denied.
-- Append-only audit trail (no DELETE FROM WHERE 1=1 boilerplate here,
-- unlike this file's earlier single-row/set-membership tables) --
-- matches archipelago_hints/archipelago_items_received's own precedent
-- (the two most recent durable accumulating-history tables in this same
-- directory), since wiping accumulated audit rows on a manual re-apply
-- would defeat the whole point of an accountability log.
CREATE TABLE IF NOT EXISTS `archipelago_admin_queries` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` INT UNSIGNED NOT NULL,
  `character_name` VARCHAR(50) NOT NULL,
  `query_type` VARCHAR(16) NOT NULL,
  `query_target` VARCHAR(32) NOT NULL,
  `was_granted` TINYINT UNSIGNED NOT NULL,
  `queried_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_account_id` (`account_id`),
  KEY `idx_queried_at` (`queried_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: admin query audit trail (REQ_LOGIC, REQ_STUCK) from spoiler & logic viewer addon (M6.2.7)';
