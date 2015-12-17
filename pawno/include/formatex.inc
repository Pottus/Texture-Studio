// formatex.inc by Slice

#include <a_samp>

#if defined FORMAT_EXTRA_TAGS
	#define FORMAT_TAGS  _, PlayerText3D, Text, Text3D, Menu, DB, DBResult, File, Float, FORMAT_EXTRA_TAGS
#else
	#define FORMAT_TAGS  _, PlayerText3D, Text, Text3D, Menu, DB, DBResult, File, Float
#endif

#if !defined FORMAT_BUFFER_SIZE
	#define FORMAT_BUFFER_SIZE  2048
#endif

#if !defined FORMAT_PRINT_BUFFER_SIZE
	#define FORMAT_PRINT_BUFFER_SIZE 512
#endif

#if !defined FORMAT_CUSTOM_SPEC_BUFFER_SIZE
	#define FORMAT_CUSTOM_SPEC_BUFFER_SIZE  512
#endif

#if !defined FORMAT_REPLACE_NATIVES
	#define FORMAT_REPLACE_NATIVES true
#endif

#define FormatSpecifier<'%1'>(%2[%3],%4)  FMAT@1:F@%1(%2[FORMAT_CUSTOM_SPEC_BUFFER_SIZE],FMAT@2:___unused,%4)
#define FMAT@2:___unused,%1[              %1[
#define FMAT@1:%1(%2)                     forward %1(%2); public %1(%2)

static stock
	     gs_CustomFormatFunctions[127] = {-1, ...},
	bool:gs_bIsInitialized = false
;

forward __fmt_funcinc();
public __fmt_funcinc() {
	new szOutput[1];
	
	format(szOutput, 0, "");
}

static stock InitializeFormatSpecifiers() {
	new
		szFunctionName[4 char] = !"F@_",
		iIndex,
		iFunctionAddress
	;
	
	gs_bIsInitialized = true;
	
	for (new c = '@'; c <= 'z'; c++) {
		// Skip the chars that can't be used in function names
		if (c == 'Z' + 1)
			c = '_';
		else if (c == '_' + 1)
			c = 'a';
		
		szFunctionName{2} = c;
		
		// Get the function's address if it exists
		if (-1 != (iIndex = funcidx(szFunctionName))) {
			#emit LCTRL		   1
			#emit NEG
			#emit MOVE.alt
			#emit ADD.C		   32
			#emit STOR.S.pri   iFunctionAddress
			#emit LREF.S.pri   iFunctionAddress
			#emit ADD
			#emit LOAD.S.alt   iIndex
			#emit SHL.C.alt	   3
			#emit ADD
			#emit STOR.S.pri   iFunctionAddress
			#emit LREF.S.pri   iFunctionAddress
			#emit STOR.S.pri   iFunctionAddress
			
			gs_CustomFormatFunctions[c] = iFunctionAddress;
		}
	}
}

stock formatex(szOutput[], iLength = sizeof(szOutput), const szFormatString[], {FORMAT_TAGS}:...) {
	static
		     s_szBuffer[FORMAT_BUFFER_SIZE],
		bool:s_bIsInCustomSpecifier = false
	;
	
	// If formatex is called inside a custom specifier, the original "format" will be used
	// to prevent having s_szBuffer overwritten. Specifiers shouldn't depend on other specifiers, anyway.
	if (s_bIsInCustomSpecifier) {
		new
			iNumArgs,
			i
		;
		
		#emit LOAD.S.pri  8
		#emit STOR.S.pri  iNumArgs
		#emit SHR.C.pri   2
		#emit STOR.S.pri  i

		while (--i >= 0) {
			#emit LOAD.S.pri  i
			#emit SHL.C.pri   2
			#emit ADD.C       12
			#emit MOVE.alt
			#emit LCTRL       5
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		
		#emit LOAD.S.pri  iNumArgs
		#emit PUSH.pri
		#emit MOVE.alt
		#emit SYSREQ.C    format
		#emit CONST.pri   4
		#emit ADD
		#emit MOVE.alt
		#emit LCTRL       4
		#emit ADD
		#emit SCTRL       4
	} else {
		new
			iPos = -1,
			iArg = 12 + (3 * 4),
			iArgCount,
			iAddress,
			iArgValue,
			aiArgs[128],
			i
		;
	
		if (!gs_bIsInitialized)
			InitializeFormatSpecifiers();
	
		iLength = min(FORMAT_BUFFER_SIZE, iLength);
	
		s_szBuffer[0] = 0;
	
		strunpack(s_szBuffer, szFormatString);
		
		while (-1 != (iPos = strfind(s_szBuffer, !"%", _, ++iPos))) {
			while (s_szBuffer[++iPos]) {
				// Look for custom formats
				if (1 <= s_szBuffer[iPos] < sizeof(gs_CustomFormatFunctions) && gs_CustomFormatFunctions[s_szBuffer[iPos]] != -1) {
					new
						iFunc = gs_CustomFormatFunctions[s_szBuffer[iPos]]
					;
				
					static
						s_szCustomFormatBuffer[FORMAT_CUSTOM_SPEC_BUFFER_SIZE]
					;
				
					strdel(s_szBuffer, iPos - 1, iPos + 1);
				
					s_szCustomFormatBuffer[0] = 0;
				
					#emit LCTRL       5
					#emit LOAD.S.alt  iArg
					#emit ADD
					#emit LOAD.I
					#emit MOVE.alt
					#emit LOAD.I
					#emit PUSH.pri
					#emit PUSH.alt
				
					iArg += 4;
					
					s_bIsInCustomSpecifier = true;
				
					#emit PUSH.C      s_szCustomFormatBuffer
					#emit PUSH.C      12
					#emit LCTRL       6
					#emit ADD.C       28
					#emit PUSH.pri
					#emit LOAD.S.pri  iFunc
					#emit SCTRL       6
					
					s_bIsInCustomSpecifier = false;
				
					strins(s_szBuffer, s_szCustomFormatBuffer, iPos - 1);
				
					break;
				}
			
				switch (s_szBuffer[iPos]) {
					// Handled by the original format function
					case '*', 'i', 'd', 'x', 'h', 'c', 's', 'f', 'b': {
						// Get the argument address and save it for later
						#emit LCTRL        5
						#emit LOAD.S.alt  iArg
						#emit ADD
						#emit LOAD.I
						#emit STOR.S.pri  iAddress
						#emit MOVE.pri
						#emit ADD.C       4
						#emit STOR.S.pri  iArg
					
						aiArgs[iArgCount++] = iAddress;
					
						if (s_szBuffer[iPos] == '*')
							continue;
					
						break;
					}
				
					// Unsigned numbers
					case 'u': {
						new
							szBuffer[11]
						;
					
						#emit LCTRL       5
						#emit LOAD.S.alt  iArg
						#emit ADD
						#emit LOAD.I
						#emit LOAD.I
						#emit STOR.S.pri  iArgValue
						#emit MOVE.pri
						#emit ADD.C       4
						#emit STOR.S.pri  iArg
					
						strdel(s_szBuffer, iPos - 1, iPos + 1);
					
						if (!iArgValue) {
							strins(s_szBuffer, "0", iPos - 1);
						} else {
							new
								j = sizeof(szBuffer) - 1
							;
						
							while (iArgValue) {
								// szBuffer[--i]
								#emit ADDR.alt    szBuffer  // alt = *szBuffer
								#emit LOAD.S.pri  j         // pri = i
								#emit DEC.pri               // pri -= 1
								#emit STOR.S.pri  j         // i = pri
								#emit IDXADDR               // pri = alt + i * 4
								#emit PUSH.pri              // Store pri for later

								// Now do an unsigned divide on uValue then use both the quotient and remainder!
								#emit LOAD.S.pri  iArgValue // pri = uValue
								#emit CONST.alt   10
								#emit UDIV                  // pri = uValue / 10; alt = uValue % 10
								#emit STOR.S.pri  iArgValue // uValue = pri
								#emit CONST.pri   '0'
								#emit ADD                   // pri = '0' + (uValue % 10)
								#emit POP.alt               // alt = szBuffer[i]
								#emit STOR.I                // szBuffer[i] = pri
							}
						
							strins(s_szBuffer, szBuffer[j], iPos - 1);
						}
					}
				
					case '0' .. '9', ' ', '.':
						continue;
				
					case '%':
						break;
			
					default: {
						break;
					}
				}
			}
		}
	
		i = iArgCount;
	
		// Push the arguments we stored above
		while (--i >= 0) {
			#emit ADDR.alt    aiArgs
			#emit LOAD.S.pri  i
			#emit LIDX
			#emit PUSH.pri
			#emit STOR.S.pri iAddress
		}
	
		// New format specifier
		#emit PUSH.C     s_szBuffer
	
		// Max length
		#emit PUSH.S     iLength
	
		// Output string
		#emit PUSH.S     szOutput
	
		// Argument count
		#emit LOAD.S.pri iArgCount
		#emit SHL.C.pri  2
		#emit ADD.C      12
		#emit PUSH.pri
	
		// Save the argument count for later
		#emit MOVE.alt
	
		// Call format (duh)
		#emit SYSREQ.C   format
	
		// Add 4 to the argument count
		#emit CONST.pri  4
		#emit ADD
		#emit MOVE.alt
	
		// Remove <argument count> from the stack
		#emit LCTRL      4
		#emit ADD
		#emit SCTRL      4
	}
	
	// Return in case anyone uses it
	return 1;
}

stock printfex(const szFormatString[], {FORMAT_TAGS}:...) {
	const
		iBufferSize = FORMAT_PRINT_BUFFER_SIZE
	;
	
	static
		s_szBuffer[FORMAT_PRINT_BUFFER_SIZE]
	;
	
	new
		iNumArgs = numargs(),
		i = iNumArgs - 1
	;
	
	while (--i >= 0) {
		#emit LOAD.S.pri  i
		#emit SHL.C.pri   2
		#emit ADD.C       16
		#emit MOVE.alt
		#emit LCTRL       5
		#emit ADD
		#emit LOAD.I
		#emit PUSH.pri
	}
	
	#emit PUSH.S      szFormatString
	#emit PUSH.C      iBufferSize
	#emit PUSH.C      s_szBuffer
	#emit LOAD.S.pri  iNumArgs
	#emit SHL.C.pri   2
	#emit ADD.C       8
	#emit PUSH.pri
	#emit LCTRL       6
	#emit ADD.C       28
	#emit PUSH.pri
	#emit CONST.pri   formatex
	#emit SCTRL       6
	
	print(s_szBuffer);
}

// -----------------------------------------------------------------------------------------------------
// Specifiers
// -----------------------------------------------------------------------------------------------------

// Inline color
FormatSpecifier<'C'>(output[], color) {
	format(output, sizeof(output), "{%06x}", color >>> 8);
}

// Player name
FormatSpecifier<'p'>(output[], playerid) {
	if (0 <= playerid < GetMaxPlayers() && IsPlayerConnected(playerid))
		GetPlayerName(playerid, output, sizeof(output));
	else
		strcat(output, "<UNKNOWN>");
}

// Player name and color
FormatSpecifier<'P'>(output[], playerid) {
	if (0 <= playerid < GetMaxPlayers() && IsPlayerConnected(playerid)) {
		format(output, sizeof(output), "{%06x}", GetPlayerColor(playerid) >>> 8);
		
		GetPlayerName(playerid, output[8], sizeof(output) - 8);
	} else
		strcat(output, "{FFFFFF}<UNKNOWN>");
}

// Weapon name
FormatSpecifier<'W'>(output[], weapon) {
	static const
		s_WeaponNames[][] = {
			{!"Fists"          }, {!"Knuckles"    }, {!"Golfclub"       }, //  0,  1,  2
			{!"Nightstick"     }, {!"Knife"       }, {!"Bat"            }, //  3,  4,  5
			{!"Shovel"         }, {!"Pool Cue"    }, {!"Katana"         }, //  6,  7,  8
			{!"Chainsaw"       }, {!"Dildo"       }, {!"Vibrator"       }, //  9, 10, 11
			{!"Vibrator"       }, {!"Vibrator"    }, {!"Flowers"        }, // 12, 13, 14
			{!"Cane"           }, {!"Grenade"     }, {!"Teargas"        }, // 15, 16, 17
			{!"Molotov"        }, {!""            }, {!""               }, // 18,   ,   
			{!""               }, {!"9mm"         }, {!"Silenced Pistol"}, //   , 22, 23
			{!"Deagle"         }, {!"Shotgun"     }, {!"Sawnoffs"       }, // 24, 25, 26
			{!"Combat Shotgun" }, {!"Mac-10"      }, {!"MP5"            }, // 27, 28, 29
			{!"AK-47"          }, {!"M4"          }, {!"Tec-9"          }, // 30, 31, 32
			{!"Cuntgun"        }, {!"Sniper"      }, {!"Rocketlauncher" }, // 33, 34, 35
			{!"Heatseeking RPG"}, {!"Flamethrower"}, {!"Minigun"        }, // 36, 37, 38
			{!"Satchel"        }, {!"Detonator"   }, {!"Spraycan"       }, // 39, 40, 41
			{!"Extinguisher"   }, {!"Camera"      }, {!"Nightvision"    }, // 42, 43, 44
			{!"Infrared"       }, {!"Parachute"   }, {!"Fake Pistol"    }, // 45, 46, 47
			{!""               }, {!"Vehicle"     }, {!"Helikill"       }, //   , 49, 50
			{!"Explosion"      }, {!""            }, {!"Drown"          }, // 51,   , 53
			{!"Collision"      }, {!"Splat"       }, {!"Unknown"        }  // 54, 55, 56
		}
	;
	
	if (0 <= weapon < sizeof(s_WeaponNames))
		strcat(output, s_WeaponNames[weapon]);
	else
		strcat(output, "Unknown");
}

// Weapon name, lower-case singular (for sentences)
FormatSpecifier<'w'>(output[], weapon) {
	static const
		s_WeaponNamesLowercaseSingular[][] = {
			{!"fists"             }, {!"knuckles"      }, {!"a golfclub"       }, //  0,  1,  2
			{!"a nightstick"      }, {!"a knife"       }, {!"a bat"            }, //  3,  4,  5
			{!"a shovel"          }, {!"a pool cue"    }, {!"a katana"         }, //  6,  7,  8
			{!"a chainsaw"        }, {!"a dildo"       }, {!"a vibrator"       }, //  9, 10, 11
			{!"a vibrator"        }, {!"a vibrator"    }, {!"flowers"          }, // 12, 13, 14
			{!"a cane"            }, {!"a grenade"     }, {!"teargas"          }, // 15, 16, 17
			{!"a molotov"         }, {!""              }, {!""                 }, // 18,   ,   
			{!""                  }, {!"a 9mm"         }, {!"a silenced pistol"}, //   , 22, 23
			{!"a deagle"          }, {!"a shotgun"     }, {!"sawnoffs"         }, // 24, 25, 26
			{!"a combat shotgun"  }, {!"a mac-10"      }, {!"an mp5"           }, // 27, 28, 29
			{!"an ak-47"          }, {!"an m4"         }, {!"a tec-9"          }, // 30, 31, 32
			{!"a cuntgun"         }, {!"a sniper"      }, {!"a rocketlauncher" }, // 33, 34, 35
			{!"a heatseeking rpg" }, {!"a flamethrower"}, {!"a minigun"        }, // 36, 37, 38
			{!"a satchel"         }, {!"a detonator"   }, {!"a spraycan"       }, // 39, 40, 41
			{!"an extinguisher"   }, {!"a camera"      }, {!"nightvision"      }, // 42, 43, 44
			{!"an infrared"       }, {!"a parachute"   }, {!"a fake pistol"    }, // 45, 46, 47
			{!""                  }, {!"a vehicle"     }, {!"a helikill"       }, //   , 49, 50
			{!"an explosion"      }, {!""              }, {!"drowning"         }, // 51,   , 53
			{!"a collision"       }, {!"a splat"       }, {!"something unknown"}  // 54, 55, 56
		}
	;
	
	if (0 <= weapon < sizeof(s_WeaponNamesLowercaseSingular))
		strcat(output, s_WeaponNamesLowercaseSingular[weapon]);
	else
		strcat(output, "something unknown");
}

// Vehicle name
FormatSpecifier<'v'>(output[], modelid) {
	static const
		s_VehicleNames[][] = {	
			{!"Landstalker"      }, {!"Bravura"          }, {!"Buffalo"          }, {!"Linerunner"       },
			{!"Perrenial"        }, {!"Sentinel"         }, {!"Dumper"           }, {!"Firetruck"        },
			{!"Trashmaster"      }, {!"Stretch"          }, {!"Manana"           }, {!"Infernus"         },
			{!"Voodoo"           }, {!"Pony"             }, {!"Mule"             }, {!"Cheetah"          },
			{!"Ambulance"        }, {!"Leviathan"        }, {!"Moonbeam"         }, {!"Esperanto"        },
			{!"Taxi"             }, {!"Washington"       }, {!"Bobcat"           }, {!"Mr Whoopee"       },
			{!"BF Injection"     }, {!"Hunter"           }, {!"Premier"          }, {!"Enforcer"         },
			{!"Securicar"        }, {!"Banshee"          }, {!"Predator"         }, {!"Bus"              },
			{!"Rhino"            }, {!"Barracks"         }, {!"Hotknife"         }, {!"Trailer 1"        },
			{!"Previon"          }, {!"Coach"            }, {!"Cabbie"           }, {!"Stallion"         },
			{!"Rumpo"            }, {!"RC Bandit"        }, {!"Romero"           }, {!"Packer"           },
			{!"Monster"          }, {!"Admiral"          }, {!"Squalo"           }, {!"Seasparrow"       },
			{!"Pizzaboy"         }, {!"Tram"             }, {!"Trailer 2"        }, {!"Turismo"          },
			{!"Speeder"          }, {!"Reefer"           }, {!"Tropic"           }, {!"Flatbed"          },
			{!"Yankee"           }, {!"Caddy"            }, {!"Solair"           }, {!"Berkley's RC Van" },
			{!"Skimmer"          }, {!"PCJ-600"          }, {!"Faggio"           }, {!"Freeway"          },
			{!"RC Baron"         }, {!"RC Raider"        }, {!"Glendale"         }, {!"Oceanic"          },
			{!"Sanchez"          }, {!"Sparrow"          }, {!"Patriot"          }, {!"Quad"             },
			{!"Coastguard"       }, {!"Dinghy"           }, {!"Hermes"           }, {!"Sabre"            },
			{!"Rustler"          }, {!"ZR-350"           }, {!"Walton"           }, {!"Regina"           },
			{!"Comet"            }, {!"BMX"              }, {!"Burrito"          }, {!"Camper"           },
			{!"Marquis"          }, {!"Baggage"          }, {!"Dozer"            }, {!"Maverick"         },
			{!"News Chopper"     }, {!"Rancher"          }, {!"FBI Rancher"      }, {!"Virgo"            },
			{!"Greenwood"        }, {!"Jetmax"           }, {!"Hotring"          }, {!"Sandking"         },
			{!"Blista Compact"   }, {!"Police Maverick"  }, {!"Boxville"         }, {!"Benson"           },
			{!"Mesa"             }, {!"RC Goblin"        }, {!"Hotring Racer A"  }, {!"Hotring Racer B"  },
			{!"Bloodring Banger" }, {!"Rancher"          }, {!"Super GT"         }, {!"Elegant"          },
			{!"Journey"          }, {!"Bike"             }, {!"Mountain Bike"    }, {!"Beagle"           },
			{!"Cropdust"         }, {!"Stunt"            }, {!"Tanker"           }, {!"Roadtrain"        },
			{!"Nebula"           }, {!"Majestic"         }, {!"Buccaneer"        }, {!"Shamal"           },
			{!"Hydra"            }, {!"FCR-900"          }, {!"NRG-500"          }, {!"HPV1000"          },
			{!"Cement Truck"     }, {!"Tow Truck"        }, {!"Fortune"          }, {!"Cadrona"          },
			{!"FBI Truck"        }, {!"Willard"          }, {!"Forklift"         }, {!"Tractor"          },
			{!"Combine"          }, {!"Feltzer"          }, {!"Remington"        }, {!"Slamvan"          },
			{!"Blade"            }, {!"Freight"          }, {!"Streak"           }, {!"Vortex"           },
			{!"Vincent"          }, {!"Bullet"           }, {!"Clover"           }, {!"Sadler"           },
			{!"Firetruck LA"     }, {!"Hustler"          }, {!"Intruder"         }, {!"Primo"            },
			{!"Cargobob"         }, {!"Tampa"            }, {!"Sunrise"          }, {!"Merit"            },
			{!"Utility"          }, {!"Nevada"           }, {!"Yosemite"         }, {!"Windsor"          },
			{!"Monster A"        }, {!"Monster B"        }, {!"Uranus"           }, {!"Jester"           },
			{!"Sultan"           }, {!"Stratum"          }, {!"Elegy"            }, {!"Raindance"        },
			{!"RC Tiger"         }, {!"Flash"            }, {!"Tahoma"           }, {!"Savanna"          },
			{!"Bandito"          }, {!"Freight Flat"     }, {!"Streak Carriage"  }, {!"Kart"             },
			{!"Mower"            }, {!"Duneride"         }, {!"Sweeper"          }, {!"Broadway"         },
			{!"Tornado"          }, {!"AT-400"           }, {!"DFT-30"           }, {!"Huntley"          },
			{!"Stafford"         }, {!"BF-400"           }, {!"Newsvan"          }, {!"Tug"              },
			{!"Trailer 3"        }, {!"Emperor"          }, {!"Wayfarer"         }, {!"Euros"            },
			{!"Hotdog"           }, {!"Club"             }, {!"Freight Carriage" }, {!"Trailer 3"        },
			{!"Andromada"        }, {!"Dodo"             }, {!"RC Cam"           }, {!"Launch"           },
			{!"Police Car (LSPD)"}, {!"Police Car (SFPD)"}, {!"Police Car (LVPD)"}, {!"Police Ranger"    },
			{!"Picador"          }, {!"S.W.A.T. Van"     }, {!"Alpha"            }, {!"Phoenix"          },
			{!"Glendale"         }, {!"Sadler"           }, {!"Luggage Trailer A"}, {!"Luggage Trailer B"},
			{!"Stair Trailer"    }, {!"Boxville"         }, {!"Farm Plow"        }, {!"Utility Trailer"  }
		}
	;
	
	if (0 <= (modelid -= 400) < sizeof(s_VehicleNames))
		strcat(output, s_VehicleNames[modelid]);
	else
		strcat(output, "Unknown");
}

// Unsigned 4-byte hex
FormatSpecifier<'X'>(output[], value) {
	format(output, sizeof(output), "%02x%06x", value >>> 24, value & 0xFFFFFF);
}

// Do this last so the specifiers always use the native function
#if FORMAT_REPLACE_NATIVES
	#define format  formatex
	#define printf  printfex
#endif