-- M4.11.1 (Task 13): BarrensBeater realm setup -- overrides every real
-- race/class's `playercreateinfo` spawn row to the Crossroads inn in
-- Barrens, matching the design spec's "one realm = one AP slot, so this is
-- baked into realm state, not a live per-connection toggle" reasoning.
-- Applied ONLY on a realm dedicated to zone_leveler/BarrensBeater, per the
-- same manual-operator-step convention M4.9's StartPlayerLevel/
-- StartHeroicPlayerLevel worldserver.conf flip already uses (see
-- docs/testing/m4.11.1-manual-verification-checklist.md for the operator
-- checklist entry).
--
-- Real coordinates, from this checkout's own live acore_world query:
--   SELECT c.id, ct.name, ct.subname, c.map, c.position_x, c.position_y,
--          c.position_z, c.orientation, c.zoneId
--   FROM creature c JOIN creature_template ct ON ct.entry = c.id
--   WHERE ct.subname = "Innkeeper" AND c.map = 1
--     AND c.position_x BETWEEN -600 AND -300
--     AND c.position_y BETWEEN -2700 AND -2500;
-- -> Innkeeper Boorand Plainswind (creature entry 3934, the real, canonical
-- Crossroads inn NPC): map=1, position_x=-407.123, position_y=-2645.22,
-- position_z=96.3063, orientation=3.4383. Confirmed inside Barrens (not
-- Mulgore) via an empirical bounding box built from 91 real Barrens
-- quest-giver positions (x in [-4217.54, 2045.53], y in [-4753.81, 38.971],
-- map=1) -- `WorldMapArea.dbc`'s own crude rectangle mechanism misresolves
-- this exact point to Mulgore (a known-flawed mechanism already flagged in
-- an earlier task of this plan), so it was not used for this check.
--
-- `zone` = 17 confirmed directly against this checkout's real
-- `AreaTable.dbc` (var/extractors/dbc/AreaTable.dbc, read via
-- modules/archipelago_wow/tools/dbc_reader.py's generic WDBC reader):
-- record id 17's name field (field index 11 of the file's 36-field record
-- layout, located by cross-checking two independently known-correct area
-- ids -- 14, whose field 11 decodes to "Durotar" and which also matches
-- this checkout's own existing `playercreateinfo` Orc/Warrior row already
-- using `zone` = 14; and 1637, whose field 11 decodes to "Orgrimmar")
-- decodes to "The Barrens". (The same pass caught and fixed a real,
-- unrelated bug: Archipelago/worlds/wow/zone_level_data.py's
-- ZONE_ID_MOLTEN_CORE placeholder of 409 does NOT decode to "Molten Core"
-- in this checkout's AreaTable.dbc -- area id 409 is Molten Core's real
-- `ParentAreaID` (Blackrock Mountain), not Molten Core's own id. The real
-- Molten Core area id, found by searching the DBC's string block for the
-- exact string "Molten Core", is 2717 -- corrected in that file separately
-- from this SQL migration.)
--
-- Target position (-410.0, -2643.0) is a small, deliberate offset a few
-- yards northwest of the innkeeper's own exact spawn point, matching this
-- project's own "don't overlap an existing NPC exactly" convention (see
-- 2026_08_29_01_archipelago_wow_holiday_herald.sql's per-capital landmark
-- offsets). `position_z`/`orientation` are kept at the innkeeper's own
-- real, already-verified-safe values (96.3063 / 3.4383) since the offset is
-- small enough that the inn's own floor height/facing still applies.
--
-- Full race/class enumeration confirmed live, not hand-enumerated from
-- `ChrRaces.dbc`/`ChrClasses.dbc` assumptions:
--   SELECT race, class, COUNT(*) FROM playercreateinfo
--   GROUP BY race, class ORDER BY race, class;
-- returned 62 real rows (`SELECT COUNT(*) FROM playercreateinfo` also = 62)
-- across all 10 playable races (every id 1-11 except the unused id 9) and
-- all 10 playable classes (ids 1-9, 11) -- NOT the full 11x11 = 121 cross
-- product. E.g. Blood Elves (race 10) have no Warrior/Shaman/Druid row and
-- Orcs (race 2) have no Paladin/Priest/Mage/Druid row, matching real WotLK
-- race/class availability. See this task's report for the full pair list.
--
-- Pure UPDATE (no INSERT), so no DELETE-before-INSERT pairing applies --
-- same shape as this directory's existing UPDATE precedent,
-- rev_1786926932993832400.sql (Northrend transport gating).
UPDATE `playercreateinfo` SET `map` = 1, `zone` = 17, `position_x` = -410.0,
    `position_y` = -2643.0, `position_z` = 96.3063, `orientation` = 3.4383
    WHERE (`race`, `class`) IN (
        (1, 1), (1, 2), (1, 4), (1, 5), (1, 6), (1, 8), (1, 9),
        (2, 1), (2, 3), (2, 4), (2, 6), (2, 7), (2, 9),
        (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6),
        (4, 1), (4, 3), (4, 4), (4, 5), (4, 6), (4, 11),
        (5, 1), (5, 4), (5, 5), (5, 6), (5, 8), (5, 9),
        (6, 1), (6, 3), (6, 6), (6, 7), (6, 11),
        (7, 1), (7, 4), (7, 6), (7, 8), (7, 9),
        (8, 1), (8, 3), (8, 4), (8, 5), (8, 6), (8, 7), (8, 8),
        (10, 2), (10, 3), (10, 4), (10, 5), (10, 6), (10, 8), (10, 9),
        (11, 1), (11, 2), (11, 3), (11, 5), (11, 6), (11, 7), (11, 8)
    );
