-- Generic realm-wide Archipelago unlock-flag store (M4): every new gate item
-- (Progressive Riding tiers, armor/weapon proficiency, bank/AH/mail/hearth/
-- gathering access, continent/city/zone gates) stores its state as one row
-- here instead of a new bespoke column per feature. tier=0 means "not
-- unlocked"; boolean gates use tier=1 for "unlocked". flag_key values are
-- assigned per gate item in content/gates.yaml (see Task 4) and mirrored as
-- C++ string constants generated from that table -- never hand-typed at the
-- call site.
CREATE TABLE IF NOT EXISTS `archipelago_unlocks` (
  `flag_key` VARCHAR(64) NOT NULL,
  `tier` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`flag_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: realm-wide generic unlock flags (M4 gate family)';
DELETE FROM `archipelago_unlocks` WHERE 1=1;
