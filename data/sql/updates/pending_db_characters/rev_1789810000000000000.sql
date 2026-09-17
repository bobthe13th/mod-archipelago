-- M6.2.7: Add archipelago_admin_queries table for recording when admins query
-- REQ_LOGIC and REQ_STUCK via the spoiler & logic viewer addon (see
-- ArchipelagoRealmState::RecordAdminQuery, Task 4's real committed C++ implementation).
-- One row per query attempt, regardless of whether it was granted, recording
-- the account, character, query type (REQ_LOGIC/REQ_STUCK), query target
-- (e.g. location_id), and whether the query was granted or denied.
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
DELETE FROM `archipelago_admin_queries` WHERE 1=1;
