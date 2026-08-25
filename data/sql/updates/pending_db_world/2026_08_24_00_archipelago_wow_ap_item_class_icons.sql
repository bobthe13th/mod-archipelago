-- Four classification-flavored "Archipelago Item" placeholder templates
-- (M4.7). Icons sourced via ItemDisplayInfo.dbc lookup (confirmed real
-- icons from 3.3.5a client at var/extractors/dbc/ItemDisplayInfo.dbc).
-- No MPQ client patch, per this project's unmodified-client principle.
--
-- displayid resolution (confirmed via ItemDisplayInfo.dbc direct lookup):
--   850100 (Progression, Quality 4):  displayid 6394, icon INV_Misc_Gift_02
--     (Locked Gift, entry 5046, class=0; note: requested item_shop_giftbox01
--      does not exist in this 3.3.5a client DBC — 6394 is deliberate substitute)
--   850101 (Useful, Quality 3):       displayid 6329, icon INV_Misc_Gift_03
--     (Blue Ribboned Gift, entry 5044, class=0)
--   850102 (Trap, Quality 1):         displayid 6411, icon INV_Misc_Gift_04
--     (Skull Gift, entry 5045, class=0)
--   850103 (Filler, Quality 1):       displayid 21375, icon INV_Misc_Gift_05
--     (Gnome Engineer's Renewal Gift, entry 11423, class=15)

DELETE FROM `item_template` WHERE `entry` IN (850100, 850101, 850102, 850103);
INSERT INTO `item_template`
    (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`,
     `InventoryType`, `maxcount`, `stackable`, `ContainerSlots`, `bonding`, `description`, `VerifiedBuild`)
VALUES
    (850100, 15, 0, 'Archipelago Item (Progression)', 6394, 4, 0, 1, 0, 0, 0, 1, 1, 0, 1,
     'A progression item from the multiworld. Interacting with this consumes it and sends the check.', 12340),
    (850101, 15, 0, 'Archipelago Item (Useful)',      6329, 3, 0, 1, 0, 0, 0, 1, 1, 0, 1,
     'A useful item from the multiworld. Interacting with this consumes it and sends the check.', 12340),
    (850102, 15, 0, 'Archipelago Item (Trap)',        6411, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1,
     'A trap item from the multiworld. Interacting with this consumes it and sends the check.', 12340),
    (850103, 15, 0, 'Archipelago Item (Filler)',      21375, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1,
     'A filler item from the multiworld. Interacting with this consumes it and sends the check.', 12340);
