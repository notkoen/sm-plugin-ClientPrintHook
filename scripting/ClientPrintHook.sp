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

DynamicDetour g_hClientPrintDtr;

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
        if (!g_hClientPrintDtr.Enable(Hook_Pre, Detour_ClientPrint)) {
            LogError("[ClientPrintHook] Failed to detour ClientPrint()");
        } else {
            LogMessage("[ClientPrintHook] Successfully detoured ClientPrint()");
        }
    }
}

public MRESReturn Detour_ClientPrint(DHookParam hParams) {
    // From https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions
    // void ClientPrint(CBasePlayer player, EHudNotify destination, string message)
    // CBasePlayer player and EHudNotify are int
    PrintToChatAll("-------------------------[ Detour_ClientPrint ]-------------------------");

    // Get player num
    int iPlayer = hParams.Get(1);
    PrintToChatAll("CBasePlayer player = %i", iPlayer);

    // Get display method
    int iDestination = hParams.Get(2);
    PrintToChatAll("EHudNotify destination = %i", iDestination);

    // Get string
    // We add "\x01" in front so hex codes/chat messages are rendered properly
    // Why? I don't know. Source engine spaghetti :shrug:
    char sBuffer[512];
    hParams.GetString(3, sBuffer, sizeof(sBuffer));
    PrintToChatAll("\x01string message: %s", sBuffer);
    PrintToChatAll("-------------------------------------------------------------------------");
    return MRES_Supercede;
}