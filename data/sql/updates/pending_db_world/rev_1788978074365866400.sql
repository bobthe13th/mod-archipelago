-- Portable Mailbox (M4.14.1 "Useful Items", Task 5): a despawn-timed clone
-- of the real static mailbox gameobject_template row (entry 32349,
-- confirmed live: type=19, displayId=1947, all 24 Data columns 0), summoned
-- at the player's position on use of a new consumable item_template row.
-- First custom gameobject_template row this project adds (item_template's
-- own custom-row convention is 850100-850103; this uses the parallel
-- 850200 block for gameobject_template so the two id ranges never collide).
--
-- Use-effect mechanism (honors the "no MPQ client patch" constraint): the
-- consumable item's spellid_1 is bound to spell 5735, a real, existing,
-- client-shipped spell (Spell.dbc name "REUSE") confirmed live at
-- implementation time to be:
--   - a single-effect spell, Effect_1 = SPELL_EFFECT_DUMMY (3), no other
--     real effect (confirmed via this project's own tools/dbc_reader.py
--     against var/extractors/dbc/Spell.dbc, using the authoritative
--     SpellEntry field layout from
--     src/server/shared/DataStores/DBCStructure.h -- Effect[3] lives at
--     DBC fields 71-73, not 69-71 as an earlier, unrelated tool in this
--     module's own tools/parse_spell_dbc.py assumed; that offset
--     mismatch is why this project's own DBC field-offset knowledge is
--     documented as unreliable and why
--     ArchipelagoPortableMailboxScript.cpp registers its handler against
--     all three EFFECT_0/1/2 slots rather than trusting one derived index)
--   - zero item_template.spellid_1..5 references anywhere in this
--     checkout before this migration (re-confirmed live)
--   - zero references anywhere under src/server/scripts/ (re-confirmed
--     live, exact-word search)
--   - zero references in spell_script_names, npc_trainer, creature_template,
--     playercreateinfo_cast_spell, playercreateinfo_spell_custom,
--     npc_spellclick_spells, spell_area (re-confirmed live)
-- The real HandleScriptEffect (ArchipelagoPortableMailboxScript.cpp)
-- summons gameobject_template entry 850200 for 5 minutes.
--
-- Item icon: displayid 1102, a real, existing generic letter/note icon
-- already used by "Letter to Ello" (entry 1637), "Translated Letter"
-- (entry 1656) and "Muddy Note" (entry 2720) -- confirmed live.
--
-- Both target ids (850200, 850104) re-confirmed free immediately before
-- writing this migration.
DELETE FROM `gameobject_template` WHERE `entry` = 850200;
INSERT INTO `gameobject_template`
    (`entry`, `type`, `displayId`, `name`, `IconName`, `castBarCaption`, `unk1`, `size`,
     `Data0`, `Data1`, `Data2`, `Data3`, `Data4`, `Data5`, `Data6`, `Data7`, `Data8`, `Data9`,
     `Data10`, `Data11`, `Data12`, `Data13`, `Data14`, `Data15`, `Data16`, `Data17`, `Data18`,
     `Data19`, `Data20`, `Data21`, `Data22`, `Data23`, `AIName`, `ScriptName`, `VerifiedBuild`)
VALUES
    (850200, 19, 1947, 'Portable Mailbox', '', '', '', 1,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, '', '', 12340);

DELETE FROM `item_template` WHERE `entry` = 850104;
INSERT INTO `item_template`
    (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `FlagsExtra`, `BuyCount`,
     `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`,
     `RequiredLevel`, `maxcount`, `stackable`, `ContainerSlots`, `spellid_1`, `spelltrigger_1`,
     `spellcharges_1`, `spellcooldown_1`, `spellcategory_1`, `spellcategorycooldown_1`, `bonding`,
     `description`, `Material`, `VerifiedBuild`)
VALUES
    (850104, 15, 0, 'Portable Mailbox', 1102, 1, 0, 0, 1,
     0, 0, 0, -1, -1, 1,
     0, 1, 1, 0, 5735, 0,
     0, -1, 0, -1, 1,
     'Summons a portable mailbox at your location for 5 minutes. Delivered by the Archipelago multiworld.', -1, 12340);
