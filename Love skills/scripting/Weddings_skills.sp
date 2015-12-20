#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <weddings>
#include <zombiereloaded>
#include <cstrike>


new g_BeamSprite;
new g_HaloSprite;
//new g_iAccount = -1;


//new bool:money[MAXPLAYERS+1];
new bool:beacon[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "SM Weddings skills",
	author = "Franc1sco Steam: franug",
	description = "",
	version = "2.0",
	url = "http://www.zeuszombie.com/"
};

public OnPluginStart()
{
	CreateConVar("sm_weddings_skills", "1.0", "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	RegConsoleCmd("sm_loveskills", TheLove);
	
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPostAdminCheck(i);
}

public OnClientPostAdminCheck(client)
{
	//money[client] = true;
	beacon[client] = true;
}

public OnMapStart()
{
	g_BeamSprite = PrecacheModel("materials/sprites/bomb_planted_ring.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo.vtf");

	CreateTimer(1.0, Temporizador, _,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	//g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
}

public Action:Temporizador(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			new casado = GetPartnerSlot(i);
			if(casado < 1 || !IsClientInGame(casado) || !IsPlayerAlive(casado)) continue;
			
			if(beacon[i]) SetupBeacon(i, casado);
			//SharedMoney(i, casado);
				
		}
}

SetupBeacon(client, married)
{
	new Float:vec[3];
	GetClientAbsOrigin(married, vec);
	vec[2] += 10;
	TE_SetupBeamRingPoint(vec, 10.0, 375.0, g_BeamSprite, g_HaloSprite, 0, 15, 0.5, 5.0, 0.0, {247, 191, 190, 255}, 10, 0);
	TE_SendToClient(client);
}

/* SharedMoney(client, married)
{
	if(!money[client] || !money[married]) return;
	
	new dinerototal = ObtenerDinero(client) + ObtenerDinero(married);
	dinerototal /= 2;
	FijarDinero(client, dinerototal);
	FijarDinero(married, dinerototal);
}

stock ObtenerDinero(client)
{
	new dinero = GetEntData(client, g_iAccount);
	return dinero;
}

stock FijarDinero(client, cantidad)
{
	SetEntData(client, g_iAccount, cantidad);
} */

public Action:TheLove(client,args)
{
	if(GetPartnerSlot(client) > 0)
		DID(client);
	else
		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05You need to be married and your love in the server for use this command");
		
	return Plugin_Handled;
}

Teleportar(client, casado)
{
	if(!IsClientInGame(casado) || !IsPlayerAlive(client) || !IsPlayerAlive(casado) || !ZR_IsClientHuman(client) || !ZR_IsClientHuman(casado))
	{
		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05You and your love need to be alive and human");
		return;
	}

	decl Float:ang[3], Float:vec[3];
	GetClientAbsAngles(casado, ang);
	GetClientAbsOrigin(casado, vec);
	
	TeleportEntity(client, vec, ang, NULL_VECTOR);
	
	PrintToChat(client, " \x04[SM_Weddings-Skills] \x05You has been teleported to your love");


}

Sacrificio(client, casado)
{
	if(!IsClientInGame(casado) || !IsPlayerAlive(client) || !IsPlayerAlive(casado))
	{
		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05You and your love need to be alive");
		return;
	}
	
	if(ZR_IsClientHuman(client) && ZR_IsClientZombie(casado))
	{
		decl Float:ang[3], Float:vec[3];
		GetClientAbsAngles(client, ang);
		GetClientAbsOrigin(client, vec);
		
/* 		decl Float:ang2[3], Float:vec2[3];
		GetClientAbsAngles(casado, ang2);
		GetClientAbsOrigin(casado, vec2); */
		
		ForcePlayerSuicide(client);
		CS_RespawnPlayer(casado);
		
		
		TeleportEntity(casado, vec, ang, NULL_VECTOR);
		//TeleportEntity(client, vec2, ang2, NULL_VECTOR);
		
	
		PrintToChat(casado, " \x04[SM_Weddings-Skills] \x05Your love has been dead for save you");

		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05You has been sacrificed for save to your love of infection");
		
	}
	else PrintToChat(client, " \x04[SM_Weddings-Skills] \x05You need to be human and your love zombie for use it");


}

public Action:DID(clientId) 
{
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Weddings Skills");
/* 	if(money[clientId]) AddMenuItem(menu, "option1", "Disable shared money");
	else AddMenuItem(menu, "option1", "Enable shared money"); */
	
	if(beacon[clientId]) AddMenuItem(menu, "option2", "Disable beacon in your love");
	else AddMenuItem(menu, "option2", "Enable beacon in your love");
	
	AddMenuItem(menu, "option3", "Teleport to your love position");
	AddMenuItem(menu, "option4", "Sacrifice for your love");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, clientId, MENU_TIME_FOREVER);

}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new casado = GetPartnerSlot(client);
		if(casado < 1)
		{
			PrintToChat(client, " \x04[SM_Weddings-Skills] \x05You need to be married for use this command");
			return;
		}
		
		new String:info[32];
        
		GetMenuItem(menu, itemNum, info, sizeof(info));
        
/* 		if ( strcmp(info,"option1") == 0 ) 
		{
			if(money[client])
			{
				money[client] = false;
				PrintToChat(client, " \x04[SM_Weddings-Skills] \x05Shared money disabled");
			}
			else
			{
				money[client] = true;
				PrintToChat(client, " \x04[SM_Weddings-Skills] \x05Shared money enabled");
			}
			DID(client);
		} */
        
		if ( strcmp(info,"option2") == 0 ) 
		{
			if(beacon[client])
			{
				beacon[client] = false;
				PrintToChat(client, " \x04[SM_Weddings-Skills] \x05Beacon in your love disabled");
			}
			else
			{
				beacon[client] = true;
				PrintToChat(client, " \x04[SM_Weddings-Skills] \x05Beacon in your love enabled");
			}
			DID(client);
		}
		else if ( strcmp(info,"option3") == 0 ) 
		{
			Teleportar(client, casado);
		}
		else if ( strcmp(info,"option4") == 0 ) 
		{
			Sacrificio(client, casado);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
