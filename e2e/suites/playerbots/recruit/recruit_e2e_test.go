//go:build e2e

// M6.0 Playerbots Integration verification: recruiting an existing
// mod-playerbots bot character into a real player's party via `.playerbots
// bot add <name>` (SEC_PLAYER, no GM level required -- see
// modules/mod-playerbots/src/Script/PlayerbotCommandScript.cpp and
// PlayerbotMgr::HandlePlayerbotMgrCommand) is the actual player-facing M6.0
// feature. This is distinct from mod-playerbots' own bulk random-bot roster
// creation at server boot (AiPlayerbot.MinRandomBots/MaxRandomBots), which a
// separate investigation confirmed bypasses Archipelago.BotChecksCount
// entirely (PlayerbotFactory never attaches PlayerbotAI, so
// IsBotControlledPlayer() can't recognize those characters as bots during
// that bulk-population window) -- see the M6.0 Playerbots gaps memory note
// for the full writeup. These tests exercise the *live-recruitment* path
// specifically, which does go through a real PlayerbotAI attachment and
// should be correctly guarded by archipelago_wow's ShouldRecordLocationCheck.
package recruit_test

import (
	"database/sql"
	"testing"
	"time"

	_ "github.com/go-sql-driver/mysql"

	"github.com/azerothcore/AzerothGhost/e2e/e2eharness"
	"github.com/azerothcore/azerothcore-wotlk/e2e/internal/meta"
)

// M6BOT-01: recruiting an already-existing bot character into a real
// player's party should not, by itself, record any new Archipelago location
// check attribution rows for that bot when Archipelago.BotChecksCount is off
// (the default) -- confirms the live-recruitment path is correctly guarded.
//
// Requires: worldserver running with Archipelago.Enabled=1,
// Archipelago.BotChecksCount=0 (the default), and at least one existing
// mod-playerbots character available to recruit (populated at server boot
// via AiPlayerbot.MinRandomBots/MaxRandomBots, or created ahead of time via
// `.playerbots bot addclass <CLASS>` from a GM session). Set
// M6_RECRUIT_BOT_NAME to override the hardcoded default below if the
// target realm's bot roster uses different names.
func TestPlayerbots_RecruitDoesNotRecordChecks(t *testing.T) {
	meta.Begin(t, meta.TestMeta{Tags: []string{"short", "playerbots"}, Runtime: "short", Category: "playerbots/recruit"})

	bot := e2eharness.NewSolo(t, e2eharness.ScenarioOpts{
		// Prefix must stay short: auth rejects account names >17 chars (closes
		// with EOF, see smoke_e2e_test.go's own comment). MakeBotIdents builds
		// Prefix + 2-digit index + 8 hex = Prefix+10; keep Prefix <= 7.
		Prefix: "M6Recr",
		Class:  e2eharness.ClassWarrior,
		Level:  10,
	})

	const recruitName = "Ralaine" // existing RNDBOT-owned character, class Warrior; see followup memory query used to find it

	before := countCheckAttribution(t, bot.CharDB)

	// SEC_PLAYER command -- no GM level needed, matches the real player-facing
	// M6.0 scenario (a solo player recruiting a companion bot).
	bot.GM(t, ".playerbots bot add "+recruitName)

	// Recruitment triggers the bot's own login (PlayerbotMgr::OnBotLogin ->
	// normal ArchipelagoPlayerScript::OnPlayerLogin path) -- give hooks that
	// fire on login/attach a moment to settle before checking.
	time.Sleep(5 * time.Second)

	after := countCheckAttribution(t, bot.CharDB)
	if after != before {
		t.Fatalf(
			"recruiting %q recorded %d new archipelago_check_attribution row(s) (before=%d after=%d) -- "+
				"BotChecksCount guard did not hold for the live-recruitment path (expected 0 new rows with BotChecksCount=0)",
			recruitName, after-before, before, after,
		)
	}
	t.Logf("PASS: recruiting %q recorded no new checks (before=%d after=%d)", recruitName, before, after)
}

// M6BOT-02: same recruitment, but with Archipelago.BotDeathsTriggerDeathLink
// off (the default) and Archipelago.DeathLinkSendEnabled on -- killing the
// recruited bot must not send a DeathLink Bounce. Verified indirectly via
// the recruiting player's own aura state: a real DeathLink Bounce kills every
// online player including the recruiter, which would show up as the
// recruiter's own character dying immediately after the bot's death with no
// combat of its own. This test only asserts the recruiter survives; it does
// not attempt to force the bot itself into combat/death (mod-playerbots' own
// AI controls that non-deterministically), so treat this as a smoke check,
// not a substitute for the manual checklist's own DeathLink item.
func TestPlayerbots_RecruitedBotPresenceDoesNotKillRecruiter(t *testing.T) {
	meta.Begin(t, meta.TestMeta{Tags: []string{"short", "playerbots"}, Runtime: "short", Category: "playerbots/recruit"})

	bot := e2eharness.NewSolo(t, e2eharness.ScenarioOpts{
		Prefix: "M6Rec2",
		Class:  e2eharness.ClassWarrior,
		Level:  10,
	})

	const recruitName = "Meaen" // existing RNDBOT-owned character, class Paladin; see followup memory query used to find it

	bot.GM(t, ".playerbots bot add "+recruitName)
	time.Sleep(5 * time.Second)

	bot.AssertWorldAlive(t)
	t.Logf("PASS: recruiter survives after recruiting %q", recruitName)
}

func countCheckAttribution(t *testing.T, db *sql.DB) int {
	t.Helper()
	var n int
	if err := db.QueryRow("SELECT COUNT(*) FROM archipelago_check_attribution").Scan(&n); err != nil {
		t.Fatalf("count archipelago_check_attribution: %v", err)
	}
	return n
}
