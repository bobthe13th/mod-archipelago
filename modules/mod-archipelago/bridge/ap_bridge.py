#!/usr/bin/env python3
"""
AzerothCore-Archipelago Database Bridge Client
Provides bi-directional synchronization between AzerothCore characters database
and an Archipelago multiworld server.
"""

import sys
import time
import json
import logging
import traceback

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger("AC-AP-Bridge")

# Try to import mysql connector, provide mock support if missing
try:
    import mysql.connector
    from mysql.connector import Error as MySQLError
except ImportError:
    logger.warning("mysql-connector-python is not installed. Running in mock/simulation mode.")
    class MySQLError(Exception): pass
    mysql = None

# Simple dummy implementation of an Archipelago client connection.
# In a full deployment, this inherits from or uses the official 'apclientpy' WebSocket client.
class MockArchipelagoClient:
    def __init__(self, server_url, slot_name, password=None):
        self.server_url = server_url
        self.slot_name = slot_name
        self.password = password
        self.connected = False
        self.checked_locations = set()
        self.received_items = [] # list of (item_id, item_name, index)

    def connect(self):
        logger.info(f"Connecting to Archipelago server at {self.server_url} for slot '{self.slot_name}'...")
        time.sleep(0.5)
        self.connected = True
        logger.info("Successfully connected and authenticated with Archipelago!")
        # Simulate some starting items sent to us from the multiworld
        self._simulate_incoming_items()
        return True

    def disconnect(self):
        self.connected = False
        logger.info("Disconnected from Archipelago.")

    def send_location(self, location_id):
        if location_id not in self.checked_locations:
            self.checked_locations.add(location_id)
            logger.info(f"AP Client: Sent Location Check {location_id} to Archipelago server.")
            return True
        return False

    def _simulate_incoming_items(self):
        # We simulate some items received from our slots:
        # 11000001: Level Cap Increase (+10 Levels)
        # 11000001: Level Cap Increase (+10 Levels)
        # 11000002: XP Boost (+50%)
        # 11000031: Unlock Class: Paladin
        self.received_items = [
            (11000001, "Level Cap Increase (+10 Levels)", 1),
            (11000001, "Level Cap Increase (+10 Levels)", 2),
            (11000002, "XP Boost (+50%)", 3),
            (11000031, "Unlock Class: Paladin", 4),
        ]

class DatabaseBridge:
    def __init__(self, db_config):
        self.db_config = db_config
        self.conn = None

    def connect(self):
        if mysql is None:
            logger.info("Mock DB: Connected successfully (simulation).")
            return True
        try:
            self.conn = mysql.connector.connect(**self.db_config)
            logger.info("Successfully connected to AzerothCore Characters Database.")
            return True
        except MySQLError as e:
            logger.error(f"Failed to connect to MySQL database: {e}")
            return False

    def close(self):
        if self.conn and self.conn.is_connected():
            self.conn.close()
            logger.info("Database connection closed.")

    def fetch_pending_checks(self):
        """Fetches completed checks that haven't been processed or cleared yet."""
        if mysql is None:
            # Mock mode: return dummy local player check
            # Character GUID 1 finished Edwin VanCleef check (11000100)
            return [{"guid": 1, "location_id": 11000100}]

        try:
            cursor = self.conn.cursor(dictionary=True)
            # Find any checks that have been inserted by the C++ module
            query = "SELECT guid, location_id FROM character_archipelago_checks"
            cursor.execute(query)
            results = cursor.fetchall()
            cursor.close()
            return results
        except MySQLError as e:
            logger.error(f"Error fetching pending checks: {e}")
            return []

    def insert_received_item(self, guid, item_id, item_name, index_received):
        """Inserts a received item from AP into characters database for in-game delivery."""
        if mysql is None:
            logger.info(f"Mock DB: Inserted item {item_name} (ID: {item_id}, Index: {index_received}) for Guid {guid}.")
            return True

        try:
            cursor = self.conn.cursor()
            # Avoid duplicating received items using index_received
            check_query = """
                SELECT id FROM character_archipelago_received
                WHERE guid = %s AND index_received = %s
            """
            cursor.execute(check_query, (guid, index_received))
            if cursor.fetchone():
                cursor.close()
                return False # Already registered

            insert_query = """
                INSERT INTO character_archipelago_received (guid, item_id, item_name, index_received, processed)
                VALUES (%s, %s, %s, %s, 0)
            """
            cursor.execute(insert_query, (guid, item_id, item_name, index_received))
            self.conn.commit()
            cursor.close()
            logger.info(f"DB: Successfully queued item {item_name} for character {guid}.")
            return True
        except MySQLError as e:
            logger.error(f"Error inserting received item: {e}")
            return False

def main():
    logger.info("Starting AzerothCore Archipelago Bridge Daemon...")

    # Standard db configuration (this would map to your real server setup)
    db_config = {
        "host": "127.0.0.1",
        "user": "root",
        "password": "",
        "database": "acore_characters",
        "port": 3306
    }

    # Bridge and AP connection setup
    bridge = DatabaseBridge(db_config)
    if not bridge.connect():
        logger.error("Database connection could not be established. Exiting.")
        sys.exit(1)

    # In a production environment, slot information can be parsed from a config or database
    ap_client = MockArchipelagoClient(
        server_url="localhost:38281",
        slot_name="WoW_Adventurer",
        password=None
    )

    if not ap_client.connect():
        logger.error("Could not connect to Archipelago. Exiting.")
        sys.exit(1)

    try:
        # Start main loop
        logger.info("Bridge is fully active and synchronizing data...")
        iteration = 0
        while True:
            # 1. Outbound synchronization: Read checks from DB and report them to Archipelago
            pending_checks = bridge.fetch_pending_checks()
            for check in pending_checks:
                guid = check["guid"]
                loc_id = check["location_id"]
                ap_client.send_location(loc_id)

            # 2. Inbound synchronization: Sync items received from Archipelago into the DB
            # We assume a fixed target character guid (e.g., 1) for the main account player
            # In a real setup, characters are mapped to slot names using the `character_archipelago_state` table.
            for item in ap_client.received_items:
                item_id, item_name, idx = item
                bridge.insert_received_item(guid=1, item_id=item_id, item_name=item_name, index_received=idx)

            iteration += 1
            if mysql is None and iteration >= 2:
                # In simulation/mock mode, terminate after performing sync runs
                logger.info("Simulation mode runs completed successfully.")
                break

            time.sleep(5)  # Poll databases and sockets every 5 seconds

    except KeyboardInterrupt:
        logger.info("Bridge daemon interrupted by user.")
    except Exception as e:
        logger.error(f"Unexpected error in bridge loop: {e}")
        traceback.print_exc()
    finally:
        ap_client.disconnect()
        bridge.close()
        logger.info("Bridge stopped.")

if __name__ == "__main__":
    main()
