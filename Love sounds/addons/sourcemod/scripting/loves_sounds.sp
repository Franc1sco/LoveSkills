#include <sourcemod>
#include <sdktools>
#include <weddings>
#include <emitsoundany>

public Plugin:myinfo =
{
	name = "SM Weddings Sounds",
	author = "Franc1sco Steam: franug",
	description = "",
	version = "1.0",
	url = "http://servers-cfg.foroactivo.com/"
};

public OnMapStart()
{
	AddFileToDownloadsTable("sound/franug/love_incoming.mp3");
	AddFileToDownloadsTable("sound/franug/love_wins.mp3");
	
	PrecacheSoundAny("franug/love_incoming.mp3");
	PrecacheSoundAny("franug/love_wins.mp3");
}


public OnProposal(proposer, target)
{
	EmitSoundToClientAny(proposer, "franug/love_incoming.mp3");
	EmitSoundToClientAny(target, "franug/love_incoming.mp3");
}

public OnWedding(proposer, accepter)
{
	EmitSoundToAllAny("franug/love_wins.mp3");
}