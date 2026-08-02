# AzerothCore Archipelago Integration Module (`mod-archipelago`)

An Archipelago Multiworld randomizer implementation for AzerothCore (World of Warcraft 3.3.5a). This module enables World of Warcraft to be integrated into an Archipelago multiworld session, where players can complete in-game tasks (leveling, quests, achievements, boss kills) to unlock items, classes, races, progressive levels, and speeds for themselves and other players across different games.

---

## Setup & Installation Instructions

This setup guide is divided into four main parts:
1. **Database Setup** (MySQL)
2. **AzerothCore C++ Module Compilation**
3. **Archipelago `.apworld` Plugin Installation**
4. **Python Database Bridge Daemon Operation**

---

### Part 1: Database Setup

You must import the Archipelago schema into your AzerothCore characters database.

1. Locate the custom database script at:
   `modules/mod-archipelago/sql/characters/base/character_archipelago.sql`
2. Run this script against your `acore_characters` database:
   ```bash
   mysql -u root -p acore_characters < modules/mod-archipelago/sql/characters/base/character_archipelago.sql
   ```

This will create three new tables:
- `character_archipelago_checks`: Tracks locations checked in WoW.
- `character_archipelago_received`: Queues items found in other games for delivery in WoW.
- `character_archipelago_state`: Holds player-specific progressive caps and state multipliers.

---

### Part 2: AzerothCore C++ Module

To compile and enable the Archipelago AzerothCore module:

1. Clone or copy this repository directory to your `/modules` folder in your AzerothCore sources:
   ```bash
   cp -R modules/mod-archipelago [YOUR_AZEROTHCORE_ROOT]/modules/
   ```
2. Re-run CMake to detect the new module:
   ```bash
   mkdir -p build && cd build
   cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/azeroth-server -DCMAKE_BUILD_TYPE=RelWithDebInfo
   ```
3. Compile the worldserver target:
   ```bash
   make -j$(nproc) && make install
   ```
4. Copy the configuration template file from:
   `modules/mod-archipelago/conf/mod_archipelago.conf.dist` to your worldserver bin folder, naming it `mod_archipelago.conf`.
5. Adjust any configuration values inside `mod_archipelago.conf` to customize experience limits, movement speeds, or progression rates.

---

### Part 3: Archipelago `.apworld` Installation

To let Archipelago recognize World of Warcraft as a randomizer game and generate player YAML configuration files:

1. Locate the `.apworld` directory:
   `modules/mod-archipelago/apworld/`
2. Create a zip archive containing this directory renamed to `wow.apworld` (or copy it to the Archipelago installation directory):
   ```bash
   cd modules/mod-archipelago/apworld
   zip -r ../../../wow.apworld .
   ```
3. Place `wow.apworld` into your Archipelago installation `custom_worlds/` folder.
4. Players can now generate multiworld game YAML files using the options defined in the world configuration!

---

### Part 4: Python Database Bridge Daemon

The Bridge Daemon acts as the communication link between your AzerothCore database and the Archipelago websocket server.

1. Make sure you have python3 and the MySQL connector installed:
   ```bash
   pip install mysql-connector-python
   ```
2. Open the bridge script configuration block:
   `modules/mod-archipelago/bridge/ap_bridge.py`
3. Edit the `db_config` block to match your AzerothCore character database credentials and update the target Archipelago server connection parameters (`server_url`, `slot_name`).
4. Start the bridge daemon on the same machine running the worldserver:
   ```bash
   python3 modules/mod-archipelago/bridge/ap_bridge.py
   ```

The bridge daemon will now run, automatically polling for completed locations in-game to dispatch to Archipelago, and instantly processing any multiworld items to queue them inside the database for immediate in-game mail delivery!
