#include "ScriptMgr.h"
#include "Player.h"
#include "Config.h"
#include "Chat.h"
#include "Mail.h"
#include "DatabaseEnv.h"
#include "Log.h"
#include "World.h"
#include "SharedDefines.h"
#include <sstream>

// Constants matching Archipelago configuration offsets
constexpr uint64 WOW_LOCATION_OFFSET = 11000000;
constexpr uint64 WOW_ITEM_OFFSET = 11000000;

class ArchipelagoPlayerScript : public PlayerScript
{
public:
    ArchipelagoPlayerScript() : PlayerScript("ArchipelagoPlayerScript") {}

    // Hook: Triggered when a player levels up
    void OnPlayerLevelChanged(Player* player, uint8 oldLevel) override
    {
        if (!sConfigMgr->GetOption<bool>("Archipelago.Enable", false))
            return;

        uint8 newLevel = player->GetLevel();
        LOG_INFO("server.loading", "Archipelago: Player {} leveled up to {} (Old: {})", player->GetName(), newLevel, oldLevel);

        // Enforce active level cap
        uint32 activeCap = GetActiveLevelCap(player);
        if (newLevel > activeCap)
        {
            LOG_INFO("server.loading", "Archipelago: Player {} reached level cap ({}), rolling back.", player->GetName(), activeCap);
            player->SetLevel(activeCap);
            ChatHandler(player->GetSession()).PSendSysMessage("You have reached your current progressive Archipelago Level Cap (%u)! Unlock more caps in the multiworld.", activeCap);
            return;
        }

        // Trigger milestone level checks (e.g., Level 10, 20, ..., 80)
        if (newLevel % 10 == 0)
        {
            uint64 locationId = WOW_LOCATION_OFFSET + newLevel;
            RegisterCompletedCheck(player, locationId);
            ChatHandler(player->GetSession()).PSendSysMessage("Archipelago check completed! Reached Level %u. Checking multiworld...", newLevel);
        }
    }

    // Hook: Triggered when a player completes a quest
    void OnQuestComplete(Player* player, Quest const* quest) override
    {
        if (!sConfigMgr->GetOption<bool>("Archipelago.Enable", false))
            return;

        uint64 locationId = WOW_LOCATION_OFFSET + 1000 + quest->GetQuestId();
        RegisterCompletedCheck(player, locationId);
        LOG_INFO("server.loading", "Archipelago: Player completed quest {}. Triggering check {}.", quest->GetQuestId(), locationId);
    }

    // Hook: Triggered when a player earns an achievement
    void OnAchievementEarned(Player* player, AchievementEntry const* achievement) override
    {
        if (!sConfigMgr->GetOption<bool>("Archipelago.Enable", false))
            return;

        uint64 locationId = WOW_LOCATION_OFFSET + 2000 + achievement->ID;
        RegisterCompletedCheck(player, locationId);
        LOG_INFO("server.loading", "Archipelago: Player earned achievement {}. Triggering check {}.", achievement->ID, locationId);
    }

    // Hook: Triggered on player login
    void OnPlayerLogin(Player* player) override
    {
        if (!sConfigMgr->GetOption<bool>("Archipelago.Enable", false))
            return;

        ChatHandler(player->GetSession()).PSendSysMessage("Welcome to the Archipelago Multiworld! Syncing checks and receiving items...");

        // Apply progressive adjustments to player stats
        ApplyProgressiveStats(player);
    }

private:
    uint32 GetActiveLevelCap(Player* player)
    {
        // Read character's current progressive level cap from database
        uint32 cap = sConfigMgr->GetOption<uint32>("Archipelago.StartLevelCap", 10);
        QueryResult result = CharacterDatabase.Query("SELECT level_cap FROM character_archipelago_state WHERE guid = {}", player->GetGUID().GetCounter());
        if (result)
        {
            Field* fields = result->Fetch();
            cap = fields[0].Get<uint32>();
        }
        return cap;
    }

    void ApplyProgressiveStats(Player* player)
    {
        uint32 guid = player->GetGUID().GetCounter();
        float speedMult = sConfigMgr->GetOption<float>("Archipelago.BaseSpeedMultiplier", 0.5f);
        float xpMult = sConfigMgr->GetOption<float>("Archipelago.BaseXPMultiplier", 0.2f);

        QueryResult result = CharacterDatabase.Query("SELECT speed_multiplier, xp_multiplier FROM character_archipelago_state WHERE guid = {}", guid);
        if (result)
        {
            Field* fields = result->Fetch();
            speedMult = fields[0].Get<float>();
            xpMult = fields[1].Get<float>();
        }

        // Apply progressive movement speed
        player->SetSpeed(MOVE_RUN, speedMult, true);
        ChatHandler(player->GetSession()).PSendSysMessage("Archipelago Speed Multiplier applied: %.2fx", speedMult);
        ChatHandler(player->GetSession()).PSendSysMessage("Archipelago XP Multiplier active: %.2fx", xpMult);
    }

    void RegisterCompletedCheck(Player* player, uint64 locationId)
    {
        uint32 guid = player->GetGUID().GetCounter();
        // Insert asynchronously / prepared statement to characters database
        CharacterDatabase.Execute("INSERT IGNORE INTO character_archipelago_checks (guid, location_id) VALUES ({}, {})", guid, locationId);
    }
};

class ArchipelagoWorldScript : public WorldScript
{
public:
    ArchipelagoWorldScript() : WorldScript("ArchipelagoWorldScript") {}

    // Hook: Periodic update of the world server (runs every tick)
    void OnUpdate(uint32 diff) override
    {
        if (!sConfigMgr->GetOption<bool>("Archipelago.Enable", false))
            return;

        _updateTimer += diff;
        if (_updateTimer >= 5000) // Poll for new items every 5 seconds
        {
            _updateTimer = 0;
            ProcessIncomingArchipelagoItems();
        }
    }

private:
    uint32 _updateTimer = 0;

    void ProcessIncomingArchipelagoItems()
    {
        // Query database for unprocessed items
        QueryResult result = CharacterDatabase.Query("SELECT id, guid, item_id, item_name, index_received FROM character_archipelago_received WHERE processed = 0");
        if (!result)
            return;

        do
        {
            Field* fields = result->Fetch();
            uint32 id = fields[0].Get<uint32>();
            uint32 guidVal = fields[1].Get<uint32>();
            uint64 itemId = fields[2].Get<uint64>();
            std::string itemName = fields[3].Get<std::string>();
            uint32 indexReceived = fields[4].Get<uint32>();

            ObjectGuid guid = ObjectGuid::Create<HighGuid::Player>(guidVal);
            Player* player = ObjectAccessor::FindPlayer(guid);

            bool processedSuccessfully = false;

            // Apply Archipelago specific action / item
            if (itemId == WOW_ITEM_OFFSET + 1) // Level Cap Increase
            {
                processedSuccessfully = IncreaseLevelCap(guidVal);
                if (player && processedSuccessfully)
                    ChatHandler(player->GetSession()).PSendSysMessage("Your Archipelago Level Cap increased by 10!");
            }
            else if (itemId == WOW_ITEM_OFFSET + 2) // XP Boost
            {
                processedSuccessfully = IncreaseXPMultiplier(guidVal);
                if (player && processedSuccessfully)
                    ChatHandler(player->GetSession()).PSendSysMessage("Your progressive experience rate was boosted!");
            }
            else if (itemId == WOW_ITEM_OFFSET + 3) // Speed Boost
            {
                processedSuccessfully = IncreaseSpeedMultiplier(guidVal);
                if (player && processedSuccessfully)
                {
                    player->SetSpeed(MOVE_RUN, GetSpeedMultiplier(guidVal), true);
                    ChatHandler(player->GetSession()).PSendSysMessage("Your progressive run speed was increased!");
                }
            }
            else
            {
                // Deliver via standard mail
                processedSuccessfully = DeliverMailItem(guidVal, itemId, itemName);
                if (player && processedSuccessfully)
                    ChatHandler(player->GetSession()).PSendSysMessage("You received item '%s' from the Archipelago Multiworld! Check your Mailbox.", itemName.c_str());
            }

            if (processedSuccessfully)
            {
                CharacterDatabase.Execute("UPDATE character_archipelago_received SET processed = 1, processed_at = NOW() WHERE id = {}", id);
                LOG_INFO("server.loading", "Archipelago: Processed incoming item {}: {} for player {}.", itemId, itemName, guidVal);
            }

        } while (result->NextRow());
    }

    bool IncreaseLevelCap(uint32 guid)
    {
        CharacterDatabase.Execute(
            "INSERT INTO character_archipelago_state (guid, level_cap) VALUES ({}, 20) "
            "ON DUPLICATE KEY UPDATE level_cap = LEAST(80, level_cap + 10)", guid
        );
        return true;
    }

    bool IncreaseXPMultiplier(uint32 guid)
    {
        CharacterDatabase.Execute(
            "INSERT INTO character_archipelago_state (guid, xp_multiplier) VALUES ({}, 0.7) "
            "ON DUPLICATE KEY UPDATE xp_multiplier = xp_multiplier + 0.5", guid
        );
        return true;
    }

    bool IncreaseSpeedMultiplier(uint32 guid)
    {
        CharacterDatabase.Execute(
            "INSERT INTO character_archipelago_state (guid, speed_multiplier) VALUES ({}, 0.6) "
            "ON DUPLICATE KEY UPDATE speed_multiplier = LEAST(2.0, speed_multiplier + 0.1)", guid
        );
        return true;
    }

    float GetSpeedMultiplier(uint32 guid)
    {
        QueryResult result = CharacterDatabase.Query("SELECT speed_multiplier FROM character_archipelago_state WHERE guid = {}", guid);
        if (result)
        {
            Field* fields = result->Fetch();
            return fields[0].Get<float>();
        }
        return 1.0f;
    }

    bool DeliverMailItem(uint32 guidVal, uint64 itemId, std::string const& itemName)
    {
        // For standard items, we map the AP Item ID back to a standard WoW Database Item ID, then construct mail.
        // Let's assume standard item ids under 10000 are actual WoW item ids.
        uint32 wowItemId = itemId < 1000000 ? static_cast<uint32>(itemId) : 12057; // Default placeholder item

        SQLTransaction trans = CharacterDatabase.BeginTransaction();
        MailDraft draft("Archipelago Multiworld", "Here is an item found for you in the multiworld!");

        // MailDraft::AddItem or create item to attach
        Item* item = Item::CreateItem(wowItemId, 1);
        if (item)
        {
            item->SaveToDB(trans);
            draft.AddItem(item);
        }
        draft.SendMailTo(trans, MailReceiver(guidVal), MailSender(MAIL_CREATURE, 0));
        CharacterDatabase.CommitTransaction(trans);
        return true;
    }
};

void Addmod_archipelagoScripts()
{
    new ArchipelagoPlayerScript();
    new ArchipelagoWorldScript();
}
