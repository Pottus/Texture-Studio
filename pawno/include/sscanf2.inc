/*  
 *  Version: MPL 1.1
 *  
 *  The contents of this file are subject to the Mozilla Public License Version
 *  1.1 (the "License"); you may not use this file except in compliance with
 *  the License. You may obtain a copy of the License at
 *  [url]http://www.mozilla.org/MPL/[/url]
 *  
 *  Software distributed under the License is distributed on an "AS IS" basis,
 *  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 *  for the specific language governing rights and limitations under the
 *  License.
 *  
 *  The Original Code is the sscanf 2.0 SA:MP plugin.
 *  
 *  The Initial Developer of the Original Code is Alex "Y_Less" Cole.
 *  Portions created by the Initial Developer are Copyright (C) 2010
 *  the Initial Developer. All Rights Reserved.
 *  
 *  Contributor(s):
 *  
 *  Special Thanks to:
 *  
 *  SA:MP Team past, present and future
 */

#define SSCANF:%0(%1) sscanf_%0(%1);public sscanf_%0(%1)

#if defined sscanf
    #error sscanf (possibly the PAWN version) already defined.
#endif
native sscanf(const data[], const format[], {Float,_}:...);
native unformat(const data[], const format[], {Float,_}:...) = sscanf;
native SSCANF_Init(players, invalid, len);
native SSCANF_Join(playerid, const name[], npc);
native SSCANF_Leave(playerid);

static stock
    SSCANF_gInit = 0xFFFFFFFF,
    SSCANF_gOPC,
    SSCANF_gOPDC;

public OnFilterScriptInit()
{
    //printf("OnFilter");
    SSCANF_Init(GetMaxPlayers(), INVALID_PLAYER_ID, MAX_PLAYER_NAME);
    SSCANF_gInit = funcidx("SSCANF_OnGameModeInit") != -1;
    SSCANF_gOPC  = funcidx("SSCANF_OnPlayerConnect") != -1;
    SSCANF_gOPDC = funcidx("SSCANF_OnPlayerDisconnect") != -1;
    return CallLocalFunction("SSCANF_OnFilterScriptInit", "");
}

#if defined _ALS_OnFilterScriptInit
    #undef OnFilterScriptInit
#else
    #define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit SSCANF_OnFilterScriptInit

forward OnFilterScriptInit();

public OnGameModeInit()
{
    //printf("OnGameo");
    if (SSCANF_gInit == -1)
    {
        SSCANF_Init(GetMaxPlayers(), INVALID_PLAYER_ID, MAX_PLAYER_NAME);
        SSCANF_gInit = funcidx("SSCANF_OnGameModeInit") != -1;
        SSCANF_gOPC  = funcidx("SSCANF_OnPlayerConnect") != -1;
        SSCANF_gOPDC = funcidx("SSCANF_OnPlayerDisconnect") != -1;
    }
    if (SSCANF_gInit)
    {
        // Can't do the clever assembly version without y_amx.
        /*#emit PUSH.S   reason
        #emit PUSH.S   playerid
        #emit PUSH.C   8
        #emit LCTRL    6
        #emit ADD.C    28
        #emit PUSH.pri
        #emit LOAD.pri SSCANF_gOPDC
        #emit SCTRL    6
        #emit RETN*/
        return CallLocalFunction("SSCANF_OnGameModeInit", "");
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit SSCANF_OnGameModeInit

forward OnGameModeInit();

public OnPlayerConnect(playerid)
{
    new
        name[MAX_PLAYER_NAME];
    if(IsPlayerNPC(playerid)) return 1;
    GetPlayerName(playerid, name, sizeof (name));
    SSCANF_Join(playerid, name, IsPlayerNPC(playerid));
    if (SSCANF_gOPC)
    {
        /*#emit PUSH.S   playerid
        #emit PUSH.C   4
        #emit LCTRL    6
        #emit ADD.C    28
        #emit PUSH.pri
        #emit LOAD.pri SSCANF_gOPC
        #emit SCTRL    6
        #emit RETN*/
        return CallLocalFunction("SSCANF_OnPlayerConnect", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect SSCANF_OnPlayerConnect

forward OnPlayerConnect(playerid);

public OnPlayerDisconnect(playerid, reason)
{
    new
        ret = 1;
    if (SSCANF_gOPDC)
    {
        /*#emit PUSH.S   reason
        #emit PUSH.S   playerid
        #emit PUSH.C   8
        #emit LCTRL    6
        #emit ADD.C    28
        #emit PUSH.pri
        #emit LOAD.pri SSCANF_gOPDC
        #emit SCTRL    6
        #emit RETN*/
        ret = CallLocalFunction("SSCANF_OnPlayerDisconnect", "ii", playerid, reason);
    }
    SSCANF_Leave(playerid);
    return ret;
}

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect SSCANF_OnPlayerDisconnect

forward OnPlayerDisconnect(playerid, reason);

#define SSCANF_Init
#define SSCANF_Join
#define SSCANF_Leave

#define extract%0->%1; EXTRN%1;unformat(_:EXTRZ:EXTRX:%0,##,%1,,);
#define unformat(_:EXTRZ:EXTRX:%0,##,%1);%2else%3; if (unformat(_:EXTRX:%0,##,%1))%3;

#define EXTRX:%0##,%9new%1,%2) EXTRY:%0##,|||%1|||%2)
#define EXTRY: EXTR8:EXTR9:EXTR0:EXTR1:EXTR2:EXTR3:EXTR4:

#define EXTR8:EXTR9:EXTR0:EXTR1:EXTR2:EXTR3:EXTR4:%0##%1,%2|||%6:%3=%9|||%4) %6_EXTRO:%0##%1,%2|||%3=%9|||%4)
#define EXTR9:EXTR0:EXTR1:EXTR2:EXTR3:EXTR4:%0##%1,%2|||%3=%9|||%4) __EXTRO:%0##%1,%2|||%3=%9|||%4)
#define EXTR0:EXTR1:EXTR2:EXTR3:EXTR4:%0##%1,%2|||%6:%3[%7]|||%4) %6_EXTRW:%0##%1,%2|||%3[%7]|||%4)
#define EXTR1:EXTR2:EXTR3:EXTR4:%0##%1,%2|||%3[%7]|||%4) __EXTRW:%0##%1,%2|||%3|||%4)
#define EXTR2:EXTR3:EXTR4:%0##%1,%2|||%6:%3|||%4) %6_EXTRN:%0##%1,%2|||%3|||%4)
#define EXTR3:EXTR4:%0##%1,,%2||||||%4) %0##%1,%2)
#define EXTR4:%0##%1,%2|||%3|||%4) __EXTRN:%0##%1,%2|||%3|||%4)

// Optional specifiers.
#define __EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1I"("#%9")"#,%2,%3|||%4|||%5)
#define Float_EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1F"("#%9")"#,%2,%3|||%4|||%5)
#define player_EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1U"("#%9")"#,%2,%3|||%4|||%5)
#define string_EXTRO:%0##%1,%2|||%3[%7]=%9|||%4,%5) EXTRY:%0##%1S"("#%9")"#[%7],%2,%3|||%4|||%5)

// Normal specifiers (the double underscore is to work for "_:".
#define __EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1i,%2,%3|||%4|||%5)
#define Float_EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1f,%2,%3|||%4|||%5)
#define player_EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1u,%2,%3|||%4|||%5)
//#define string_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1s[%7],%2,%3|||%4|||%5)

// Array versions of normal specifiers.
#define __EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<i>[%7],%2,%3|||%4|||%5)
#define Float_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<f>[%7],%2,%3|||%4|||%5)
#define player_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<u>[%7],%2,%3|||%4|||%5)
#define string_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1s[%7],%2,%3|||%4|||%5)

// Get rid of excess leading space which causes warnings.
#define EXTRN%0new%1; new%1;

#if !defined string
    #define string:
#endif

#define player:

#define hex:
#define hex_EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1H"("#%9")"#,%2,%3|||%4|||%5)
#define hex_EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1h,%2,%3|||%4|||%5)
#define hex_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<h>[%7],%2,%3|||%4|||%5)

#define bin:
#define bin_EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1B"("#%9")"#,%2,%3|||%4|||%5)
#define bin_EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1b,%2,%3|||%4|||%5)
#define bin_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<b>[%7],%2,%3|||%4|||%5)

#define kustom:%0<%1> %0
#define kustom_EXTRO:%0##%1,%2|||%3<%8>=%9|||%4,%5) EXTRY:%0##%1K<%8>"("#%9")"#,%2,%3|||%4|||%5)
#define kustom_EXTRN:%0##%1,%2|||%3<%8>|||%4,%5) EXTRY:%0##%1k<%8>,%2,%3|||%4|||%5)
//#define bin_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<b>[%7],%2,%3|||%4|||%5)

SSCANF:weapon(string[])
{
    // This function is VERY basic, needs VASTLY improving to detect variations.
    if ('0' <= string[0] <= '9')
    {
        new
            ret = strval(string);
        if (0 <= ret <= 18 || 22 <= ret <= 46)
        {
            return ret;
        }
    }
    else if (!strcmp(string, "Unarmed")) return 0;
    else if (!strcmp(string, "Brass Knuckles")) return 1;
    else if (!strcmp(string, "Golf Club")) return 2;
    else if (!strcmp(string, "Night Stick")) return 3;
    else if (!strcmp(string, "Knife")) return 4;
    else if (!strcmp(string, "Baseball Bat")) return 5;
    else if (!strcmp(string, "Shovel")) return 6;
    else if (!strcmp(string, "Pool cue")) return 7;
    else if (!strcmp(string, "Katana")) return 8;
    else if (!strcmp(string, "Chainsaw")) return 9;
    else if (!strcmp(string, "Purple Dildo")) return 10;
    else if (!strcmp(string, "White Dildo")) return 11;
    else if (!strcmp(string, "Long White Dildo")) return 12;
    else if (!strcmp(string, "White Dildo 2")) return 13;
    else if (!strcmp(string, "Flowers")) return 14;
    else if (!strcmp(string, "Cane")) return 15;
    else if (!strcmp(string, "Grenades")) return 16;
    else if (!strcmp(string, "Tear Gas")) return 17;
    else if (!strcmp(string, "Molotovs")) return 18;
    else if (!strcmp(string, "Pistol")) return 22;
    else if (!strcmp(string, "Silenced Pistol")) return 23;
    else if (!strcmp(string, "Desert Eagle")) return 24;
    else if (!strcmp(string, "Shotgun")) return 25;
    else if (!strcmp(string, "Sawn Off Shotgun")) return 26;
    else if (!strcmp(string, "Combat Shotgun")) return 27;
    else if (!strcmp(string, "Micro Uzi")) return 28;
    else if (!strcmp(string, "Mac 10")) return 28;
    else if (!strcmp(string, "MP5")) return 29;
    else if (!strcmp(string, "AK47")) return 30;
    else if (!strcmp(string, "M4")) return 31;
    else if (!strcmp(string, "Tec9")) return 32;
    else if (!strcmp(string, "Rifle")) return 33;
    else if (!strcmp(string, "Sniper Rifle")) return 34;
    else if (!strcmp(string, "RPG")) return 35;
    else if (!strcmp(string, "Missile Launcher")) return 36;
    else if (!strcmp(string, "Flame Thrower")) return 37;
    else if (!strcmp(string, "Minigun")) return 38;
    else if (!strcmp(string, "Sachel Charges")) return 39;
    else if (!strcmp(string, "Detonator")) return 40;
    else if (!strcmp(string, "Spray Paint")) return 41;
    else if (!strcmp(string, "Fire Extinguisher")) return 42;
    else if (!strcmp(string, "Camera")) return 43;
    else if (!strcmp(string, "Nightvision Goggles")) return 44;
    else if (!strcmp(string, "Thermal Goggles")) return 45;
    else if (!strcmp(string, "Parachute")) return 46;
    return -1;
}

SSCANF:vehicle(string[])
{
    // This function is VERY basic, needs VASTLY improving to detect variations.
    if ('0' <= string[0] <= '9')
    {
        new
            ret = strval(string);
        if (400 <= ret <= 611)
        {
            return ret;
        }
    }
    else if (!strcmp(string, "Landstalker")) return 400;
    else if (!strcmp(string, "Bravura")) return 401;
    else if (!strcmp(string, "Buffalo")) return 402;
    else if (!strcmp(string, "Linerunner")) return 403;
    else if (!strcmp(string, "Perenniel")) return 404;
    else if (!strcmp(string, "Sentinel")) return 405;
    else if (!strcmp(string, "Dumper")) return 406;
    else if (!strcmp(string, "Firetruck")) return 407;
    else if (!strcmp(string, "Trashmaster")) return 408;
    else if (!strcmp(string, "Stretch")) return 409;
    else if (!strcmp(string, "Manana")) return 410;
    else if (!strcmp(string, "Infernus")) return 411;
    else if (!strcmp(string, "Voodoo")) return 412;
    else if (!strcmp(string, "Pony")) return 413;
    else if (!strcmp(string, "Mule")) return 414;
    else if (!strcmp(string, "Cheetah")) return 415;
    else if (!strcmp(string, "Ambulance")) return 416;
    else if (!strcmp(string, "Leviathan")) return 417;
    else if (!strcmp(string, "Moonbeam")) return 418;
    else if (!strcmp(string, "Esperanto")) return 419;
    else if (!strcmp(string, "Taxi")) return 420;
    else if (!strcmp(string, "Washington")) return 421;
    else if (!strcmp(string, "Bobcat")) return 422;
    else if (!strcmp(string, "Mr Whoopee")) return 423;
    else if (!strcmp(string, "BF Injection")) return 424;
    else if (!strcmp(string, "Hunter")) return 425;
    else if (!strcmp(string, "Premier")) return 426;
    else if (!strcmp(string, "Enforcer")) return 427;
    else if (!strcmp(string, "Securicar")) return 428;
    else if (!strcmp(string, "Banshee")) return 429;
    else if (!strcmp(string, "Predator")) return 430;
    else if (!strcmp(string, "Bus")) return 431;
    else if (!strcmp(string, "Rhino")) return 432;
    else if (!strcmp(string, "Barracks")) return 433;
    else if (!strcmp(string, "Hotknife")) return 434;
    else if (!strcmp(string, "Article Trailer")) return 435;
    else if (!strcmp(string, "Previon")) return 436;
    else if (!strcmp(string, "Coach")) return 437;
    else if (!strcmp(string, "Cabbie")) return 438;
    else if (!strcmp(string, "Stallion")) return 439;
    else if (!strcmp(string, "Rumpo")) return 440;
    else if (!strcmp(string, "RC Bandit")) return 441;
    else if (!strcmp(string, "Romero")) return 442;
    else if (!strcmp(string, "Packer")) return 443;
    else if (!strcmp(string, "Monster")) return 444;
    else if (!strcmp(string, "Admiral")) return 445;
    else if (!strcmp(string, "Squallo")) return 446;
    else if (!strcmp(string, "Seasparrow")) return 447;
    else if (!strcmp(string, "Pizzaboy")) return 448;
    else if (!strcmp(string, "Tram")) return 449;
    else if (!strcmp(string, "Article Trailer 2")) return 450;
    else if (!strcmp(string, "Turismo")) return 451;
    else if (!strcmp(string, "Speeder")) return 452;
    else if (!strcmp(string, "Reefer")) return 453;
    else if (!strcmp(string, "Tropic")) return 454;
    else if (!strcmp(string, "Flatbed")) return 455;
    else if (!strcmp(string, "Yankee")) return 456;
    else if (!strcmp(string, "Caddy")) return 457;
    else if (!strcmp(string, "Solair")) return 458;
    else if (!strcmp(string, "Berkley's RC Van")) return 459;
    else if (!strcmp(string, "Skimmer")) return 460;
    else if (!strcmp(string, "PCJ-600")) return 461;
    else if (!strcmp(string, "Faggio")) return 462;
    else if (!strcmp(string, "Freeway")) return 463;
    else if (!strcmp(string, "RC Baron")) return 464;
    else if (!strcmp(string, "RC Raider")) return 465;
    else if (!strcmp(string, "Glendale")) return 466;
    else if (!strcmp(string, "Oceanic")) return 467;
    else if (!strcmp(string, "Sanchez")) return 468;
    else if (!strcmp(string, "Sparrow")) return 469;
    else if (!strcmp(string, "Patriot")) return 470;
    else if (!strcmp(string, "Quad")) return 471;
    else if (!strcmp(string, "Coastguard")) return 472;
    else if (!strcmp(string, "Dinghy")) return 473;
    else if (!strcmp(string, "Hermes")) return 474;
    else if (!strcmp(string, "Sabre")) return 475;
    else if (!strcmp(string, "Rustler")) return 476;
    else if (!strcmp(string, "ZR-350")) return 477;
    else if (!strcmp(string, "Walton")) return 478;
    else if (!strcmp(string, "Regina")) return 479;
    else if (!strcmp(string, "Comet")) return 480;
    else if (!strcmp(string, "BMX")) return 481;
    else if (!strcmp(string, "Burrito")) return 482;
    else if (!strcmp(string, "Camper")) return 483;
    else if (!strcmp(string, "Marquis")) return 484;
    else if (!strcmp(string, "Baggage")) return 485;
    else if (!strcmp(string, "Dozer")) return 486;
    else if (!strcmp(string, "Maverick")) return 487;
    else if (!strcmp(string, "SAN News Maverick")) return 488;
    else if (!strcmp(string, "Rancher")) return 489;
    else if (!strcmp(string, "FBI Rancher")) return 490;
    else if (!strcmp(string, "Virgo")) return 491;
    else if (!strcmp(string, "Greenwood")) return 492;
    else if (!strcmp(string, "Jetmax")) return 493;
    else if (!strcmp(string, "Hotring Racer")) return 494;
    else if (!strcmp(string, "Sandking")) return 495;
    else if (!strcmp(string, "Blista Compact")) return 496;
    else if (!strcmp(string, "Police Maverick")) return 497;
    else if (!strcmp(string, "Boxville")) return 498;
    else if (!strcmp(string, "Benson")) return 499;
    else if (!strcmp(string, "Mesa")) return 500;
    else if (!strcmp(string, "RC Goblin")) return 501;
    else if (!strcmp(string, "Hotring Racer")) return 502;
    else if (!strcmp(string, "Hotring Racer")) return 503;
    else if (!strcmp(string, "Bloodring Banger")) return 504;
    else if (!strcmp(string, "Rancher")) return 505;
    else if (!strcmp(string, "Super GT")) return 506;
    else if (!strcmp(string, "Elegant")) return 507;
    else if (!strcmp(string, "Journey")) return 508;
    else if (!strcmp(string, "Bike")) return 509;
    else if (!strcmp(string, "Mountain Bike")) return 510;
    else if (!strcmp(string, "Beagle")) return 511;
    else if (!strcmp(string, "Cropduster")) return 512;
    else if (!strcmp(string, "Stuntplane")) return 513;
    else if (!strcmp(string, "Tanker")) return 514;
    else if (!strcmp(string, "Roadtrain")) return 515;
    else if (!strcmp(string, "Nebula")) return 516;
    else if (!strcmp(string, "Majestic")) return 517;
    else if (!strcmp(string, "Buccaneer")) return 518;
    else if (!strcmp(string, "Shamal")) return 519;
    else if (!strcmp(string, "Hydra")) return 520;
    else if (!strcmp(string, "FCR-900")) return 521;
    else if (!strcmp(string, "NRG-500")) return 522;
    else if (!strcmp(string, "HPV1000")) return 523;
    else if (!strcmp(string, "Cement Truck")) return 524;
    else if (!strcmp(string, "Towtruck")) return 525;
    else if (!strcmp(string, "Fortune")) return 526;
    else if (!strcmp(string, "Cadrona")) return 527;
    else if (!strcmp(string, "FBI Truck")) return 528;
    else if (!strcmp(string, "Willard")) return 529;
    else if (!strcmp(string, "Forklift")) return 530;
    else if (!strcmp(string, "Tractor")) return 531;
    else if (!strcmp(string, "Combine Harvester")) return 532;
    else if (!strcmp(string, "Feltzer")) return 533;
    else if (!strcmp(string, "Remington")) return 534;
    else if (!strcmp(string, "Slamvan")) return 535;
    else if (!strcmp(string, "Blade")) return 536;
    else if (!strcmp(string, "Freight (Train)")) return 537;
    else if (!strcmp(string, "Brownstreak (Train)")) return 538;
    else if (!strcmp(string, "Vortex")) return 539;
    else if (!strcmp(string, "Vincent")) return 540;
    else if (!strcmp(string, "Bullet")) return 541;
    else if (!strcmp(string, "Clover")) return 542;
    else if (!strcmp(string, "Sadler")) return 543;
    else if (!strcmp(string, "Firetruck LA")) return 544;
    else if (!strcmp(string, "Hustler")) return 545;
    else if (!strcmp(string, "Intruder")) return 546;
    else if (!strcmp(string, "Primo")) return 547;
    else if (!strcmp(string, "Cargobob")) return 548;
    else if (!strcmp(string, "Tampa")) return 549;
    else if (!strcmp(string, "Sunrise")) return 550;
    else if (!strcmp(string, "Merit")) return 551;
    else if (!strcmp(string, "Utility Van")) return 552;
    else if (!strcmp(string, "Nevada")) return 553;
    else if (!strcmp(string, "Yosemite")) return 554;
    else if (!strcmp(string, "Windsor")) return 555;
    else if (!strcmp(string, "Monster \"A\"")) return 556;
    else if (!strcmp(string, "Monster \"B\"")) return 557;
    else if (!strcmp(string, "Uranus")) return 558;
    else if (!strcmp(string, "Jester")) return 559;
    else if (!strcmp(string, "Sultan")) return 560;
    else if (!strcmp(string, "Stratum")) return 561;
    else if (!strcmp(string, "Elegy")) return 562;
    else if (!strcmp(string, "Raindance")) return 563;
    else if (!strcmp(string, "RC Tiger")) return 564;
    else if (!strcmp(string, "Flash")) return 565;
    else if (!strcmp(string, "Tahoma")) return 566;
    else if (!strcmp(string, "Savanna")) return 567;
    else if (!strcmp(string, "Bandito")) return 568;
    else if (!strcmp(string, "Freight Flat Trailer (Train)")) return 569;
    else if (!strcmp(string, "Streak Trailer (Train)")) return 570;
    else if (!strcmp(string, "Kart")) return 571;
    else if (!strcmp(string, "Mower")) return 572;
    else if (!strcmp(string, "Dune")) return 573;
    else if (!strcmp(string, "Sweeper")) return 574;
    else if (!strcmp(string, "Broadway")) return 575;
    else if (!strcmp(string, "Tornado")) return 576;
    else if (!strcmp(string, "AT400")) return 577;
    else if (!strcmp(string, "DFT-30")) return 578;
    else if (!strcmp(string, "Huntley")) return 579;
    else if (!strcmp(string, "Stafford")) return 580;
    else if (!strcmp(string, "BF-400")) return 581;
    else if (!strcmp(string, "Newsvan")) return 582;
    else if (!strcmp(string, "Tug")) return 583;
    else if (!strcmp(string, "Petrol Trailer")) return 584;
    else if (!strcmp(string, "Emperor")) return 585;
    else if (!strcmp(string, "Wayfarer")) return 586;
    else if (!strcmp(string, "Euros")) return 587;
    else if (!strcmp(string, "Hotdog")) return 588;
    else if (!strcmp(string, "Club")) return 589;
    else if (!strcmp(string, "Freight Box Trailer (Train)")) return 590;
    else if (!strcmp(string, "Article Trailer 3")) return 591;
    else if (!strcmp(string, "Andromada")) return 592;
    else if (!strcmp(string, "Dodo")) return 593;
    else if (!strcmp(string, "RC Cam")) return 594;
    else if (!strcmp(string, "Launch")) return 595;
    else if (!strcmp(string, "Police Car (LSPD)")) return 596;
    else if (!strcmp(string, "Police Car (SFPD)")) return 597;
    else if (!strcmp(string, "Police Car (LVPD)")) return 598;
    else if (!strcmp(string, "Police Ranger")) return 599;
    else if (!strcmp(string, "Picador")) return 600;
    else if (!strcmp(string, "S.W.A.T.")) return 601;
    else if (!strcmp(string, "Alpha")) return 602;
    else if (!strcmp(string, "Phoenix")) return 603;
    else if (!strcmp(string, "Glendale Shit")) return 604;
    else if (!strcmp(string, "Sadler Shit")) return 605;
    else if (!strcmp(string, "Baggage Trailer \"A\"")) return 606;
    else if (!strcmp(string, "Baggage Trailer \"B\"")) return 607;
    else if (!strcmp(string, "Tug Stairs Trailer")) return 608;
    else if (!strcmp(string, "Boxville")) return 609;
    else if (!strcmp(string, "Farm Trailer")) return 610;
    else if (!strcmp(string, "Utility Trailer")) return 611;
    return -1;
}

// Fix the compiler crash when both the PAWN and Plugin versions of sscanf are
// found by renaming the old version at declaration.  (fixes.inc compatible
// naming scheme: "BAD_Function()").
#define sscanf(%0:...) BAD_sscanf(%0:...)
