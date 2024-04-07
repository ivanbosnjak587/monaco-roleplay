/*
   ______              ____             __               __    _     
  / ____/___ ______   / __ \___  ____ _/ /__  __________/ /_  (_)___ 
 / /   / __ `/ ___/  / / / / _ \/ __ `/ / _ \/ ___/ ___/ __ \/ / __ \
/ /___/ /_/ / /     / /_/ /  __/ /_/ / /  __/ /  (__  ) / / / / /_/ /
\____/\__,_/_/     /_____/\___/\__,_/_/\___/_/  /____/_/ /_/_/ .___/ 
                                                            /_/      
    Developed by Danis Čavalić.
*/
 
#include    <ysilib\YSI_Coding\y_hooks>
#include 	"backend/vehicles/vehicles_data/utilities.pwn"

#define     MAX_DEALERSHIP_MODELS   8

static // ui
    Text:Dealership_GlobalTD[17],
    PlayerText:Dealership_PTD[MAX_PLAYERS][9] = {PlayerText:INVALID_TEXT_DRAW, ...},
    Text:Contract_GlobalTD[13],
    PlayerText:Contract_PTD[MAX_PLAYERS][7] = {PlayerText:INVALID_TEXT_DRAW, ...},
    // operations
    dealer_Player_Dealership[MAX_PLAYERS],
    dealer_Player_VehIndex[MAX_PLAYERS],
    dealer_Player_FuelIndex[MAX_PLAYERS],
    dealer_Player_ColIndex[MAX_PLAYERS],
    dealer_Player_WheelIndex[MAX_PLAYERS],
    dealer_Player_PayType[MAX_PLAYERS];

enum    E_DLS_PLAYER_PAY_TYPES
{
	pay_type_name[33],
    e_PAY_TYPE:pay_type,
	bool:pay_type_credit
}
static PayTypes[][E_DLS_PLAYER_PAY_TYPES] = {
	{"Cash", 				PAY_TYPE_POCKET,    false},
	{"Bankovni transfer", 	PAY_TYPE_BANK,      false},
	{"Kredit", 				PAY_TYPE_CREDIT,    true}
};

enum    E_DEALERSHIP_VEH_COLORS
{
	color_name[33],
	color_code,
	color_hex[10]
}
static VehicleColors[][E_DEALERSHIP_VEH_COLORS] = {
	{"Bijela", 				1, 		"FFFFFF"},
	{"Crna", 				0, 		"000000"},
	{"Plava", 				2, 		"00C0FF"},
	{"Crvena", 				3, 		"F81414"},
	{"Maslinasta", 	        51, 	"60B554"},
	{"Zelena", 				86, 	"36D720"},
	{"Roza", 				126, 	"FF9CFA"},
	{"Tamno plava", 		79, 	"0B72D3"},
	{"Svijetlo zuta", 		65, 	"F1F57A"},
	{"Narandzasta", 		158, 	"FF9300"}
};

enum    E_DEALERSHIP_VEH_WHEELS
{
	wheel_name[33],
	wheel_comp_id
}
static VehicleWheels[][E_DEALERSHIP_VEH_WHEELS] = {
	{"Shadow", 		1073},
	{"Mega", 		1074},
	{"Rimshine", 	1075},
	{"Wires", 		1076},
	{"Classic", 	1077},
	{"Twist", 		1078},
	{"Cutter", 		1079},
	{"Switch", 		1080},
	{"Grove", 		1081},
	{"Ahab", 		1096},
	{"Virtual", 	1097},
	{"Atomic", 		1085}
};

enum    E_DEALERSHIP_DATA
{
	dship_name[20],
    Float:dship_cam_pos[6],
    Float:dship_cam_look_pos[6],
    Float:dship_pos[3],
    Float:dship_vehicle_pos[4],
    Float:dship_vehicle_buy_pos[4],
    dship_veh_models[MAX_DEALERSHIP_MODELS],
    dship_int,
    dship_vw,

    dship_vehicle_id,
    Text3D:dship_label,
    dship_pickup,
    dship_player_id
}
static Dealership[][E_DEALERSHIP_DATA] = {
	{
        /* naziv salona */ "Grotti Cars",
        /* camera pos */ {1401.918090, -24.882469, 1003.693115, 1401.918090, -24.882469, 1003.693115},
        /* camera look at */ {1405.063842, -28.588148, 1002.521606, 1405.063842, -28.588148, 1002.521606},
        /* pozicija za kupovinu */ {1391.8030, -27.7318, 1000.8630},
        /* izlozbeni primjerak */ {1406.0607, -32.8932, 1002.6105, 64.3434},
        /* parking ispred salona */ {0.0, 0.0, 0.0, 0.0},
        /* dostupni modeli vozila */ {411, 560, 400, 541, 451, 581, 408, 522},
        /* interior id */ 1,
        /* virtual world */ 333
    }
};

OperateDealershipContract(playerid) {

    new 
        veh_index = dealer_Player_VehIndex[playerid],
        col_index = dealer_Player_ColIndex[playerid],
        wheel_index = dealer_Player_WheelIndex[playerid],
        id = dealer_Player_Dealership[playerid];
    dealer_Player_PayType[playerid] = 0;

    // toggle ui
    ToggleDealershipUI(playerid, false);
    ToggleContractUI(playerid, true);
    SetCameraBehindPlayer(playerid);

    // update ui
    new ui_operate_string[180];
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][0], Dealership[id][dship_name]);
    form:ui_operate_string("Ugovor o kupovini: %s", GetVehicleNameEx(Dealership[id][dship_veh_models][veh_index]));
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][1], ui_operate_string);
    form:ui_operate_string("Vozilo: %s~n~Boja: %s~n~Felge: %s~n~Cijena: $%d", 
                      GetVehicleNameEx(Dealership[id][dship_veh_models][veh_index]),
                      VehicleColors[col_index][color_name],
                      VehicleWheels[wheel_index][wheel_name],
                      VehPrice[ Dealership[id][dship_veh_models][veh_index]-400 ][ 1 ]);
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][2], ui_operate_string);
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][3], PayTypes[dealer_Player_PayType[playerid]][pay_type_name]);
    form:ui_operate_string("%s Dealership", Dealership[id][dship_name]);
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][4], ui_operate_string);
    form:ui_operate_string("Potvrdi: ~g~$%d", VehPrice[ Dealership[id][dship_veh_models][veh_index]-400 ][ 1 ]);
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][6], ui_operate_string);
}

stock OperateDealership(playerid) {
    new id = GetClosestDealershipID(playerid);
    if(id != -1 && Dealership[id][dship_player_id] == -1) {
        InterpolateCameraPos(
            playerid, 
            Dealership[id][dship_cam_pos][0], Dealership[id][dship_cam_pos][1], Dealership[id][dship_cam_pos][2],
            Dealership[id][dship_cam_pos][3], Dealership[id][dship_cam_pos][4], Dealership[id][dship_cam_pos][5],
            1000
        );
        InterpolateCameraLookAt(
            playerid, 
            Dealership[id][dship_cam_look_pos][0], Dealership[id][dship_cam_look_pos][1], Dealership[id][dship_cam_look_pos][2],
            Dealership[id][dship_cam_look_pos][3], Dealership[id][dship_cam_look_pos][4], Dealership[id][dship_cam_look_pos][5],
            1000
        );
        dealer_Player_Dealership[playerid] = id;
        dealer_Player_VehIndex[playerid] = dealer_Player_FuelIndex[playerid] = dealer_Player_ColIndex[playerid] = dealer_Player_WheelIndex[playerid] = 0;
        Dealership[id][dship_player_id] = playerid;

        ToggleDealershipUI(playerid, true);
        UpdateDealershipParams(playerid, true);
    }
}

DS_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
    // dealership > ugovor
    if(playertextid == Dealership_PTD[playerid][8]) {
        OperateDealershipContract(playerid);
    }
    // potpis ugovora
    else if(playertextid == Contract_PTD[playerid][6]) {
        //SendClientMessage(playerid, -1, "TBD");
    }
}

hook OnPlayerKeyStateChange(playerid, KEY:newkeys, oldkeys) {
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
        if(newkeys & KEY_SECONDARY_ATTACK) {
            OperateDealership(playerid);
        }
    }
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
    // hide cursor
    /*if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        for(new i; i < sizeof(Dealership); i++) {
            if(Dealership[i][dship_player_id] == playerid) {
                Dealership[i][dship_player_id] = -1;
            }
        }
        ToggleDealershipUI(playerid, false);
        ToggleContractUI(playerid, false);
        SetCameraBehindPlayer(playerid);
    }*/
    // model
    if(clickedid == Dealership_GlobalTD[5]) {
        new index_size = MAX_DEALERSHIP_MODELS;
        if(dealer_Player_VehIndex[playerid] == 0) dealer_Player_VehIndex[playerid] = index_size - 1;
        else dealer_Player_VehIndex[playerid]--;
        UpdateDealershipParams(playerid, true);
    }
    else if(clickedid == Dealership_GlobalTD[6]) {
        new index_size = MAX_DEALERSHIP_MODELS;
        if(dealer_Player_VehIndex[playerid] == index_size - 1) dealer_Player_VehIndex[playerid] = 0;
        else dealer_Player_VehIndex[playerid]++;
        UpdateDealershipParams(playerid, true);
    }
    // gorivo
    else if(clickedid == Dealership_GlobalTD[8] || clickedid == Dealership_GlobalTD[9]) {
        dealer_Player_FuelIndex[playerid] = (dealer_Player_FuelIndex[playerid] == 0) ? 1 : 0;
        UpdateDealershipParams(playerid, false);
    }
    // boja
    else if(clickedid == Dealership_GlobalTD[12]) {
        new index_size = sizeof(VehicleColors);
        if(dealer_Player_ColIndex[playerid] == 0) dealer_Player_ColIndex[playerid] = index_size - 1;
        else dealer_Player_ColIndex[playerid]--;
        UpdateDealershipParams(playerid, false);
    }
    else if(clickedid == Dealership_GlobalTD[13]) {
        new index_size = sizeof(VehicleColors);
        if(dealer_Player_ColIndex[playerid] == index_size - 1) dealer_Player_ColIndex[playerid] = 0;
        else dealer_Player_ColIndex[playerid]++;
        UpdateDealershipParams(playerid, false);
    }
    // felge
    else if(clickedid == Dealership_GlobalTD[14]) {
        new index_size = sizeof(VehicleWheels);
        if(dealer_Player_WheelIndex[playerid] == 0) dealer_Player_WheelIndex[playerid] = index_size - 1;
        else dealer_Player_WheelIndex[playerid]--;
        UpdateDealershipParams(playerid, false);
    }
    else if(clickedid == Dealership_GlobalTD[15]) {
        new index_size = sizeof(VehicleWheels);
        if(dealer_Player_WheelIndex[playerid] == index_size - 1) dealer_Player_WheelIndex[playerid] = 0;
        else dealer_Player_WheelIndex[playerid]++;
        UpdateDealershipParams(playerid, false);
    }
    // contract: vrsta placanja
    else if(clickedid == Contract_GlobalTD[5]) {
        new index_size = sizeof(PayTypes);
        if(dealer_Player_PayType[playerid] == 0) dealer_Player_PayType[playerid] = index_size - 1;
        else dealer_Player_PayType[playerid]--;
        PlayerTextDrawSetString(playerid, Contract_PTD[playerid][3], PayTypes[dealer_Player_PayType[playerid]][pay_type_name]);
    }
    else if(clickedid == Contract_GlobalTD[6]) {
        new index_size = sizeof(PayTypes);
        if(dealer_Player_PayType[playerid] == index_size - 1) dealer_Player_PayType[playerid] = 0;
        else dealer_Player_PayType[playerid]++;
        PlayerTextDrawSetString(playerid, Contract_PTD[playerid][3], PayTypes[dealer_Player_PayType[playerid]][pay_type_name]);
    }
}

UpdateDealershipParams(playerid, bool: updatecar = false) {
    new 
        veh_index = dealer_Player_VehIndex[playerid],
        fuel_index = dealer_Player_FuelIndex[playerid],
        col_index = dealer_Player_ColIndex[playerid],
        wheel_index = dealer_Player_WheelIndex[playerid],
        id = dealer_Player_Dealership[playerid];

    // vehicle update
    if (updatecar) 
    {
        DestroyVehicle(Dealership[id][dship_vehicle_id]);
        Dealership[id][dship_vehicle_id] = CreateVehicle(
                Dealership[id][dship_veh_models][veh_index], 
                Dealership[id][dship_vehicle_pos][0], Dealership[id][dship_vehicle_pos][1], Dealership[id][dship_vehicle_pos][2], Dealership[id][dship_vehicle_pos][3], 
                VehicleColors[col_index][color_code], VehicleColors[col_index][color_code], 
                -1
            );
        LinkVehicleToInterior(Dealership[id][dship_vehicle_id], Dealership[id][dship_int]);
        SetVehicleVirtualWorld(Dealership[id][dship_vehicle_id], Dealership[id][dship_vw]);
    }
    AddVehicleComponent(Dealership[id][dship_vehicle_id], VehicleWheels[wheel_index][wheel_comp_id]);
    ChangeVehicleColours(Dealership[id][dship_vehicle_id], VehicleColors[col_index][color_code], VehicleColors[col_index][color_code]);

    // ui update
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][0], Dealership[id][dship_name]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][1], GetVehicleNameEx(Dealership[id][dship_veh_models][veh_index]));
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][2], (fuel_index == 0) ? ("Benzin") : ("Dizel"));
    new temporary_string[12];
    format(temporary_string, sizeof(temporary_string), "0x%sFF", VehicleColors[col_index][color_hex]);
    PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][3], HexToInt(temporary_string));
    PlayerTextDrawColour(playerid, Dealership_PTD[playerid][3], HexToInt(temporary_string));
    PlayerTextDrawShow(playerid, Dealership_PTD[playerid][3]);
    PlayerTextDrawSetPreviewModel(playerid, Dealership_PTD[playerid][4], VehicleWheels[wheel_index][wheel_comp_id]);
    PlayerTextDrawShow(playerid, Dealership_PTD[playerid][4]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][5], VehicleColors[col_index][color_name]);
    PlayerTextDrawColour(playerid, Dealership_PTD[playerid][5], HexToInt(temporary_string));
    PlayerTextDrawShow(playerid, Dealership_PTD[playerid][5]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][6], VehicleWheels[wheel_index][wheel_name]);
    new ugovor_text[180], pregled_text[35];
    form:ugovor_text("Nakon odabira zeljenog modela, tipa pogonskog goriva, te specifikacija vezanih za samo vozilo \
                      biti ce vam prikazan salonski ugovor, cijim potpisom osiguravate kupovinu vozila. Nakon potpisa \
                      vozilo ce vam biti dostavljeno ispred salona. Vrijednost ugovora je: ~g~$%d", VehPrice[ Dealership[id][dship_veh_models][veh_index]-400 ][ 1 ]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][7], ugovor_text);
    form:pregled_text("Pregledaj ugovor: ~g~$%d", VehPrice[ Dealership[id][dship_veh_models][veh_index]-400 ][ 1 ]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][8], pregled_text);
}

stock GetClosestDealershipID(playerid, Float: range = 5.0) 
{
    new Float:x, Float:y, Float:z;

	if (!GetPlayerPos(playerid, x, y, z))
	{
		return -1;
	}

	new Float:distance = FLOAT_INFINITY, closestid = -1, Float:distance2;

    for(new i; i < sizeof(Dealership); i++) 
    {
        distance2 = VectorSize(x - Dealership[i][dship_pos][0], y - Dealership[i][dship_pos][1], z - Dealership[i][dship_pos][2]);
        if (distance2 < distance && distance2 <= range)
        {
            distance = distance2;
            closestid = i;
        }
    }

    return closestid;
}

hook OnPlayerDisconnect(playerid, reason) {
    for(new i; i < sizeof(Dealership); i++) {
        if(Dealership[i][dship_player_id] == playerid) {
            Dealership[i][dship_player_id] = -1;
        }
    }
    ToggleDealershipUI(playerid, false);
    ToggleContractUI(playerid, false);
}

hook OnPlayerDeath(playerid, killerid, reason) {
    for(new i; i < sizeof(Dealership); i++) {
        if(Dealership[i][dship_player_id] == playerid) {
            Dealership[i][dship_player_id] = -1;
        }
    }
    ToggleDealershipUI(playerid, false);
    ToggleContractUI(playerid, false);
}

stock HexToInt(const value[]) // By DracoBlue
{
    if (value[0]==0) return 0;
    new i;
    new cur=1;
    new res=0;
    for (i=strlen(value);i>0;i--) {
        if (value[i-1]<58) res=res+cur*(value[i-1]-48); else res=res+cur*(value[i-1]-65+10);
        cur=cur*16;
    }
    return res;
}

stock ToggleDealershipUI(playerid, bool:toggle = true) {
    if (toggle) {
        Dealership_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 124.000000, 140.000000, "OTTOS CARS");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][0], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][0], 0.283333, 1.200001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][0], 400.000000, 137.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][0], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][0], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][0], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][0], 1687547391);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][0], 255);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][0], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][0], true);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][0], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][0], false);

        Dealership_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 111.000000, 172.000000, "Infernus");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][1], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][1], 0.283333, 1.050001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][1], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][1], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][1], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][1], TEXT_DRAW_ALIGN:1);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][1], -1);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][1], 255);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][1], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][1], true);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][1], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][1], false);

        Dealership_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 111.000000, 191.000000, "BENZIN");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][2], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][2], 0.283333, 1.050001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][2], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][2], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][2], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][2], TEXT_DRAW_ALIGN:1);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][2], -1);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][2], 255);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][2], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][2], true);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][2], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][2], false);

        Dealership_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 54.000000, 228.000000, "ld_beat:chit");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][3], TEXT_DRAW_FONT:4);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][3], 0.600000, 2.000000);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][3], 30.000000, 30.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][3], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][3], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][3], TEXT_DRAW_ALIGN:1);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][3], 852308735);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][3], 255);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][3], 50);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][3], true);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][3], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][3], false);

        Dealership_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 153.000000, 229.000000, "Preview_Model");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][4], TEXT_DRAW_FONT:5);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][4], 0.600000, 2.000000);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][4], 28.500000, 28.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][4], TEXT_DRAW_ALIGN:1);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][4], -1);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][4], false);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][4], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][4], false);
        PlayerTextDrawSetPreviewModel(playerid, Dealership_PTD[playerid][4], 1080);
        PlayerTextDrawSetPreviewRot(playerid, Dealership_PTD[playerid][4], -10.000000, 0.000000, 90.000000, 1.000000);
        PlayerTextDrawSetPreviewVehicleColours(playerid, Dealership_PTD[playerid][4], 1, 1);

        Dealership_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 69.000000, 258.000000, "Svijetlo Zelena");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][5], TEXT_DRAW_FONT:3);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][5], 0.191666, 0.750001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][5], 400.000000, 152.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][5], 0);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][5], 1);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][5], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][5], 852308735);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][5], 255);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][5], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][5], false);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][5], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][5], false);

        Dealership_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 168.000000, 258.000000, "Switch");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][6], TEXT_DRAW_FONT:3);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][6], 0.191666, 0.750001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][6], 400.000000, 152.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][6], 0);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][6], 1);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][6], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][6], -741092353);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][6], 255);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][6], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][6], false);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][6], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][6], false);

        Dealership_PTD[playerid][7] = CreatePlayerTextDraw(playerid, 29.000000, 277.000000, "Nakon sto odaberete model i odgovarajuce specifikacije, mozete preci na pregled ugovora za vozilo. Cijena ovog vozila je: ~g~$1");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][7], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][7], 0.191666, 0.750001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][7], 218.000000, 242.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][7], 0);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][7], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][7], TEXT_DRAW_ALIGN:1);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][7], -741092353);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][7], 255);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][7], 74);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][7], true);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][7], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][7], false);

        Dealership_PTD[playerid][8] = CreatePlayerTextDraw(playerid, 123.000000, 318.000000, "Pregled ugovora: ~g~$1");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][8], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][8], 0.187499, 0.850000);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][8], 18.000000, 188.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][8], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][8], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][8], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawColour(playerid, Dealership_PTD[playerid][8], -1);
        PlayerTextDrawBackgroundColour(playerid, Dealership_PTD[playerid][8], 255);
        PlayerTextDrawBoxColour(playerid, Dealership_PTD[playerid][8], 200);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][8], true);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][8], true);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][8], true);

        for(new i; i < sizeof(Dealership_GlobalTD); i++) {
            TextDrawShowForPlayer(playerid, Dealership_GlobalTD[i]);
        }

        for(new i; i < 9; i++) {
            PlayerTextDrawShow(playerid, Dealership_PTD[playerid][i]);
        }

        SelectTextDraw( playerid, 0x12C706FF );
    }
    else {
        for(new i = 0; i < 9; i++) {
            if(Dealership_PTD[playerid][i] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, Dealership_PTD[playerid][i]);
            Dealership_PTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new i; i < sizeof(Dealership_GlobalTD); i++) {
            TextDrawHideForPlayer(playerid, Dealership_GlobalTD[i]);
        }
        CancelSelectTextDraw(playerid);
    }
}

stock ToggleContractUI(playerid, bool:toggle = true) {
    if (toggle) {

        Contract_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 316.000, 104.000, "Ottos Autos");
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][0], 0.266, 1.250);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][0], 400.000, 197.000);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][0], TEXT_DRAW_ALIGN_CENTER);
        PlayerTextDrawColour(playerid, Contract_PTD[playerid][0], -1);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][0], 0);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][0], 1);
        PlayerTextDrawBackgroundColour(playerid, Contract_PTD[playerid][0], 255);
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][0], TEXT_DRAW_FONT_2);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][0], true);

        Contract_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 314.000, 128.000, "Ugovor o kupovini: Infernus");
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][1], 0.170, 0.750);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][1], 400.000, 197.000);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][1], TEXT_DRAW_ALIGN_CENTER);
        PlayerTextDrawColour(playerid, Contract_PTD[playerid][1], 1296911871);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][1], 0);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][1], 0);
        PlayerTextDrawBackgroundColour(playerid, Contract_PTD[playerid][1], 255);
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][1], TEXT_DRAW_FONT_1);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][1], true);

        Contract_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 211.000, 159.000, "Vozilo: Infernus~n~Boja: Svijetlo Zelena~n~Felge: Switch~n~Cijena: $1");
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][2], 0.170, 0.750);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][2], 400.000, 197.000);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][2], TEXT_DRAW_ALIGN_LEFT);
        PlayerTextDrawColour(playerid, Contract_PTD[playerid][2], 1296911871);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][2], 0);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][2], 0);
        PlayerTextDrawBackgroundColour(playerid, Contract_PTD[playerid][2], 255);
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][2], TEXT_DRAW_FONT_1);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][2], true);

        Contract_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 243.000, 215.000, "BANKOVNI TRANSFER");
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][3], 0.170, 0.750);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][3], 400.000, 197.000);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][3], TEXT_DRAW_ALIGN_LEFT);
        PlayerTextDrawColour(playerid, Contract_PTD[playerid][3], 1296911871);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][3], 0);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][3], 0);
        PlayerTextDrawBackgroundColour(playerid, Contract_PTD[playerid][3], 255);
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][3], TEXT_DRAW_FONT_2);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][3], true);

        Contract_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 238.000, 313.000, "Ottos Autos Dealership");
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][4], 0.170, 0.750);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][4], 400.000, 197.000);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][4], TEXT_DRAW_ALIGN_CENTER);
        PlayerTextDrawColour(playerid, Contract_PTD[playerid][4], 1296911871);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][4], 0);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][4], 0);
        PlayerTextDrawBackgroundColour(playerid, Contract_PTD[playerid][4], 255);
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][4], TEXT_DRAW_FONT_1);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][4], true);

        Contract_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 385.000, 313.000, "385.000000, 313.000000, ReturnPlayerName(playerid));");
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][5], 0.170, 0.750);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][5], 400.000, 197.000);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][5], TEXT_DRAW_ALIGN_CENTER);
        PlayerTextDrawColour(playerid, Contract_PTD[playerid][5], 1296911871);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][5], 0);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][5], 0);
        PlayerTextDrawBackgroundColour(playerid, Contract_PTD[playerid][5], 255);
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][5], TEXT_DRAW_FONT_1);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][5], true);

        Contract_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 314.000, 338.000, "POTVRDI: ~g~$1");
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][6], 0.258, 1.100);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][6], 19.500, 200.000);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][6], TEXT_DRAW_ALIGN_CENTER);
        PlayerTextDrawColour(playerid, Contract_PTD[playerid][6], -1);
        PlayerTextDrawUseBox(playerid, Contract_PTD[playerid][6], true);
        PlayerTextDrawBoxColour(playerid, Contract_PTD[playerid][6], 1296911816);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][6], 0);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][6], 1);
        PlayerTextDrawBackgroundColour(playerid, Contract_PTD[playerid][6], 255);
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][6], TEXT_DRAW_FONT_1);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][6], true);
        PlayerTextDrawSetSelectable(playerid, Contract_PTD[playerid][6], true);

        for(new i; i < sizeof(Contract_GlobalTD); i++) {
            TextDrawShowForPlayer(playerid, Contract_GlobalTD[i]);
        }

        for(new i; i < 7; i++) {
            PlayerTextDrawShow(playerid, Contract_PTD[playerid][i]);
        }

        SelectTextDraw( playerid, 0x12C706FF );
    }
    else {
        for(new i = 0; i < 7; i++) {
            if(Contract_PTD[playerid][i] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, Contract_PTD[playerid][i]);
            Contract_PTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new i; i < sizeof(Contract_GlobalTD); i++) {
            TextDrawHideForPlayer(playerid, Contract_GlobalTD[i]);
        }
        CancelSelectTextDraw(playerid);
    }
}

hook OnGameModeInit() {
    DS_LoadDealershipsData();
    DS_LoadGlobalTextDraws();
}

DS_LoadDealershipsData() {
    new format_string[220];
    for(new i; i < sizeof(Dealership); i++) {
        form:format_string(""c_blue"°°°°°°°°°°°°°°°°°°°°\nDealership\n{FFFFFF}%s\n\n"c_blue"Katalog salona: {FFFFFF}/katalog\n"c_blue"Brza tipka: {FFFFFF}F\n"c_blue"°°°°°°°°°°°°°°°°°°°°", Dealership[i][dship_name]);
        Dealership[i][dship_label] = CreateDynamic3DTextLabel(format_string, 0xFFFFFFFF, Dealership[i][dship_pos][0], Dealership[i][dship_pos][1], Dealership[i][dship_pos][2] + 1, 15.0, .interiorid = Dealership[i][dship_int], .worldid = Dealership[i][dship_vw], .testlos = 1);
        Dealership[i][dship_pickup] = CreateDynamicPickup(1272, 1, Dealership[i][dship_pos][0], Dealership[i][dship_pos][1], Dealership[i][dship_pos][2], .interiorid = Dealership[i][dship_int], .worldid = Dealership[i][dship_vw]);
        Dealership[i][dship_vehicle_id] = CreateVehicle(
                Dealership[i][dship_veh_models][0], 
                Dealership[i][dship_vehicle_pos][0], Dealership[i][dship_vehicle_pos][1], Dealership[i][dship_vehicle_pos][2], 
                Dealership[i][dship_vehicle_pos][3], 
                1, 1, -1
            );
        LinkVehicleToInterior(Dealership[i][dship_vehicle_id], Dealership[i][dship_int]);
        SetVehicleVirtualWorld(Dealership[i][dship_vehicle_id], Dealership[i][dship_vw]);
        Dealership[i][dship_player_id] = -1;
    }
}

DS_LoadGlobalTextDraws() {
    // Dealership
    Dealership_GlobalTD[0] = TextDrawCreate(124.000, 137.000, "_");
    TextDrawLetterSize(Dealership_GlobalTD[0], 0.625, 21.650);
    TextDrawTextSize(Dealership_GlobalTD[0], 298.500, 200.000);
    TextDrawAlignment(Dealership_GlobalTD[0], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Dealership_GlobalTD[0], -1);
    TextDrawUseBox(Dealership_GlobalTD[0], true);
    TextDrawBoxColour(Dealership_GlobalTD[0], 1097458055);
    TextDrawSetShadow(Dealership_GlobalTD[0], 0);
    TextDrawSetOutline(Dealership_GlobalTD[0], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[0], 255);
    TextDrawFont(Dealership_GlobalTD[0], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Dealership_GlobalTD[0], true);

    Dealership_GlobalTD[1] = TextDrawCreate(124.000, 141.000, "_");
    TextDrawLetterSize(Dealership_GlobalTD[1], 0.625, 20.650);
    TextDrawTextSize(Dealership_GlobalTD[1], 298.500, 193.500);
    TextDrawAlignment(Dealership_GlobalTD[1], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Dealership_GlobalTD[1], -1);
    TextDrawUseBox(Dealership_GlobalTD[1], true);
    TextDrawBoxColour(Dealership_GlobalTD[1], 135);
    TextDrawSetShadow(Dealership_GlobalTD[1], 0);
    TextDrawSetOutline(Dealership_GlobalTD[1], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[1], 255);
    TextDrawFont(Dealership_GlobalTD[1], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Dealership_GlobalTD[1], true);

    Dealership_GlobalTD[2] = TextDrawCreate(98.000, 150.000, "dealership");
    TextDrawLetterSize(Dealership_GlobalTD[2], 0.283, 1.050);
    TextDrawTextSize(Dealership_GlobalTD[2], 400.000, 17.000);
    TextDrawAlignment(Dealership_GlobalTD[2], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[2], -1);
    TextDrawUseBox(Dealership_GlobalTD[2], true);
    TextDrawBoxColour(Dealership_GlobalTD[2], 0);
    TextDrawSetShadow(Dealership_GlobalTD[2], 0);
    TextDrawSetOutline(Dealership_GlobalTD[2], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[2], 255);
    TextDrawFont(Dealership_GlobalTD[2], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Dealership_GlobalTD[2], true);

    Dealership_GlobalTD[3] = TextDrawCreate(124.000, 163.000, "_");
    TextDrawLetterSize(Dealership_GlobalTD[3], 0.625, 0.049);
    TextDrawTextSize(Dealership_GlobalTD[3], 298.500, 194.000);
    TextDrawAlignment(Dealership_GlobalTD[3], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Dealership_GlobalTD[3], -1);
    TextDrawUseBox(Dealership_GlobalTD[3], true);
    TextDrawBoxColour(Dealership_GlobalTD[3], 1097458055);
    TextDrawSetShadow(Dealership_GlobalTD[3], 0);
    TextDrawSetOutline(Dealership_GlobalTD[3], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[3], 255);
    TextDrawFont(Dealership_GlobalTD[3], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Dealership_GlobalTD[3], true);

    Dealership_GlobalTD[4] = TextDrawCreate(34.000, 172.000, "MODEL:");
    TextDrawLetterSize(Dealership_GlobalTD[4], 0.283, 1.050);
    TextDrawTextSize(Dealership_GlobalTD[4], 400.000, 17.000);
    TextDrawAlignment(Dealership_GlobalTD[4], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[4], -1);
    TextDrawUseBox(Dealership_GlobalTD[4], true);
    TextDrawBoxColour(Dealership_GlobalTD[4], 0);
    TextDrawSetShadow(Dealership_GlobalTD[4], 0);
    TextDrawSetOutline(Dealership_GlobalTD[4], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[4], 255);
    TextDrawFont(Dealership_GlobalTD[4], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Dealership_GlobalTD[4], true);

    Dealership_GlobalTD[5] = TextDrawCreate(73.000, 171.000, "ld_beat:left");
    TextDrawLetterSize(Dealership_GlobalTD[5], 0.600, 2.000);
    TextDrawTextSize(Dealership_GlobalTD[5], 13.000, 12.500);
    TextDrawAlignment(Dealership_GlobalTD[5], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[5], -1);
    TextDrawUseBox(Dealership_GlobalTD[5], true);
    TextDrawBoxColour(Dealership_GlobalTD[5], 50);
    TextDrawSetShadow(Dealership_GlobalTD[5], 0);
    TextDrawSetOutline(Dealership_GlobalTD[5], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[5], 255);
    TextDrawFont(Dealership_GlobalTD[5], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Dealership_GlobalTD[5], true);
    TextDrawSetSelectable(Dealership_GlobalTD[5], true);

    Dealership_GlobalTD[6] = TextDrawCreate(92.000, 171.000, "LD_BEAT:right");
    TextDrawLetterSize(Dealership_GlobalTD[6], 0.600, 2.000);
    TextDrawTextSize(Dealership_GlobalTD[6], 13.000, 12.500);
    TextDrawAlignment(Dealership_GlobalTD[6], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[6], -1);
    TextDrawUseBox(Dealership_GlobalTD[6], true);
    TextDrawBoxColour(Dealership_GlobalTD[6], 50);
    TextDrawSetShadow(Dealership_GlobalTD[6], 0);
    TextDrawSetOutline(Dealership_GlobalTD[6], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[6], 255);
    TextDrawFont(Dealership_GlobalTD[6], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Dealership_GlobalTD[6], true);
    TextDrawSetSelectable(Dealership_GlobalTD[6], true);

    Dealership_GlobalTD[7] = TextDrawCreate(34.000, 191.000, "GORIVO:");
    TextDrawLetterSize(Dealership_GlobalTD[7], 0.283, 1.050);
    TextDrawTextSize(Dealership_GlobalTD[7], 400.000, 17.000);
    TextDrawAlignment(Dealership_GlobalTD[7], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[7], -1);
    TextDrawUseBox(Dealership_GlobalTD[7], true);
    TextDrawBoxColour(Dealership_GlobalTD[7], 0);
    TextDrawSetShadow(Dealership_GlobalTD[7], 0);
    TextDrawSetOutline(Dealership_GlobalTD[7], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[7], 255);
    TextDrawFont(Dealership_GlobalTD[7], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Dealership_GlobalTD[7], true);

    Dealership_GlobalTD[8] = TextDrawCreate(73.000, 190.000, "ld_beat:left");
    TextDrawLetterSize(Dealership_GlobalTD[8], 0.600, 2.000);
    TextDrawTextSize(Dealership_GlobalTD[8], 13.000, 12.500);
    TextDrawAlignment(Dealership_GlobalTD[8], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[8], -1);
    TextDrawUseBox(Dealership_GlobalTD[8], true);
    TextDrawBoxColour(Dealership_GlobalTD[8], 50);
    TextDrawSetShadow(Dealership_GlobalTD[8], 0);
    TextDrawSetOutline(Dealership_GlobalTD[8], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[8], 255);
    TextDrawFont(Dealership_GlobalTD[8], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Dealership_GlobalTD[8], true);
    TextDrawSetSelectable(Dealership_GlobalTD[8], true);

    Dealership_GlobalTD[9] = TextDrawCreate(92.000, 190.000, "LD_BEAT:right");
    TextDrawLetterSize(Dealership_GlobalTD[9], 0.600, 2.000);
    TextDrawTextSize(Dealership_GlobalTD[9], 13.000, 12.500);
    TextDrawAlignment(Dealership_GlobalTD[9], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[9], -1);
    TextDrawUseBox(Dealership_GlobalTD[9], true);
    TextDrawBoxColour(Dealership_GlobalTD[9], 50);
    TextDrawSetShadow(Dealership_GlobalTD[9], 0);
    TextDrawSetOutline(Dealership_GlobalTD[9], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[9], 255);
    TextDrawFont(Dealership_GlobalTD[9], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Dealership_GlobalTD[9], true);
    TextDrawSetSelectable(Dealership_GlobalTD[9], true);

    Dealership_GlobalTD[10] = TextDrawCreate(124.000, 209.000, "_");
    TextDrawLetterSize(Dealership_GlobalTD[10], 0.625, 0.049);
    TextDrawTextSize(Dealership_GlobalTD[10], 298.500, 194.000);
    TextDrawAlignment(Dealership_GlobalTD[10], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Dealership_GlobalTD[10], -1);
    TextDrawUseBox(Dealership_GlobalTD[10], true);
    TextDrawBoxColour(Dealership_GlobalTD[10], 1097458055);
    TextDrawSetShadow(Dealership_GlobalTD[10], 0);
    TextDrawSetOutline(Dealership_GlobalTD[10], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[10], 255);
    TextDrawFont(Dealership_GlobalTD[10], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Dealership_GlobalTD[10], true);

    Dealership_GlobalTD[11] = TextDrawCreate(34.000, 214.000, "Zeljene specifikacije:");
    TextDrawLetterSize(Dealership_GlobalTD[11], 0.283, 1.050);
    TextDrawTextSize(Dealership_GlobalTD[11], 400.000, 17.000);
    TextDrawAlignment(Dealership_GlobalTD[11], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[11], -1);
    TextDrawUseBox(Dealership_GlobalTD[11], true);
    TextDrawBoxColour(Dealership_GlobalTD[11], 0);
    TextDrawSetShadow(Dealership_GlobalTD[11], 0);
    TextDrawSetOutline(Dealership_GlobalTD[11], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[11], 255);
    TextDrawFont(Dealership_GlobalTD[11], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Dealership_GlobalTD[11], true);

    Dealership_GlobalTD[12] = TextDrawCreate(43.000, 237.000, "ld_beat:left");
    TextDrawLetterSize(Dealership_GlobalTD[12], 0.600, 2.000);
    TextDrawTextSize(Dealership_GlobalTD[12], 13.000, 12.500);
    TextDrawAlignment(Dealership_GlobalTD[12], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[12], -1);
    TextDrawUseBox(Dealership_GlobalTD[12], true);
    TextDrawBoxColour(Dealership_GlobalTD[12], 50);
    TextDrawSetShadow(Dealership_GlobalTD[12], 0);
    TextDrawSetOutline(Dealership_GlobalTD[12], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[12], 255);
    TextDrawFont(Dealership_GlobalTD[12], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Dealership_GlobalTD[12], true);
    TextDrawSetSelectable(Dealership_GlobalTD[12], true);

    Dealership_GlobalTD[13] = TextDrawCreate(82.000, 237.000, "LD_BEAT:right");
    TextDrawLetterSize(Dealership_GlobalTD[13], 0.600, 2.000);
    TextDrawTextSize(Dealership_GlobalTD[13], 13.000, 12.500);
    TextDrawAlignment(Dealership_GlobalTD[13], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[13], -1);
    TextDrawUseBox(Dealership_GlobalTD[13], true);
    TextDrawBoxColour(Dealership_GlobalTD[13], 50);
    TextDrawSetShadow(Dealership_GlobalTD[13], 0);
    TextDrawSetOutline(Dealership_GlobalTD[13], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[13], 255);
    TextDrawFont(Dealership_GlobalTD[13], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Dealership_GlobalTD[13], true);
    TextDrawSetSelectable(Dealership_GlobalTD[13], true);

    Dealership_GlobalTD[14] = TextDrawCreate(139.000, 237.000, "ld_beat:left");
    TextDrawLetterSize(Dealership_GlobalTD[14], 0.600, 2.000);
    TextDrawTextSize(Dealership_GlobalTD[14], 13.000, 12.500);
    TextDrawAlignment(Dealership_GlobalTD[14], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[14], -1);
    TextDrawUseBox(Dealership_GlobalTD[14], true);
    TextDrawBoxColour(Dealership_GlobalTD[14], 50);
    TextDrawSetShadow(Dealership_GlobalTD[14], 0);
    TextDrawSetOutline(Dealership_GlobalTD[14], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[14], 255);
    TextDrawFont(Dealership_GlobalTD[14], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Dealership_GlobalTD[14], true);
    TextDrawSetSelectable(Dealership_GlobalTD[14], true);

    Dealership_GlobalTD[15] = TextDrawCreate(184.000, 237.000, "LD_BEAT:right");
    TextDrawLetterSize(Dealership_GlobalTD[15], 0.600, 2.000);
    TextDrawTextSize(Dealership_GlobalTD[15], 13.000, 12.500);
    TextDrawAlignment(Dealership_GlobalTD[15], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Dealership_GlobalTD[15], -1);
    TextDrawUseBox(Dealership_GlobalTD[15], true);
    TextDrawBoxColour(Dealership_GlobalTD[15], 50);
    TextDrawSetShadow(Dealership_GlobalTD[15], 0);
    TextDrawSetOutline(Dealership_GlobalTD[15], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[15], 255);
    TextDrawFont(Dealership_GlobalTD[15], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Dealership_GlobalTD[15], true);
    TextDrawSetSelectable(Dealership_GlobalTD[15], true);

    Dealership_GlobalTD[16] = TextDrawCreate(124.000, 271.000, "_");
    TextDrawLetterSize(Dealership_GlobalTD[16], 0.625, 0.049);
    TextDrawTextSize(Dealership_GlobalTD[16], 298.500, 194.000);
    TextDrawAlignment(Dealership_GlobalTD[16], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Dealership_GlobalTD[16], -1);
    TextDrawUseBox(Dealership_GlobalTD[16], true);
    TextDrawBoxColour(Dealership_GlobalTD[16], 1097458055);
    TextDrawSetShadow(Dealership_GlobalTD[16], 0);
    TextDrawSetOutline(Dealership_GlobalTD[16], 1);
    TextDrawBackgroundColour(Dealership_GlobalTD[16], 255);
    TextDrawFont(Dealership_GlobalTD[16], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Dealership_GlobalTD[16], true);

    // Contract
    Contract_GlobalTD[0] = TextDrawCreate(315.000, 98.000, "_");
    TextDrawLetterSize(Contract_GlobalTD[0], 0.600, 26.300);
    TextDrawTextSize(Contract_GlobalTD[0], 298.500, 239.500);
    TextDrawAlignment(Contract_GlobalTD[0], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Contract_GlobalTD[0], -1);
    TextDrawUseBox(Contract_GlobalTD[0], true);
    TextDrawBoxColour(Contract_GlobalTD[0], -1094795521);
    TextDrawSetShadow(Contract_GlobalTD[0], 0);
    TextDrawSetOutline(Contract_GlobalTD[0], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[0], 255);
    TextDrawFont(Contract_GlobalTD[0], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Contract_GlobalTD[0], true);

    Contract_GlobalTD[1] = TextDrawCreate(315.000, 104.000, "_");
    TextDrawLetterSize(Contract_GlobalTD[1], 0.600, 24.650);
    TextDrawTextSize(Contract_GlobalTD[1], 298.500, 227.500);
    TextDrawAlignment(Contract_GlobalTD[1], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Contract_GlobalTD[1], -1);
    TextDrawUseBox(Contract_GlobalTD[1], true);
    TextDrawBoxColour(Contract_GlobalTD[1], -161);
    TextDrawSetShadow(Contract_GlobalTD[1], 0);
    TextDrawSetOutline(Contract_GlobalTD[1], 2);
    TextDrawBackgroundColour(Contract_GlobalTD[1], 255);
    TextDrawFont(Contract_GlobalTD[1], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Contract_GlobalTD[1], true);

    Contract_GlobalTD[2] = TextDrawCreate(316.000, 115.000, "deal contract");
    TextDrawLetterSize(Contract_GlobalTD[2], 0.266, 0.949);
    TextDrawTextSize(Contract_GlobalTD[2], 400.000, 197.000);
    TextDrawAlignment(Contract_GlobalTD[2], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Contract_GlobalTD[2], -1);
    TextDrawSetShadow(Contract_GlobalTD[2], 0);
    TextDrawSetOutline(Contract_GlobalTD[2], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[2], 255);
    TextDrawFont(Contract_GlobalTD[2], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Contract_GlobalTD[2], true);

    Contract_GlobalTD[3] = TextDrawCreate(264.000, 147.000, "Odabrane postavke kupovine:");
    TextDrawLetterSize(Contract_GlobalTD[3], 0.220, 0.850);
    TextDrawTextSize(Contract_GlobalTD[3], 400.000, 197.000);
    TextDrawAlignment(Contract_GlobalTD[3], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Contract_GlobalTD[3], -1);
    TextDrawSetShadow(Contract_GlobalTD[3], 0);
    TextDrawSetOutline(Contract_GlobalTD[3], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[3], 255);
    TextDrawFont(Contract_GlobalTD[3], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Contract_GlobalTD[3], true);

    Contract_GlobalTD[4] = TextDrawCreate(258.000, 200.000, "odaberite nacin placanja:");
    TextDrawLetterSize(Contract_GlobalTD[4], 0.220, 0.850);
    TextDrawTextSize(Contract_GlobalTD[4], 400.000, 197.000);
    TextDrawAlignment(Contract_GlobalTD[4], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Contract_GlobalTD[4], -1);
    TextDrawSetShadow(Contract_GlobalTD[4], 0);
    TextDrawSetOutline(Contract_GlobalTD[4], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[4], 255);
    TextDrawFont(Contract_GlobalTD[4], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Contract_GlobalTD[4], true);

    Contract_GlobalTD[5] = TextDrawCreate(210.000, 213.000, "ld_beat:left");
    TextDrawLetterSize(Contract_GlobalTD[5], 0.600, 2.000);
    TextDrawTextSize(Contract_GlobalTD[5], 11.500, 12.000);
    TextDrawAlignment(Contract_GlobalTD[5], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Contract_GlobalTD[5], -1);
    TextDrawUseBox(Contract_GlobalTD[5], true);
    TextDrawBoxColour(Contract_GlobalTD[5], 50);
    TextDrawSetShadow(Contract_GlobalTD[5], 0);
    TextDrawSetOutline(Contract_GlobalTD[5], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[5], 255);
    TextDrawFont(Contract_GlobalTD[5], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Contract_GlobalTD[5], true);
    TextDrawSetSelectable(Contract_GlobalTD[5], true);

    Contract_GlobalTD[6] = TextDrawCreate(228.000, 213.000, "LD_BEAT:right");
    TextDrawLetterSize(Contract_GlobalTD[6], 0.600, 2.000);
    TextDrawTextSize(Contract_GlobalTD[6], 11.500, 12.000);
    TextDrawAlignment(Contract_GlobalTD[6], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Contract_GlobalTD[6], -1);
    TextDrawUseBox(Contract_GlobalTD[6], true);
    TextDrawBoxColour(Contract_GlobalTD[6], 50);
    TextDrawSetShadow(Contract_GlobalTD[6], 0);
    TextDrawSetOutline(Contract_GlobalTD[6], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[6], 255);
    TextDrawFont(Contract_GlobalTD[6], TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetProportional(Contract_GlobalTD[6], true);
    TextDrawSetSelectable(Contract_GlobalTD[6], true);

    Contract_GlobalTD[7] = TextDrawCreate(207.000, 286.000, "Prodaje:");
    TextDrawLetterSize(Contract_GlobalTD[7], 0.220, 0.850);
    TextDrawTextSize(Contract_GlobalTD[7], 400.000, 197.000);
    TextDrawAlignment(Contract_GlobalTD[7], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Contract_GlobalTD[7], -1);
    TextDrawSetShadow(Contract_GlobalTD[7], 0);
    TextDrawSetOutline(Contract_GlobalTD[7], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[7], 255);
    TextDrawFont(Contract_GlobalTD[7], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Contract_GlobalTD[7], true);

    Contract_GlobalTD[8] = TextDrawCreate(354.000, 286.000, "Kupuje:");
    TextDrawLetterSize(Contract_GlobalTD[8], 0.220, 0.850);
    TextDrawTextSize(Contract_GlobalTD[8], 400.000, 197.000);
    TextDrawAlignment(Contract_GlobalTD[8], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Contract_GlobalTD[8], -1);
    TextDrawSetShadow(Contract_GlobalTD[8], 0);
    TextDrawSetOutline(Contract_GlobalTD[8], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[8], 255);
    TextDrawFont(Contract_GlobalTD[8], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Contract_GlobalTD[8], true);

    Contract_GlobalTD[9] = TextDrawCreate(206.000, 303.000, "-------------------");
    TextDrawLetterSize(Contract_GlobalTD[9], 0.220, 0.850);
    TextDrawTextSize(Contract_GlobalTD[9], 400.000, 197.000);
    TextDrawAlignment(Contract_GlobalTD[9], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Contract_GlobalTD[9], 255);
    TextDrawSetShadow(Contract_GlobalTD[9], 0);
    TextDrawSetOutline(Contract_GlobalTD[9], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[9], 255);
    TextDrawFont(Contract_GlobalTD[9], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Contract_GlobalTD[9], true);

    Contract_GlobalTD[10] = TextDrawCreate(353.000, 303.000, "-------------------");
    TextDrawLetterSize(Contract_GlobalTD[10], 0.220, 0.850);
    TextDrawTextSize(Contract_GlobalTD[10], 400.000, 197.000);
    TextDrawAlignment(Contract_GlobalTD[10], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Contract_GlobalTD[10], 255);
    TextDrawSetShadow(Contract_GlobalTD[10], 0);
    TextDrawSetOutline(Contract_GlobalTD[10], 1);
    TextDrawBackgroundColour(Contract_GlobalTD[10], 255);
    TextDrawFont(Contract_GlobalTD[10], TEXT_DRAW_FONT_3);
    TextDrawSetProportional(Contract_GlobalTD[10], true);

    Contract_GlobalTD[11] = TextDrawCreate(197.000, 292.000, "Preview_Model");
    TextDrawLetterSize(Contract_GlobalTD[11], 0.600, 2.000);
    TextDrawTextSize(Contract_GlobalTD[11], 84.000, 25.000);
    TextDrawAlignment(Contract_GlobalTD[11], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Contract_GlobalTD[11], 255);
    TextDrawSetShadow(Contract_GlobalTD[11], 0);
    TextDrawSetOutline(Contract_GlobalTD[11], 0);
    TextDrawBackgroundColour(Contract_GlobalTD[11], 0);
    TextDrawFont(Contract_GlobalTD[11], TEXT_DRAW_FONT_MODEL_PREVIEW);
    TextDrawSetProportional(Contract_GlobalTD[11], true);
    TextDrawSetPreviewModel(Contract_GlobalTD[11], 1490);
    TextDrawSetPreviewRot(Contract_GlobalTD[11], 6.000, 0.000, -61.000, 1.000);
    TextDrawSetPreviewVehicleColours(Contract_GlobalTD[11], 1, 1);

    Contract_GlobalTD[12] = TextDrawCreate(343.000, 316.000, "Preview_Model");
    TextDrawLetterSize(Contract_GlobalTD[12], 0.600, 2.000);
    TextDrawTextSize(Contract_GlobalTD[12], 89.000, -25.500);
    TextDrawAlignment(Contract_GlobalTD[12], TEXT_DRAW_ALIGN_LEFT);
    TextDrawColour(Contract_GlobalTD[12], 255);
    TextDrawSetShadow(Contract_GlobalTD[12], 0);
    TextDrawSetOutline(Contract_GlobalTD[12], 0);
    TextDrawBackgroundColour(Contract_GlobalTD[12], 0);
    TextDrawFont(Contract_GlobalTD[12], TEXT_DRAW_FONT_MODEL_PREVIEW);
    TextDrawSetProportional(Contract_GlobalTD[12], true);
    TextDrawSetPreviewModel(Contract_GlobalTD[12], 1531);
    TextDrawSetPreviewRot(Contract_GlobalTD[12], 6.000, 0.000, -61.000, 1.000);
    TextDrawSetPreviewVehicleColours(Contract_GlobalTD[12], 1, 1);
}