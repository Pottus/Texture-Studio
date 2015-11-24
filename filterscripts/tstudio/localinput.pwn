#define VK_KEY_0	0x30
#define VK_KEY_1	0x31
#define VK_KEY_2	0x32
#define VK_KEY_3	0x33
#define VK_KEY_4	0x34
#define VK_KEY_5	0x35
#define VK_KEY_6	0x36
#define VK_KEY_7	0x37
#define VK_KEY_8	0x38
#define VK_KEY_9	0x39

#define VK_KEY_A	0x41
#define VK_KEY_B	0x42
#define VK_KEY_C	0x43
#define VK_KEY_D	0x44
#define VK_KEY_E	0x45
#define VK_KEY_F	0x46
#define VK_KEY_G	0x47
#define VK_KEY_H	0x48
#define VK_KEY_I	0x49
#define VK_KEY_J	0x4A
#define VK_KEY_K	0x4B
#define VK_KEY_L	0x4C
#define VK_KEY_M	0x4D
#define VK_KEY_N	0x4E
#define VK_KEY_O	0x4F
#define VK_KEY_P	0x50
#define VK_KEY_Q	0x51
#define VK_KEY_R	0x52
#define VK_KEY_S	0x53
#define VK_KEY_T	0x54
#define VK_KEY_U	0x55
#define VK_KEY_V	0x56
#define VK_KEY_W	0x57
#define VK_KEY_X	0x58
#define VK_KEY_Y	0x59
#define VK_KEY_Z	0x5A

#define VK_LBUTTON	0x01
#define VK_MBUTTON	0x04
#define VK_RBUTTON	0x02

#define VK_UP		0x26
#define VK_DOWN		0x28
#define VK_LEFT		0x25
#define VK_RIGHT	0x27

#define VK_LSHIFT	0xA0
#define VK_RSHIFT	0xA1

#define VK_SPACE	0x20

native GetVirtualKeyState(key);
native GetScreenSize(&Width, &Height);
native GetMousePos(&X, &Y);

#include <colandreas>

forward OnCursorPositionChange(OldX, OldY, NewX, NewY);
forward OnVirtualKeyDown(key);
forward OnVirtualKeyRelease(key);

forward OnEditorUpdate();

enum E_KEY_STRUCT
{
	bool:KEY_PRESSED,
	KEY_CODE
};

static
	editorid,
	CursorOX, CursorOY,
	CursorX, CursorY,
	ScreenWidth, ScreenHeight,
	VirtualKeys[46][E_KEY_STRUCT];

public OnFilterScriptInit()
{
	VirtualKeys[00][KEY_CODE] = VK_KEY_0;
	VirtualKeys[01][KEY_CODE] = VK_KEY_1;
	VirtualKeys[02][KEY_CODE] = VK_KEY_2;
	VirtualKeys[03][KEY_CODE] = VK_KEY_3;
	VirtualKeys[04][KEY_CODE] = VK_KEY_4;
	VirtualKeys[05][KEY_CODE] = VK_KEY_5;
	VirtualKeys[06][KEY_CODE] = VK_KEY_6;
	VirtualKeys[07][KEY_CODE] = VK_KEY_7;
	VirtualKeys[08][KEY_CODE] = VK_KEY_8;
	VirtualKeys[09][KEY_CODE] = VK_KEY_9;
	VirtualKeys[10][KEY_CODE] = VK_KEY_A;
	VirtualKeys[11][KEY_CODE] = VK_KEY_B;
	VirtualKeys[12][KEY_CODE] = VK_KEY_C;
	VirtualKeys[13][KEY_CODE] = VK_KEY_D;
	VirtualKeys[14][KEY_CODE] = VK_KEY_E;
	VirtualKeys[15][KEY_CODE] = VK_KEY_F;
	VirtualKeys[16][KEY_CODE] = VK_KEY_G;
	VirtualKeys[17][KEY_CODE] = VK_KEY_H;
	VirtualKeys[18][KEY_CODE] = VK_KEY_I;
	VirtualKeys[19][KEY_CODE] = VK_KEY_J;
	VirtualKeys[20][KEY_CODE] = VK_KEY_K;
	VirtualKeys[21][KEY_CODE] = VK_KEY_L;
	VirtualKeys[22][KEY_CODE] = VK_KEY_M;
	VirtualKeys[23][KEY_CODE] = VK_KEY_N;
	VirtualKeys[24][KEY_CODE] = VK_KEY_O;
	VirtualKeys[25][KEY_CODE] = VK_KEY_P;
	VirtualKeys[26][KEY_CODE] = VK_KEY_Q;
	VirtualKeys[27][KEY_CODE] = VK_KEY_R;
	VirtualKeys[28][KEY_CODE] = VK_KEY_S;
	VirtualKeys[29][KEY_CODE] = VK_KEY_T;
	VirtualKeys[30][KEY_CODE] = VK_KEY_U;
	VirtualKeys[31][KEY_CODE] = VK_KEY_V;
	VirtualKeys[32][KEY_CODE] = VK_KEY_W;
	VirtualKeys[33][KEY_CODE] = VK_KEY_X;
	VirtualKeys[34][KEY_CODE] = VK_KEY_Y;
	VirtualKeys[35][KEY_CODE] = VK_KEY_Z;
	VirtualKeys[36][KEY_CODE] = VK_LBUTTON;
	VirtualKeys[37][KEY_CODE] = VK_MBUTTON;
	VirtualKeys[38][KEY_CODE] = VK_RBUTTON;
	VirtualKeys[39][KEY_CODE] = VK_LEFT;
	VirtualKeys[40][KEY_CODE] = VK_RIGHT;
	VirtualKeys[41][KEY_CODE] = VK_UP;
	VirtualKeys[42][KEY_CODE] = VK_DOWN;
	VirtualKeys[43][KEY_CODE] = VK_LSHIFT;
	VirtualKeys[44][KEY_CODE] = VK_RSHIFT;
	VirtualKeys[45][KEY_CODE] = VK_SPACE;

	editorid = INVALID_PLAYER_ID;
	SetTimer("OnEditorUpdate", 25, true);

	#if defined LI_OnFilterScriptInit
		LI_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit LI_OnFilterScriptInit
#if defined LI_OnFilterScriptInit
	forward LI_OnFilterScriptInit();
#endif

public OnPlayerConnect(playerid)
{
	if(editorid != INVALID_PLAYER_ID)
		return 1;
		
	new ip[24];
	GetPlayerIp(playerid, ip, 24);
	
	if(!strcmp(ip, "127.0.0.1"))
		editorid = playerid;

	#if defined LI_OnPlayerConnect
		LI_OnPlayerConnect(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect LI_OnPlayerConnect
#if defined LI_OnPlayerConnect
	forward LI_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
	if(editorid == playerid)
		editorid = INVALID_PLAYER_ID;
		
    #if defined LI_OnPlayerDisconnect
        LI_OnPlayerDisconnect(playerid, reason);
    #endif
    return 1;
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect LI_OnPlayerDisconnect
#if defined LI_OnPlayerDisconnect
    forward LI_OnPlayerDisconnect(playerid, reason);
#endif

public OnEditorUpdate()
{
	if(editorid == INVALID_PLAYER_ID)
		return 1;

	for(new c; c < sizeof VirtualKeys; c++)
	{
		if(GetVirtualKeyState(VirtualKeys[c][KEY_CODE]) & 0x8000)
		{
			if(!VirtualKeys[c][KEY_PRESSED])
			{
				CallLocalFunction("OnVirtualKeyDown", "d", VirtualKeys[c][KEY_CODE]);
				VirtualKeys[c][KEY_PRESSED] = true;
			}
			else
				CallLocalFunction("OnVirtualKeyHold", "d", VirtualKeys[c][KEY_CODE]);
		}
		else if(VirtualKeys[c][KEY_PRESSED])
		{
			CallLocalFunction("OnVirtualKeyRelease", "d", VirtualKeys[c][KEY_CODE]);
			VirtualKeys[c][KEY_PRESSED] = false;
		}
	}

	GetScreenSize(ScreenWidth, ScreenHeight);
	GetMousePos(CursorX, CursorY);
	CursorX = floatround(floatdiv(CursorX, ScreenWidth) * 640.0, floatround_floor);
	CursorY = floatround(floatdiv(CursorY, ScreenHeight) * 448.0, floatround_floor);

	if(CursorOX != CursorX || CursorOY != CursorY)
	{
		CallLocalFunction("OnCursorPositionChange", "dddd", CursorOX, CursorOY, CursorX, CursorY);
		CursorOX = CursorX;
		CursorOY = CursorY;
	}
	
	return 1;
}

public OnCursorPositionChange(OldX, OldY, NewX, NewY)
{
	if(editorid == INVALID_PLAYER_ID)
		return 1;
	
	//else
	return 1;
}

public OnVirtualKeyDown(key)
{
	if(editorid == INVALID_PLAYER_ID)
		return 1;
	
	if(GetVirtualKeyState(VK_KEY_B) & 0x8000) switch(key) {
		case VK_KEY_0:
			BroadcastCommand(editorid, "/runbind 0");
		case VK_KEY_1:
			BroadcastCommand(editorid, "/runbind 1");
		case VK_KEY_2:
			BroadcastCommand(editorid, "/runbind 2");
		case VK_KEY_3:
			BroadcastCommand(editorid, "/runbind 3");
		case VK_KEY_4:
			BroadcastCommand(editorid, "/runbind 4");
		case VK_KEY_5:
			BroadcastCommand(editorid, "/runbind 5");
		case VK_KEY_6:
			BroadcastCommand(editorid, "/runbind 6");
		case VK_KEY_7:
			BroadcastCommand(editorid, "/runbind 7");
		case VK_KEY_8:
			BroadcastCommand(editorid, "/runbind 8");
		case VK_KEY_9:
			BroadcastCommand(editorid, "/runbind 9");
	}
	else switch(key) {
		case VK_LBUTTON: {
		}
		case VK_MBUTTON: {
		}
		case VK_RBUTTON: {
			//Example Of Right Clicking On The Ground
			/*new Float:cX, Float:cY, Float:cZ,
				Float:wX, Float:wY, Float:wZ;
			if(ScreenToWorld(editorid, 320.0, 224.0, wX, wY, wZ)) {
					
				GetPlayerCameraPos(editorid, cX, cY, cZ);
				wX = cX + (wX * 300.0);
				wY = cY + (wY * 300.0);
				wZ = cZ + (wZ * 300.0);
				
				if(CA_RayCastLine(cX, cY, cZ, wX, wY, wZ, wX, wY, wZ)) {
					SendClientMessage(editorid, -1, "What do you want to do here?");
				}
			}*/
		}
	}
	
	return 1;
}

public OnVirtualKeyRelease(key)
{
	if(editorid == INVALID_PLAYER_ID)
		return 1;
	
	switch(key) {
		case VK_LBUTTON: {
		}
		case VK_MBUTTON: {
		}
		case VK_RBUTTON: {
		}
	}
	
	return 1;
}
