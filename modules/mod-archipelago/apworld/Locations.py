# Locations list for World of Warcraft Archipelago World

from typing import Dict, NamedTuple

class LocationData(NamedTuple):
    name: str
    code: int
    region: str

# Starting offset of Location IDs for World of Warcraft (to avoid collisions)
WOW_LOCATION_OFFSET = 11000000

location_table: Dict[int, LocationData] = {
    # Level Reached Checks (10 to 80)
    WOW_LOCATION_OFFSET + 10: LocationData("Level Reached: 10", WOW_LOCATION_OFFSET + 10, "Azeroth"),
    WOW_LOCATION_OFFSET + 20: LocationData("Level Reached: 20", WOW_LOCATION_OFFSET + 20, "Azeroth"),
    WOW_LOCATION_OFFSET + 30: LocationData("Level Reached: 30", WOW_LOCATION_OFFSET + 30, "Azeroth"),
    WOW_LOCATION_OFFSET + 40: LocationData("Level Reached: 40", WOW_LOCATION_OFFSET + 40, "Azeroth"),
    WOW_LOCATION_OFFSET + 50: LocationData("Level Reached: 50", WOW_LOCATION_OFFSET + 50, "Azeroth"),
    WOW_LOCATION_OFFSET + 60: LocationData("Level Reached: 60", WOW_LOCATION_OFFSET + 60, "Azeroth"),
    WOW_LOCATION_OFFSET + 70: LocationData("Level Reached: 70", WOW_LOCATION_OFFSET + 70, "Outland"),
    WOW_LOCATION_OFFSET + 80: LocationData("Level Reached: 80", WOW_LOCATION_OFFSET + 80, "Northrend"),

    # Notable Dungeon/Raid Boss Kill Checks
    WOW_LOCATION_OFFSET + 100: LocationData("Defeat Deadmines: Edwin VanCleef", WOW_LOCATION_OFFSET + 100, "Deadmines"),
    WOW_LOCATION_OFFSET + 101: LocationData("Defeat Scarlet Monastery: Scarlet Commander Mograine", WOW_LOCATION_OFFSET + 101, "Scarlet Monastery"),
    WOW_LOCATION_OFFSET + 102: LocationData("Defeat Molten Core: Ragnaros", WOW_LOCATION_OFFSET + 102, "Molten Core"),
    WOW_LOCATION_OFFSET + 103: LocationData("Defeat Onyxia's Lair: Onyxia", WOW_LOCATION_OFFSET + 103, "Onyxia's Lair"),
    WOW_LOCATION_OFFSET + 104: LocationData("Defeat Blackwing Lair: Nefarian", WOW_LOCATION_OFFSET + 104, "Blackwing Lair"),
    WOW_LOCATION_OFFSET + 105: LocationData("Defeat Temple of Ahn'Qiraj: C'Thun", WOW_LOCATION_OFFSET + 105, "Temple of Ahn'Qiraj"),
    WOW_LOCATION_OFFSET + 106: LocationData("Defeat Karazhan: Prince Malchezaar", WOW_LOCATION_OFFSET + 106, "Karazhan"),
    WOW_LOCATION_OFFSET + 107: LocationData("Defeat Black Temple: Illidan Stormrage", WOW_LOCATION_OFFSET + 107, "Black Temple"),
    WOW_LOCATION_OFFSET + 108: LocationData("Defeat Sunwell Plateau: Kil'jaeden", WOW_LOCATION_OFFSET + 108, "Sunwell Plateau"),
    WOW_LOCATION_OFFSET + 109: LocationData("Defeat Naxxramas: Kel'Thuzad", WOW_LOCATION_OFFSET + 109, "Naxxramas"),
    WOW_LOCATION_OFFSET + 110: LocationData("Defeat Ulduar: Yogg-Saron", WOW_LOCATION_OFFSET + 110, "Ulduar"),
    WOW_LOCATION_OFFSET + 111: LocationData("Defeat Icecrown Citadel: The Lich King", WOW_LOCATION_OFFSET + 111, "Icecrown Citadel"),

    # Milestone Achievement Checks
    WOW_LOCATION_OFFSET + 200: LocationData("Achievement: 10 Quests Completed", WOW_LOCATION_OFFSET + 200, "Azeroth"),
    WOW_LOCATION_OFFSET + 201: LocationData("Achievement: 100 Quests Completed", WOW_LOCATION_OFFSET + 201, "Azeroth"),
    WOW_LOCATION_OFFSET + 202: LocationData("Achievement: 500 Quests Completed", WOW_LOCATION_OFFSET + 202, "Azeroth"),
    WOW_LOCATION_OFFSET + 203: LocationData("Achievement: Giddy Up!", WOW_LOCATION_OFFSET + 203, "Azeroth"),
    WOW_LOCATION_OFFSET + 204: LocationData("Achievement: Professional Artisan", WOW_LOCATION_OFFSET + 204, "Azeroth"),
}
