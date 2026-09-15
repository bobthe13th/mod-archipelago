-- M4.10.1 Task 5: persists the ORIGINAL wow_item_entry for each
-- synthesized loot-slot location (gameobject_loot_template today;
-- creature_loot_template's skinning-loot slots will reuse this same
-- table starting M4.10.2, per this plan's own architecture note --
-- named generically, not "container"-specific), keyed by location_id.
-- Mirrors archipelago_vendor_original_items' exact shape/rationale (M4.7
-- Task 8) -- ArchipelagoLootSlotScript.cpp's vanilla_item/gold_conversion
-- repeat-loot behaviors need this value back after the loot template's
-- Item column has been overwritten to point at the synthesized item.
CREATE TABLE IF NOT EXISTS `archipelago_lootslot_original_items` (
    `location_id` BIGINT NOT NULL,
    `original_item_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
