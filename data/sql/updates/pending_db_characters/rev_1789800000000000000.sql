-- M6.2.5: extend archipelago_hints with the two new AP_HINT fields (target
-- player and priority classification) the hint tracker panel needs to
-- group/filter by. Existing rows (recorded before this migration) get
-- 0/HINT_UNSPECIFIED defaults -- their real values were never captured, so
-- they display as target-player-unknown/unspecified priority until that
-- location is hinted again.
ALTER TABLE `archipelago_hints`
  ADD COLUMN `target_player_id` BIGINT NOT NULL DEFAULT 0 AFTER `location_id`,
  ADD COLUMN `priority` INT NOT NULL DEFAULT 0 AFTER `target_player_id`;
