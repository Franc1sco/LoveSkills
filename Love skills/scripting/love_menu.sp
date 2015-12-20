#pragma semicolon 1
#include <sourcemod>
#include <sdktools>


public Plugin:myinfo =
{
	name = "SM Love Menu",
	author = "Franc1sco Steam: franug",
	description = "",
	version = "1.0",
	url = "http://www.zeuszombie.com/"
};


public OnPluginStart()
{
	RegConsoleCmd("sm_love", DOMenu);
}

public Action:DOMenu(client,args)
{
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Love menu by Franug");
	AddMenuItem(menu, "sm_loveskills", "Weddings Skills");
	AddMenuItem(menu, "sm_marry", "Marry");
	AddMenuItem(menu, "sm_revoke", "Revoke");
	AddMenuItem(menu, "sm_proposals", "Proposals");
	AddMenuItem(menu, "sm_divorce", "Divorce");
	AddMenuItem(menu, "sm_couples", "Couples");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		
		FakeClientCommand(client, info);
		
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}