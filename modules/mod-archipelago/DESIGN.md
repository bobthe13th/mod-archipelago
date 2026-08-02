# Architecture Design: AzerothCore Archipelago Integration

This document outlines the design and integration architecture of the **AzerothCore Archipelago Multiworld Mod**. It enables World of Warcraft (3.3.5a) to act as a client/world in an Archipelago multiworld session, where players can complete checks (leveling, quests, achievements, boss kills, etc.) to unlock items, progressive caps, races, classes, and other rewards for themselves and other players across different games.

---

## 1. High-Level Architecture Overview

To maintain server stability, avoid complex multi-threaded asynchronous network code within the C++ AzerothCore core, and use native Archipelago Python tools, the system is designed around a **Three-Tier Architecture**:

```
+---------------------------------------------------------------------------------+
|                                                                                 |
|                              Archipelago Server                                 |
|                                                                                 |
+----------------------------------------^----------------------------------------+
                                         | (AP Protocol / JSON WebSockets)
                                         v
+---------------------------------------------------------------------------------+
|                                                                                 |
|                       Python Bridge Client (AP Client)                          |
|                                                                                 |
|  - Connects to AP server and tracks connection/slot state.                      |
|  - Polls `character_archipelago_pending_checks` table for new game completions  |
|    and sends them to the AP server.                                             |
|  - Receives incoming items/unlocks from the AP server and writes them into      |
|    `character_archipelago_received_items` table.                                |
|                                                                                 |
+----------------------------------------^----------------------------------------+
                                         | (MySQL Database Queries)
                                         v
+---------------------------------------------------------------------------------+
|                                                                                 |
|                           AzerothCore Game Server                               |
|                                                                                 |
|  - Custom C++ Module (`mod-archipelago`) running inside the `worldserver` process.  |
|  - Listens to C++ Game Hooks (level up, quest completion, achievements, etc.).  |
|  - Inserts triggered checks into database tables.                               |
|  - Periodically polls database for pending items/unlocks and delivers them.    |
|  - Enforces progressive limits (level caps, speed bonuses, XP multipliers,      |
|    class/race availability, and randomized drops).                              |
|                                                                                 |
+---------------------------------------------------------------------------------+
```

---

## 2. Database Schema (MySQL)

We use custom tables inside the `acore_characters` database to manage the bridge state. This ensures transactions are fully synchronized with player saves and prevents race conditions.

### `character_archipelago_checks`
Tracks all Archipelago checks (locations) completed by players on this server.
- `guid` (INT): Character Guid.
- `location_id` (BIGINT): The Archipelago location ID.
- `completed_at` (TIMESTAMP): When the check was completed.
- *Primary Key*: `(guid, location_id)`

### `character_archipelago_received`
Tracks all items received from Archipelago for each character.
- `id` (INT AUTO_INCREMENT): Local unique sequence ID.
- `guid` (INT): Character Guid.
- `item_id` (BIGINT): The Archipelago item ID.
- `item_name` (VARCHAR): Descriptive name of the item.
- `index_received` (INT): The index of the item in the AP receive queue (for ordering).
- `processed` (TINYINT): `0` if pending delivery, `1` if successfully processed in-game.
- `processed_at` (TIMESTAMP NULL): Timestamp of delivery.
- *Primary Key*: `id`

### `character_archipelago_state`
Stores character-specific meta-state (e.g., current progressive XP rate, maximum progressive level cap, current slot mapping).
- `guid` (INT PRIMARY KEY): Character Guid.
- `slot_name` (VARCHAR): Archipelago Slot Name.
- `level_cap` (INT): Active progressive level cap.
- `xp_multiplier` (FLOAT): Active progressive experience multiplier.
- `speed_multiplier` (FLOAT): Active movement speed multiplier.
- `unlocked_features` (TEXT): JSON/serialized list of account-wide/character-wide unlocks (e.g., races, classes, mounts, specs).

---

## 3. Archipelago World (`.apworld`) Design

The `.apworld` is written in Python and loaded by the Archipelago generation server. It defines the rules, options, items, and logical regions of World of Warcraft.

### A. Core Generation Options
The mod allows administrators to customize their WoW multiworld experience via a standard YAML configuration:

1. **`progressive_level_cap`**:
   - `Disabled`: Standard 1-80 level progression.
   - `Enabled`: Starts with a level cap of 10. Items called "Level Cap Increase (+10 Levels)" must be found to progress (10 -> 20 -> 30 -> ... -> 80).
2. **`progressive_xp_multiplier`**:
   - `Disabled`: Standard XP.
   - `Enabled`: Starts with an XP penalty (e.g., 0.2x). Finding "XP Boost (+50%)" items scales up the XP rate.
3. **`progressive_movement_speed`**:
   - `Disabled`: Normal movement.
   - `Enabled`: Starts slow (e.g., 50% run speed). Finding "Speed Boost (+10%)" items increases speed up to a maximum.
4. **`restrict_classes_races`**:
   - `Disabled`: All classes/races unlocked.
   - `Enabled`: Starts with only a basic race/class combination available. Unlocking other races or classes requires finding corresponding AP items.
5. **`randomize_loot_tables`**:
   - `Disabled`: Normal drop tables.
   - `Enabled`: Intercepts mob loot generation and rewards randomized drops/AP item checks.

### B. Archipelago Location Checks
Wow contains thousands of possible checks, grouped by category in the `.apworld` logic:
- **Level Checks**: Reaching level 10, 20, 30, 40, 50, 60, 70, 80.
- **Quest Checks**: Specific quest IDs (e.g., "The Battle for Undercity").
- **Achievement Checks**: Unlocking specific achievements or achievement categories.
- **Dungeon/Raid Boss Checks**: Defeating major bosses (e.g., Onyxia, Ragnaros, Arthas).
- **Profession Milestones**: Reaching skill levels 75, 150, 225, 300, 375, 450 in primary/secondary professions.
- **Faction Reputation**: Reaching Friendly, Honored, Revered, or Exalted with major factions.

### C. Archipelago Items
Items sent to the AzerothCore player:
- **Equipment Items**: Specific World of Warcraft item IDs (sent directly to the player's in-game Mailbox).
- **Progressive Upgrades**:
  - `Level Cap Increase (+10 Levels)`
  - `XP Boost (+50%)`
  - `Speed Boost (+10%)`
  - `Progressive Mount Speed` (e.g., 60% ground -> 100% ground -> 150% flying -> 280% flying)
- **Unlocks**:
  - Class Unlock: `Unlock Death Knight`, `Unlock Paladin`, etc.
  - Race Unlock: `Unlock Blood Elf`, `Unlock Draenei`, etc.
  - Instance Unlock: Unlocks access to specific dungeons or raids (e.g., `Unlock Icecrown Citadel`).
  - Profession Unlock: Unlocks ability to learn specific professions (e.g., `Unlock Jewelcrafting`).

---

## 4. The Python Bridge Client Flow

The Bridge client is a standalone Python daemon that runs alongside the server.

1. **Initialization**:
   - Connects to the AzerothCore Characters MySQL database.
   - Connects to the Archipelago Server WebSocket using `apclientpy` library.
2. **Outbound Sync (Checks)**:
   - Polls the `character_archipelago_checks` table for new entries.
   - When a new check is found, it calls `ap_client.send_location(location_id)` and marks it sent.
3. **Inbound Sync (Items/Unlocks)**:
   - Registers for the `ReceivedItems` callback from the AP server.
   - For every incoming item, it maps the AP Item ID to the local target Character, and inserts it into `character_archipelago_received` if not already present.

---

## 5. AzerothCore C++ Module (`mod-archipelago`)

The C++ module uses AzerothCore's modular script hook engine to intercept events and apply limits.

### Event Interception Hooks:
- **`OnPlayerLevelChanged` (in `PlayerScript`)**:
  - Enforces active progressive level caps. If a player reaches the active level cap, experience gain is locked or capped.
  - Generates a level check (e.g., `location_id = BASE_LEVEL_CHECK_ID + new_level`) and writes it to `character_archipelago_checks`.
- **`OnQuestComplete` (in `PlayerScript`)**:
  - Writes standard quest checks (`location_id = BASE_QUEST_CHECK_ID + quest_id`) to the database.
- **`OnAchievementEarned` (in `PlayerScript`)**:
  - Writes achievement checks to the database.
- **`OnCreatureKilledByPetOrPlayer` (in `PlayerScript`)**:
  - Checks if the killed creature is a boss or registered encounter, then registers a boss-kill check.

### Reward Delivery & Feature Enforcement:
- **Periodic Update Loop (`WorldScript` / custom timer)**:
  - Selects unprocessed items from `character_archipelago_received`.
  - Maps AP Item ID to game action:
    - If it's a physical equipment item: Constructs a Mail message with the item attachments and mails it to the player.
    - If it's a progressive upgrade (e.g. Level Cap, XP Multiplier, Speed): Updates the player's state in `character_archipelago_state` and instantly adjusts active level cap, speed modifier, or XP rate.
    - If it's a class/race unlock: Writes to the state table to allow future character creations or spec shifts.
- **Login Restrictions (`OnPlayerLogin` / `OnPlayerCreate`)**:
  - Validates if the player's selected class or race is unlocked. If not, alerts the player or locks character access until unlocked.
  - Computes and applies movement speed adjustments based on progressive speed item count.
  - Computes and applies experience multipliers based on progressive XP item count.
- **Instance Restrictions (`OnPlayerEnterMap`)**:
  - Prevents players from entering instances/raids unless the corresponding AP unlock item has been processed.
