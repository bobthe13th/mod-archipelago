# World of Warcraft Archipelago World Integration

from typing import List
from worlds.AutoWorld import World, WebWorld
from BaseClasses import MultiWorld, Item, Location, Entrance, Tutorial, ItemClassification
from .Items import item_table, WOW_ITEM_OFFSET
from .Locations import location_table, WOW_LOCATION_OFFSET
from .Options import wow_options

class WoWWebWorld(WebWorld):
    theme = "ocean"
    tutorials = [
        Tutorial(
            "Multiworld AzerothCore WoW Setup Guide",
            "A guide to configuring and playing World of Warcraft randomized under Archipelago.",
            "English",
            "wow_setup_en.md",
            "wow_setup/en",
            ["Jules"]
        )
    ]

class WoWWorld(World):
    """
    World of Warcraft integration for AzerothCore.
    Explore Azeroth, complete dungeons, quests, achievements, and unlock character caps and features!
    """
    game = "World of Warcraft"
    web = WoWWebWorld()
    options_dataclass = None # Defined dynamically or configured
    options = wow_options
    topology_present = True

    item_name_to_id = {data.name: data.code for data in item_table.values()}
    location_name_to_id = {data.name: data.code for data in location_table.values()}

    def create_items(self) -> None:
        # Create pool of items to put in the multiworld based on configuration
        for item_id, item_data in item_table.items():
            classification = ItemClassification.filler
            if item_data.classification == "progression":
                classification = ItemClassification.progression
            elif item_data.classification == "useful":
                classification = ItemClassification.useful

            item = self.create_item(item_data.name)
            self.multiworld.itempool.append(item)

    def create_item(self, name: str) -> Item:
        item_id = self.item_name_to_id[name]
        item_data = item_table[item_id]
        classification = ItemClassification.filler
        if item_data.classification == "progression":
            classification = ItemClassification.progression
        elif item_data.classification == "useful":
            classification = ItemClassification.useful

        return Item(name, classification, item_id, self.player)

    def create_regions(self) -> None:
        # Create regions (e.g., Azeroth, Outland, Northrend)
        from BaseClasses import Region

        menu = Region("Menu", self.player, self.multiworld)
        self.multiworld.regions.append(menu)

        azeroth = Region("Azeroth", self.player, self.multiworld)
        self.multiworld.regions.append(azeroth)

        outland = Region("Outland", self.player, self.multiworld)
        self.multiworld.regions.append(outland)

        northrend = Region("Northrend", self.player, self.multiworld)
        self.multiworld.regions.append(northrend)

        # Basic connections (entrances)
        menu.connect(azeroth)
        azeroth.connect(outland, "Dark Portal", lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 5)) # Needs lvl 60
        outland.connect(northrend, "Boat to Northrend", lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 6)) # Needs lvl 70

        # Populate locations in their respective regions
        for loc_id, loc_data in location_table.items():
            region = self.multiworld.get_region(loc_data.region, self.player)
            location = Location(self.player, loc_data.name, loc_id, region)
            region.locations.append(location)

    def set_rules(self) -> None:
        # Define rules for accessing specific locations
        # For example, Level 80 requires reaching level 80 (finding 7 level cap increases)
        self.multiworld.get_location("Level Reached: 20", self.player).access_rule = \
            lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 1)
        self.multiworld.get_location("Level Reached: 30", self.player).access_rule = \
            lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 2)
        self.multiworld.get_location("Level Reached: 40", self.player).access_rule = \
            lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 3)
        self.multiworld.get_location("Level Reached: 50", self.player).access_rule = \
            lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 4)
        self.multiworld.get_location("Level Reached: 60", self.player).access_rule = \
            lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 5)
        self.multiworld.get_location("Level Reached: 70", self.player).access_rule = \
            lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 6)
        self.multiworld.get_location("Level Reached: 80", self.player).access_rule = \
            lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 7)

        # Defeating the Lich King requires reaching level 80
        self.multiworld.get_location("Defeat Icecrown Citadel: The Lich King", self.player).access_rule = \
            lambda state: state.has("Level Cap Increase (+10 Levels)", self.player, 7)

    def fill_slot_data(self) -> dict:
        return {
            "progressive_level_cap": int(self.options.progressive_level_cap.value),
            "progressive_xp_multiplier": int(self.options.progressive_xp_multiplier.value),
            "progressive_movement_speed": int(self.options.progressive_movement_speed.value),
            "restrict_classes_races": int(self.options.restrict_classes_races.value),
            "randomize_loot_tables": int(self.options.randomize_loot_tables.value),
        }
