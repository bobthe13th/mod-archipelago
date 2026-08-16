-- Tracks the last-processed Archipelago ReceivedItems index for this realm's
-- single AP slot, so a reconnect/restart never re-mails an already-delivered
-- item. One row, always id=1.
DROP TABLE IF EXISTS `archipelago_state`;
CREATE TABLE IF NOT EXISTS `archipelago_state` (
  `id` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `last_item_index` BIGINT NOT NULL DEFAULT -1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archipelago WoW module state';

DELETE FROM `archipelago_state` WHERE `id` = 1;
INSERT INTO `archipelago_state` (`id`, `last_item_index`) VALUES (1, -1);
