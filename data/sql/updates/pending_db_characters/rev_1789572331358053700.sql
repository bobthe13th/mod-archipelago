-- Durable hint persistence (M6.2.1): stores every location this realm's own
-- AP slot has been told the contents of via a real Hint PrintJSON event, so
-- the checklist/tooltip spoiler-gating state survives a server restart the
-- same way archipelago_checks already does for sent location checks.
CREATE TABLE IF NOT EXISTS `archipelago_hints` (
  `location_id` BIGINT UNSIGNED NOT NULL,
  `hinted_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: durably recorded location hints for this realm''s own AP slot';
