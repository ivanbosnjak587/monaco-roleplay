// =======================================//
/* 

    __  _______  _   _____   __________ 
   /  |/  / __ \/ | / /   | / ____/ __ |
  / /|_/ / / / /  |/ / /| |/ /   / / / /
 / /  / / /_/ / /|  / ___ / /___/ /_/ / 
/_/  /_/\____/_/ |_/_/  |_\____/\____/  
                                        
  ___  ___  _    ___ ___ _      ___   __
 | _ \/ _ \| |  | __| _ \ |    /_\ \ / /
 |   / (_) | |__| _||  _/ |__ / _ \ V / 
 |_|_\\___/|____|___|_| |____/_/ \_\_|  
                                        

		Developed by Danis Čavalić (Slade).
		Credits: 
			- realnaith (core - myserver)
			- developers of includes (Y_Less, samp-incognito...)
*/
// =======================================//
//			Main
#define		YSI_YES_HEAP_MALLOC
#define 	CGEN_MEMORY 60000
//			Core Includes
#include 	<a_samp>
#include 	<a_actor>
#include 	<a_objects>
#include 	<a_players>
#include 	<a_vehicles>
#include 	<crashdetect>
#include 	<ysilib\YSI_Coding\y_hooks>
#include 	<ysilib\YSI_Coding\y_va>
#include 	<ysilib\YSI_Core\y_utils.inc>
#include 	<ysilib\YSI_Storage\y_ini>
#include 	<ysilib\YSI_Coding\y_timers>
#include 	<ysilib\YSI_Visual\y_commands>
#include 	<ysilib\YSI_Data\y_foreach>
#include 	<ysilib\YSI_Data\y_iterate>
#include 	<sscanf2>
#include 	<streamer>
#include 	<mapfix>
#include 	<easyDialog>
#include 	<formatex>
#include 	<distance>
// --------------------------------------------------------------------//
//          Assets
#include 	"utils/main.pwn"
// --------------------------------------------------------------------//
#define	 	SECONDS_TO_LOGIN 		30
#define 	DEFAULT_POS_X 			1958.3783
#define 	DEFAULT_POS_Y 			1343.1572
#define 	DEFAULT_POS_Z 			15.3746
#define 	DEFAULT_POS_A 			270.1425
const 		MAX_PASSWORD_LENGTH 	= 64;
const 		MIN_PASSWORD_LENGTH 	= 6;
const 		MAX_LOGIN_ATTEMPTS 		= 3;

enum E_PLAYERS
{
	ORM: ORM_ID,

	ID,
	Name[MAX_PLAYER_NAME],
	Registered,
	Password[65],
	Salt[17],
	Email[50],
	AdminLevel,
	CharGender,
	Skin,
	FightStyle,
	Money,
	BankMoney,
	Kills,
	Deaths,
	Float: X_Pos,
	Float: Y_Pos,
	Float: Z_Pos,
	Float: A_Pos,
	Interior,

	bool: IsLoggedIn,
	LoginAttempts,
	LoginTimer
};
new Player[MAX_PLAYERS][E_PLAYERS],
	g_MysqlRaceCheck[MAX_PLAYERS];

stock GetStaffRankName( rank_level ) {
	new rank_name[15];
	switch(rank_level) {
		case 1: form:rank_name("Server Moderator");
		case 2: form:rank_name("Administrator");
		case 3: form:rank_name("Lead Administrator");
		case 4: form:rank_name("Manager");
	}
	return rank_name;
}

bool:Auth(playerid, level) {
	if (Player[playerid][AdminLevel] >= level) return true;
	else return false;
}
// --------------------------------------------------------------------//
//			Backend
#include 	"backend/vehicles/vehicles_handler.pwn"
//			Frontend
#include 	"client/account/register_char.pwn"
//			Frontend (UI)
#include 	"client/ui/login_gui.pwn"
// --------------------------------------------------------------------//

main()
{
    print("-                                     -");
	print(" Founder : Danis Cavalic (Slade)");
	print(" "server_name" : "server_version"");
	print(" Credits : realnaith (myserver) ");
	print("-                                     -");
}

#define PRESSED(%0) \
    ( newkeys & %0 == %0 && oldkeys & %0 != %0 )

public OnGameModeInit()
{
	DisableInteriorEnterExits();
	ManualVehicleEngineAndLights();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	SetNameTagDrawDistance(20.0);
	LimitGlobalChatRadius(20.0);
	AllowInteriorWeapons(1);
	EnableVehicleFriendlyFire();
	EnableStuntBonusForAll(0);

	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

	return 1;
}

public OnPlayerConnect(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	SetPlayerColor(playerid, x_white);
	LoadPlayer(playerid);

	return 1;
}

LoadPlayer(playerid) {
	g_MysqlRaceCheck[playerid]++;

	static const empty_player[E_PLAYERS];
	Player[playerid] = empty_player;

	GetPlayerName(playerid, Player[playerid][Name], MAX_PLAYER_NAME);

	new ORM: ormid = Player[playerid][ORM_ID] = orm_create("players", Database);

	orm_addvar_int(ormid, Player[playerid][ID], "id");
	orm_addvar_string(ormid, Player[playerid][Name], MAX_PLAYER_NAME, "username");
	orm_addvar_string(ormid, Player[playerid][Password], 65, "password");
	orm_addvar_string(ormid, Player[playerid][Salt], 17, "salt");
	orm_addvar_string(ormid, Player[playerid][Email], 50, "email");
	orm_addvar_int(ormid, Player[playerid][Registered], "registered");
	orm_addvar_int(ormid, Player[playerid][AdminLevel], "admin");
	orm_addvar_int(ormid, Player[playerid][CharGender], "chargender");
	orm_addvar_int(ormid, Player[playerid][FightStyle], "fightstyle");
	orm_addvar_int(ormid, Player[playerid][Skin], "skin");
	orm_addvar_int(ormid, Player[playerid][Money], "money");
	orm_addvar_int(ormid, Player[playerid][BankMoney], "bankmoney");
	orm_addvar_int(ormid, Player[playerid][Kills], "kills");
	orm_addvar_int(ormid, Player[playerid][Deaths], "deaths");
	orm_addvar_float(ormid, Player[playerid][X_Pos], "x");
	orm_addvar_float(ormid, Player[playerid][Y_Pos], "y");
	orm_addvar_float(ormid, Player[playerid][Z_Pos], "z");
	orm_addvar_float(ormid, Player[playerid][A_Pos], "angle");
	orm_addvar_int(ormid, Player[playerid][Interior], "interior");
	orm_setkey(ormid, "username");

	orm_load(ormid, "OnPlayerDataLoaded", "dd", playerid, g_MysqlRaceCheck[playerid]);
}

public OnPlayerDisconnect(playerid, reason)
{
	OnPlayerExitCleanup(playerid, reason);
	return 1;
}

// ====================================================================================================================== //

OnPlayerExitCleanup(playerid, reason) {
	g_MysqlRaceCheck[playerid]++;

	UpdatePlayerData(playerid, reason);
	if (Player[playerid][LoginTimer])
	{
		KillTimer(Player[playerid][LoginTimer]);
		Player[playerid][LoginTimer] = 0;
	}
	Player[playerid][IsLoggedIn] = false;
}

forward OnPlayerDataLoaded(playerid, race_check);
public OnPlayerDataLoaded(playerid, race_check)
{
	if (race_check != g_MysqlRaceCheck[playerid]) return Kick(playerid);

	ClearChat(playerid, 50);

	orm_setkey(Player[playerid][ORM_ID], "id");
	switch (orm_errno(Player[playerid][ORM_ID]))
	{
		// login - account postoji
		case ERROR_OK:
		{
			TogglePlayerSpectating(playerid, true);
			InterpolateCameraPos(playerid, 1175.634521, -1394.490844, 194.949890, 1425.817138, -1619.597900, 128.609146, 30000);
			InterpolateCameraLookAt(playerid, 1177.622558, -1390.000000, 194.011642, 1430.231689, -1621.545532, 127.297996, 30000);
			ToggleWrapperGUI(playerid, true);

			Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD, server_dialog_header,
				""c_torq"Dobrodosao %s nazad na "server_dialog_header" "c_torq"RolePlay.\n\n{FFFFFF}Unesite lozinku racuna za nastavak igre:",
				"Prijava", "Izlaz", 
				PlayerNameEx(playerid)
			);

			Player[playerid][LoginTimer] = SetTimerEx("OnLoginTimeout", SECONDS_TO_LOGIN * 1000, false, "d", playerid);
		}
		// register - account ne postoji
		case ERROR_NO_DATA:
		{
			if (!IsValidRolePlayName(ReturnPlayerName(playerid))) {
				Server(playerid, "Greska u povezivanju: Vase ime nije u RolePlay formatu.");
				DelayedKick(playerid);
			}
			else {
				TogglePlayerSpectating(playerid, true);
				InterpolateCameraPos(playerid, 2510.893554, -1438.940917, 38.034278, 2513.375000, -1244.077636, 47.519313, 30000);
				InterpolateCameraLookAt(playerid, 2510.830078, -1443.934570, 37.791206, 2513.311523, -1249.071289, 47.276241, 30000);
				ToggleWrapperGUI(playerid, true);

				Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT, server_dialog_header,
				//
					""c_torq"Pozdrav %s, dobrodosli na "server_dialog_header" "c_torq"RolePlay.\n\n\
					{FFFFFF}Za pocetak unesite lozinku koju cete koristiti za prijavljivanje:",
				//
					"Potvrdi", "Izlaz", 
					PlayerNameEx(playerid)
				);
			}
		}
	}
	return 1;
}

forward OnLoginTimeout(playerid);
public OnLoginTimeout(playerid)
{
	// reset the variable that stores the timerid
	Player[playerid][LoginTimer] = 0;
	DelayedKick(playerid);
	return 1;
}

forward _KickPlayerDelayed(playerid);
public _KickPlayerDelayed(playerid)
{
	Kick(playerid);
	return 1;
}

DelayedKick(playerid, time = 500)
{
	SetTimerEx("_KickPlayerDelayed", time, false, "d", playerid);
	return 1;
}

SetupPlayerTable()
{
	mysql_tquery(Database, "CREATE TABLE IF NOT EXISTS `players` (`id` int(11) NOT NULL AUTO_INCREMENT,`username` varchar(24) NOT NULL,`password` char(64) NOT NULL,`salt` char(16) NOT NULL,`kills` mediumint(8) NOT NULL DEFAULT '0',`deaths` mediumint(8) NOT NULL DEFAULT '0',`x` float NOT NULL DEFAULT '0',`y` float NOT NULL DEFAULT '0',`z` float NOT NULL DEFAULT '0',`angle` float NOT NULL DEFAULT '0',`interior` tinyint(3) NOT NULL DEFAULT '0', PRIMARY KEY (`id`), UNIQUE KEY `username` (`username`))");
	return 1;
}

UpdatePlayerData(playerid, reason = 1)
{
	if (Player[playerid][IsLoggedIn] == false) return 0;

	// if the client crashed, it's not possible to get the player's position in OnPlayerDisconnect callback
	// so we will use the last saved position (in case of a player who registered and crashed/kicked, the position will be the default spawn point)
	if (reason == 1)
	{
		GetPlayerPos(playerid, Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos]);
		GetPlayerFacingAngle(playerid, Player[playerid][A_Pos]);
	}

	// it is important to store everything in the variables registered in ORM instance
	Player[playerid][Interior] = GetPlayerInterior(playerid);

	// orm_save sends an UPDATE query
	orm_save(Player[playerid][ORM_ID]);
	orm_destroy(Player[playerid][ORM_ID]);
	return 1;
}

UpdatePlayerDeaths(playerid)
{
	if (Player[playerid][IsLoggedIn] == false) return 0;

	Player[playerid][Deaths]++;

	orm_update(Player[playerid][ORM_ID]);
	return 1;
}

UpdatePlayerKills(killerid)
{
	// we must check before if the killer wasn't valid (connected) player to avoid run time error 4
	if (killerid == INVALID_PLAYER_ID) return 0;
	if (Player[killerid][IsLoggedIn] == false) return 0;

	Player[killerid][Kills]++;

	orm_update(Player[killerid][ORM_ID]);
	return 1;
}

// ====================================================================================================================== //

public OnPlayerSpawn(playerid)
{
	SetPlayerTeam(playerid, NO_TEAM);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	UpdatePlayerDeaths(playerid);
	UpdatePlayerKills(killerid);

	return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
	ToggleWrapperGUI(playerid, false);
	StartCharacterRegistration(playerid);
	return 1;
}

Dialog: dialog_regpassword(playerid, response, listitem, string: inputtext[])
{
	if (!response) return Kick(playerid);

	if (strlen(inputtext) <= 5) return Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT, server_dialog_header,
										//
											""c_torq"Pozdrav %s, dobrodosli na "server_dialog_header" "c_torq"RolePlay.\n\n\
											{FFFFFF}Za pocetak unesite lozinku koju cete koristiti za prijavljivanje:",
										//
											"Potvrdi", "Izlaz", 
											PlayerNameEx(playerid)
										);

	for (new i = 0; i < 16; i++) Player[playerid][Salt][i] = random(94) + 33;
	SHA256_PassHash(inputtext, Player[playerid][Salt], Player[playerid][Password], 65);

	Player[playerid][Registered] = 0;

	Dialog_Show(playerid, "dialog_regmail", DIALOG_STYLE_INPUT, server_dialog_header,
	//
		""c_torq"Odlicno %s, vas racun je registriran sa unesenom lozinkom.\n\
		Koristite ovo ime kako biste se logirali na vas racun u buducnosti.\n\n\
		{FFFFFF}Sada unesite validnu e-mail adresu koju ce koristiti vas racun:",
	//
		"Potvrdi", "Izlaz", 
		PlayerNameEx(playerid)
	);

	return 1;
}

Dialog: dialog_regmail(playerid, response, listitem, string: inputtext[])
{
	if (!response) return Kick(playerid);

	if (strlen(inputtext) <= 5) return Dialog_Show(playerid, "dialog_regmail", DIALOG_STYLE_INPUT, server_dialog_header,
										//
											""c_red"Unesena e-mail adresa nije validnog formata.\n\
											Za validaciju racuna, kao i za resetiranje postavki potrebno je podesiti ispravnu adresu.\n\n\
											{FFFFFF}Unesite ispravnu e-mail adresu:",
										//
											"Potvrdi", "Izlaz"
										);

	if (!IsValidEmail(inputtext)) return Dialog_Show(playerid, "dialog_regmail", DIALOG_STYLE_INPUT, server_dialog_header,
										//
											""c_red"Unesena e-mail adresa nije validnog formata.\n\
											Za validaciju racuna, kao i za resetiranje postavki potrebno je podesiti ispravnu adresu.\n\n\
											{FFFFFF}Unesite ispravnu e-mail adresu:",
										//
											"Potvrdi", "Izlaz"
										);

	// EMAIL setter
	format(Player[playerid][Email], _, "%s", inputtext);

	// INSERT korisnika
	orm_save(Player[playerid][ORM_ID], "OnPlayerRegister", "d", playerid);

	return 1;
}

Dialog: dialog_login(const playerid, response, listitem, string: inputtext[])
{
	if (!response) return Kick(playerid);

	new hashed_pass[65];
	SHA256_PassHash(inputtext, Player[playerid][Salt], hashed_pass, 65);

	if (strcmp(hashed_pass, Player[playerid][Password]) == 0)
	{
		ToggleWrapperGUI(playerid, false);
		KillTimer(Player[playerid][LoginTimer]);
		Player[playerid][LoginTimer] = 0;
		if(Player[playerid][Registered] == 1) LogPlayer(playerid);
		else StartCharacterRegistration(playerid);
	}
	else
	{
		Player[playerid][LoginAttempts]++;

		if (Player[playerid][LoginAttempts] >= 3) DelayedKick(playerid);
		else Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD, server_dialog_header,
				""c_red"Niste unijeli ispravnu lozinku (%d/3) za racun %s.\n\n{FFFFFF}Unesite lozinku racuna za nastavak igre:",
				"Prijava", "Izlaz", 
				Player[playerid][LoginAttempts], PlayerNameEx(playerid)
			);
	}

	return 1;
}

LogPlayer(playerid) {
	// player init
	TogglePlayerSpectating(playerid, false);
	Player[playerid][IsLoggedIn] = true;
	SetSpawnInfo(playerid, NO_TEAM, Player[playerid][Skin], Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos], Player[playerid][A_Pos], 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	// set values
	GivePlayerMoney(playerid, Player[playerid][Money]);
	SetPlayerSkin(playerid, Player[playerid][Skin]);
	SetPlayerFightingStyle(playerid, Player[playerid][FightStyle]);

	// notifications
	Blue(playerid, "(prijava) Dobrodosao/la nazad na "server_dialog_header" "c_blue"RolePlay, %s.", PlayerNameEx(playerid));
	Blue(playerid, "(prijava) Vraceni ste na snimljenu poziciju prije posljednjeg izlaska sa servera.");
	if (Auth(playerid, 1)) Server(playerid, "Prijavljeni ste kao %s.", GetStaffRankName(Player[playerid][AdminLevel]));
}

stock IsValidEmail(const email[])
{
	// Email validator: Validira prisutnost tačke i @ simbola.
    new atpos = -1, dotpos = -1;
    for (new i = 0; i < strlen(email); i++)
    {
        if (email[i] == '@')
        {
            atpos = i;
        }
        else if (email[i] == '.' && atpos != -1)
        {
            dotpos = i;
        }
    }
    return (atpos > 0 && dotpos > atpos && dotpos < strlen(email) - 1);
}

stock IsValidRolePlayName(const name[])
{
    new separator_pos = -1;
    for (new i = 0; i < strlen(name); i++)
    {
        if (name[i] == '_')
        {
            separator_pos = i;
            break;
        }
    }
    return (separator_pos > 0 && separator_pos < strlen(name) - 1);
}

stock PlayerNameEx(playerid)
{
	new source[MAX_PLAYER_NAME];
	GetPlayerName(playerid, source, sizeof(source));
    new source_len = strlen(source);
    new target[32];
    new target_pos = 0;
    for (new i = 0; i < source_len && target_pos < sizeof(target) - 1; i++)
    {
        if (source[i] != '_')
        {
            target[target_pos++] = source[i];
        }
    }
    target[target_pos] = EOS;
    return target;
}

ClearChat(playerid, rows = 20) {
	for(new cc; cc < rows; cc++)
	{
		SendClientMessage(playerid, 0x00000000, "");
	}
}

public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
	if(success != COMMAND_OK) {
		Torq(playerid, "(komanda) Unesena komanda ne postoji, koristite '/help' za pomoc oko komandi.");
		return COMMAND_OK;
	}
	return COMMAND_OK;
}

public e_COMMAND_ERRORS:OnPlayerCommandPerformed(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
	if(success != COMMAND_OK) {
		Torq(playerid, "(komanda) Unesena komanda ne postoji, koristite '/help' za pomoc oko komandi.");
		return COMMAND_OK;
	}
	return COMMAND_OK;
}

YCMD:test(playerid, params[], help) 
{
	StartCharacterRegistration(playerid);
	return 1;
}

YCMD:cmdhelp(playerid, params[], help)
{
	if (help)
	{
		Usage(playerid, "Koristite `/cmdhelp [naziv komande]` da dobijete pomoc oko koristenja neke komande.");
	}
	else if (IsNull(params))
	{
		Usage(playerid, "Koristite `/cmdhelp [naziv komande]` da dobijete pomoc oko koristenja neke komande.");
	}
	else
	{
		Command_ReProcess(playerid, params, true);
	}
	return 1;
}


YCMD:staffcmd(playerid, const string: params[], help)
{
	if (!Auth(playerid, 1)) return Error(playerid, NO_AUTH);
	if(help) return CommandHelp(playerid, "Komanda za pregled liste komandi za administratore.");

	Dialog_Show(playerid, "dialog_staffcmd", DIALOG_STYLE_MSGBOX,
		""c_server"myserver // "c_white"Staff Commands",
		""c_white"%s, Vi ste deo naseg "c_server"staff "c_white"tima!\n\
		"c_server"SLVL1 >> "c_white"/sduty\n\
		"c_server"SLVL1 >> "c_white"/sc\n\
		"c_server"SLVL1 >> "c_white"/staffcmd\n\
		"c_server"SLVL1 >> "c_white"/sveh\n\
		"c_server"SLVL1 >> "c_white"/goto\n\
		"c_server"SLVL1 >> "c_white"/cc\n\
		"c_server"SLVL1 >> "c_white"/fv\n\
		"c_server"SLVL2 >> "c_white"/gethere\n\
		"c_server"SLVL3 >> "c_white"/nitro\n\
		"c_server"SLVL4 >> "c_white"/jetpack\n\
		"c_server"SLVL4 >> "c_white"/setskin\n\
		"c_server"SLVL4 >> "c_white"/xgoto\n\
		"c_server"SLVL4 >> "c_white"/spanel\n\
		"c_server"SLVL4 >> "c_white"/setstaff",
		"U redu", "", ReturnPlayerName(playerid)
	);

    return 1;
}

YCMD:sc(playerid, const string: params[], help)
{
	if (!Auth(playerid, 1)) return Error(playerid, NO_AUTH);

	if(help) return CommandHelp(playerid, "Komunikacija izmedju pripadnika administracije servera.");

	if (isnull(params)) return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"/sc [text]");

	static tmp_str[128];

	format(tmp_str, sizeof(tmp_str), "Staff - %s(%d): "c_white"%s", ReturnPlayerName(playerid), playerid, params);

	foreach (new i: Player)
		if (Auth(i, 1))
			SendClientMessage(i, x_ltblue, tmp_str);
	
    return 1;
}

YCMD:goto(playerid, params[],help)
{
	if (!Auth(playerid, 1))
		return Error(playerid, NO_AUTH);

	if(help) return CommandHelp(playerid, "Pomocu ove komande se mozete teleportirati do drugog logiranog igraca.");

	new giveplayerid, giveplayer[MAX_PLAYER_NAME];

	new Float:plx,Float:ply,Float:plz;

	GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));

	if(!sscanf(params, "u", giveplayerid))
	{	
		GetPlayerPos(giveplayerid, plx, ply, plz);
			
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, plx, ply+4, plz);
		}
		else
		{
			SetPlayerPos(playerid,plx,ply+2, plz);
		}
		SetPlayerInterior(playerid, GetPlayerInterior(giveplayerid));
	}
    return 1;
}

YCMD:cc(playerid, params[], help)
{
	if (!Auth(playerid, 1))
		return Error(playerid, NO_AUTH);

	if(help) return CommandHelp(playerid, "Brisanje kompletnog chata svim aktivnim igracima.");

	for(new cc; cc < 110; cc++)
	{
		SendClientMessageToAll(-1, "");
	}
	static fmt_string[120];
	format(fmt_string, sizeof(fmt_string), ""c_server"myproject // "c_white"chat je ocistio"c_server" %s", ReturnPlayerName(playerid));
	SendClientMessageToAll(-1, fmt_string);
    return 1;
}

YCMD:fv(playerid, params[], help)
{
	if (!Auth(playerid, 1))
		return Error(playerid, NO_AUTH);

	if(help) return CommandHelp(playerid, "Pomocu ove komande popravljate vozilo unutar kojeg se nalazite.");

	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Niste u vozilu!");

	RepairVehicle(vehicleid);

	SetVehicleHealth(vehicleid, 999.0);

	return 1;
}
YCMD:gethere(playerid, const params[], help)
{
	if (!Auth(playerid, 1))
		return Error(playerid, NO_AUTH);

	if(help) return CommandHelp(playerid, "Pomocu ove komande mozete prebaciti logiranog igraca do sebe.");

	new targetid = INVALID_PLAYER_ID;

	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"/gethere [id]");

	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, x_server, "myproject // "c_white"Taj ID nije konektovan.");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetPlayerPos(targetid, x+1, y, z+1);

	SetPlayerInterior(targetid, GetPlayerInterior(playerid));

	SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

	new name[MAX_PLAYER_NAME];
	GetPlayerName(targetid, name, sizeof(name));

	static fmt_string[60];

	format(fmt_string, sizeof(fmt_string),""c_server"myproject // "c_white"Teleportovali ste igraca %s do sebe.", name);
	SendClientMessage(playerid, -1, fmt_string);

	GetPlayerName(playerid, name, sizeof(name));

	format(fmt_string, sizeof(fmt_string), ""c_server"myproject // "c_white"Staff %s vas je teleportovao do sebe.", name);
	SendClientMessage(targetid, -1, fmt_string);

    return 1;
}

YCMD:xgoto(playerid, params[], help)
{
	if (!Auth(playerid, 1))
		return Error(playerid, NO_AUTH);

	if(help) return CommandHelp(playerid, "Pomocu ove komande se mozete teleportirati na unesene koordinate.");

	new Float:x, Float:y, Float:z;

	static fmt_string[100];

	if (sscanf(params, "fff", x, y, z)) SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"xgoto <X Float> <Y Float> <Z Float>");
	else
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    SetVehiclePos(GetPlayerVehicleID(playerid), x,y,z);
		}
		else
		{
		    SetPlayerPos(playerid, x, y, z);
		}
		format(fmt_string, sizeof(fmt_string), ""c_server"myproject // "c_white"Postavili ste koordinate na %f, %f, %f", x, y, z);
		SendClientMessage(playerid, x_ltblue, fmt_string);
	}
 	return 1;
}

YCMD:setadminlvl(playerid, params[], help)
{
	if (!Auth(playerid, 4) || !IsPlayerAdmin(playerid)) return Error(playerid, NO_AUTH);
	if (help) return Usage(playerid, "Komanda za operiranje nad administratorskim levelom igraca.");
	new user, level;
	if (sscanf(params, "ui", user, level)) Usage(playerid, "/setadminlvl [ID / Dio Imena] [Admin Level]");
	else {
		Player[user][AdminLevel] = level;
		Server(user, "Administrator %s vam je postavio admin level na %d.", PlayerNameEx(playerid), level);
		Server(playerid, "Postavili ste %s admin level na %d.", PlayerNameEx(playerid), level);
	}
 	return 1;
}

YCMD:createvehicle(playerid, params[], help)
{
	if (!Auth(playerid, 4) || !IsPlayerAdmin(playerid)) return Error(playerid, NO_AUTH);
	if (help) Usage(playerid, "Pretvara administratorsko vozilo u server vozilo datog tipa.");
	if (!IsPlayerInAnyVehicle(playerid)) return Error(playerid, "Niste u vozilu jednokratne upotrebe.");
	if (!IsPlayerInVehicle(playerid, AdminVozilo[playerid])) return Error(playerid, "Niste u vozilu jednokratne upotrebe.");
	new boja;
	if (sscanf(params, "i", boja)) Usage(playerid, "/createvehicle [Boja]");
	else {
		new Float:pozicijeVozila[4], vehicleid = GetPlayerVehicleID(playerid), owner[30];
		GetVehiclePos(vehicleid, pozicijeVozila[0], pozicijeVozila[1], pozicijeVozila[2]);
		GetVehicleZAngle(vehicleid, pozicijeVozila[3]);
		form:owner("Drzava");
		CreateNewVehicle(
				GetVehicleModel(vehicleid), boja, E_VEHICLE_TYPE_UNDEFINED, 
				pozicijeVozila[0], pozicijeVozila[1], pozicijeVozila[2], pozicijeVozila[3],
				-1, owner
			);
		//
		if(AdminVozilo[playerid] != INVALID_VEHICLE_ID) {
			DestroyVehicle(AdminVozilo[playerid]);
			AdminVozilo[playerid] = INVALID_VEHICLE_ID;
		}
	}
	return 1;
}

stock SendClientMessageEx(id, color, const fmt[], va_args<>) {
	new str[128]; 
	va_format(str, sizeof str, fmt, va_start<3>); 
	return SendClientMessage(id, color, str); 
}
