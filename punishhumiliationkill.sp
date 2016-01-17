#include <sourcemod>
#include <sdktools_functions>
#include <sdktools_sound>
#include <tf2>

#define PLUGIN_VERSION		"1.0.0"

// Might want to change this to pre so we can prevent deaths.
#define HOOK_MODE EventHookMode_Post

static bool:eventHooked = false;

public Plugin:myinfo = {
	name = "[TF2] Punish Humiliation Kill",
	author = "Daverball",
	description = "Punishes players for attemping to kill other people during humiliation mode.",
	version = PLUGIN_VERSION,
	url = "https://github.com/Daverball/punishhumiliationkill"
}

public OnPluginStart() {
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_round_win", Event_RoundWin);
}

public Event_RoundStart(Event:event, const String:name[], bool:dontBroadcast) {
	if (eventHooked) {
		UnhookEvent("player_death", Event_PlayerDeath, HOOK_MODE);
		eventHooked = false;
	}
}

public Event_RoundWin(Event:event, const String:name[], bool:dontBroadcast) {
	HookEvent("player_death", Event_PlayerDeath, HOOK_MODE);
	eventHooked = true;
}

public Action Event_PlayerDeath(Event:event, const String:name[], bool:dontBroadcast) {
	int attacker = event.GetInt("attacker");
	int victim = event.GetInt("userid");
	if (attacker == victim) {
		// Can't punish a suicide
		return Plugin_Handled;
	}

	int client_id = GetClientOfUserId(attacker);

	if (client_id == 0) {
		// Wasn't killed by a player
		return Plugin_Handled;
	}

	TF2_StunPlayer(client_id, 2.0, 0.5, TF_STUNFLAGS_SMALLBONK, 0);
	CreateTimer(0.6, Timer_SlapPlayer, client_id);
	CreateTimer(1.0, Timer_SlapPlayer, client_id);
	CreateTimer(1.3, Timer_SlapPlayer, client_id);
	CreateTimer(1.6, Timer_SlapPlayer, client_id);
	CreateTimer(1.9, Timer_KillPlayer, client_id);

	return Plugin_Handled;
}

public Action Timer_SlapPlayer(Handle timer, any client_id) {
	SlapPlayer(client_id, 0);
}

public Action Timer_KillPlayer(Handle timer, any client_id) {
	ForcePlayerSuicide(client_id);
}
