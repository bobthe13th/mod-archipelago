-- Gate the Dark Portal (Blasted Lands -> Outland) behind the Archipelago
-- Dark Portal Access item. Trigger id verified against
-- data/sql/base/db_world/areatrigger_teleport.sql.
DELETE FROM `areatrigger_scripts` WHERE `entry` = 4354;
INSERT INTO `areatrigger_scripts` (`entry`, `ScriptName`) VALUES (4354, 'at_archipelago_dark_portal');
