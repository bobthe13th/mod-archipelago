-- M5.0 Sec8: world_seed marker + generic pristine-row snapshot for
-- Pipeline B mutation application (APWorldState.cpp). Both live in `world`
-- DB, not `characters` -- a `world` rebuild must reset marker, snapshot,
-- and mutated data together, by construction (Sec8's own split-brain
-- rationale), unlike every other Archipelago realm-state table (which
-- lives in `characters`).
DELETE FROM `archipelago_world_mutation_state` WHERE `id` = 1;
CREATE TABLE IF NOT EXISTS `archipelago_world_mutation_state` (
    `id` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `world_seed` VARCHAR(64) NOT NULL,
    `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `archipelago_world_mutation_snapshot`;
CREATE TABLE `archipelago_world_mutation_snapshot` (
    `table_name` VARCHAR(64) NOT NULL,
    `row_id` BIGINT NOT NULL,
    `original_data_json` TEXT NOT NULL,
    PRIMARY KEY (`table_name`, `row_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
