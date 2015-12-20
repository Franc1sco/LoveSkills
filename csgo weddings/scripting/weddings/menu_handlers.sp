// Handler for the !marry menu.
public MarryMenuHandler(Handle:marry_menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_Select : {
			new target; 
			decl String:source_id[MAX_ID_LENGTH];
			decl String:target_id[MAX_ID_LENGTH];
			decl String:source_name[MAX_NAME_LENGTH];
			decl String:target_name[MAX_NAME_LENGTH];
			
			GetMenuItem(marry_menu, param2, target_id, sizeof(target_id));
			if(GetClientName(param1, source_name, sizeof(source_name)) && GetClientAuthString(param1, source_id, sizeof(source_id))) {
				target = getClientBySteamID(target_id);
				if(target != -1 && GetClientName(target, target_name, sizeof(target_name))) {
					if(marriage_slots[target] == -2) {					
						if(proposal_slots[target] != param1) {												
							addProposal(source_name, source_id, target_name, target_id);
							forwardProposal(param1, target);
							cacheUsage(source_id);
							PrintToChat(param1, " [LOVE] %t", 	"submission info");
							CPrintToChat(target, " [LOVE] %t", "proposal notification", source_name);
							PrintToChat(target, " [LOVE] %t", "proposal info");
							proposal_slots[param1] = target;
							proposal_names[param1] = target_name;
							proposal_ids[param1] = target_id;
						} else {
							CPrintToChat(param1, " [LOVE] %t", "bidirectional proposal", target_name);
							PrintToChat(param1, " [LOVE] %t", "proposal info");
						}
					} else {
						PrintToChat(param1, " [LOVE] %t", "love already married");
					}
				} else {
					PrintToChat(param1, " [LOVE] %t", "target not on server");
				}
			}
		}
		case MenuAction_End : {
			CloseHandle(marry_menu);
		}
	}
	return 0;
}


// Handler for the !proposals menu.
public ProposalsMenuHandler(Handle:proposals_menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_Select : {
			new time;
			new source;
			decl String:source_id[MAX_ID_LENGTH];
			decl String:source_name[MAX_NAME_LENGTH];	
			
			GetMenuItem(proposals_menu, param2, source_id, sizeof(source_id));
			source = getClientBySteamID(source_id);
			if(source != -1 && GetClientName(source, source_name, sizeof(source_name))) {
				if(marriage_slots[source] == -2) {				
					addMarriage(source_name, source_id, proposal_names[source], proposal_ids[source]);
					forwardWedding(source, param1);
					cacheUsage(proposal_ids[source]);						
					CPrintToChat(param1, " [LOVE] %t", "got married", source_name);
					CPrintToChat(source, " [LOVE] %t", "proposal accepted", proposal_names[source]);
					CPrintToChatAll(" [LOVE] %t", "marriage notification", source_name, proposal_names[source]);						
					time = GetTime();
					marriage_slots[source] = param1;
					marriage_names[source] = proposal_names[source];
					marriage_ids[source] = proposal_ids[source];
					marriage_scores[source] = 0;
					marriage_times[source] = time;						
					marriage_slots[param1] = source;						
					marriage_names[param1] = source_name;						
					marriage_ids[param1] = source_id;						
					marriage_scores[param1] = 0;
					marriage_times[param1] = time;	
					proposal_slots[source] = -2;
					proposal_names[source] = "";
					proposal_ids[source] = "";
					proposal_slots[param1] = -2;
					proposal_names[param1] = "";
					proposal_ids[param1] = "";
					for(new i = 1; i <= MaxClients; i++) {
						if(proposal_slots[i] == source || proposal_slots[i] == param1) {
							proposal_slots[i] = -2;
							proposal_names[i] = "";
							proposal_ids[i] = "";
						}						
					}																									
				} else {
					PrintToChat(param1, " [LOVE] %t", "love already married");
				}
			} else {
				PrintToChat(param1, " [LOVE] %t", "proposer not on server");
			}
		} 
		case MenuAction_End : {
			CloseHandle(proposals_menu);
		}
	}
	return 0;
}


// Handler for the !couples menu.
public CouplesMenuHandler(Handle:couples_menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End : {
			CloseHandle(couples_menu);
		}
	}
	return 0;
}