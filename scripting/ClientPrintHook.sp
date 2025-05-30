#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <dhooks>

public Plugin myinfo = {
    name = "Client Print Hook",
    author = "koen",
    description = "Proof of concept plugin for hooking \"ClientPrint\" function in vscript for CS:S",
    version = "",
    url = ""
};

DHookSetup g_hClientPrintDtr;

public void OnPluginStart() {
    GameData gd;
    if ((gd = new GameData("ClientPrintHook.games")) == null) {
        LogError("[ClientPrintHook] gamedata file not found or failed to load");
        delete gd;
        return;
    }

    if ((g_hClientPrintDtr = DynamicDetour.FromConf(gd, "ClientPrint")) == null) {
        LogError("[ClientPrintHook] Failed to setup ClientPrint detour!");
        delete gd;
        return;
    } else {
        if (!DHookEnableDetour(g_hClientPrintDtr, false, Detour_ClientPrint)) {
            LogError("[ClientPrintHook] Failed to detour ClientPrint()");
        } else {
            LogMessage("[ClientPrintHook] Successfully detoured ClientPrint()");
        }
    }
}

public MRESReturn Detour_ClientPrint(Handle hParams) {
    // From https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions
    // void ClientPrint(CBasePlayer player, EHudNotify destination, string message)
    // CBasePlayer player and EHudNotify are int
    PrintToChatAll("-------------------------[ Detour_ClientPrint ]-------------------------");

    // Get player num
    int iPlayer = DHookGetParam(hParams, 1);
    PrintToChatAll("CBasePlayer player = %i", iPlayer);

    // Get display method
    char sBuffer[512];
    int iDestination = DHookGetParam(hParams, 2);
    PrintToChatAll("EHudNotify destination = %i", iDestination);

    // Get string
    // We add "\x01" in front so hex codes/chat messages are rendered properly
    // Why? I don't know. Source engine spaghetti :shrug:
    DHookGetParamString(hParams, 3, sBuffer, sizeof(sBuffer));
    PrintToChatAll("\x01string message: %s", sBuffer);
    PrintToChatAll("-------------------------------------------------------------------------");
    return MRES_Supercede;
}