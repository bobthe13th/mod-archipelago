# Options for World of Warcraft Archipelago World

from Options import Choice, Toggle, Range, SpecialRange

class ProgressiveLevelCap(Choice):
    """Enforce progressive level caps. Players start capped at level 10 and must find Level Cap Increase items to increase their maximum level up to 80."""
    display_name = "Progressive Level Cap"
    option_disabled = 0
    option_enabled = 1
    default = 1

class ProgressiveXPMultiplier(Choice):
    """Enforce progressive experience multipliers. Players start with a low multiplier (e.g. 0.2x) and find XP Boost items to reach standard or enhanced multipliers."""
    display_name = "Progressive XP Multiplier"
    option_disabled = 0
    option_enabled = 1
    default = 0

class ProgressiveMovementSpeed(Choice):
    """Enforce progressive movement speed multipliers. Players start with slower run speeds and find Speed Boost items."""
    display_name = "Progressive Movement Speed"
    option_disabled = 0
    option_enabled = 1
    default = 0

class RestrictClassesRaces(Toggle):
    """If enabled, players only start with standard basic combinations and must find Unlock Class / Unlock Race items to create characters of other classes/races."""
    display_name = "Restrict Classes and Races"
    default = False

class RandomizeLootTables(Toggle):
    """If enabled, standard mob drops and chest loot are randomized with custom items and locations."""
    display_name = "Randomize Loot Tables"
    default = False

class LevelCapIncrement(Range):
    """Increments of level caps if progressive level cap is enabled."""
    display_name = "Level Cap Increment"
    range_start = 5
    range_end = 20
    default = 10

wow_options = {
    "progressive_level_cap": ProgressiveLevelCap,
    "progressive_xp_multiplier": ProgressiveXPMultiplier,
    "progressive_movement_speed": ProgressiveMovementSpeed,
    "restrict_classes_races": RestrictClassesRaces,
    "randomize_loot_tables": RandomizeLootTables,
    "level_cap_increment": LevelCapIncrement,
}
