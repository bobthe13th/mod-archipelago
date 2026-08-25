-- M4.7 Task 8: persists the ORIGINAL wow_item_entry for each synthesized
-- Vendor Inventories slot (Task 6/Task 1's npc_vendor rewrite), keyed by
-- location_id -- ArchipelagoInterceptionScript.cpp's vanilla_item/
-- gold_conversion repeat-purchase behaviors need this value back after the
-- npc_vendor.item column has been overwritten to point at the synthesized
-- AP-display item, and re-deriving it from anything else (e.g. the
-- synthesized item's player-chosen name) would be lossy/unreliable.
CREATE TABLE IF NOT EXISTS `archipelago_vendor_original_items` (
    `location_id` BIGINT NOT NULL,
    `original_item_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
