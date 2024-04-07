/*
    __                _          ________  ______
   / /   ____  ____ _(_)___     / ____/ / / /  _/
  / /   / __ \/ __ `/ / __ \   / / __/ / / // /  
 / /___/ /_/ / /_/ / / / / /  / /_/ / /_/ // /   
/_____/\____/\__, /_/_/ /_/   \____/\____/___/   
            /____/                               

    Developed by Danis Čavalić
*/

#include <ysilib\YSI_Coding\y_hooks>

new 
    Text:LoginGUI[2];
    
hook OnGameModeInit() {
    LoginGUI[0] = TextDrawCreate(157.000000, 139.000000, "~r~]~n~M~n~O~n~N~n~~w~A~n~C~n~O");
    TextDrawFont(LoginGUI[0], TEXT_DRAW_FONT:2);
    TextDrawLetterSize(LoginGUI[0], 0.600000, 2.000000);
    TextDrawTextSize(LoginGUI[0], 400.000000, 17.000000);
    TextDrawSetOutline(LoginGUI[0], 1);
    TextDrawSetShadow(LoginGUI[0], 0);
    TextDrawAlignment(LoginGUI[0], TEXT_DRAW_ALIGN:1);
    TextDrawColour(LoginGUI[0], -1);
    TextDrawBackgroundColour(LoginGUI[0], 255);
    TextDrawBoxColour(LoginGUI[0], 0);
    TextDrawUseBox(LoginGUI[0], true);
    TextDrawSetProportional(LoginGUI[0], true);
    TextDrawSetSelectable(LoginGUI[0], false);

    LoginGUI[1] = TextDrawCreate(439.000000, 139.000000, "~r~]~n~M~n~O~n~N~n~~w~A~n~C~n~O");
    TextDrawFont(LoginGUI[1], TEXT_DRAW_FONT:2);
    TextDrawLetterSize(LoginGUI[1], 0.600000, 2.000000);
    TextDrawTextSize(LoginGUI[1], 525.000000, 17.000000);
    TextDrawSetOutline(LoginGUI[1], 1);
    TextDrawSetShadow(LoginGUI[1], 0);
    TextDrawAlignment(LoginGUI[1], TEXT_DRAW_ALIGN:1);
    TextDrawColour(LoginGUI[1], -1);
    TextDrawBackgroundColour(LoginGUI[1], 255);
    TextDrawBoxColour(LoginGUI[1], 0);
    TextDrawUseBox(LoginGUI[1], true);
    TextDrawSetProportional(LoginGUI[1], true);
    TextDrawSetSelectable(LoginGUI[1], false);
}

stock ToggleWrapperGUI(playerid, bool:toggle = true) {
    if (toggle) {
        for(new i; i < sizeof(LoginGUI); i++) {
            TextDrawShowForPlayer(playerid, LoginGUI[i]);
        }
    }
    else {
        for(new i; i < sizeof(LoginGUI); i++) {
            TextDrawHideForPlayer(playerid, LoginGUI[i]);
        }
    }
}