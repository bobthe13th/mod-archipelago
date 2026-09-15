-- M4.11.5.0.5: durable queue for a Trainer Spells direct spell-grant reward
-- (Archipelago::SpellGrant::GrantOrQueue) when the intended recipient is
-- offline at delivery time -- there is no mail equivalent for a
-- non-physical spell grant (unlike GiveOrMailItem's item case), so this
-- table is the deliberate substitute, drained by ApplyPendingGrants on the
-- recipient's next login (ArchipelagoPlayerScript::OnPlayerLogin).
CREATE TABLE IF NOT EXISTS `archipelago_pending_spell_grants` (
  `guid` INT UNSIGNED NOT NULL,
  `spell_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`guid`, `spell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module: pending direct spell grants for an offline recipient (M4.11.5.0.5)';
DELETE FROM `archipelago_pending_spell_grants` WHERE 1=1;
