-- M4.11.7 (Raidlogger): overrides every real non-Death-Knight race/class's
-- playercreateinfo spawn row to the appropriate faction capital at level
-- 60 -- Raidlogger's own chained progression (classic_to_tbc,
-- classic_to_wotlk) always starts at 60 regardless of which value is
-- chosen (see docs/superpowers/plans/2026-09-08-archipelago-wow-m4.11.7-raidlogger.md
-- for why there is exactly one starting point, not one per tier). Applied
-- ONLY on a realm dedicated to Raidlogger, per the same manual-operator-step
-- convention BarrensBeater's own realm-setup migration already established
-- (2026_09_01_00_zone_leveler_barrens_playercreateinfo.sql) --
-- worldserver.conf's StartPlayerLevel=60 is a separate manual step (conf is
-- gitignored, not committed here). Death Knight (class=6) rows are
-- deliberately excluded -- their own Ebon Hold intro has a scripted level
-- progression that conflicts with "start already at tier level, zero
-- grinding"; whether DK characters make sense in Raidlogger mode at all is
-- an open question for the project owner, not resolved by this migration.
--
-- Real coordinates, from this checkout's own live acore_world game_tele query:
--   Orgrimmar: map=1, (1629.85, -4373.64, 31.5573), o=3.69762
--   Stormwind: map=0, (-8833.38, 628.628, 94.0066), o=1.06535
--
-- Real (race, class) roster confirmed live at implementation time:
--   SELECT race, class FROM playercreateinfo WHERE class != 6 ORDER BY race, class;
-- -> 52 rows (62 total, 10 class=6), matching this checkout's base
-- playercreateinfo.sql race/class availability.
--
-- Pure UPDATE (no INSERT), so no DELETE-before-INSERT pairing applies --
-- same shape as 2026_09_01_00_zone_leveler_barrens_playercreateinfo.sql.
UPDATE `playercreateinfo` SET `map` = 1, `position_x` = 1629.85,
    `position_y` = -4373.64, `position_z` = 31.5573, `orientation` = 3.69762
    WHERE (`race`, `class`) IN (
        (2, 1), (2, 3), (2, 4), (2, 7), (2, 9),
        (5, 1), (5, 4), (5, 5), (5, 8), (5, 9),
        (6, 1), (6, 3), (6, 7), (6, 11),
        (8, 1), (8, 3), (8, 4), (8, 5), (8, 7), (8, 8),
        (10, 2), (10, 3), (10, 4), (10, 5), (10, 8), (10, 9)
    );

UPDATE `playercreateinfo` SET `map` = 0, `position_x` = -8833.38,
    `position_y` = 628.628, `position_z` = 94.0066, `orientation` = 1.06535
    WHERE (`race`, `class`) IN (
        (1, 1), (1, 2), (1, 4), (1, 5), (1, 8), (1, 9),
        (3, 1), (3, 2), (3, 3), (3, 4), (3, 5),
        (4, 1), (4, 3), (4, 4), (4, 5), (4, 11),
        (7, 1), (7, 4), (7, 8), (7, 9),
        (11, 1), (11, 2), (11, 3), (11, 5), (11, 7), (11, 8)
    );
