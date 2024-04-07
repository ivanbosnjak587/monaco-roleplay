/*
   ________                  ____             _      __             __  _           
  / ____/ /_  ____ ______   / __ \___  ____ _(_)____/ /__________ _/ /_(_)___  ____ 
 / /   / __ \/ __ `/ ___/  / /_/ / _ \/ __ `/ / ___/ __/ ___/ __ `/ __/ / __ \/ __ \
/ /___/ / / / /_/ / /     / _, _/  __/ /_/ / (__  ) /_/ /  / /_/ / /_/ / /_/ / / / /
\____/_/ /_/\__,_/_/     /_/ |_|\___/\__, /_/____/\__/_/   \__,_/\__/_/\____/_/ /_/ 
                                    /____/                                          

    Developed by Danis Čavalić.
*/

#include <ysilib\YSI_Coding\y_hooks>

enum    E_REG_CHAR_SKIN_DATA
{
	skin_desc_name[20],
	skin_id
}
static Male_Skins_Data[][E_REG_CHAR_SKIN_DATA] = {
	{"Konobar", 	20},
	{"Deejay", 		19},
	{"Kapuljaca", 	29},
	{"Starac", 		43},
	{"Biker", 	    67}
};
static Female_Skins_Data[][E_REG_CHAR_SKIN_DATA] = {
	{"Direktorica", 9},
	{"Baba", 		10},
	{"Hostesa", 	12},
	{"Konobar", 	64},
	{"Plavusa", 	93}
};

enum    E_REG_CHAR_FIGHT_STYLES
{
	fight_style_name[15],
	fight_style_id
}
static Fight_Styles[][E_REG_CHAR_FIGHT_STYLES] = {
	{"Normalno", 	        4},
	{"Boks", 		        5},
	{"Kung-Fu", 	        6},
	{"Koljeno-Glava", 		7},
	{"Lakat", 	            16}
};

enum    E_REG_CHAR_HISTORY
{
	history_name[15],
	Float:history_cam_pos[6],
    Float:history_cam_look_pos[6],
    Float:history_char_pos[4]
}
static Char_Histories[][E_REG_CHAR_HISTORY] = {
	{   
        "Turista", 
        {1632.648681, -2325.904541, 14.549610, 1632.648681, -2325.904541, 14.549610}, 
        {1636.590576, -2328.916748, 13.927350, 1636.590576, -2328.916748, 13.927350},
        {1637.9888, -2332.0828, 13.5469, 52.5358}
    },
	{   
        "Ulicni Diler", 
        {2417.961181, -1227.408935, 26.250349, 2417.961181, -1227.408935, 26.250349}, 
        {2418.163574, -1222.493286, 25.358394, 2418.163574, -1222.493286, 25.358394},
        {2419.6116, -1222.6368, 25.2446, 176.9361}
    },
    {   
        "Zatvorenik", 
        {1811.704711, -1577.008056, 14.939336, 1811.704711, -1577.008056, 14.939336}, 
        {1806.918212, -1578.152343, 14.056106, 1806.918212, -1578.152343, 14.056106},
        {1804.4203, -1576.7646, 13.4281, 280.5467}
    }
};

static 
    Text:Register_Char_Global[22],
    PlayerText:Register_Char_Player[MAX_PLAYERS][4] = {PlayerText:INVALID_TEXT_DRAW, ...},
    char_Register_Pol[MAX_PLAYERS], 
    char_Register_Skin_Index[MAX_PLAYERS],
    char_Register_Fight_Index[MAX_PLAYERS],
    char_Register_Historija[MAX_PLAYERS],
    char_Register_Actor[MAX_PLAYERS][sizeof(Char_Histories)],
    char_Operations_Tick[MAX_PLAYERS];

StartCharacterRegistration(playerid) {
    //
    ClearChat(playerid, 50);
    Torq(playerid, "(karakter) Sada odaberite postavke vezane za vas karakter.");
    ClearChat(playerid, 3);
    //
    TogglePlayerSpectating(playerid, true);
    ToggleCharacterRegistrationGUI(playerid, true);
    char_Register_Pol[playerid] = 0;
    new skin = char_Register_Skin_Index[playerid] = 0;
    char_Register_Fight_Index[playerid] = 0;
    char_Register_Historija[playerid] = 0;
    for(new i; i < sizeof(Char_Histories); i++) {
        char_Register_Actor[playerid][i] = CreateDynamicActor(
                Male_Skins_Data[skin][skin_id], 
                Char_Histories[i][history_char_pos][0], Char_Histories[i][history_char_pos][1], Char_Histories[i][history_char_pos][2], Char_Histories[i][history_char_pos][3], 
                1, 100.0, 
                playerid, 0, playerid
            );
    }
    UpdateCharacterGUI(playerid);
}

UpdateCharacterGUI(playerid, bool:update_actor = true) {
    new gender = char_Register_Pol[playerid];
    new skin = char_Register_Skin_Index[playerid];
    new fightstyle = char_Register_Fight_Index[playerid];
    new history = char_Register_Historija[playerid];
    new skinid = (gender == 0) ? Male_Skins_Data[skin][skin_id] : Female_Skins_Data[skin][skin_id];

    // textdraw update
    PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][0], (gender == 0) ? "Muski" : "Zenski");
    if(gender == 0) PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][1], Male_Skins_Data[skin][skin_desc_name]);
    else PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][1], Female_Skins_Data[skin][skin_desc_name]);
    PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][2], Fight_Styles[fightstyle][fight_style_name]);
    PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][3], Char_Histories[history][history_name]);

    // actor update
    if (update_actor) {
        for(new i; i < sizeof(Char_Histories); i++) {
            Streamer_SetIntData(STREAMER_TYPE_ACTOR, char_Register_Actor[playerid][i], E_STREAMER_MODEL_ID, skinid);
        }
    }

    // camera update
    InterpolateCameraPos(
        playerid, 
        Char_Histories[history][history_cam_pos][0], Char_Histories[history][history_cam_pos][1], Char_Histories[history][history_cam_pos][2], 
        Char_Histories[history][history_cam_pos][3], Char_Histories[history][history_cam_pos][4], Char_Histories[history][history_cam_pos][5], 
        1000
    );
    InterpolateCameraLookAt(
        playerid, 
        Char_Histories[history][history_cam_look_pos][0], Char_Histories[history][history_cam_look_pos][1], Char_Histories[history][history_cam_look_pos][2], 
        Char_Histories[history][history_cam_look_pos][3], Char_Histories[history][history_cam_look_pos][4], Char_Histories[history][history_cam_look_pos][5], 
        1000
    );

    Streamer_Update(playerid);
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
    if(GetTickCount() >= char_Operations_Tick[playerid]) 
    {
        if(clickedid == Register_Char_Global[6] || clickedid == Register_Char_Global[7]) 
        {
            char_Register_Pol[playerid] = (char_Register_Pol[playerid] == 0) ? 1 : 0;
            UpdateCharacterGUI(playerid);
            char_Operations_Tick[playerid] = GetTickCount() + 500;
        } 
        else if(clickedid == Register_Char_Global[10]) 
        {
            new index_size = (char_Register_Pol[playerid] == 0) ? sizeof(Male_Skins_Data) : sizeof(Female_Skins_Data);
            if(char_Register_Skin_Index[playerid] == 0) char_Register_Skin_Index[playerid] = index_size - 1;
            else char_Register_Skin_Index[playerid]--;
            UpdateCharacterGUI(playerid);
            char_Operations_Tick[playerid] = GetTickCount() + 500;
        } 
        else if(clickedid == Register_Char_Global[11]) 
        {
            new index_size = (char_Register_Pol[playerid] == 0) ? sizeof(Male_Skins_Data) : sizeof(Female_Skins_Data);
            if(char_Register_Skin_Index[playerid] == index_size - 1) char_Register_Skin_Index[playerid] = 0;
            else char_Register_Skin_Index[playerid]++;
            UpdateCharacterGUI(playerid);
            char_Operations_Tick[playerid] = GetTickCount() + 500;
        } 
        else if(clickedid == Register_Char_Global[14]) 
        {
            new index_size = sizeof(Fight_Styles);
            if(char_Register_Fight_Index[playerid] == 0) char_Register_Fight_Index[playerid] = index_size - 1;
            else char_Register_Fight_Index[playerid]--;
            UpdateCharacterGUI(playerid, false);
        } 
        else if(clickedid == Register_Char_Global[15]) 
        {
            new index_size = sizeof(Fight_Styles);
            if(char_Register_Fight_Index[playerid] == index_size - 1) char_Register_Fight_Index[playerid] = 0;
            else char_Register_Fight_Index[playerid]++;
            UpdateCharacterGUI(playerid, false);
        } 
        else if(clickedid == Register_Char_Global[18]) 
        {
            new index_size = sizeof(Char_Histories);
            if(char_Register_Historija[playerid] == 0) char_Register_Historija[playerid] = index_size - 1;
            else char_Register_Historija[playerid]--;
            UpdateCharacterGUI(playerid, false);
            char_Operations_Tick[playerid] = GetTickCount() + 1000;
        }
        else if(clickedid == Register_Char_Global[19]) 
        {
            new index_size = sizeof(Char_Histories);
            if(char_Register_Historija[playerid] == index_size - 1) char_Register_Historija[playerid] = 0;
            else char_Register_Historija[playerid]++;
            UpdateCharacterGUI(playerid, false);
            char_Operations_Tick[playerid] = GetTickCount() + 1000;
        }
        else if(clickedid == Register_Char_Global[21]) {
            CompleteRegistration(playerid);
        }
    }
}

CompleteRegistration(playerid) {
    new gender = char_Register_Pol[playerid];
    new skin = char_Register_Skin_Index[playerid];
    new fightstyle = char_Register_Fight_Index[playerid];
    new history = char_Register_Historija[playerid];
    new skinid = (gender == 0) ? Male_Skins_Data[skin][skin_id] : Female_Skins_Data[skin][skin_id];
    //
    for(new i; i < sizeof(Char_Histories); i++) {
        if(char_Register_Actor[playerid][i] != -1) DestroyDynamicActor(char_Register_Actor[playerid][i]);
        char_Register_Actor[playerid][i] = -1;
    }
    ToggleCharacterRegistrationGUI(playerid, false);
    CancelSelectTextDraw(playerid);

    //
    Player[playerid][Registered] = 1;
    Player[playerid][IsLogged] = true;
	Player[playerid][X_Pos] = Char_Histories[history][history_char_pos][0];
	Player[playerid][Y_Pos] = Char_Histories[history][history_char_pos][1];
	Player[playerid][Z_Pos] = Char_Histories[history][history_char_pos][2];
	Player[playerid][A_Pos] = Char_Histories[history][history_char_pos][3];
	Player[playerid][Skin] = skinid;
    Player[playerid][CharGender] = Fight_Styles[fightstyle][fight_style_id];
    Player[playerid][FightStyle] = Fight_Styles[fightstyle][fight_style_id];

    //
    ClearChat(playerid, 20);
	Torq(playerid, "(racun) Dobrodosao/la na "server_dialog_header" "c_torq"RolePlay, %s.", ReturnPlayerName(playerid));
    Torq(playerid, "(racun) Vas racun je uspjesno registriran, a karakter je naslijedio odabrane podatke.");

    //
    TogglePlayerSpectating(playerid, false);
	SetSpawnInfo(playerid, 0, Player[playerid][Skin],
		Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos], Player[playerid][A_Pos],
		WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0
	);
	SpawnPlayer(playerid);
    SetPlayerFightingStyle(playerid, FIGHT_STYLE:Player[playerid][FightStyle]);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
}

hook OnPlayerConnect(playerid) {
    for(new i; i < sizeof(Char_Histories); i++) {
        char_Register_Actor[playerid][i] = -1;
    }
}

hook OnPlayerDisconnect(playerid, reason) {
    for(new i; i < sizeof(Char_Histories); i++) {
        if(char_Register_Actor[playerid][i] != -1) DestroyDynamicActor(char_Register_Actor[playerid][i]);
        char_Register_Actor[playerid][i] = -1;
    }
    ToggleCharacterRegistrationGUI(playerid, false);
}

hook OnGameModeInit() {

    Register_Char_Global[0] = TextDrawCreate(161.000, 74.000, "_");
    TextDrawLetterSize(Register_Char_Global[0], 1.391, 27.999);
    TextDrawTextSize(Register_Char_Global[0], 298.500, 215.000);
    TextDrawAlignment(Register_Char_Global[0], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Register_Char_Global[0], -1);
    TextDrawUseBox(Register_Char_Global[0], true);
    TextDrawBoxColour(Register_Char_Global[0], 1296911751);
    TextDrawSetShadow(Register_Char_Global[0], 0);
    TextDrawSetOutline(Register_Char_Global[0], 1);
    TextDrawBackgroundColour(Register_Char_Global[0], 255);
    TextDrawFont(Register_Char_Global[0], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Register_Char_Global[0], true);

    Register_Char_Global[1] = TextDrawCreate(161.000, 80.000, "_");
    TextDrawLetterSize(Register_Char_Global[1], 1.391, 26.649);
    TextDrawTextSize(Register_Char_Global[1], 298.500, 204.000);
    TextDrawAlignment(Register_Char_Global[1], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Register_Char_Global[1], -1);
    TextDrawUseBox(Register_Char_Global[1], true);
    TextDrawBoxColour(Register_Char_Global[1], 135);
    TextDrawSetShadow(Register_Char_Global[1], 0);
    TextDrawSetOutline(Register_Char_Global[1], 1);
    TextDrawBackgroundColour(Register_Char_Global[1], 255);
    TextDrawFont(Register_Char_Global[1], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Register_Char_Global[1], true);

    Register_Char_Global[2] = TextDrawCreate(136.000, 78.000, "~r~MON~w~ACO");
    TextDrawLetterSize(Register_Char_Global[2], 0.262, 1.399);
    TextDrawTextSize(Register_Char_Global[2], 400.000, 17.000);
    TextDrawAlignment(Register_Char_Global[2], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[2], -1);
    TextDrawUseBox(Register_Char_Global[2], true);
    TextDrawBoxColour(Register_Char_Global[2], 0);
    TextDrawSetShadow(Register_Char_Global[2], 0);
    TextDrawSetOutline(Register_Char_Global[2], 1);
    TextDrawBackgroundColour(Register_Char_Global[2], 255);
    TextDrawFont(Register_Char_Global[2], TEXT_DRAW_FONT_2);
    TextDrawSetProportional(Register_Char_Global[2], true);

    Register_Char_Global[3] = TextDrawCreate(135.000, 88.000, "Character");
    TextDrawLetterSize(Register_Char_Global[3], 0.262, 1.000);
    TextDrawTextSize(Register_Char_Global[3], 400.000, 17.000);
    TextDrawAlignment(Register_Char_Global[3], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[3], -1);
    TextDrawUseBox(Register_Char_Global[3], true);
    TextDrawBoxColour(Register_Char_Global[3], 0);
    TextDrawSetShadow(Register_Char_Global[3], 0);
    TextDrawSetOutline(Register_Char_Global[3], 1);
    TextDrawBackgroundColour(Register_Char_Global[3], 255);
    TextDrawFont(Register_Char_Global[3], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Register_Char_Global[3], true);

    Register_Char_Global[4] = TextDrawCreate(161.000, 102.000, "_");
    TextDrawLetterSize(Register_Char_Global[4], 1.391, 0.249);
    TextDrawTextSize(Register_Char_Global[4], 298.500, 204.500);
    TextDrawAlignment(Register_Char_Global[4], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Register_Char_Global[4], -1);
    TextDrawUseBox(Register_Char_Global[4], true);
    TextDrawBoxColour(Register_Char_Global[4], 1296911751);
    TextDrawSetShadow(Register_Char_Global[4], 0);
    TextDrawSetOutline(Register_Char_Global[4], 1);
    TextDrawBackgroundColour(Register_Char_Global[4], 255);
    TextDrawFont(Register_Char_Global[4], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Register_Char_Global[4], true);

    Register_Char_Global[5] = TextDrawCreate(62.000, 109.000, "odabir spola:");
    TextDrawLetterSize(Register_Char_Global[5], 0.262, 1.000);
    TextDrawTextSize(Register_Char_Global[5], 400.000, 17.000);
    TextDrawAlignment(Register_Char_Global[5], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[5], -1);
    TextDrawUseBox(Register_Char_Global[5], true);
    TextDrawBoxColour(Register_Char_Global[5], 0);
    TextDrawSetShadow(Register_Char_Global[5], 0);
    TextDrawSetOutline(Register_Char_Global[5], 1);
    TextDrawBackgroundColour(Register_Char_Global[5], 255);
    TextDrawFont(Register_Char_Global[5], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Register_Char_Global[5], true);

    Register_Char_Global[6] = TextDrawCreate(130.000, 108.000, "ld_beat:left");
    TextDrawLetterSize(Register_Char_Global[6], 0.600, 2.000);
    TextDrawTextSize(Register_Char_Global[6], 11.500, 11.500);
    TextDrawAlignment(Register_Char_Global[6], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[6], -1);
    TextDrawUseBox(Register_Char_Global[6], true);
    TextDrawBoxColour(Register_Char_Global[6], 50);
    TextDrawSetShadow(Register_Char_Global[6], 0);
    TextDrawSetOutline(Register_Char_Global[6], 1);
    TextDrawBackgroundColour(Register_Char_Global[6], 255);
    TextDrawFont(Register_Char_Global[6], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Register_Char_Global[6], true);
    TextDrawSetSelectable(Register_Char_Global[6], true);

    Register_Char_Global[7] = TextDrawCreate(148.000, 108.000, "LD_BEAT:right");
    TextDrawLetterSize(Register_Char_Global[7], 0.600, 2.000);
    TextDrawTextSize(Register_Char_Global[7], 11.500, 11.500);
    TextDrawAlignment(Register_Char_Global[7], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[7], -1);
    TextDrawUseBox(Register_Char_Global[7], true);
    TextDrawBoxColour(Register_Char_Global[7], 50);
    TextDrawSetShadow(Register_Char_Global[7], 0);
    TextDrawSetOutline(Register_Char_Global[7], 1);
    TextDrawBackgroundColour(Register_Char_Global[7], 255);
    TextDrawFont(Register_Char_Global[7], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Register_Char_Global[7], true);
    TextDrawSetSelectable(Register_Char_Global[7], true);

    Register_Char_Global[8] = TextDrawCreate(161.000, 124.000, "_");
    TextDrawLetterSize(Register_Char_Global[8], 1.391, 0.249);
    TextDrawTextSize(Register_Char_Global[8], 298.500, 204.500);
    TextDrawAlignment(Register_Char_Global[8], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Register_Char_Global[8], -1);
    TextDrawUseBox(Register_Char_Global[8], true);
    TextDrawBoxColour(Register_Char_Global[8], 1296911751);
    TextDrawSetShadow(Register_Char_Global[8], 0);
    TextDrawSetOutline(Register_Char_Global[8], 1);
    TextDrawBackgroundColour(Register_Char_Global[8], 255);
    TextDrawFont(Register_Char_Global[8], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Register_Char_Global[8], true);

    Register_Char_Global[9] = TextDrawCreate(62.000, 130.000, "odjeca:");
    TextDrawLetterSize(Register_Char_Global[9], 0.262, 1.000);
    TextDrawTextSize(Register_Char_Global[9], 400.000, 17.000);
    TextDrawAlignment(Register_Char_Global[9], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[9], -1);
    TextDrawUseBox(Register_Char_Global[9], true);
    TextDrawBoxColour(Register_Char_Global[9], 0);
    TextDrawSetShadow(Register_Char_Global[9], 0);
    TextDrawSetOutline(Register_Char_Global[9], 1);
    TextDrawBackgroundColour(Register_Char_Global[9], 255);
    TextDrawFont(Register_Char_Global[9], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Register_Char_Global[9], true);

    Register_Char_Global[10] = TextDrawCreate(130.000, 129.000, "ld_beat:left");
    TextDrawLetterSize(Register_Char_Global[10], 0.600, 2.000);
    TextDrawTextSize(Register_Char_Global[10], 11.500, 11.500);
    TextDrawAlignment(Register_Char_Global[10], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[10], -1);
    TextDrawUseBox(Register_Char_Global[10], true);
    TextDrawBoxColour(Register_Char_Global[10], 50);
    TextDrawSetShadow(Register_Char_Global[10], 0);
    TextDrawSetOutline(Register_Char_Global[10], 1);
    TextDrawBackgroundColour(Register_Char_Global[10], 255);
    TextDrawFont(Register_Char_Global[10], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Register_Char_Global[10], true);
    TextDrawSetSelectable(Register_Char_Global[10], true);

    Register_Char_Global[11] = TextDrawCreate(148.000, 129.000, "LD_BEAT:right");
    TextDrawLetterSize(Register_Char_Global[11], 0.600, 2.000);
    TextDrawTextSize(Register_Char_Global[11], 11.500, 11.500);
    TextDrawAlignment(Register_Char_Global[11], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[11], -1);
    TextDrawUseBox(Register_Char_Global[11], true);
    TextDrawBoxColour(Register_Char_Global[11], 50);
    TextDrawSetShadow(Register_Char_Global[11], 0);
    TextDrawSetOutline(Register_Char_Global[11], 1);
    TextDrawBackgroundColour(Register_Char_Global[11], 255);
    TextDrawFont(Register_Char_Global[11], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Register_Char_Global[11], true);
    TextDrawSetSelectable(Register_Char_Global[11], true);

    Register_Char_Global[12] = TextDrawCreate(161.000, 145.000, "_");
    TextDrawLetterSize(Register_Char_Global[12], 1.391, 0.249);
    TextDrawTextSize(Register_Char_Global[12], 298.500, 204.500);
    TextDrawAlignment(Register_Char_Global[12], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Register_Char_Global[12], -1);
    TextDrawUseBox(Register_Char_Global[12], true);
    TextDrawBoxColour(Register_Char_Global[12], 1296911751);
    TextDrawSetShadow(Register_Char_Global[12], 0);
    TextDrawSetOutline(Register_Char_Global[12], 1);
    TextDrawBackgroundColour(Register_Char_Global[12], 255);
    TextDrawFont(Register_Char_Global[12], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Register_Char_Global[12], true);

    Register_Char_Global[13] = TextDrawCreate(62.000, 151.000, "borbeni stil:");
    TextDrawLetterSize(Register_Char_Global[13], 0.262, 1.000);
    TextDrawTextSize(Register_Char_Global[13], 400.000, 17.000);
    TextDrawAlignment(Register_Char_Global[13], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[13], -1);
    TextDrawUseBox(Register_Char_Global[13], true);
    TextDrawBoxColour(Register_Char_Global[13], 0);
    TextDrawSetShadow(Register_Char_Global[13], 0);
    TextDrawSetOutline(Register_Char_Global[13], 1);
    TextDrawBackgroundColour(Register_Char_Global[13], 255);
    TextDrawFont(Register_Char_Global[13], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Register_Char_Global[13], true);

    Register_Char_Global[14] = TextDrawCreate(130.000, 150.000, "ld_beat:left");
    TextDrawLetterSize(Register_Char_Global[14], 0.600, 2.000);
    TextDrawTextSize(Register_Char_Global[14], 11.500, 11.500);
    TextDrawAlignment(Register_Char_Global[14], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[14], -1);
    TextDrawUseBox(Register_Char_Global[14], true);
    TextDrawBoxColour(Register_Char_Global[14], 50);
    TextDrawSetShadow(Register_Char_Global[14], 0);
    TextDrawSetOutline(Register_Char_Global[14], 1);
    TextDrawBackgroundColour(Register_Char_Global[14], 255);
    TextDrawFont(Register_Char_Global[14], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Register_Char_Global[14], true);
    TextDrawSetSelectable(Register_Char_Global[14], true);

    Register_Char_Global[15] = TextDrawCreate(148.000, 150.000, "LD_BEAT:right");
    TextDrawLetterSize(Register_Char_Global[15], 0.600, 2.000);
    TextDrawTextSize(Register_Char_Global[15], 11.500, 11.500);
    TextDrawAlignment(Register_Char_Global[15], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[15], -1);
    TextDrawUseBox(Register_Char_Global[15], true);
    TextDrawBoxColour(Register_Char_Global[15], 50);
    TextDrawSetShadow(Register_Char_Global[15], 0);
    TextDrawSetOutline(Register_Char_Global[15], 1);
    TextDrawBackgroundColour(Register_Char_Global[15], 255);
    TextDrawFont(Register_Char_Global[15], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Register_Char_Global[15], true);
    TextDrawSetSelectable(Register_Char_Global[15], true);

    Register_Char_Global[16] = TextDrawCreate(161.000, 164.000, "_");
    TextDrawLetterSize(Register_Char_Global[16], 1.391, 0.249);
    TextDrawTextSize(Register_Char_Global[16], 298.500, 204.500);
    TextDrawAlignment(Register_Char_Global[16], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Register_Char_Global[16], -1);
    TextDrawUseBox(Register_Char_Global[16], true);
    TextDrawBoxColour(Register_Char_Global[16], 1296911751);
    TextDrawSetShadow(Register_Char_Global[16], 0);
    TextDrawSetOutline(Register_Char_Global[16], 1);
    TextDrawBackgroundColour(Register_Char_Global[16], 255);
    TextDrawFont(Register_Char_Global[16], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Register_Char_Global[16], true);

    Register_Char_Global[17] = TextDrawCreate(62.000, 170.000, "Historija:");
    TextDrawLetterSize(Register_Char_Global[17], 0.262, 1.000);
    TextDrawTextSize(Register_Char_Global[17], 400.000, 17.000);
    TextDrawAlignment(Register_Char_Global[17], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[17], -1);
    TextDrawUseBox(Register_Char_Global[17], true);
    TextDrawBoxColour(Register_Char_Global[17], 0);
    TextDrawSetShadow(Register_Char_Global[17], 0);
    TextDrawSetOutline(Register_Char_Global[17], 1);
    TextDrawBackgroundColour(Register_Char_Global[17], 255);
    TextDrawFont(Register_Char_Global[17], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Register_Char_Global[17], true);

    Register_Char_Global[18] = TextDrawCreate(130.000, 169.000, "ld_beat:left");
    TextDrawLetterSize(Register_Char_Global[18], 0.600, 2.000);
    TextDrawTextSize(Register_Char_Global[18], 11.500, 11.500);
    TextDrawAlignment(Register_Char_Global[18], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[18], -1);
    TextDrawUseBox(Register_Char_Global[18], true);
    TextDrawBoxColour(Register_Char_Global[18], 50);
    TextDrawSetShadow(Register_Char_Global[18], 0);
    TextDrawSetOutline(Register_Char_Global[18], 1);
    TextDrawBackgroundColour(Register_Char_Global[18], 255);
    TextDrawFont(Register_Char_Global[18], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Register_Char_Global[18], true);
    TextDrawSetSelectable(Register_Char_Global[18], true);

    Register_Char_Global[19] = TextDrawCreate(148.000, 169.000, "LD_BEAT:right");
    TextDrawLetterSize(Register_Char_Global[19], 0.600, 2.000);
    TextDrawTextSize(Register_Char_Global[19], 11.500, 11.500);
    TextDrawAlignment(Register_Char_Global[19], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[19], -1);
    TextDrawUseBox(Register_Char_Global[19], true);
    TextDrawBoxColour(Register_Char_Global[19], 50);
    TextDrawSetShadow(Register_Char_Global[19], 0);
    TextDrawSetOutline(Register_Char_Global[19], 1);
    TextDrawBackgroundColour(Register_Char_Global[19], 255);
    TextDrawFont(Register_Char_Global[19], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Register_Char_Global[19], true);
    TextDrawSetSelectable(Register_Char_Global[19], true);

    Register_Char_Global[20] = TextDrawCreate(62.000, 186.000, "62.000000, 186.000000, ");
    TextDrawLetterSize(Register_Char_Global[20], 0.187, 0.850);
    TextDrawTextSize(Register_Char_Global[20], 259.000, 12.500);
    TextDrawAlignment(Register_Char_Global[20], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Register_Char_Global[20], 1296911871);
    TextDrawUseBox(Register_Char_Global[20], true);
    TextDrawBoxColour(Register_Char_Global[20], 63);
    TextDrawSetShadow(Register_Char_Global[20], 1);
    TextDrawSetOutline(Register_Char_Global[20], 0);
    TextDrawBackgroundColour(Register_Char_Global[20], 255);
    TextDrawFont(Register_Char_Global[20], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Register_Char_Global[20], true);

    Register_Char_Global[21] = TextDrawCreate(163.000, 307.000, "~r~ZAV~w~RSI");
    TextDrawLetterSize(Register_Char_Global[21], 0.258, 1.399);
    TextDrawTextSize(Register_Char_Global[21], 16.500, 90.500);
    TextDrawAlignment(Register_Char_Global[21], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Register_Char_Global[21], -1);
    TextDrawUseBox(Register_Char_Global[21], true);
    TextDrawBoxColour(Register_Char_Global[21], 64);
    TextDrawSetShadow(Register_Char_Global[21], 0);
    TextDrawSetOutline(Register_Char_Global[21], 1);
    TextDrawBackgroundColour(Register_Char_Global[21], 255);
    TextDrawFont(Register_Char_Global[21], TEXT_DRAW_FONT_2);
    TextDrawSetProportional(Register_Char_Global[21], true);
    TextDrawSetSelectable(Register_Char_Global[21], true);

}

ToggleCharacterRegistrationGUI(playerid, bool:toggle = true) 
{
    if (toggle) 
    {
        Register_Char_Player[playerid][0] = CreatePlayerTextDraw(playerid, 165.000, 109.000, "ZENSKI");
        PlayerTextDrawLetterSize(playerid, Register_Char_Player[playerid][0], 0.262, 1.000);
        PlayerTextDrawTextSize(playerid, Register_Char_Player[playerid][0], 400.000, 17.000);
        PlayerTextDrawAlignment(playerid, Register_Char_Player[playerid][0], TEXT_DRAW_ALIGN_LEFT);
        PlayerTextDrawColour(playerid, Register_Char_Player[playerid][0], -1);
        PlayerTextDrawUseBox(playerid, Register_Char_Player[playerid][0], true);
        PlayerTextDrawBoxColour(playerid, Register_Char_Player[playerid][0], 0);
        PlayerTextDrawSetShadow(playerid, Register_Char_Player[playerid][0], 0);
        PlayerTextDrawSetOutline(playerid, Register_Char_Player[playerid][0], 1);
        PlayerTextDrawBackgroundColour(playerid, Register_Char_Player[playerid][0], 255);
        PlayerTextDrawFont(playerid, Register_Char_Player[playerid][0], TEXT_DRAW_FONT_2);
        PlayerTextDrawSetProportional(playerid, Register_Char_Player[playerid][0], true);

        Register_Char_Player[playerid][1] = CreatePlayerTextDraw(playerid, 165.000, 130.000, "KAPULJACA");
        PlayerTextDrawLetterSize(playerid, Register_Char_Player[playerid][1], 0.262, 1.000);
        PlayerTextDrawTextSize(playerid, Register_Char_Player[playerid][1], 400.000, 17.000);
        PlayerTextDrawAlignment(playerid, Register_Char_Player[playerid][1], TEXT_DRAW_ALIGN_LEFT);
        PlayerTextDrawColour(playerid, Register_Char_Player[playerid][1], -1);
        PlayerTextDrawUseBox(playerid, Register_Char_Player[playerid][1], true);
        PlayerTextDrawBoxColour(playerid, Register_Char_Player[playerid][1], 0);
        PlayerTextDrawSetShadow(playerid, Register_Char_Player[playerid][1], 0);
        PlayerTextDrawSetOutline(playerid, Register_Char_Player[playerid][1], 1);
        PlayerTextDrawBackgroundColour(playerid, Register_Char_Player[playerid][1], 255);
        PlayerTextDrawFont(playerid, Register_Char_Player[playerid][1], TEXT_DRAW_FONT_2);
        PlayerTextDrawSetProportional(playerid, Register_Char_Player[playerid][1], true);

        Register_Char_Player[playerid][2] = CreatePlayerTextDraw(playerid, 165.000, 151.000, "lakat-koljeno");
        PlayerTextDrawLetterSize(playerid, Register_Char_Player[playerid][2], 0.262, 1.000);
        PlayerTextDrawTextSize(playerid, Register_Char_Player[playerid][2], 400.000, 17.000);
        PlayerTextDrawAlignment(playerid, Register_Char_Player[playerid][2], TEXT_DRAW_ALIGN_LEFT);
        PlayerTextDrawColour(playerid, Register_Char_Player[playerid][2], -1);
        PlayerTextDrawUseBox(playerid, Register_Char_Player[playerid][2], true);
        PlayerTextDrawBoxColour(playerid, Register_Char_Player[playerid][2], 0);
        PlayerTextDrawSetShadow(playerid, Register_Char_Player[playerid][2], 0);
        PlayerTextDrawSetOutline(playerid, Register_Char_Player[playerid][2], 1);
        PlayerTextDrawBackgroundColour(playerid, Register_Char_Player[playerid][2], 255);
        PlayerTextDrawFont(playerid, Register_Char_Player[playerid][2], TEXT_DRAW_FONT_2);
        PlayerTextDrawSetProportional(playerid, Register_Char_Player[playerid][2], true);

        Register_Char_Player[playerid][3] = CreatePlayerTextDraw(playerid, 165.000, 170.000, "Ulicni Diler");
        PlayerTextDrawLetterSize(playerid, Register_Char_Player[playerid][3], 0.262, 1.000);
        PlayerTextDrawTextSize(playerid, Register_Char_Player[playerid][3], 400.000, 17.000);
        PlayerTextDrawAlignment(playerid, Register_Char_Player[playerid][3], TEXT_DRAW_ALIGN_LEFT);
        PlayerTextDrawColour(playerid, Register_Char_Player[playerid][3], -1);
        PlayerTextDrawUseBox(playerid, Register_Char_Player[playerid][3], true);
        PlayerTextDrawBoxColour(playerid, Register_Char_Player[playerid][3], 0);
        PlayerTextDrawSetShadow(playerid, Register_Char_Player[playerid][3], 0);
        PlayerTextDrawSetOutline(playerid, Register_Char_Player[playerid][3], 1);
        PlayerTextDrawBackgroundColour(playerid, Register_Char_Player[playerid][3], 255);
        PlayerTextDrawFont(playerid, Register_Char_Player[playerid][3], TEXT_DRAW_FONT_2);
        PlayerTextDrawSetProportional(playerid, Register_Char_Player[playerid][3], true);

        for(new i; i < sizeof(Register_Char_Global); i++) {
            TextDrawShowForPlayer(playerid, Register_Char_Global[i]);
        }

        for(new i; i < 4; i++) {
            PlayerTextDrawShow(playerid, Register_Char_Player[playerid][i]);
        }

        SelectTextDraw( playerid, 0x12C706FF );
    } 
    else {
        for(new i = 0; i < 4; i++) {
            if(Register_Char_Player[playerid][i] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, Register_Char_Player[playerid][i]);
            Register_Char_Player[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new i; i < sizeof(Register_Char_Global); i++) {
            TextDrawHideForPlayer(playerid, Register_Char_Global[i]);
        }
        CancelSelectTextDraw(playerid);
    }
}