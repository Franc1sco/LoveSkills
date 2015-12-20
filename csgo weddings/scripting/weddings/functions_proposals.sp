/**
 * Adds a proposal made by a client.
 *
 * @param source_name			The name of the proposer.
 * @param source_id				The steam ID of the proposer.
 * @param target_name 			The name of the target.
 * @param target_id				The steam ID of the target.
 * @noreturn
 */ 
addProposal(String:source_name[], String:source_id[], String:target_name[], String:target_id[]) {
	decl String:query[MAX_BUFFER_LENGTH];
	
	if(weddings_db == INVALID_HANDLE) {
		LogError("Unable to connect to database.");
	} else {
		decl String:source_id_temp[MAX_BUFFER_LENGTH];
		decl String:target_id_temp[MAX_BUFFER_LENGTH];
		decl String:source_name_temp[MAX_BUFFER_LENGTH];
		decl String:target_name_temp[MAX_BUFFER_LENGTH];
				
		SQL_EscapeString(weddings_db, source_name, source_name_temp, sizeof(source_name_temp));
		SQL_EscapeString(weddings_db, source_id, source_id_temp, sizeof(source_id_temp));
		SQL_EscapeString(weddings_db, target_name, target_name_temp, sizeof(target_name_temp));
		SQL_EscapeString(weddings_db, target_id, target_id_temp, sizeof(target_id_temp));
		Format(query, sizeof(query), sql_addProposal, source_name_temp, source_id_temp, target_name_temp, target_id_temp);
		SQL_TQuery(weddings_db, Proposal_Add, query);
	}
}


/**
 * Checks whether there are proposals from and to a client.
 *
 * @param client_id				The steam ID of the client.
 * @noreturn
 */
checkProposal(String:client_id[]) {
	decl String:query[MAX_BUFFER_LENGTH];
	
	if(weddings_db == INVALID_HANDLE) {
		LogError("Unable to connect to database.");
	} else {
		new Handle:data = CreateDataPack();
		decl String:client_id_temp[MAX_BUFFER_LENGTH];
		
		SQL_EscapeString(weddings_db, client_id, client_id_temp, sizeof(client_id_temp));
		Format(query, sizeof(query), sql_getAllProposals, client_id_temp, client_id_temp);
		WritePackString(data, client_id);
		ResetPack(data, false);
		SQL_TQuery(weddings_db, Proposal_Check, query, data); 
	}
}


/**
 * Revokes a proposal made by a client.
 *
 * @param source_id				The steam ID of the proposer.
 * @noreturn
 */
revokeProposal(String:source_id[]) {
	decl String:query[MAX_BUFFER_LENGTH];
	
	if(weddings_db == INVALID_HANDLE) {
		LogError("Unable to connect to database.");
	} else {
		decl String:source_id_temp[MAX_BUFFER_LENGTH];
		
		SQL_EscapeString(weddings_db, source_id, source_id_temp, sizeof(source_id_temp));
		Format(query, sizeof(query), sql_deleteProposalsSource, source_id_temp);
		SQL_TQuery(weddings_db, Proposal_Revoke, query);
	}
}


/**
 * Retrieves all proposals made to a client.
 *
 * @param target_id				The steam ID of the client.
 * @noreturn
 */
findProposals(String:target_id[]) {
	decl String:query[MAX_BUFFER_LENGTH];
	
	if(weddings_db == INVALID_HANDLE) {
		LogError("Unable to connect to database.");
	} else {
		new Handle:data = CreateDataPack();
		decl String:target_id_temp[MAX_ID_LENGTH];
		
		SQL_EscapeString(weddings_db, target_id, target_id_temp, sizeof(target_id_temp));
		Format(query, sizeof(query), sql_getProposals, target_id_temp);
		WritePackString(data, target_id);
		ResetPack(data, false);
		SQL_TQuery(weddings_db, Proposals_Find, query, data);
	}
}


/**
 * Retrieves the new name of a client.
 *
 * @param client_name			The old name of the client.
 * @param client_id				The steam ID of the client.
 * @param newName 				String to store the new name of the client.
 * @param update_db				If true, the weddings_proposals table will be updated.
 * @param who					Update mode. 0 : update source, 1 : update target.
 * @noreturn
 */ 
updateProposal(String:client_name[], String:client_id[], String:newName[], update_db, who) {
	decl String:query[MAX_BUFFER_LENGTH];
	
	new client_index = getClientBySteamID(client_id);	
	if(client_index == -1) {
		strcopy(newName, MAX_NAME_LENGTH, client_name);
	} else {
		if(GetClientName(client_index, newName, MAX_NAME_LENGTH) && !StrEqual(newName, client_name) && update_db) {
			if(weddings_db == INVALID_HANDLE) {
				LogError("Unable to connect to database.");
			} else {
				decl String:newName_temp[MAX_BUFFER_LENGTH];
				decl String:client_id_temp[MAX_BUFFER_LENGTH];
				
				SQL_EscapeString(weddings_db, newName, newName_temp, sizeof(newName_temp));
				SQL_EscapeString(weddings_db, client_id, client_id_temp, sizeof(client_id_temp));
				switch(who) {
					case 0 : {
						Format(query, sizeof(query), sql_updateProposalSource, newName_temp, client_id_temp);
					}
					case 1 :{
						Format(query, sizeof(query), sql_updateProposalTarget, newName_temp, client_id_temp);
					}
				}
				SQL_TQuery(weddings_db, Proposal_Update, query);		
			}
		}
	}
}


// Callback for addProposal.
public Proposal_Add(Handle:owner, Handle:handle, const String:error[], any:data) {
	if(handle == INVALID_HANDLE) {
		LogError("Error adding proposal to database. (%s)", error);
	}
}


// Callback for checkProposal.
public Proposal_Check(Handle:owner, Handle:handle, const String:error[], any:data) {
	if(handle == INVALID_HANDLE) {
		LogError("Error checking proposals in database. (%s)", error);
	} else {
		new client;
		new source;
		decl String:client_id[MAX_ID_LENGTH];
		decl String:client_name[MAX_ID_LENGTH];
		decl String:temp_name[MAX_NAME_LENGTH];
		decl String:other_name[MAX_NAME_LENGTH];
		decl String:other_id[MAX_ID_LENGTH];
		
		ReadPackString(data, client_id, sizeof(client_id));
		CloseHandle(data);
		client = getClientBySteamID(client_id);
		if(client != -1 && GetClientName(client, client_name, sizeof(client_name))) {
			proposal_slots[client] = -2;
			proposal_names[client] = "";
			proposal_ids[client] = "";
			while(SQL_FetchRow(handle)) {
				SQL_FetchString(handle, 1, other_id, sizeof(other_id));
				if(StrEqual(client_id, other_id)) {
					SQL_FetchString(handle, 2, temp_name, sizeof(temp_name));
					SQL_FetchString(handle, 3, other_id, sizeof(other_id));
					updateProposal(temp_name, other_id, other_name, true, 1);
					proposal_slots[client] = getClientBySteamID(other_id);
					proposal_names[client] = other_name;
					proposal_ids[client] = other_id;				
				} else {
					SQL_FetchString(handle, 0, temp_name, sizeof(temp_name));
					updateProposal(temp_name, other_id, other_name, true, 0);
					source = getClientBySteamID(other_id);
					if(source != -1) {
						proposal_slots[source] = client;
						proposal_names[source] = client_name;
						proposal_ids[source] = client_id;
					}
				}
			}									
			proposal_checked[client] = true;
			proposal_beingChecked[client] = false;
		}
	}
}


// Callback for revokeProposal.
public Proposal_Revoke(Handle:owner, Handle:handle, const String:error[], any:data) {
	if(handle == INVALID_HANDLE) {
		LogError("Error revoking proposal in databse. (%s)", error);
	}
}


// Callback for findProposals.
public Proposals_Find(Handle:owner, Handle:handle, const String:error[], any:data) {
	if(handle == INVALID_HANDLE) {
		LogError("Error finding proposals in database. (%s)", error);
	} else {
		new client;
		decl String:client_id[MAX_ID_LENGTH];
		
		ReadPackString(data, client_id, sizeof(client_id));
		CloseHandle(data);
		client = getClientBySteamID(client_id);
		if(client != -1) {
			if(SQL_GetRowCount(handle) == 0) {
				PrintToChat(client, " [LOVE] %t", "no proposals");
			} else {
				decl String:newName[MAX_NAME_LENGTH];
				decl String:source_name[MAX_NAME_LENGTH];
				decl String:source_id[MAX_ID_LENGTH];
				new Handle:proposals_menu = CreateMenu(ProposalsMenuHandler, MENU_ACTIONS_DEFAULT);
				
				SetMenuTitle(proposals_menu, "%t", "!proposals menu title");
				while(SQL_FetchRow(handle)) {
					SQL_FetchString(handle, 0, source_name, sizeof(source_name));
					SQL_FetchString(handle, 1, source_id, sizeof(source_id));
					updateProposal(source_name, source_id, newName, true, 0);
					AddMenuItem(proposals_menu, source_id, newName);
				}
				DisplayMenu(proposals_menu, client, MAX_MENU_DISPLAY_TIME);
			}
		}
	}
}


// Callback for updateProposal.
public Proposal_Update(Handle:owner, Handle:handle, const String:error[], any:data) {
	if(handle == INVALID_HANDLE) {
		LogError("Error updating proposal in database. (%s)", error);
	}
}