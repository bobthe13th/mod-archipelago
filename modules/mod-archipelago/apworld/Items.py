# Items list for World of Warcraft Archipelago World

from typing import Dict, NamedTuple

class ItemData(NamedTuple):
    name: str
    code: int
    classification: str  # progression, useful, filler, trap

# Starting offset of Item IDs for World of Warcraft (to avoid collisions)
WOW_ITEM_OFFSET = 11000000

# Classifications mapping to AP ItemClassification
PROGRESSION = "progression"
USEFUL = "useful"
FILLER = "filler"

item_table: Dict[int, ItemData] = {
    # Progressive Level Caps
    WOW_ITEM_OFFSET + 1: ItemData("Level Cap Increase (+10 Levels)", WOW_ITEM_OFFSET + 1, PROGRESSION),
    # Progressive XP Boosts
    WOW_ITEM_OFFSET + 2: ItemData("XP Boost (+50%)", WOW_ITEM_OFFSET + 2, PROGRESSION),
    # Progressive Speed Boosts
    WOW_ITEM_OFFSET + 3: ItemData("Speed Boost (+10%)", WOW_ITEM_OFFSET + 3, USEFUL),

    # Race Unlocks
    WOW_ITEM_OFFSET + 10: ItemData("Unlock Race: Blood Elf", WOW_ITEM_OFFSET + 10, PROGRESSION),
    WOW_ITEM_OFFSET + 11: ItemData("Unlock Race: Draenei", WOW_ITEM_OFFSET + 11, PROGRESSION),
    WOW_ITEM_OFFSET + 12: ItemData("Unlock Race: Orc", WOW_ITEM_OFFSET + 12, PROGRESSION),
    WOW_ITEM_OFFSET + 13: ItemData("Unlock Race: Human", WOW_ITEM_OFFSET + 13, PROGRESSION),
    WOW_ITEM_OFFSET + 14: ItemData("Unlock Race: Undead", WOW_ITEM_OFFSET + 14, PROGRESSION),
    WOW_ITEM_OFFSET + 15: ItemData("Unlock Race: Dwarf", WOW_ITEM_OFFSET + 15, PROGRESSION),
    WOW_ITEM_OFFSET + 16: ItemData("Unlock Race: Night Elf", WOW_ITEM_OFFSET + 16, PROGRESSION),
    WOW_ITEM_OFFSET + 17: ItemData("Unlock Race: Troll", WOW_ITEM_OFFSET + 17, PROGRESSION),
    WOW_ITEM_OFFSET + 18: ItemData("Unlock Race: Gnome", WOW_ITEM_OFFSET + 18, PROGRESSION),
    WOW_ITEM_OFFSET + 19: ItemData("Unlock Race: Tauren", WOW_ITEM_OFFSET + 19, PROGRESSION),

    # Class Unlocks
    WOW_ITEM_OFFSET + 30: ItemData("Unlock Class: Death Knight", WOW_ITEM_OFFSET + 30, PROGRESSION),
    WOW_ITEM_OFFSET + 31: ItemData("Unlock Class: Paladin", WOW_ITEM_OFFSET + 31, PROGRESSION),
    WOW_ITEM_OFFSET + 32: ItemData("Unlock Class: Mage", WOW_ITEM_OFFSET + 32, PROGRESSION),
    WOW_ITEM_OFFSET + 33: ItemData("Unlock Class: Warlock", WOW_ITEM_OFFSET + 33, PROGRESSION),
    WOW_ITEM_OFFSET + 34: ItemData("Unlock Class: Priest", WOW_ITEM_OFFSET + 34, PROGRESSION),
    WOW_ITEM_OFFSET + 35: ItemData("Unlock Class: Druid", WOW_ITEM_OFFSET + 35, PROGRESSION),
    WOW_ITEM_OFFSET + 36: ItemData("Unlock Class: Shaman", WOW_ITEM_OFFSET + 36, PROGRESSION),
    WOW_ITEM_OFFSET + 37: ItemData("Unlock Class: Hunter", WOW_ITEM_OFFSET + 37, PROGRESSION),
    WOW_ITEM_OFFSET + 38: ItemData("Unlock Class: Rogue", WOW_ITEM_OFFSET + 38, PROGRESSION),
    WOW_ITEM_OFFSET + 39: ItemData("Unlock Class: Warrior", WOW_ITEM_OFFSET + 39, PROGRESSION),

    # Utility Unlocks
    WOW_ITEM_OFFSET + 50: ItemData("Unlock Profession: Jewelcrafting", WOW_ITEM_OFFSET + 50, USEFUL),
    WOW_ITEM_OFFSET + 51: ItemData("Unlock Profession: Inscription", WOW_ITEM_OFFSET + 51, USEFUL),
    WOW_ITEM_OFFSET + 52: ItemData("Unlock Riding: Apprentice", WOW_ITEM_OFFSET + 52, PROGRESSION),
    WOW_ITEM_OFFSET + 53: ItemData("Unlock Riding: Journeyman", WOW_ITEM_OFFSET + 53, PROGRESSION),
    WOW_ITEM_OFFSET + 54: ItemData("Unlock Riding: Expert", WOW_ITEM_OFFSET + 54, PROGRESSION),
    WOW_ITEM_OFFSET + 55: ItemData("Unlock Riding: Artisan", WOW_ITEM_OFFSET + 55, PROGRESSION),
}

# Standard items can also map directly to WoW Item Templates (Database IDs) inside the AzerothCore delivery system.
