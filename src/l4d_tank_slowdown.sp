#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

const TANK_ZOMBIE_CLASS = 8;

new iTankClient = -1;

new Handle:cvar_tankSlowdown;

public Plugin:myinfo = {
    name        = "L4D2 Remove Tank Slowdown",
    author      = "Jahze",
    version     = "0.2",
    description = "Removes the slow down from tanks and some other buffs"
};

public OnPluginStart() {
    cvar_tankSlowdown = CreateConVar("l4d_tank_slowdown", "1", "Enables/disables removal of the slow down that weapons to do tanks", FCVAR_PLUGIN);
    HookConVarChange(cvar_tankSlowdown, TankSlowdownChange);
    
    PluginEnable();
}

PluginEnable() {
    HookEvent("tank_spawn", TankSpawnSlowdown);
}

PluginDisable() {
    UnhookEvent("tank_spawn", TankSpawnSlowdown);
}

public TankSlowdownChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if ( StringToInt(newValue) == 0 ) {
        PluginDisable();
    }
    else {
        PluginEnable();
    }
}

public Action:TankSpawnSlowdown( Handle:event, const String:name[], bool:dontBroadcast ) {
    iTankClient = GetClientOfUserId(GetEventInt(event, "userid"));
    HookEvent("player_hurt", TankHurtSlowdown);
    SetConVarInt(GetConVar("sv_tankpropfade"), 0);
}

public Action:TankHurtSlowdown( Handle:event, const String:name[], bool:dontBroadcast ) {
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    
    if ( !IsTank(iTankClient) ) {
        iTankClient = FindTank();
        
        if ( iTankClient < 0 ) {
            UnhookEvent("player_hurt", TankHurtSlowdown);
            SetConVarInt(GetConVar("sv_tankpropfade"), 1);
            return;
        }
    }
    
    if ( victim != iTankClient ) {
        return;
    }
    
    SetEntPropFloat(iTankClient, Prop_Send, "m_flVelocityModifier", 1.0); 
}

FindTank() {
    for ( new i = 1; i <= MaxClients; i++ ) {
        if ( IsTank(i) ) {
            return i;
        }
    }
    
    return -1;
}

bool:IsTank( client ) {
    if ( client < 0
    || !IsClientConnected(client)
    || !IsClientInGame(client)
    || GetClientTeam(client) != 3
    || !IsPlayerAlive(client) ) {
        return false;
    }
    
    new playerClass = GetEntProp(client, Prop_Send, "m_zombieClass");
    
    if ( playerClass == TANK_ZOMBIE_CLASS ) {
        return true;
    }
    
    return false;
}

