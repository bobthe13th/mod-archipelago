-- Four classification-flavored "Archipelago Item" placeholder templates
-- (M4.7). Icons borrowed from existing real item_template rows already
-- using giftbox/wrapped-gift textures. No MPQ client patch, per this
-- project's unmodified-client principle.
--
-- displayid resolution (from data/sql/base/db_world/item_template.sql):
--   850100 (Progression, Quality 4):  displayid 6394 (entry 5046: Locked Gift)
--   850101 (Useful, Quality 3):       displayid 6404 (entry 5043: Red Ribboned Gift)
--   850102 (Trap, Quality 1):         displayid 6329 (entry 5044: Blue Ribboned Gift)
--   850103 (Filler, Quality 1):       displayid 6411 (entry 5045: Skull Gift)

DELETE FROM `item_template` WHERE `entry` IN (850100, 850101, 850102, 850103);
INSERT INTO `item_template`
    (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`,
     `InventoryType`, `maxcount`, `stackable`, `ContainerSlots`, `bonding`, `description`, `VerifiedBuild`)
VALUES
    (850100, 15, 0, 'Archipelago Item (Progression)', 6394, 4, 0, 1, 0, 0, 0, 1, 1, 0, 1,
     'A progression item from the multiworld. Interacting with this consumes it and sends the check.', 12340),
    (850101, 15, 0, 'Archipelago Item (Useful)',      6404, 3, 0, 1, 0, 0, 0, 1, 1, 0, 1,
     'A useful item from the multiworld. Interacting with this consumes it and sends the check.', 12340),
    (850102, 15, 0, 'Archipelago Item (Trap)',        6329, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1,
     'A trap item from the multiworld. Interacting with this consumes it and sends the check.', 12340),
    (850103, 15, 0, 'Archipelago Item (Filler)',      6411, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1,
     'A filler item from the multiworld. Interacting with this consumes it and sends the check.', 12340);
